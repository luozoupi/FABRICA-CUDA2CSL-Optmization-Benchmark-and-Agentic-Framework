"""Append-only, provider-neutral records for later supervised and RL training.

Only caller-supplied messages and visible replies are retained. Client objects,
HTTP headers, credential files, and hidden reasoning are never serialized.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import uuid


def canonical_hash(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False,
                                    separators=(",", ":")).encode()).hexdigest()


def archive_call(record, messages, reply):
    root = os.getenv("XKERNEL_CALL_ARCHIVE")
    if not root:
        return None
    partition = os.getenv("XKERNEL_DATA_PARTITION", "development")
    if partition == "final_test":
        raise RuntimeError("Model calls are forbidden during final-test evaluation")
    call_id = uuid.uuid4().hex
    data = {
        "schema": "xkernel.model_call/1", "call_id": call_id,
        "cell_id": os.getenv("XKERNEL_CELL_ID"), "partition": partition,
        "framework_commit": os.getenv("XKERNEL_FROZEN_COMMIT"),
        "protocol_sha256": os.getenv("XKERNEL_PROTOCOL_SHA256"),
        "usage": dict(record), "messages": messages,
        "response": {"role": "assistant", "content": reply or ""},
        "request_sha256": canonical_hash(messages),
        "response_sha256": hashlib.sha256((reply or "").encode()).hexdigest(),
    }
    directory = Path(root) / "calls"
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / (call_id + ".json")
    # Exclusive creation: reruns cannot overwrite an earlier call.
    with path.open("x", encoding="utf8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return {"call_id": call_id, "call_artifact": str(path),
            "request_sha256": data["request_sha256"],
            "response_sha256": data["response_sha256"]}


def code_hash(text):
    """Ignore only outer whitespace and platform newlines, never CSL tokens."""
    return hashlib.sha256(text.replace("\r\n", "\n").strip().encode()).hexdigest()


def archive_candidate(code, result, compile_only=False):
    """Keep every tested source and feedback, including unsuccessful attempts.

    This is raw evidence, not an independent correctness verdict for SFT.
    Full staged builds remain under the workflow's retained scratch directory.
    """
    root = os.getenv("XKERNEL_CALL_ARCHIVE")
    if not root:
        return None
    directory = Path(root) / "candidates" / uuid.uuid4().hex
    directory.mkdir(parents=True)
    (directory / "pe.csl").write_text(code)
    record = {
        "schema": "xkernel.candidate/1", "cell_id": os.getenv("XKERNEL_CELL_ID"),
        "partition": os.getenv("XKERNEL_DATA_PARTITION", "development"),
        "framework_commit": os.getenv("XKERNEL_FROZEN_COMMIT"),
        "protocol_sha256": os.getenv("XKERNEL_PROTOCOL_SHA256"),
        "code_sha256": code_hash(code), "compile_only": compile_only,
        "benchmark": result,
        "build_files": {},
    }
    bundle = Path(result["staged_bundle"])
    for path in sorted(bundle.rglob("*")):
        if path.is_file() and path.suffix in (".elf", ".ll", ".csl", ".py", ".sh"):
            record["build_files"][str(path.relative_to(bundle))] = hashlib.sha256(path.read_bytes()).hexdigest()
    (directory / "evaluation.json").write_text(json.dumps(record, indent=2) + "\n")
    return str(directory)


def export_records(archive, evaluations, destination):
    """Export strictly matched correct responses and auditable outcome examples.

    evaluations are explicit source-hash verdicts, supplied by the independent
    evaluator. No correctness verdict is inferred from a compiler exit code.
    Final-test records cannot select SFT examples or supply reward examples.
    """
    from workflow_common import extract_code_block
    archive, destination = Path(archive), Path(destination)
    destination.mkdir(parents=True, exist_ok=True)
    by_code = {}
    for verdict in evaluations:
        if verdict.get("partition") != "final_test":
            by_code.setdefault(verdict["code_sha256"], []).append(verdict)
    sft, rewards, prompts, seen = [], [], [], set()
    counts = {"calls": 0, "truncated": 0, "unmatched": 0, "correct": 0}
    for path in sorted(archive.rglob("calls/*.json")):
        call = json.loads(path.read_text())
        if call.get("partition") == "final_test":
            continue
        counts["calls"] += 1
        usage = call["usage"]
        if usage.get("incomplete_reason") or usage.get("finish_reason") == "length":
            counts["truncated"] += 1
            continue
        code = extract_code_block(call["response"]["content"], "csl")
        if code is None or code_hash(code) not in by_code:
            counts["unmatched"] += 1
            continue
        matches = by_code[code_hash(code)]
        # A code fragment must have an explicit verdict in its own workflow.
        matches = [v for v in matches if v.get("cell_id") == call.get("cell_id")]
        if not matches:
            counts["unmatched"] += 1
            continue
        provenance = {"call_id": call["call_id"], "cell_id": call.get("cell_id"),
                      "model": usage.get("response_model"),
                      "framework_commit": call.get("framework_commit"),
                      "protocol_sha256": call.get("protocol_sha256"),
                      "code_sha256": code_hash(code), "call_artifact": str(path)}
        # Any conflicting explicit numerical verdict excludes SFT selection.
        passed = all(v.get("correct") is True for v in matches)
        row = {"messages": call["messages"], "response": call["response"],
               "correct": passed, "evaluations": matches, "provenance": provenance}
        rewards.append(row)
        prompt_id = call["request_sha256"]
        if prompt_id not in seen:
            prompts.append({"prompt_id": prompt_id, "messages": call["messages"],
                            "cell_id": call.get("cell_id"),
                            "reward_contract": "compile + numeric validation before speedup",
                            "provenance": provenance})
            seen.add(prompt_id)
        if passed:
            counts["correct"] += 1
            sft.append({"messages": call["messages"] + [call["response"]],
                        "provenance": provenance})
    for name, rows in (("sft.jsonl", sft), ("outcomes.jsonl", rewards),
                       ("grpo_prompts.jsonl", prompts)):
        with (destination / name).open("x") as f:
            for row in rows:
                f.write(json.dumps(row, ensure_ascii=False) + "\n")
    manifest = {"schema": "xkernel.training_export/1", "counts": counts,
                "files": {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in destination.glob("*.jsonl")},
                "notes": ["GRPO requires online rollouts and the executable verifier; outcomes are offline evidence.",
                          "Split future training/evaluation by task and matrix family, not individual attempts.",
                          "No hidden reasoning, credentials, or final-test feedback is exported."]}
    (destination / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return manifest
