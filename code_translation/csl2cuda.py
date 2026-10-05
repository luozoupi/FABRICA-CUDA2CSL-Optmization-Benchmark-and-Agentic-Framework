#!/usr/bin/env python3
"""
CSL ↔ CUDA Translation Pipeline
================================
Adapted from the Fortran→C++ framework (test.py).

Phases:
  A  – Analyse the source CSL kernel (LLM-based, no local compiler).
  B  – Translate CSL → CUDA, compile with nvcc, run, verify correctness.
       Iterative debug loop if compilation or correctness fails.

Usage:
  # Translate a single CSL file
  python csl2cuda.py --csl path/to/kernel.csl --model Qwen/Qwen3.5-35B-A3B

  # Translate all kernels from xkernel repo
  python csl2cuda.py --xkernel ../xkernel/kernels --model Qwen/Qwen3.5-35B-A3B

  # Use Anthropic API
  python csl2cuda.py --csl path/to/kernel.csl --model claude-haiku-4-5-20251001 --backend anthropic
"""

import os
import re
import json
import glob
import logging
import argparse
import subprocess
from typing import Optional, Tuple, List
from datetime import datetime

from openai import OpenAI
from dotenv import load_dotenv

from prompt_csl2cuda import *

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s'
)

TIMEOUT_LIMIT = 120  # seconds
NVCC_PATH = "nvcc"


# ── Helpers ─────────────────────────────────────────────────────────────

def extract_code_block(text: str, lang: str) -> Optional[str]:
    """Extract a fenced code block for the given language tag."""
    if not text:
        return None
    # Try exact lang match first, then common aliases
    aliases = {
        "cuda": ["cuda", "cu", "cpp", "c++"],
        "csl": ["csl"],
    }
    tags = aliases.get(lang, [lang])
    for tag in tags:
        pattern = re.compile(rf"```{re.escape(tag)}\s*\n(.*?)```", re.DOTALL | re.IGNORECASE)
        m = pattern.search(text)
        if m:
            return m.group(1).strip()
    # Fallback: any fenced block
    pattern = re.compile(r"```\w*\s*\n(.*?)```", re.DOTALL)
    m = pattern.search(text)
    if m:
        return m.group(1).strip()
    return None


def compile_and_run_cuda(cuda_code: str, work_dir: str,
                         timeout_seconds: int = TIMEOUT_LIMIT) -> Tuple[str, str, bool]:
    """
    Write cuda_code to work_dir/kernel.cu, compile with nvcc, run.
    Returns (stdout, stderr, success).
    """
    os.makedirs(work_dir, exist_ok=True)
    cu_path = os.path.join(work_dir, "kernel.cu")
    exe_path = os.path.join(work_dir, "kernel")

    with open(cu_path, "w") as f:
        f.write(cuda_code)

    # Compile
    compile_cmd = f'{NVCC_PATH} -O3 -Wno-deprecated-gpu-targets -o "{exe_path}" "{cu_path}"'
    try:
        comp = subprocess.run(compile_cmd, shell=True, capture_output=True,
                              timeout=timeout_seconds)
    except subprocess.TimeoutExpired:
        return "", "nvcc compilation timed out", False

    if comp.returncode != 0:
        stderr = comp.stderr.decode("utf-8", "replace")
        stdout = comp.stdout.decode("utf-8", "replace")
        return stdout, stderr, False

    # Run
    try:
        run = subprocess.run(f'"{exe_path}"', shell=True, capture_output=True,
                             timeout=timeout_seconds)
        stdout = run.stdout.decode("utf-8", "replace")
        stderr = run.stderr.decode("utf-8", "replace")
        return stdout, stderr, run.returncode == 0
    except subprocess.TimeoutExpired:
        return "", "CUDA execution timed out", False


def check_cuda_pass(output: str) -> bool:
    """Heuristic: does the program output contain PASS?"""
    if not output:
        return False
    return "PASS" in output.upper() and "FAIL" not in output.upper()


# ── Orchestrator ────────────────────────────────────────────────────────

class CSL2CUDAOrchestrator:
    """
    Two-phase pipeline for CSL → CUDA kernel translation.
    """

    def __init__(self, model: str = "Qwen/Qwen3.5-35B-A3B",
                 backend: str = "vllm",
                 max_tokens: int = 8192,
                 turns_limit: int = 5,
                 work_dir: str = "./sandbox/csl2cuda"):
        self.model = model
        self.backend = backend
        self.max_tokens = max_tokens
        self.turns_limit = turns_limit
        self.work_dir = work_dir

        self.messages: List[dict] = []
        self.history: List[dict] = []
        self.csl_source: Optional[str] = None
        self.csl_analysis: Optional[str] = None
        self.cuda_code: Optional[str] = None

        # Structured results for benchmarking
        self.run_log: List[dict] = []  # per-turn compile/run results

        # Set up API client
        if backend == "anthropic":
            import anthropic
            self.anthropic_client = anthropic.Anthropic()
            self.client = None
        else:
            base_url = os.getenv("OPENAI_BASE_URL", "http://localhost:8000/v1")
            api_key = os.getenv("OPENAI_API_KEY", "EMPTY")
            self.client = OpenAI(base_url=base_url, api_key=api_key)
            self.anthropic_client = None

    def _llm_call(self, messages: List[dict], max_tokens: Optional[int] = None) -> str:
        """Unified LLM call supporting vLLM/OpenAI and Anthropic backends."""
        mt = max_tokens or self.max_tokens

        if self.backend == "anthropic":
            # Separate system message
            sys_msg = ""
            user_msgs = []
            for m in messages:
                if m["role"] == "system":
                    sys_msg += m["content"] + "\n"
                else:
                    user_msgs.append(m)
            kwargs = {"model": self.model, "max_tokens": mt, "messages": user_msgs}
            if sys_msg.strip():
                kwargs["system"] = sys_msg.strip()
            resp = self.anthropic_client.messages.create(**kwargs)
            return resp.content[0].text
        else:
            extra_body = {}
            if "qwen" in self.model.lower():
                extra_body["enable_thinking"] = False
            resp = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                max_tokens=mt,
                extra_body=extra_body if extra_body else None,
            )
            return resp.choices[0].message.content or ""

    def _append(self, role: str, content: str):
        msg = {"role": role, "content": content}
        self.messages.append(msg)
        self.history.append(msg)

    # ── Phase A: Analyse CSL source ─────────────────────────────────────

    def run_phase_a(self, csl_code: str) -> bool:
        """
        Phase A: Ask the LLM to analyse the CSL kernel.
        Since CSL can't be compiled locally, we validate understanding only.
        """
        self.csl_source = csl_code
        logging.info("=== [Phase A] Analysing CSL kernel (%d chars) ===", len(csl_code))

        self._append("system", Instruction_system)
        prompt = q_analyse_csl_source.format(csl_code=csl_code)
        self._append("user", prompt)

        analysis = self._llm_call(self.messages)
        self._append("assistant", analysis)
        self.csl_analysis = analysis

        logging.info("=== [Phase A] CSL Analysis ===\n%s", analysis[:500])
        return True

    # ── Phase B: Translate & verify CUDA ────────────────────────────────

    def run_phase_b(self) -> bool:
        """
        Phase B: Translate CSL → CUDA, compile, run, verify.
        Iterative debug loop up to turns_limit.
        """
        logging.info("=== [Phase B] Translating CSL → CUDA ===")

        # Initial translation request
        prompt = q_translate_csl_to_cuda.format(
            csl_code=self.csl_source,
            csl_analysis=self.csl_analysis
        )
        self._append("user", prompt)

        reply = self._llm_call(self.messages)
        self._append("assistant", reply)

        self.cuda_code = extract_code_block(reply, "cuda")
        if not self.cuda_code:
            logging.error("[Phase B] No CUDA code block found in initial reply")
            return False

        # Iterative compile/run/fix loop
        for turn in range(self.turns_limit):
            logging.info("[Phase B] Turn %d / %d", turn + 1, self.turns_limit)

            stdout, stderr, ok = compile_and_run_cuda(
                self.cuda_code, self.work_dir
            )
            logging.info("  Compile+Run: ok=%s", ok)
            logging.info("  stdout: %s", stdout[:300] if stdout else "(empty)")
            if stderr:
                logging.info("  stderr: %s", stderr[:300])

            # Record structured per-turn result
            self.run_log.append({
                "turn": turn + 1,
                "compiled": ok or ("error" not in (stderr or "").lower()),
                "ran_ok": ok,
                "stdout": stdout,
                "stderr": stderr[:500] if stderr else "",
                "pass": ok and check_cuda_pass(stdout),
            })

            if ok and check_cuda_pass(stdout):
                logging.info("[Phase B] SUCCESS at turn %d", turn + 1)
                return True

            if ok and stdout:
                # Compiled and ran but FAIL or wrong output
                # First try AI judge
                judge_msgs = [
                    {"role": "system", "content": Instruction_system},
                    {"role": "user", "content": output_comparison_analysis.format(
                        cuda_code=self.cuda_code, cuda_output=stdout
                    )}
                ]
                judge_reply = self._llm_call(judge_msgs, max_tokens=512)
                if not judge_reply:
                    logging.warning("[Phase B] AI judge returned empty response")
                    continue
                logging.info("[Phase B] AI judge: %s", judge_reply[:200])

                first_line = judge_reply.strip().split('\n')[0].strip().upper()
                if first_line.startswith("YES"):
                    logging.info("[Phase B] AI judge says PASS at turn %d", turn + 1)
                    return True

                # Output mismatch – ask LLM to fix
                fix_prompt = cuda_output_mismatch_fix.format(
                    cuda_code=self.cuda_code, cuda_output=stdout
                )
                self._append("user", fix_prompt)
            elif not ok:
                # Compilation or runtime error
                error_info = f"Stdout:\n{stdout}\n\nStderr:\n{stderr}"
                if "undefined reference" in (stderr or "") or "No such file" in (stderr or ""):
                    fix_prompt = cuda_link_fix.format(compile_result=error_info)
                else:
                    fix_prompt = cuda_compile_fix.format(compile_result=error_info)
                self._append("user", fix_prompt)
            else:
                # ok but no stdout
                fix_prompt = cuda_compile_fix.format(
                    compile_result="Program produced no output. Ensure main() prints results."
                )
                self._append("user", fix_prompt)

            reply = self._llm_call(self.messages)
            self._append("assistant", reply)

            new_code = extract_code_block(reply, "cuda")
            if new_code:
                self.cuda_code = new_code

        logging.error("[Phase B] FAIL: exceeded %d turns", self.turns_limit)
        return False

    # ── Multi-step optimization ──────────────────────────────────────────

    def run_optimization_step(self, step_name: str, prev_output: str = "") -> bool:
        """
        Apply a single CUDA optimization step to self.cuda_code.
        Compiles and verifies correctness after each attempt.
        Returns True if the optimized code compiles, runs, and passes.
        """
        from prompt_csl2cuda import (CUDA_OPTIMIZATION_PROMPTS,
                                      Instruction_system_multistep,
                                      q_optimize_cuda_generic,
                                      cuda_compile_fix, cuda_output_mismatch_fix)

        logging.info("=== [Opt: %s] Starting optimization step ===", step_name)

        prompt_template = CUDA_OPTIMIZATION_PROMPTS.get(step_name)
        if prompt_template is None:
            # Custom step — use generic prompt
            prompt_template = q_optimize_cuda_generic
            prompt = prompt_template.format(
                optimization_name=step_name,
                optimization_description=f"Apply {step_name} optimization.",
                current_code=self.cuda_code,
                cuda_output=prev_output or "(no previous output)",
            )
        else:
            prompt = prompt_template.format(
                current_code=self.cuda_code,
                cuda_output=prev_output or "(no previous output)",
            )

        # Use a fresh conversation for each optimization step
        opt_messages = [
            {"role": "system", "content": Instruction_system_multistep},
            {"role": "user", "content": prompt},
        ]

        reply = self._llm_call(opt_messages)
        self._append("user", f"[Opt: {step_name}] {prompt[:200]}...")
        self._append("assistant", reply)

        new_code = extract_code_block(reply, "cuda")
        if not new_code:
            logging.error("[Opt: %s] No code block in LLM response", step_name)
            return False

        # Save previous code in case optimization breaks things
        backup_code = self.cuda_code

        # Iterative compile/run/fix loop for this optimization step
        self.cuda_code = new_code
        for turn in range(self.turns_limit):
            logging.info("[Opt: %s] Turn %d / %d", step_name, turn + 1, self.turns_limit)

            stdout, stderr, ok = compile_and_run_cuda(
                self.cuda_code, self.work_dir
            )

            self.run_log.append({
                "turn": len(self.run_log) + 1,
                "step": step_name,
                "compiled": ok or ("error" not in (stderr or "").lower()),
                "ran_ok": ok,
                "stdout": stdout,
                "stderr": stderr[:500] if stderr else "",
                "pass": ok and check_cuda_pass(stdout),
            })

            if ok and check_cuda_pass(stdout):
                logging.info("[Opt: %s] SUCCESS at turn %d", step_name, turn + 1)
                return True

            # Build fix prompt
            if not ok:
                error_info = f"Stdout:\n{stdout}\n\nStderr:\n{stderr}"
                fix_prompt = cuda_compile_fix.format(compile_result=error_info)
            elif ok and stdout:
                fix_prompt = cuda_output_mismatch_fix.format(
                    cuda_code=self.cuda_code, cuda_output=stdout
                )
            else:
                fix_prompt = cuda_compile_fix.format(
                    compile_result="Program produced no output. Ensure main() prints results."
                )

            opt_messages.append({"role": "assistant", "content": reply})
            opt_messages.append({"role": "user", "content": fix_prompt})
            self._append("user", fix_prompt)

            reply = self._llm_call(opt_messages)
            self._append("assistant", reply)

            code = extract_code_block(reply, "cuda")
            if code:
                self.cuda_code = code

        # All turns exhausted — revert to backup so next step starts from working code
        logging.warning("[Opt: %s] FAIL after %d turns, reverting to pre-step code",
                        step_name, self.turns_limit)
        self.cuda_code = backup_code
        return False

    def run_multistep(self, csl_code: str,
                      steps: Optional[List[str]] = None) -> Tuple[bool, Optional[str], dict]:
        """
        Run CSL → CUDA translation followed by incremental optimization steps.
        Returns (baseline_success, final_cuda_code, step_results).
        """
        from prompt_csl2cuda import DEFAULT_CUDA_OPT_STEPS

        if steps is None:
            steps = DEFAULT_CUDA_OPT_STEPS

        # Phase A + B: baseline translation
        baseline_ok = True
        if not self.run_phase_a(csl_code):
            return False, None, {}
        if not self.run_phase_b():
            baseline_ok = False

        step_results = {"baseline": baseline_ok}

        if not baseline_ok or not self.cuda_code:
            logging.error("[Multistep] Baseline translation failed, skipping optimization")
            return False, self.cuda_code, step_results

        # Get baseline output for the first optimization step
        stdout, _, ok = compile_and_run_cuda(self.cuda_code, self.work_dir)
        prev_output = stdout if ok else ""

        # Save baseline code
        baseline_code = self.cuda_code

        # Apply optimization steps incrementally
        for step_name in steps:
            step_ok = self.run_optimization_step(step_name, prev_output)
            step_results[step_name] = step_ok
            if step_ok:
                # Get new output for next step
                stdout, _, ok = compile_and_run_cuda(self.cuda_code, self.work_dir)
                prev_output = stdout if ok else prev_output
                logging.info("[Multistep] Step '%s' applied successfully", step_name)
            else:
                logging.warning("[Multistep] Step '%s' failed, continuing with previous code",
                                step_name)

        return True, self.cuda_code, step_results

    # ── Main entry point ────────────────────────────────────────────────

    def run(self, csl_code: str) -> Tuple[bool, Optional[str]]:
        """
        Run full CSL → CUDA pipeline.
        Returns (success, cuda_code).
        """
        if not self.run_phase_a(csl_code):
            return False, None
        if not self.run_phase_b():
            return False, self.cuda_code
        return True, self.cuda_code

    def save_results(self, output_dir: str, name: str):
        """Save translated CUDA code, conversation log, and benchmark results."""
        os.makedirs(output_dir, exist_ok=True)
        if self.cuda_code:
            with open(os.path.join(output_dir, f"{name}.cu"), "w") as f:
                f.write(self.cuda_code)
        with open(os.path.join(output_dir, f"{name}_log.json"), "w") as f:
            json.dump(self.history, f, indent=2)

        # Save structured results with compile/run details per turn
        success = any(t.get("pass") for t in self.run_log)
        final_stdout = ""
        for t in reversed(self.run_log):
            if t.get("pass") and t.get("stdout"):
                final_stdout = t["stdout"]
                break

        result = {
            "kernel": name,
            "model": self.model,
            "success": success,
            "total_turns": len(self.run_log),
            "pass_turn": next((t["turn"] for t in self.run_log if t.get("pass")), None),
            "final_stdout": final_stdout,
            "turns": self.run_log,
        }
        with open(os.path.join(output_dir, f"{name}_result.json"), "w") as f:
            json.dump(result, f, indent=2)


# ── CLI ─────────────────────────────────────────────────────────────────

def find_csl_kernels(xkernel_dir: str) -> List[Tuple[str, str]]:
    """Find all CSL kernel files in either xkernel or sdk-examples layout.

    Supports two directory structures:
    - xkernel:       kernels/<name>/CSL/*.csl  (with src/ subdirectory)
    - sdk-examples:  benchmarks/<name>/*.csl   (flat, .csl files at top level)

    For multi-file kernels, concatenate all compute-relevant .csl files
    (excluding layout, routes, switches, nop files) into one string and
    write it to a temporary combined file.
    """
    # Files to skip — infrastructure, not compute logic
    SKIP_NAMES = {"layout.csl", "layout_cg.csl", "layout_pcg.csl",
                  "layout_bicgstab.csl", "layout_power.csl",
                  "layout_matvec.csl", "routes.csl", "switches.csl",
                  "nop.csl", "consts.csl"}

    # Preferred main kernel file names, in priority order
    PREFERRED = [
        # State-machine kernels (iterative solvers)
        "kernel_bicgstab.csl", "kernel_cg.csl", "kernel_pcg.csl",
        "kernel_power.csl",
        # Common names
        "pe.csl", "pe_program.csl", "pe_matvec.csl",
        "kernel.csl", "residual.csl", "code.csl", "fft.csl",
        # Stencil / exchange kernels
        "task.csl", "oned_exch.csl",
    ]

    kernels = []

    # Auto-detect layout: check for */CSL pattern (xkernel) or */*.csl (sdk-examples)
    xkernel_dirs = sorted(glob.glob(os.path.join(xkernel_dir, "*/CSL")))
    if xkernel_dirs:
        # xkernel layout: kernels/<name>/CSL/*.csl
        scan_dirs = [(os.path.basename(os.path.dirname(d)), d) for d in xkernel_dirs]
    else:
        # sdk-examples layout: benchmarks/<name>/*.csl (flat)
        scan_dirs = []
        for d in sorted(os.listdir(xkernel_dir)):
            full = os.path.join(xkernel_dir, d)
            if os.path.isdir(full) and glob.glob(os.path.join(full, "*.csl")):
                scan_dirs.append((d, full))

    for kernel_name, csl_dir in scan_dirs:
        # Gather all .csl files (top-level and src/)
        all_csl = glob.glob(os.path.join(csl_dir, "*.csl")) + \
                  glob.glob(os.path.join(csl_dir, "src/*.csl"))
        # Filter out infrastructure files
        compute_csl = [f for f in all_csl
                       if os.path.basename(f) not in SKIP_NAMES
                       and "/allreduce" not in f
                       and "/hypersparse_spmv" not in f
                       and "/allreduce2R1E" not in f]

        if not compute_csl:
            continue

        # Pick the main kernel file
        main_file = None
        for pref in PREFERRED:
            for candidate in ["src/" + pref, pref]:
                path = os.path.join(csl_dir, candidate)
                if path in compute_csl:
                    main_file = path
                    break
            if main_file:
                break
        if not main_file:
            main_file = compute_csl[0]

        # If multiple compute files, concatenate them (main file first)
        if len(compute_csl) > 1:
            ordered = [main_file] + [f for f in sorted(compute_csl) if f != main_file]
            combined = ""
            for f in ordered:
                combined += f"// ── {os.path.basename(f)} ──\n"
                with open(f) as fh:
                    combined += fh.read() + "\n\n"
            # Write combined file
            combined_path = os.path.join(csl_dir, "_combined_kernel.csl")
            with open(combined_path, "w") as fh:
                fh.write(combined)
            kernels.append((kernel_name, combined_path))
        else:
            kernels.append((kernel_name, main_file))

    return kernels


def _run_single(args, csl_code: str, name: str, output_dir: str):
    """Run translation (and optionally optimization) for a single kernel."""
    work_dir = os.path.join("./sandbox/csl2cuda", name)

    orch = CSL2CUDAOrchestrator(
        model=args.model, backend=args.backend,
        max_tokens=args.max_tokens, turns_limit=args.turns,
        work_dir=work_dir,
    )

    if args.multistep:
        steps = args.steps.split(",") if args.steps else None
        success, cuda_code, step_results = orch.run_multistep(csl_code, steps)
        orch.save_results(output_dir, name)
        # Also save step results
        with open(os.path.join(output_dir, f"{name}_steps.json"), "w") as f:
            json.dump(step_results, f, indent=2)
        return name, success, len(orch.run_log), step_results
    else:
        success, cuda_code = orch.run(csl_code)
        orch.save_results(output_dir, name)
        turns_used = len(orch.run_log)
        pass_turn = next((t["turn"] for t in orch.run_log if t.get("pass")), None)
        return name, success, turns_used, {"pass_turn": pass_turn}


def main():
    parser = argparse.ArgumentParser(description="CSL ↔ CUDA Translation Pipeline")
    parser.add_argument("--csl", type=str, help="Path to a single CSL file to translate")
    parser.add_argument("--xkernel", type=str,
                        help="Path to xkernel/kernels or sdk-examples/benchmarks dir (batch mode)")
    parser.add_argument("--model", type=str, default="Qwen/Qwen3.5-35B-A3B",
                        help="Model ID for LLM")
    parser.add_argument("--backend", type=str, default="vllm",
                        choices=["vllm", "openai", "anthropic"],
                        help="API backend")
    parser.add_argument("--max-tokens", type=int, default=8192)
    parser.add_argument("--turns", type=int, default=5,
                        help="Max debug turns per kernel/step")
    parser.add_argument("--output", type=str, default="./results/csl2cuda",
                        help="Output directory for results")
    # Multi-step optimization flags
    parser.add_argument("--multistep", action="store_true",
                        help="Enable multi-step CUDA optimization after baseline translation")
    parser.add_argument("--steps", type=str, default=None,
                        help="Comma-separated optimization steps "
                             "(default: shared_memory,coalescing,warp,unroll,vectorized,occupancy)")
    parser.add_argument("--gpu", type=int, default=None,
                        help="GPU ID to use (sets CUDA_VISIBLE_DEVICES)")
    args = parser.parse_args()

    if args.gpu is not None:
        os.environ["CUDA_VISIBLE_DEVICES"] = str(args.gpu)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    mode = "multistep" if args.multistep else "run"
    output_dir = os.path.join(args.output, f"{mode}_{timestamp}")

    if args.csl:
        # Single file mode
        with open(args.csl) as f:
            csl_code = f.read()
        name = os.path.splitext(os.path.basename(args.csl))[0]
        name, success, turns, extra = _run_single(args, csl_code, name, output_dir)
        status = "PASS" if success else "FAIL"
        print(f"[{status}] {name}: translated CSL → CUDA (turns={turns})")
        if args.multistep:
            for step, ok in extra.items():
                print(f"  {step}: {'OK' if ok else 'FAIL'}")

    elif args.xkernel:
        # Batch mode
        kernels = find_csl_kernels(args.xkernel)
        print(f"Found {len(kernels)} CSL kernels to translate")
        if args.multistep:
            step_names = args.steps.split(",") if args.steps else None
            print(f"Optimization steps: {step_names or 'all defaults'}")
        results = []
        for kernel_name, csl_path in kernels:
            print(f"\n{'='*60}")
            print(f"Translating: {kernel_name} ({csl_path})")
            print(f"{'='*60}")

            with open(csl_path) as f:
                csl_code = f.read()

            name, success, turns, extra = _run_single(args, csl_code, kernel_name, output_dir)
            results.append((name, success, turns, extra))
            status = "PASS" if success else "FAIL"
            print(f"  [{status}] {kernel_name} (turns={turns})")
            if args.multistep:
                for step, ok in extra.items():
                    print(f"    {step}: {'OK' if ok else 'FAIL'}")

        # Summary
        print(f"\n{'='*60}")
        print("SUMMARY")
        print(f"{'='*60}")
        passed = sum(1 for _, s, _, _ in results if s)
        for name, s, turns, extra in results:
            print(f"  [{'PASS' if s else 'FAIL'}] {name} (turns={turns})")
        print(f"\n{passed}/{len(results)} kernels translated successfully")

        # Save summary
        with open(os.path.join(output_dir, "summary.json"), "w") as f:
            json.dump([{"kernel": n, "pass": s, "turns": t, "steps": e}
                       for n, s, t, e in results], f, indent=2, default=str)

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
