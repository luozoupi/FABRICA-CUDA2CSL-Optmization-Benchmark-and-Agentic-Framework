#!/usr/bin/env python3
"""Render the add-family compilation model as a page: two boundaries, rules, cases, evaluation."""
from __future__ import annotations
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from addfam_model import (classify, counts, predict_machine, predict_ir, ABS, RULES,
                          RULESET_VERSION, EXACT_DEF, IR_SCOPE)

HERE = Path(__file__).resolve().parent.parent
AF = HERE / "microbench" / "addfam"
CASES = json.loads((AF / "cases.json").read_text())["cases"]
HIST = json.loads((AF / "prediction_history.json").read_text())
MANIFEST = json.loads((AF / "MANIFEST.json").read_text())

def main():
    cases = []
    for c in CASES:
        spec = ABS[c["name"]]
        obs_m = counts(c["machine"]["instrs"]); pre_m = predict_machine(spec)
        pre_i = predict_ir(c["name"], spec)
        k = c["machine"]["contract"]
        v = MANIFEST["cases"].get(c["name"], {}).get("correctness")
        cases.append({
            "name": c["name"], "factor": c["factor"], "withheld": c["withheld"], "csl": c["csl"],
            "ir": c["ir"]["body"] or "", "ir_lines": c["ir"]["n_lines"], "ir_observed": c["ir"]["hist"],
            "ir_predicted": pre_i, "ir_in_scope": pre_i is not None, "ir_exact": pre_i is not None and c["ir"]["hist"] == pre_i,
            "machine": [{"pc": i["pc"], "text": i["text"], "role": i["role"]} for i in classify(c["machine"]["instrs"])],
            "observed": obs_m, "predicted": pre_m, "exact": obs_m == pre_m,
            "contract": {"n_body": k["n_body"], "n_init": k["n_init"], "n_total": k["n_total"],
                         "live_in": k["entry_live_in"], "init": k["init_closure"], "unresolved": k["unresolved_live_in"]},
            "dsrs": c["machine"]["dsrs"], "correctness": v,
        })
    ident = CASES[0]["identity"]
    ir_in = [c for c in cases if c["ir_in_scope"]]
    data = {"cases": cases, "rules": RULES, "identity": ident, "version": RULESET_VERSION,
            "exact_def": EXACT_DEF, "history": HIST,
            "hash_algorithm": MANIFEST["hash_algorithm"],
            "n_artifacts": sum(len(x.get("files", {})) for x in MANIFEST["cases"].values()),
            "score": {"b1_exact": sum(c["ir_exact"] for c in ir_in), "b1_total": len(ir_in),
                      "b1_out": len(cases) - len(ir_in),
                      "b2_exact": sum(c["exact"] for c in cases), "b2_total": len(cases),
                      "correct": sum(1 for c in cases if (c["correctness"] or {}).get("ok"))}}
    out = HERE / "results" / "anatomy" / "addfam_model.html"
    out.write_text(HTML.replace("__DATA__", json.dumps(data)))
    print("wrote", out, f"({out.stat().st_size // 1024} KB)")

HTML = r"""<title>CSL Add-Family Lowering</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Spectral:ital,wght@0,400;0,600;1,400&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
:root{
  --ground:#F5F6F4; --surface:#FFFFFF; --sunk:#ECEEEA; --ink:#14181A; --ink-2:#41494B; --muted:#6B7472; --line:#D8DDD8;
  --capture:#0C6E77; --frontend:#5A4B94; --midend:#A8660F; --refuted:#A33A5B; --confirmed:#3F7A3A; --slate:#4A6070;
  --r-load:#A8660F; --r-store:#A8660F; --r-alu:#0C6E77; --r-addr:#4A6070; --r-ctrl:#A33A5B; --r-desc:#5A4B94; --r-vecop:#3F7A3A; --r-actvt:#6B7472;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --ground:#0E1112; --surface:#171B1C; --sunk:#1F2425; --ink:#E8ECE9; --ink-2:#B4BDB9; --muted:#889490; --line:#2A3132;
  --capture:#54C7CF; --frontend:#AC9EE4; --midend:#E8A33F; --refuted:#E48AA6; --confirmed:#8ECC86; --slate:#95ACBC;
  --r-load:#E8A33F; --r-store:#E8A33F; --r-alu:#54C7CF; --r-addr:#95ACBC; --r-ctrl:#E48AA6; --r-desc:#AC9EE4; --r-vecop:#8ECC86; --r-actvt:#889490;
}}
:root[data-theme="dark"]{
  --ground:#0E1112; --surface:#171B1C; --sunk:#1F2425; --ink:#E8ECE9; --ink-2:#B4BDB9; --muted:#889490; --line:#2A3132;
  --capture:#54C7CF; --frontend:#AC9EE4; --midend:#E8A33F; --refuted:#E48AA6; --confirmed:#8ECC86; --slate:#95ACBC;
  --r-load:#E8A33F; --r-store:#E8A33F; --r-alu:#54C7CF; --r-addr:#95ACBC; --r-ctrl:#E48AA6; --r-desc:#AC9EE4; --r-vecop:#8ECC86; --r-actvt:#889490;
}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);
  font-family:"IBM Plex Sans",ui-sans-serif,system-ui,sans-serif;font-size:15px;line-height:1.55;
  font-variant-numeric:tabular-nums}
.wrap{max-width:1120px;margin:0 auto;padding:34px 22px 72px;display:flex;flex-direction:column;gap:34px}
h1{font-family:Spectral,Georgia,serif;font-weight:600;font-size:33px;margin:0;letter-spacing:-.015em;text-wrap:balance}
h2{font-family:Spectral,Georgia,serif;font-weight:600;font-size:21px;margin:0 0 3px;letter-spacing:-.01em;text-wrap:balance}
h3{font-family:Spectral,Georgia,serif;font-weight:600;font-size:16px;margin:0}
.eyebrow{font-size:10.5px;letter-spacing:.15em;text-transform:uppercase;color:var(--muted);font-weight:500}
.lede{color:var(--ink-2);max-width:66ch;margin:0}
code,.mono{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:.9em}
header{border-bottom:2px solid var(--ink);padding-bottom:16px;display:flex;flex-direction:column;gap:9px}
section{display:flex;flex-direction:column;gap:11px}
.scroll{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:13px}
th{font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--muted);text-align:left;padding:6px 9px;border-bottom:1px solid var(--line);font-weight:600;white-space:nowrap}
td{padding:6px 9px;border-bottom:1px solid var(--line);vertical-align:top}
/* the capture boundary spine */
.spine{display:grid;grid-template-columns:1fr auto 1fr;gap:0;align-items:stretch;border:1px solid var(--line);border-radius:3px;overflow:hidden;background:var(--surface)}
@media(max-width:820px){.spine{grid-template-columns:1fr}}
.stage{padding:15px 17px;display:flex;flex-direction:column;gap:7px}
.stage h3{font-size:14px}
.stage ul{margin:0;padding-left:17px;font-size:12.5px;color:var(--ink-2);line-height:1.5}
.stage li{margin:2px 0}
.bar{background:var(--capture);color:var(--ground);display:flex;align-items:center;justify-content:center;padding:13px 11px;min-width:78px}
.bar span{writing-mode:vertical-rl;transform:rotate(180deg);font-size:10.5px;letter-spacing:.16em;text-transform:uppercase;font-weight:600}
@media(max-width:820px){.bar span{writing-mode:horizontal-tb;transform:none}}
.s-front{border-right:1px solid var(--line)}
.s-front h3{color:var(--frontend)}.s-mid h3{color:var(--midend)}
.evidence{background:var(--sunk);border-left:3px solid var(--capture);padding:12px 15px;font-size:13.5px;color:var(--ink-2);border-radius:0 3px 3px 0}
.evidence strong{color:var(--ink)}
/* identity */
.ident{display:grid;grid-template-columns:repeat(auto-fit,minmax(215px,1fr));gap:0;border:1px solid var(--line);border-radius:3px;background:var(--surface)}
.ident div{padding:10px 14px;border-right:1px solid var(--line);border-bottom:1px solid var(--line)}
.ident dt{font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--muted);margin:0 0 3px}
.ident dd{margin:0;font-family:"IBM Plex Mono",monospace;font-size:11.5px;word-break:break-all;color:var(--ink)}
/* rules */
.rules{display:flex;flex-direction:column;gap:0;border-top:1px solid var(--line)}
.rule{display:grid;grid-template-columns:58px 1fr;gap:0 15px;padding:14px 0;border-bottom:1px solid var(--line);align-items:start}
.rid{font-family:"IBM Plex Mono",monospace;font-size:13px;font-weight:500;color:var(--capture);padding-top:1px}
.rule.ph .rid{color:var(--refuted)}
.rbody{display:flex;flex-direction:column;gap:6px;min-width:0}
.rname{font-family:Spectral,Georgia,serif;font-size:16.5px;font-weight:600;line-height:1.3}
.rgrid{display:grid;grid-template-columns:88px 1fr;gap:3px 13px;font-size:12.5px;color:var(--ink-2)}
.rgrid dt{color:var(--muted);font-size:10px;letter-spacing:.09em;text-transform:uppercase;padding-top:2px}
.rgrid dd{margin:0}
.tags{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.tag{font-size:10px;letter-spacing:.08em;text-transform:uppercase;padding:1px 6px;border:1px solid var(--line);border-radius:2px;color:var(--muted)}
.tag.ph{border-color:var(--refuted);color:var(--refuted)}
.note{font-size:12.5px;color:var(--ink-2);border-left:2px solid var(--line);padding-left:11px}
.note.warn{border-left-color:var(--refuted)}
/* cases */
.caserow{cursor:pointer}
.caserow:hover td{background:var(--sunk)}
.caserow[aria-expanded="true"] td{background:var(--sunk)}
.caserow th{font-weight:400}
.pill{font-size:10px;letter-spacing:.07em;text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid currentColor}
.p-exact{color:var(--confirmed)}.p-differ{color:var(--refuted)}
.p-blind{color:var(--confirmed)}.p-refined{color:var(--midend)}.p-refuted{color:var(--refuted)}
.detail td{background:var(--sunk);padding:0}
.detail .inner{display:grid;grid-template-columns:1fr 1fr;gap:0;border-top:1px solid var(--line)}
@media(max-width:900px){.detail .inner{grid-template-columns:1fr}}
.pane{padding:13px 15px;min-width:0}
.pane:first-child{border-right:1px solid var(--line)}
.pane .eyebrow{margin-bottom:7px;display:block}
pre{margin:0;font-family:"IBM Plex Mono",monospace;font-size:11.5px;line-height:1.55;overflow-x:auto;color:var(--ink-2)}
.mi{display:grid;grid-template-columns:52px 1fr 62px;gap:9px;font-family:"IBM Plex Mono",monospace;font-size:11.5px;line-height:1.75}
.mi .pc{color:var(--muted)}
.mi .rl{font-size:9.5px;letter-spacing:.07em;text-transform:uppercase;text-align:right;padding-top:2px}
.legend{display:flex;gap:13px;flex-wrap:wrap;font-size:11.5px;color:var(--ink-2)}
.legend span::before{content:"";display:inline-block;width:9px;height:9px;border-radius:1px;margin-right:5px;vertical-align:0}
.roles{font-size:12px;color:var(--ink-2)}
.big{display:flex;gap:26px;flex-wrap:wrap;align-items:baseline;padding:13px 16px;background:var(--surface);border:1px solid var(--line);border-radius:3px}
.big div{display:flex flex-direction:column}
.big .n{font-family:Spectral,Georgia,serif;font-size:25px;font-weight:600;line-height:1}
.big .l{font-size:11.5px;color:var(--muted);display:block;margin-top:3px}
a{color:var(--capture)}
.caserow:focus-visible{outline:2px solid var(--capture);outline-offset:-2px}
</style>
<div class="wrap">

<header>
  <div class="eyebrow">Cerebras WSE-3 · SDK 2.10 · compilation model</div>
  <h1>CSL Add-Family Lowering</h1>
  <p class="lede">Eighteen programs, each one factor apart, compiled with the driver-to-backend LLVM IR retained. What the compiler does to an <code>i16</code> add — and where in the pipeline it does it — stated as rules with preconditions, then tested against four compositions held back from building them.</p>
</header>

<section>
  <div class="eyebrow">the two boundaries</div>
  <h2>The retained IR is not a neutral pre-target form</h2>
  <p class="lede"><code>cslc</code> invokes <code>clang -cc1 … -x ir &lt;captured&gt;.ll … -O2</code>, so the file <code>tools/cslc_ir.py</code> keeps is the input to that pipeline. But it already carries CSL specialisation <em>and</em> target-specific lowering, so the model is split in two rather than drawn as one line.</p>
  <div class="spine">
    <div class="stage s-front">
      <h3>Decided before capture</h3>
      <ul>
        <li>source constants folded (<span class="mono">F3</span>); a constant operand already an IR immediate (<span class="mono">F2</span>)</li>
        <li>statements lowered one-to-one, nothing shared (<span class="mono">F1</span>)</li>
        <li>named locals as <code>alloca</code>; loops as <code>br</code>/<code>phi</code> (<span class="mono">F5</span>)</li>
        <li><strong>DSD descriptor sharing, intrinsic selection and DSR indices</strong> (<span class="mono">F4</span>)</li>
      </ul>
    </div>
    <div class="bar"><span>captured IR</span></div>
    <div class="stage s-mid">
      <h3>Decided after capture</h3>
      <ul>
        <li>repeat reads and repeat expressions eliminated (<span class="mono">M1</span>)</li>
        <li>stores forwarded to loads, across iterations too (<span class="mono">M2</span>)</li>
        <li>index-independent work computed once; comptime loops unrolled (<span class="mono">M3</span>, <span class="mono">M4</span>)</li>
        <li>if/else arms tail-merged; addressing sequences emitted (<span class="mono">M7</span>, <span class="mono">M5</span>)</li>
      </ul>
    </div>
  </div>
  <div class="evidence"><strong>What settles the DSD side.</strong> The captured IR for the two DSD cases already contains the answer, so it was never a downstream discovery:
  <pre style="margin:9px 0 0">dsd16          3 descriptor loads + llvm.sdr.add16.ds0s1  (i16 1, i16 1, i16 1)
W_dsd_inplace  2 descriptor loads + llvm.sdr.add16.s0s0s1 (i16 0, i16 0, i16 1)</pre>
  The intrinsic <em>name</em> encodes the operand roles and its <em>arguments</em> are the chosen DSR indices. An earlier version of this page put these decisions on the wrong side of the boundary.</div>
  <div class="evidence" style="border-left-color:var(--refuted)"><strong>No pass names, and no pass order — permanently.</strong> Three channels for an intermediate transformation log were tried and all fail on this SDK: stock <code>opt</code> rejects the IR (non-integral address space 0), the <code>clang</code> the driver names is not a binary in the container and runs in-process inside <code>cslc-backend</code>, and <code>cslc-backend</code> answers <code>--print-after-all</code>, <code>--print-changed</code>, <code>--debug-pass</code> and <code>--time-passes</code> with its usage message. Only endpoints are observable, so every rule below states resulting structure and never the sequence that produced it.</div>
</section>

<section>
  <div class="eyebrow">scope</div>
  <h2>What these rules are bound to</h2>
  <p class="lede">A lowering rule without its compilation identity is not a claim about anything. <strong>A match</strong> below means <span id="exactdef"></span></p>
  <dl class="ident" id="ident"></dl>
</section>

<section>
  <div class="eyebrow">evaluation</div>
  <h2>Where the model stands</h2>
  <div class="big" id="score"></div>
  <p class="lede">Boundary 1 is checked against the captured IR op multiset; source forms whose IR structure the model does not claim to predict are declared out of scope rather than guessed. Boundary 2 is checked against the instruction-role counts. Correctness is a separate acceptance check with its own inputs and expected values.</p>
</section>

<section>
  <div class="eyebrow">rules</div>
  <h2>Lowering rules, by boundary</h2>
  <p class="lede">Each rule carries what was actually tested and what was not. Observations are <code>compiled</code>; each rule as a general statement is <code>inferred</code>. An <span class="tag ph">open</span> rule records a shortfall the model does not explain.</p>
  <div class="rules" id="rules"></div>
</section>

<section>
  <div class="eyebrow">region contract</div>
  <h2>What is counted, and what is assumed on entry</h2>
  <p class="lede">Debug attribution is not a region boundary: a value the body needs can be materialised by an instruction the compiler tagged with a neighbouring source file. The region is the debug-attributed body up to <code>@activate(EXIT)</code> plus the transitive closure of the nearest preceding definitions of every register the body reads before defining. Fifteen of eighteen bodies need nothing on entry; the three that do are listed with their closure.</p>
  <div class="scroll"><table id="contract"><thead><tr>
    <th>case</th><th>body</th><th>init</th><th>total</th><th>entry live-in</th><th>init closure</th>
  </tr></thead><tbody></tbody></table></div>
</section>

<section>
  <div class="eyebrow">cases</div>
  <h2>One factor at a time</h2>
  <p class="lede">Select a row for its captured IR beside its machine code. Roles are assigned by dataflow, not by mnemonic: an <code>add16.nf</code> that adds a scaled index to an array base is address arithmetic, and counting it as the program's add would corrupt every rule above.</p>
  <div class="legend" id="legend"></div>
  <div class="scroll"><table id="cases"><thead><tr>
    <th>case</th><th>factor</th><th>CSL</th><th>IR</th><th>instr</th><th>predicted</th><th>b1</th><th>b2</th><th>value check</th><th>roles observed</th>
  </tr></thead><tbody></tbody></table></div>
</section>

<section>
  <div class="eyebrow">history</div>
  <h2>Prediction record, preserved not overwritten</h2>
  <p class="lede">Predictions are bound to the rule-set version that produced them. Revising a rule does not rewrite the earlier evaluation, and each withheld case records whether its revision preceded or followed inspection of the compilation result.</p>
  <div id="history"></div>
</section>

<section>
  <div class="eyebrow">reconstruction</div>
  <h2>Every case rebuilds from its manifest</h2>
  <p class="lede" id="manifest"></p>
</section>

</div>
<script>
const D = __DATA__;
const esc = s => String(s ?? "").replace(/&/g,"&amp;").replace(/</g,"&lt;");
const ROLES = ["load","store","alu","addr","ctrl","desc","vecop","actvt","other"];
const roleText = o => ROLES.filter(r => o[r]).map(r => `<span style="color:var(--r-${r})">${r} ${o[r]}</span>`).join(" · ");
const bag = o => Object.entries(o || {}).map(([k,v]) => `${k} ${v}`).join(", ");

document.getElementById("exactdef").textContent = D.exact_def + ".";

// scope
const I = D.identity, sdk = I.cslang_bin.match(/rel-sdk-([\d.]+)\/(\S+?)\/bin/) || [];
document.getElementById("ident").innerHTML = [
  ["rule set", D.version],
  ["SDK / cslang", `${sdk[1] || "2.10.0"} · ${sdk[2] || ""}`],
  ["backend target", I.backend_argv.join(" ")],
  ["compiler flags", I.cslc_args.filter(x => x.startsWith("--")).join(" ")],
  ["optimisation", "-O2 (the driver's default on the captured IR)"],
  ["runtime library", (I.libs[0] || "").split("/").pop()],
].map(([k,v]) => `<div><dt>${esc(k)}</dt><dd>${esc(v)}</dd></div>`).join("");

// score
const S = D.score;
document.getElementById("score").innerHTML = [
  [`${S.b1_exact}/${S.b1_total}`, `boundary 1 · CSL to captured IR (${S.b1_out} out of scope)`],
  [`${S.b2_exact}/${S.b2_total}`, "boundary 2 · captured IR to instruction roles"],
  [`${S.correct}/${S.b2_total}`, "numerical acceptance checks passed"],
].map(([n,l]) => `<div><span class="n">${n}</span><span class="l">${esc(l)}</span></div>`).join("");

// rules, grouped by boundary
const byB = {};
D.rules.forEach(r => (byB[r.boundary] = byB[r.boundary] || []).push(r));
document.getElementById("rules").innerHTML = Object.entries(byB).map(([b, rs]) => `
  <div style="padding:13px 0 4px"><span class="eyebrow">${esc(b)}</span></div>
  ` + rs.map(r => `
  <div class="rule${r.open ? " ph" : ""}">
    <div class="rid">${esc(r.id)}</div>
    <div class="rbody">
      <div class="rname">${esc(r.name)}</div>
      <dl class="rgrid">
        <dt>when</dt><dd>${esc(r.when)}</dd>
        <dt>result</dt><dd>${esc(r.result)}</dd>
        <dt>tested</dt><dd>${esc(r.tested)}</dd>
        <dt>untested</dt><dd style="color:var(--refuted)">${esc(r.untested)}</dd>
      </dl>
      <div class="tags">
        ${r.cases.map(c => `<span class="tag">${esc(c)}</span>`).join("")}
        <span class="tag">${esc(r.evidence)}</span>
        ${r.open ? '<span class="tag ph">open</span>' : ""}
      </div>
      ${r.note ? `<div class="note${r.open ? " warn" : ""}">${esc(r.note)}</div>` : ""}
    </div>
  </div>`).join("")).join("");

// region contract
document.querySelector("#contract tbody").innerHTML = D.cases.map(c => {
  const k = c.contract;
  const init = k.init.map(i => `<span class="mono">${esc(i.text)}</span> <span style="color:var(--muted)">tagged ${esc(i.source_file)}, defines ${esc(i.defines.join(","))}</span>`).join("<br>");
  return `<tr><td class="mono">${esc(c.name)}</td><td class="mono">${k.n_body}</td><td class="mono">${k.n_init}</td>
    <td class="mono">${k.n_total}</td><td class="mono">${k.live_in.length ? esc(k.live_in.join(", ")) : "<span style='color:var(--muted)'>none</span>"}</td>
    <td style="font-size:12px">${init || "<span style='color:var(--muted)'>—</span>"}${k.unresolved.length ? `<div style="color:var(--refuted)">unresolved: ${esc(k.unresolved.join(","))}</div>` : ""}</td></tr>`;
}).join("");

// legend
document.getElementById("legend").innerHTML = ROLES.slice(0,8)
  .map(r => `<span style="color:var(--ink-2)"><span style="background:var(--r-${r});display:inline-block;width:9px;height:9px;border-radius:1px;margin-right:5px"></span>${r}</span>`).join("");

// cases
const tb = document.querySelector("#cases tbody");
D.cases.forEach(c => {
  const tr = document.createElement("tr");
  tr.className = "caserow"; tr.tabIndex = 0; tr.setAttribute("aria-expanded","false");
  const b1 = c.ir_in_scope ? `<span class="pill ${c.ir_exact ? "p-exact" : "p-differ"}">${c.ir_exact ? "exact" : "differs"}</span>`
                           : `<span style="color:var(--muted);font-size:11px">out of scope</span>`;
  const vc = (c.correctness || {}).ok ? `<span class="pill p-exact">ok</span>` : `<span class="pill p-differ">check</span>`;
  tr.innerHTML = `<td class="mono">${esc(c.name)}${c.withheld ? ' <span class="tag">regression</span>' : ""}</td>
    <td style="color:var(--muted)">${esc(c.factor)}</td>
    <td class="mono" style="white-space:pre-wrap;max-width:25ch">${esc(c.csl)}</td>
    <td class="mono">${c.ir_lines}</td><td class="mono">${c.contract.n_total}</td>
    <td class="mono">${Object.values(c.predicted).reduce((a,b)=>a+b,0)}</td>
    <td>${b1}</td>
    <td><span class="pill ${c.exact ? "p-exact" : "p-differ"}">${c.exact ? "exact" : "differs"}</span></td>
    <td>${vc}</td>
    <td class="roles">${roleText(c.observed)}</td>`;
  const det = document.createElement("tr");
  det.className = "detail"; det.hidden = true;
  const mism = c.exact ? "" : `<div class="note warn" style="margin:0 15px 11px">predicted ${esc(bag(c.predicted))} · observed ${esc(bag(c.observed))}</div>`;
  const irpred = c.ir_in_scope ? `<div class="note" style="margin-top:9px">predicted IR ops: <span class="mono">${esc(bag(c.ir_predicted))}</span></div>` : "";
  const corr = c.correctness ? `<div class="note" style="margin-top:9px">values: expected <span class="mono">${esc(bag(c.correctness.expected))}</span> in <span class="mono">${esc(c.correctness.array)}</span>, observed <span class="mono">${esc(bag(c.correctness.observed))}</span></div>` : "";
  det.innerHTML = `<td colspan="10">${mism}<div class="inner">
      <div class="pane"><span class="eyebrow">captured IR — @compute (${c.ir_lines} lines)</span><pre>${esc(c.ir)}</pre>${irpred}</div>
      <div class="pane"><span class="eyebrow">machine code — region contract (${c.contract.n_total})</span><div class="mi">${
        c.machine.map(m => `<span class="pc">0x${m.pc.toString(16).padStart(4,"0")}</span><span>${esc(m.text)}</span><span class="rl" style="color:var(--r-${m.role})">${m.role}</span>`).join("")
      }</div>${c.dsrs.length ? `<div class="note" style="margin-top:9px">DSRs: <span class="mono">${esc(c.dsrs.join(", "))}</span></div>` : ""}${corr}</div>
    </div></td>`;
  const toggle = () => { const open = det.hidden; det.hidden = !open; tr.setAttribute("aria-expanded", String(open)); };
  tr.addEventListener("click", toggle);
  tr.addEventListener("keydown", e => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); toggle(); } });
  tb.append(tr, det);
});

// history
document.getElementById("history").innerHTML = D.history.rulesets.map(rs => `
  <div class="card" style="border:1px solid var(--line);border-radius:3px;background:var(--surface);padding:14px 16px;margin-bottom:11px">
    <div class="tags" style="margin-bottom:8px"><span class="tag" style="border-color:var(--capture);color:var(--capture)">${esc(rs.version)}</span><span class="tag">${esc(rs.date)}</span></div>
    <div style="font-size:12.5px;color:var(--ink-2);margin-bottom:9px">${esc(rs.summary)}</div>
    ${rs.withheld_evaluation ? `<div class="scroll"><table><thead><tr><th>withheld case</th><th>initial</th><th>revised</th><th>revision before inspection</th><th>observed</th><th>outcome</th></tr></thead><tbody>${
      rs.withheld_evaluation.map(e => `<tr><td class="mono">${esc(e.case)}</td><td class="mono">${e.initial_prediction}</td>
        <td class="mono">${e.revised_prediction ?? "—"}</td>
        <td class="mono">${e.revision_before_inspection === null ? "—" : (e.revision_before_inspection ? "yes" : "no")}</td>
        <td class="mono">${e.observation}</td><td style="font-size:12px">${esc(e.outcome)}${e.rule_added ? `<div style="color:var(--muted)">added: ${esc(e.rule_added)}</div>` : ""}${e.later_correction ? `<div style="color:var(--refuted)">${esc(e.later_correction)}</div>` : ""}</td></tr>`).join("")
    }</tbody></table></div>` : ""}
    ${rs.known_defects ? `<div class="note warn" style="margin-top:10px"><strong>Defects found later:</strong><ul style="margin:5px 0 0;padding-left:17px">${rs.known_defects.map(d => `<li>${esc(d)}</li>`).join("")}</ul></div>` : ""}
    ${rs.changes_from_v1 ? `<div class="note" style="margin-top:10px"><strong>Changed from the previous rule set:</strong><ul style="margin:5px 0 0;padding-left:17px">${rs.changes_from_v1.map(d => `<li>${esc(d)}</li>`).join("")}</ul></div>` : ""}
    ${rs.withheld_status ? `<div class="note" style="margin-top:10px">${esc(rs.withheld_status)}</div>` : ""}
  </div>`).join("");

document.getElementById("manifest").innerHTML =
  `<code>MANIFEST.json</code> records ${D.n_artifacts} artifacts across the 18 cases — sources, captured IR, object, ELF, task table, link script, backend and linker requests, disassembly and verification — each with a full <strong>${esc(D.hash_algorithm)}</strong> hash and the exact compile, backend and linker commands. The control for every differential result here is that an unmodified rebuild from a case's captured IR reproduces its ELF byte for byte.`;
</script>

"""
if __name__ == "__main__":
    main()
