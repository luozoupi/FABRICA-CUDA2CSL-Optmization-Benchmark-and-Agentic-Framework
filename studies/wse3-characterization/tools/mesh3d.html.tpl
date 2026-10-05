<title>Wavelets on the Wafer</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chivo:wght@700;900&family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600&display=swap">
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<style>
:root{
  --ground:#111826; --panel:#1A2233; --panel2:#141B2A; --line:#2B364C;
  --ink:#E4EAF5; --ink2:#B4C0D4; --dim:#8593AD;
  --live:#FFB454; --compute:#4FD1C5; --support:#46587A; --alarm:#F2686B;
  --view:#131A28;
  --shadow:0 1px 0 rgba(255,255,255,.03), 0 8px 24px rgba(0,0,0,.45);
}
:root:not([data-theme="dark"]){
  --ground:#F4F6FA; --panel:#FFFFFF; --panel2:#EDF0F6; --line:#D8DEEA;
  --ink:#121826; --ink2:#37415A; --dim:#5E6B85;
  --live:#B55C05; --compute:#07766C; --support:#8A97AF; --alarm:#B3282C;
  --view:#EFF2F8;
  --shadow:0 1px 0 rgba(255,255,255,.6), 0 6px 18px rgba(20,30,60,.10);
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --ground:#111826; --panel:#1A2233; --panel2:#141B2A; --line:#2B364C;
    --ink:#E4EAF5; --ink2:#B4C0D4; --dim:#8593AD;
    --live:#FFB454; --compute:#4FD1C5; --support:#46587A; --alarm:#F2686B;
    --view:#131A28;
    --shadow:0 1px 0 rgba(255,255,255,.03), 0 8px 24px rgba(0,0,0,.45);
  }
}
:root[data-theme="dark"]{
  --view:#131A28;
  --ground:#111826; --panel:#1A2233; --panel2:#141B2A; --line:#2B364C;
  --ink:#E4EAF5; --ink2:#B4C0D4; --dim:#8593AD;
  --live:#FFB454; --compute:#4FD1C5; --support:#46587A; --alarm:#F2686B;
  --shadow:0 1px 0 rgba(255,255,255,.03), 0 8px 24px rgba(0,0,0,.45);
}
*{box-sizing:border-box}
body{background:var(--ground);color:var(--ink);
  font-family:"IBM Plex Sans",ui-sans-serif,system-ui,sans-serif;
  font-size:15px;line-height:1.55;-webkit-font-smoothing:antialiased}
h1,h2,h3{font-family:Chivo,"IBM Plex Sans",sans-serif;text-wrap:balance;margin:0}
.mono{font-family:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,monospace;
  font-variant-numeric:tabular-nums}
a{color:var(--live)}
.wrap{max-width:1560px;margin:0 auto;padding:0 20px 72px}

.mast{display:flex;flex-wrap:wrap;align-items:flex-end;gap:20px 28px;
  padding:26px 0 16px;border-bottom:1px solid var(--line)}
.mast h1{font-weight:900;font-size:clamp(28px,3.4vw,46px);letter-spacing:-.02em;line-height:1}
.mast .sub{color:var(--dim);max-width:62ch;font-size:14px;margin-top:8px}
.mast .rd{margin-left:auto;display:flex;gap:22px;align-items:flex-end}
.rdv{text-align:right}
.rdv b{display:block;font-family:"IBM Plex Mono",monospace;font-variant-numeric:tabular-nums;
  font-size:26px;font-weight:600;line-height:1;letter-spacing:-.02em}
.rdv span{display:block;font-family:"IBM Plex Mono",monospace;font-size:10px;
  letter-spacing:.13em;text-transform:uppercase;color:var(--dim);margin-top:6px}
.amber{color:var(--live)} .teal{color:var(--compute)}

.console{display:grid;grid-template-columns:216px minmax(0,1fr) 268px;
  gap:14px;margin-top:18px;align-items:stretch}
@media (max-width:1180px){.console{grid-template-columns:200px minmax(0,1fr)}
  .insp{grid-column:1/-1}}
@media (max-width:760px){.console{grid-template-columns:1fr}}
.rail,.insp{background:var(--panel);border:1px solid var(--line);border-radius:3px;
  padding:12px;min-width:0;box-shadow:var(--shadow)}
.rail{display:flex;flex-direction:column;gap:4px}
.eyebrow{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.14em;
  text-transform:uppercase;color:var(--dim);margin:2px 0 8px}
.sc{display:block;width:100%;text-align:left;background:none;border:0;
  border-left:2px solid transparent;padding:7px 9px;cursor:pointer;color:var(--ink2);
  font:inherit;font-size:13px;border-radius:0 2px 2px 0;line-height:1.3}
.sc:hover{background:var(--panel2);color:var(--ink)}
.sc[aria-current="true"]{background:var(--panel2);border-left-color:var(--live);color:var(--ink);font-weight:600}
.sc em{display:block;font-style:normal;font-family:"IBM Plex Mono",monospace;
  font-size:10px;color:var(--dim);margin-top:3px;letter-spacing:.04em}
.sc[aria-current="true"] em{color:var(--live)}

.viewbox{position:relative;background:var(--view);border:1px solid var(--line);
  border-radius:3px;overflow:hidden;min-height:520px;box-shadow:var(--shadow)}
#gl{display:block;width:100%;height:100%}
#llab{position:absolute;inset:0;pointer-events:none;overflow:hidden}
.llb{position:absolute;top:0;left:0;will-change:transform;pointer-events:auto;cursor:pointer;
  font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.04em;
  color:var(--vink);background:var(--vchip);border:1px solid var(--vchipl);
  padding:2px 6px;border-radius:2px;white-space:nowrap;
  transform-origin:0 0;font-variant-numeric:tabular-nums}
.llb:hover{border-color:var(--live);color:var(--vink2)}
.llb.on{background:var(--live);border-color:var(--live);color:#14181F;font-weight:600}
.llb i{font-style:normal;opacity:.62;margin-left:6px}
.vhud{position:absolute;top:10px;left:12px;pointer-events:none;
  font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--vink);line-height:1.7}
.vhud b{color:var(--vink2);font-weight:600}
.vtools{position:absolute;top:9px;right:10px;display:flex;gap:5px;flex-wrap:wrap;
  justify-content:flex-end;max-width:70%}
.viewbox.vdark{--vink:#9FAFCC;--vink2:#EDF2FB;--vchip:rgba(22,30,45,.86);
  --vchipl:#33405B;--vhint:#7385A4}
.viewbox.vlight{--vink:#47566F;--vink2:#0E1523;--vchip:rgba(255,255,255,.90);
  --vchipl:#BFC9DA;--vhint:#78879F}
.vtools button,.tbar .tgl{font-family:"IBM Plex Mono",monospace;font-size:10px;
  letter-spacing:.09em;text-transform:uppercase;padding:5px 9px;border-radius:2px;
  cursor:pointer}
.vtools button{background:var(--vchip);border:1px solid var(--vchipl);color:var(--vink)}
.vtools button:hover{border-color:var(--live);color:var(--vink2)}
.vtools button[aria-pressed="true"]{background:var(--live);
  border-color:var(--live);color:#14181F;font-weight:600}
.tbar .tgl{background:var(--panel2);border:1px solid var(--line);color:var(--dim)}
.tbar .tgl:hover{border-color:var(--live);color:var(--ink)}
.tbar .tgl[aria-pressed="true"]{background:var(--live);border-color:var(--live);
  color:#14181F;font-weight:600}
.vtools .grp{display:flex;gap:5px;padding-right:7px;margin-right:2px;
  border-right:1px solid var(--vchipl)}
.vtools .mode[aria-pressed="true"]{background:var(--compute);border-color:var(--compute);color:#04201D}
.vlegend{position:absolute;left:12px;bottom:10px;display:flex;gap:14px;flex-wrap:wrap;
  font-family:"IBM Plex Mono",monospace;font-size:10px;color:var(--vink);pointer-events:none;
  max-width:74%}
.vlegend i{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:5px;
  vertical-align:-1px}
.vlegend i.bar{width:2px;height:9px;border-radius:0;transform:rotate(22deg)}
.vhint{position:absolute;right:12px;bottom:10px;font-family:"IBM Plex Mono",monospace;
  font-size:10px;color:var(--vhint);pointer-events:none;text-align:right}

.insp{display:flex;flex-direction:column;gap:0}
.insp h3{font-size:15px;font-weight:700;letter-spacing:-.01em}
.pill{display:inline-block;font-family:"IBM Plex Mono",monospace;font-size:9px;
  letter-spacing:.11em;text-transform:uppercase;padding:2px 7px;border-radius:9px;
  border:1px solid currentColor;margin-top:6px}
.kv{display:flex;justify-content:space-between;gap:10px;padding:5px 0;
  border-bottom:1px dotted var(--line);font-size:12px}
.kv:last-of-type{border-bottom:0}
.kv span{color:var(--dim)}
.kv b{font-family:"IBM Plex Mono",monospace;font-weight:500;font-variant-numeric:tabular-nums}
.mixrow{display:grid;grid-template-columns:1fr 44px;gap:8px;align-items:center;
  font-family:"IBM Plex Mono",monospace;font-size:11px;padding:2px 0}
.mixbar{height:3px;background:var(--line);border-radius:2px;overflow:hidden;margin-top:2px}
.mixbar i{display:block;height:100%;background:var(--compute)}
.mixrow b{text-align:right;font-weight:500;color:var(--ink2)}

.transport{margin-top:14px;background:var(--panel);border:1px solid var(--line);
  border-radius:3px;padding:11px 13px 13px;box-shadow:var(--shadow)}
.tbar{display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:9px}
.play{background:var(--live);border:0;color:#12161F;font-family:"IBM Plex Mono",monospace;
  font-weight:600;font-size:11px;letter-spacing:.1em;text-transform:uppercase;
  padding:7px 15px;border-radius:2px;cursor:pointer;min-width:82px}
.play:hover{filter:brightness(1.08)}
.spd{display:flex;gap:0;border:1px solid var(--line);border-radius:2px;overflow:hidden}
.spd button{background:none;border:0;border-right:1px solid var(--line);color:var(--dim);
  font-family:"IBM Plex Mono",monospace;font-size:11px;padding:6px 10px;cursor:pointer}
.spd button:last-child{border-right:0}
.spd button[aria-pressed="true"]{background:var(--panel2);color:var(--live);font-weight:600}
.tlabel{font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim);
  margin-left:auto;font-variant-numeric:tabular-nums;text-align:right}
.ribbon{position:relative;height:66px;cursor:crosshair;border:1px solid var(--line);
  border-radius:2px;background:var(--panel2);overflow:hidden}
#ribcv{display:block;width:100%;height:100%}
.rlab{display:flex;justify-content:space-between;font-family:"IBM Plex Mono",monospace;
  font-size:10px;color:var(--dim);margin-top:5px}

.tour{margin-top:8px;border-top:1px solid var(--line);padding-top:10px}
.tstep{display:block;width:100%;text-align:left;background:none;border:0;padding:6px 8px;
  cursor:pointer;color:var(--ink2);font:inherit;font-size:12px;line-height:1.4;
  border-left:2px solid transparent;border-radius:0 2px 2px 0}
.tstep:hover{background:var(--panel2);color:var(--ink)}
.tstep[aria-current="true"]{background:var(--panel2);border-left-color:var(--compute);color:var(--ink)}
.tstep b{display:block;font-family:"IBM Plex Mono",monospace;font-size:10px;
  letter-spacing:.09em;text-transform:uppercase;color:var(--dim);margin-bottom:2px}
.tstep[aria-current="true"] b{color:var(--compute)}

.read{margin-top:56px;display:grid;grid-template-columns:minmax(0,1fr) 300px;gap:44px}
@media (max-width:940px){.read{grid-template-columns:1fr;gap:28px}}
.read h2{font-size:24px;font-weight:900;letter-spacing:-.02em;margin:34px 0 10px}
.read h2:first-child{margin-top:0}
.read h3{font-size:15px;font-weight:700;margin:22px 0 6px}
.read p{max-width:66ch;color:var(--ink2);margin:0 0 12px}
.read li{max-width:64ch;color:var(--ink2);margin-bottom:7px}
.read code{font-family:"IBM Plex Mono",monospace;font-size:.88em;background:var(--panel2);
  border:1px solid var(--line);border-radius:2px;padding:1px 5px}
.tblwrap{overflow-x:auto;margin:14px 0}
table{border-collapse:collapse;width:100%;font-size:12.5px;min-width:460px}
th,td{text-align:left;padding:7px 12px 7px 0;border-bottom:1px solid var(--line);
  vertical-align:top}
th{font-family:"IBM Plex Mono",monospace;font-size:10px;letter-spacing:.11em;
  text-transform:uppercase;color:var(--dim);font-weight:500}
td.n{font-family:"IBM Plex Mono",monospace;font-variant-numeric:tabular-nums;text-align:right;
  padding-right:20px}
.side{font-size:13px}
.sidebox{background:var(--panel);border:1px solid var(--line);border-left:2px solid var(--live);
  border-radius:0 3px 3px 0;padding:13px 15px;margin-bottom:16px}
.sidebox h3{font-size:12px;font-family:"IBM Plex Mono",monospace;letter-spacing:.11em;
  text-transform:uppercase;color:var(--live);margin:0 0 7px}
.sidebox p{font-size:12.5px;color:var(--ink2);margin:0 0 8px;max-width:none}
.sidebox p:last-child{margin-bottom:0}
.ev{font-family:"IBM Plex Mono",monospace;font-size:9.5px;letter-spacing:.09em;
  text-transform:uppercase;padding:1px 6px;border-radius:2px;border:1px solid var(--line);
  color:var(--dim);white-space:nowrap}
.ev.sim{color:var(--compute);border-color:var(--compute)}
.ev.inf{color:var(--live);border-color:var(--live)}
.ev.cmp{color:var(--ink2)}
footer{margin-top:56px;padding-top:18px;border-top:1px solid var(--line);
  font-family:"IBM Plex Mono",monospace;font-size:11px;color:var(--dim)}
:focus-visible{outline:2px solid var(--live);outline-offset:2px;border-radius:2px}
@media (prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}}
</style>

<div class="wrap">

<header class="mast">
  <div>
    <h1>Wavelets on the Wafer</h1>
    <div class="sub">Every packet below was observed by the Cerebras simulator, on a real
      trace, at the cycle shown. Cycles are the simulator's trace clock, which is its own
      clock domain and is not host time. Nothing here is a schematic.</div>
  </div>
  <div class="rd">
    <div class="rdv"><b id="rdcyc" class="amber">0</b><span id="rdcycl">cycle</span></div>
    <div class="rdv"><b id="rdfly">0</b><span id="rdflyl">in flight</span></div>
    <div class="rdv"><b id="rdhop" class="teal">2.0</b><span>cyc / hop</span></div>
  </div>
</header>

<div class="console">
  <nav class="rail" aria-label="Scenes">
    <div class="eyebrow">Traces</div>
    <div id="scenes"></div>
    <div class="tour">
      <div class="eyebrow">Walkthrough</div>
      <div id="tour"></div>
    </div>
  </nav>

  <div class="viewbox vdark" id="viewbox">
    <canvas id="gl"></canvas>
    <div id="llab"></div>
    <div class="vhud">
      <div id="hud1"><b>&nbsp;</b></div>
      <div id="hud2">&nbsp;</div>
    </div>
    <div class="vtools">
      <span class="grp">
        <button class="mode" id="mFlow" aria-pressed="true" title="Animated replay">Flow</button>
        <button class="mode" id="mTrel" aria-pressed="false" title="Stacked cycle layers">Trellis</button>
      </span>
      <button id="vBright" aria-pressed="false" title="Light or dark viewport; follows your theme until you choose">Bright</button>
      <button id="vTop" title="Look straight down">Plan</button>
      <button id="vIso" aria-pressed="true" title="Three-quarter view">Iso</button>
      <button id="vEdge" title="Look along the rows">Edge</button>
      <span class="grp" id="flowOpts">
        <button class="tgl" id="tLinks" aria-pressed="true">Links</button>
        <button class="tgl" id="tTrails" aria-pressed="true">Trails</button>
      </span>
      <span class="grp" id="trelOpts" hidden>
        <button id="lN" title="Number of cycle layers in the stack">16 layers</button>
        <button id="lS" title="Cycles between layers">stride 2</button>
        <button id="cBy" title="What colours each PE square">colour: compute</button>
        <button class="tgl" id="lClr" hidden>clear focus</button>
      </span>
    </div>
    <div class="vlegend" id="legend"></div>
    <div class="vhint" id="hint">drag rotate &middot; wheel zoom &middot; shift-drag pan</div>
  </div>

  <aside class="insp" id="insp"></aside>
</div>

<div class="transport">
  <div class="tbar">
    <button class="play" id="play">Pause</button>
    <div class="spd" id="spd"></div>
    <button class="tgl" id="loop" aria-pressed="true">Loop</button>
    <div class="tlabel" id="tlabel"></div>
  </div>
  <div class="ribbon" id="ribbon"><canvas id="ribcv"></canvas></div>
  <div class="rlab"><span id="rl0"></span><span id="rlmid"></span><span id="rl1"></span></div>
</div>
<div class="read">
  <main>
    <h2>What you are looking at</h2>
    <p>A Cerebras WSE-3 program does not move data by writing to memory that another core
      reads. It sends <strong>wavelets</strong>: 32-bit packets that enter the fabric on a
      numbered <em>colour</em>, and are forwarded hop by hop by a router in every processing
      element, along a path the compiler fixed before the program ever ran.</p>
    <p>The study behind this page already had the layout without the time, and the time
      without the layout. Static probes read every PE's routing table out of the ELF;
      instruction traces gave exact cycles but flattened the mesh into a list of tracks.
      Neither one shows a packet crossing the fabric. This joins them.</p>

    <h3>How a wavelet becomes a moving dot</h3>
    <p>The simulator emits one <code>wavelet_trace_entry</code> each time a packet is
      observed at a PE, carrying a cycle, a tile index, an <code>ident</code>, and an opaque
      <code>fields</code> word. Observations that share an <code>ident</code> and sit at
      cardinally adjacent PEs are treated as the same packet moving. That pairing rule is the
      one inference in the pipeline, and it is marked as such wherever it appears.</p>
    <p>Once paired, the direction of each hop is read straight off the two observed
      coordinates, not decoded out of the router fields. The delay is the difference of two
      observed cycles. So the motion you see is measured, and only the question of
      <em>which observations belong together</em> is inferred.</p>

    <h3>Why a browser can hold 543,122 wavelet observations</h3>
    <p>It does not hold them. MeshGEMM's 543,122 observations group into 197,909 packets,
      and those packets take only <strong>170 distinct shapes</strong> once a shape is
      defined as a path plus its per-hop timing offsets. Every packet is then three small
      integers: which shape, when it launched, what colour. The page rebuilds exact
      positions from the shape at draw time.</p>
    <p>That is not a compression trick so much as a finding. A hand-written CSL kernel
      running for 122,741 cycles reuses 170 routes, because the routes were compiled in and
      the loop just replays them.</p>

    <h3>The hop delay is two cycles</h3>
    <p>Across the MeshGEMV route shapes, 209 of 235 hop intervals are exactly 2 cycles. In
      the MeshGEMM steady-state window, 60 of 60 are. The animation runs at that rate, so at
      1 cycle per frame you are watching the fabric's real latency, not an eased
      approximation.</p>

    <h2>The scenes</h2>
    <div class="tblwrap"><table id="stbl"></table></div>

    <h3>What each one is for</h3>
    <ul>
      <li><strong>One message crosses one link</strong> is the control. Eight words, one
        hop, nothing else happening. If the pipeline is wrong, it is visible here.</li>
      <li><strong>One PE running the basic ISA</strong> shows the overhead the study keeps
        reporting as a ratio. One PE does the arithmetic; the rest of the lit fabric is the
        memcpy runtime that gets the data to it and the answer back.</li>
      <li><strong>MeshGEMV</strong> is the clearest structure: packets run along a row,
        turn down a column and out across the application tile, which multiplies, and the
        reduction walks back west. Every strand is a separate packet, not one fanning out.</li>
      <li><strong>MeshGEMM, one window</strong> is chosen to contain a stretch of pure
        compute with no fabric traffic at all. That gap is what the whole-run view averages
        away, and it is where the kernel is actually spending its time.</li>
    </ul>

    <h2>Two ways to read the same trace</h2>
    <p><strong>Flow</strong> replays the fabric: one frame is one moment, and a packet is a
      dot that moves. It answers "what was happening at cycle C".</p>
    <p><strong>Trellis</strong> stacks the mesh instead. Each horizontal plane is the whole
      2-D fabric at one cycle, planes are stacked upward in time, and a hop becomes a line
      from the PE it left on the lower plane to the PE it reached on the upper one. Nothing
      moves; the entire routing structure of a window is visible at once.</p>
    <p>The trellis earns its keep because of the 2-cycle constant. Set the layer stride to
      2 and a 2-cycle transit hop must connect <em>adjacent</em> planes, so fabric-speed
      travel has one fixed slope and anything slower visibly leans. In the MeshGEMM
      steady-state window all 1,104 hops drawn at that moment span exactly one plane: the
      reduction is a set of parallel diagonals leaning west. In MeshGEMV about two thirds
      do, and the steeper lines that remain are injection and drain at the ends of a route,
      not slow transit. Switch the camera to <strong>Edge</strong> and the stack reads as a
      conventional space-time diagram, distance across and time up.</p>
    <p>Each plane carries one square per PE, laid out at its real fabric coordinates, and
      the square's brightness is how much was <em>recorded</em> at that PE on that plane's
      cycle. Two things can drive it. <strong>Dispatches</strong> reads a fine instruction
      histogram binned at 1 to 16 cycles depending on how long the trace is, so a PE that
      goes quiet mid-stack visibly dims. <strong>Fabric</strong> instead counts wavelet
      observations at that PE on that exact cycle, the same measurement the hop lines are
      drawn from. The control names the resolution of whichever is active, because they are
      not the same: the fabric count is exact per cycle, the dispatch count is an average
      over its bin. Neither is utilisation. A dispatch count says an instruction issued, not
      that a unit was busy, and a router observation is not a memory write.</p>
    <p>Layer count and stride are adjustable, and clicking a cycle tag isolates that plane
      and the hops touching it. Playing in trellis mode slides the whole stack forward
      through the run, so the structure changes rather than the dots.</p>

    <h2>What the pairing rule costs, measured</h2>
    <p>Joining observations by <code>ident</code> plus cardinal adjacency is the one
      inference this page makes, so it is worth asking what it hides. Three failures are
      possible. A packet could branch, and be drawn as one arbitrary strand. A step could
      have two equally recent neighbours, making the predecessor a coin flip. A pair could
      not be adjacent at all, meaning the chain is fiction.</p>
    <p>None of them occur. Auditing every identity in five captures:</p>
    <div class="tblwrap"><table>__AUDIT__</table></div>
    <p>Every multi-observation packet forms a simple cardinal path, no step ever has a
      competing predecessor, and no two packets share an origin. So no packet is ever
      replicated into a <em>tree</em>.</p>
    <p><strong>That does not mean there is no multicast, and an earlier version of this page
      said it did.</strong> A router can also multicast along a <em>line</em>: each PE on the
      way both delivers the packet to its own core and forwards it onward. Such a packet
      still has one identity and a simple path, so this audit cannot see it. The compiled
      route tables can. MeshGEMV configures colour 9 as <code>rx SOUTH &rarr; tx RAMP,
      NORTH</code> on its middle PEs, and in the trace every one of its 352 packets is observed
      at all four PEs of a column: the final result of the allreduce, broadcast by the router.
      MeshGEMM's kernel colours, by contrast, never deliver and forward at once; its only such
      routes belong to the memcpy runtime. So MeshGEMV multicasts and MeshGEMM does not.</p>
    <p>The identities that are dropped are counted, not hidden: they are packets observed
      exactly once, which form no path. They are a fraction of a percent of the two matrix
      kernels and about a sixth of the small captures, where a single hop between two
      adjacent PEs often produces one record.</p>

    <h2>Reading the picture honestly</h2>
    <p>Bar height is dispatches in the current time bin, not utilisation and not occupancy.
      A tall bar means the PE issued many instructions, including the loop and addressing
      instructions the study has repeatedly found dominate these kernels. Teal marks PEs
      that issued floating-point <em>arithmetic</em>; moves and conversions are excluded,
      because counting them makes every data-movement PE look like a compute PE.</p>
    <p>Trails in the flow view are a drawing device, not data. The head of each dot is at
      a position interpolated between two observed hops; the tail behind it is where that
      same dot was on earlier frames. The trellis view interpolates nothing: every line
      endpoint is an observation the simulator actually recorded.</p>
    <p>Identities are only meaningful inside one capture. Nothing here binds a packet
      across two runs, and an active relay that consumes a word and sends a new one creates
      a new identity that this page does not join to its cause. Equal values do not
      establish lineage: 249 pairs of packets in MeshGEMV carry the same payload word in the
      same cycle under different identities, and they are drawn as what they are, separate
      packets.</p>
    <p>Wavelet colour is bits 0 to 4 of the <code>fields</code> word. That slice was
      verified against the compiler's own routing tables, 3,021 wavelets with no mismatch,
      so the colour is real. The remaining bits of <code>fields</code> are not used here.</p>
  </main>

  <aside class="side">
    <div class="sidebox">
      <h3>Evidence</h3>
      <p><span class="ev sim">simulator</span> PE coordinates, cycles, dispatch counts,
        wavelet observations, decode-to-execute delays.</p>
      <p><span class="ev inf">inferred</span> Which observations form one packet, from
        <code>ident</code> equality plus cardinal adjacency.</p>
      <p><span class="ev cmp">compiled</span> Wavelet colour, and the application-versus-support
        role of each PE, both read from the ELF.</p>
      <p>Nothing on this page is <span class="ev">silicon</span>. The study's silicon runs
        cover the memory path, where the simulator is optimistic by 1.37 to 1.66&times;.</p>
    </div>
    <div class="sidebox">
      <h3>Not shown</h3>
      <p>Pipeline stages 4 and 5 are not traced. The simulator records decode (stage 3) and
        execute (stage 6) and nothing between, so no page in this study can say what a
        wavelet or an instruction is doing in the gap.</p>
      <p>Router queue depth and backpressure are recorded separately and are not drawn
        here, so a dot sitting still is not evidence of a stalled link.</p>
    </div>
    <div class="sidebox">
      <h3>Source</h3>
      <p>Scenes are built by <code>tools/mesh3d_scenes.py</code> from the decoded
        <code>events.jsonl.gz</code> traces, and rendered by <code>tools/mesh3d.py</code>.
        Route-template dedup lives in <code>tools/mesh3d_extract.py</code>.</p>
    </div>
  </aside>
</div>

<footer>WSE-3 characterization study &middot; SDK 2.10 &middot; scenes rebuilt from decoded traces &middot; <span id="ftr"></span></footer>
</div>

<script>
const SCENES = __SCENES__;
const TOURS  = __TOURS__;
const $ = id => document.getElementById(id);
const esc = s => String(s).replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
const fmt = n => n == null ? '--' : Math.round(n).toLocaleString('en-US');

const rgb = a => a.map(h => [((h>>16)&255)/255, ((h>>8)&255)/255, (h&255)/255]);
/* wavelet colours: bright on the dark ground, deepened for the light one */
const WCOL_D = rgb([0xFFB454,0xFF8C6B,0x7FD4F5,0x4FD1C5,0xC9A7F0,0xF5E07A,0x7FE39B,0xFF9FC4,
                    0xFFC87A,0x9FB6FF,0x6FE0D0,0xE8A0F0,0xFFD9A0,0x8FE8FF,0xB8F08A,0xFF7F9F]);
const WCOL_L = rgb([0xB35F07,0xB8402A,0x0E6B96,0x07736A,0x67409B,0x876300,0x1B7540,0xBA3A6E,
                    0xA96B08,0x2C4CA3,0x0A685D,0x853791,0x9A6500,0x0C6079,0x3C7514,0xA82A4D]);
let WCOL = WCOL_D;

const PAL = {
  dark: {
    bg:0x131A28, plate:0x1A2333, grid:0x2B3A55,
    peHueApp:0.474, peSatApp:0.52, peHueSup:0.60, peSatSup:0.26,
    peLit:(f) => 0.15 + 0.33*f, peIdle:0.105,
    linkH:0.09, linkS:0.55, linkL:(t) => 0.20 + 0.32*t,
    scaf:[0.145,0.185,0.27], tileIdle:[0.115,0.148,0.215],
    tileHueC:0.474, tileHueS:0.60, tileLit:(f) => 0.14 + 0.44*f,
    add:true, headOp:1.0, trailOp:0.45, hopOp:0.92,
    sel:0x4A3208, amb:0x8496B8, ambI:0.78, keyI:0.82, rimI:0.38, wcol:WCOL_D,
    swatch:['#FFB454','#4FD1C5','#46587A','#7FD4F5']
  },
  light: {
    bg:0xEFF2F8, plate:0xE3E8F1, grid:0xC3CDDE,
    peHueApp:0.474, peSatApp:0.62, peHueSup:0.60, peSatSup:0.20,
    peLit:(f) => 0.50 - 0.26*f, peIdle:0.74,
    linkH:0.07, linkS:0.72, linkL:(t) => 0.74 - 0.34*t,
    scaf:[0.74,0.78,0.85], tileIdle:[0.845,0.870,0.915],
    tileHueC:0.474, tileHueS:0.60, tileLit:(f) => 0.80 - 0.46*f,
    add:false, headOp:0.95, trailOp:0.34, hopOp:0.88,
    sel:0x9A6A10, amb:0xFFFFFF, ambI:0.58, keyI:0.52, rimI:0.20, wcol:WCOL_L,
    swatch:['#B35F07','#07736A','#8A97AF','#0E6B96']
  }
};
let P = PAL.dark;

/* ============================ three.js scaffolding ======================= */
const cv = $('gl');
const renderer = new THREE.WebGLRenderer({canvas:cv, antialias:true, alpha:false});
renderer.setClearColor(P.bg, 1);
const scene = new THREE.Scene();
scene.fog = new THREE.Fog(P.bg, 26, 62);
const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 600);
const amb = new THREE.AmbientLight(P.amb, P.ambI); scene.add(amb);
const key = new THREE.DirectionalLight(0xFFE6C4, P.keyI); key.position.set(6, 14, 7); scene.add(key);
const rim = new THREE.DirectionalLight(0x5FA8FF, P.rimI); rim.position.set(-8, 5, -9); scene.add(rim);

const flowGrp = new THREE.Group(), trelGrp = new THREE.Group();
scene.add(flowGrp); scene.add(trelGrp);

/* ---- orbit: written here rather than pulled from a second CDN file ---- */
const orb = {r:22, th:Math.PI*0.24, ph:Math.PI*0.30, tx:0, ty:0, tz:0, drag:0, px:0, py:0};
function place(){
  const s = Math.sin(orb.th), c = Math.cos(orb.th);
  camera.position.set(orb.tx + orb.r*s*Math.sin(orb.ph),
                      orb.ty + orb.r*c,
                      orb.tz + orb.r*s*Math.cos(orb.ph));
  if (Math.abs(c) > 0.999) camera.up.set(0,0,-1); else camera.up.set(0,1,0);
  camera.lookAt(orb.tx, orb.ty, orb.tz);
}
cv.addEventListener('pointerdown', e => {
  orb.drag = (e.shiftKey || e.button === 2) ? 2 : 1;
  orb.px = e.clientX; orb.py = e.clientY;
  try{cv.setPointerCapture(e.pointerId);}catch(_){}
});
cv.addEventListener('pointerup', e => { orb.drag = 0; try{cv.releasePointerCapture(e.pointerId);}catch(_){} });
cv.addEventListener('pointermove', e => {
  if (!orb.drag) return;
  const dx = e.clientX - orb.px, dy = e.clientY - orb.py;
  orb.px = e.clientX; orb.py = e.clientY;
  if (orb.drag === 1){
    orb.ph -= dx * 0.006;
    orb.th = Math.max(0.035, Math.min(Math.PI*0.497, orb.th - dy*0.006));
  } else {
    const k = orb.r * 0.0016;
    orb.tx -= Math.cos(orb.ph)*dx*k;  orb.tz += Math.sin(orb.ph)*dx*k;
    orb.ty += dy*k;
  }
  place();
});
cv.addEventListener('wheel', e => {
  e.preventDefault();
  orb.r = Math.max(3, Math.min(180, orb.r * (1 + Math.sign(e.deltaY)*0.09)));
  place();
}, {passive:false});
cv.addEventListener('contextmenu', e => e.preventDefault());

/* ============================ state ==================================== */
let S, W, H, peList = [], peMesh = [], linkMesh = null, headPts = null, trailPts = null;
let cyc = 0, playing = true, speed = 4, loopOn = true, showLinks = true, showTrails = true;
let sel = null, tourIdx = -1, maxFlight = 1, maxBin = 1, hopStat = null;
let mode = 'flow';
let nLayers = 16, lStride = 2, focusL = -1;
let scafGrp = null, hopSeg = null, tileMesh = null, labEls = [], scafDirty = true;
let fineRows = [], fineMax = 1, peIdx = new Map(), occ = null, colorBy = 'compute';
let labBase = null, labFocus = null;

const BOX = 0.74;
const gx = x => x - (W-1)/2;
const gz = y => y - (H-1)/2;
const layerH = () => Math.max(0.42, 13/nLayers);

function clearGroup(g){
  while (g.children.length){
    const o = g.children.pop();
    if (o.geometry) o.geometry.dispose();
    if (o.material) (Array.isArray(o.material)?o.material:[o.material]).forEach(m=>m.dispose());
  }
}

/* ============================ shared textures ========================== */
let _tex = null;
function dotTex(){
  if (_tex) return _tex;
  const c = document.createElement('canvas'); c.width = c.height = 64;
  const x = c.getContext('2d');
  const g = x.createRadialGradient(32,32,0,32,32,32);
  g.addColorStop(0,'rgba(255,255,255,1)'); g.addColorStop(0.35,'rgba(255,255,255,.75)');
  g.addColorStop(1,'rgba(255,255,255,0)');
  x.fillStyle = g; x.fillRect(0,0,64,64);
  _tex = new THREE.CanvasTexture(c);
  return _tex;
}
function mkPoints(cap, size, opacity){
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(new Float32Array(cap*3), 3));
  g.setAttribute('color', new THREE.BufferAttribute(new Float32Array(cap*3), 3));
  g.setDrawRange(0, 0);
  return new THREE.Points(g, new THREE.PointsMaterial({
    size, vertexColors:true, transparent:true, opacity,
    blending: P.add ? THREE.AdditiveBlending : THREE.NormalBlending,
    depthWrite:false, sizeAttenuation:true, map:dotTex()
  }));
}
function mkSegs(cap, opacity){
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(new Float32Array(cap*6), 3));
  g.setAttribute('color', new THREE.BufferAttribute(new Float32Array(cap*6), 3));
  g.setDrawRange(0, 0);
  return new THREE.LineSegments(g, new THREE.LineBasicMaterial({
    vertexColors:true, transparent:true, opacity,
    blending: P.add ? THREE.AdditiveBlending : THREE.NormalBlending, depthWrite:false
  }));
}

/* ============================ scene build ============================== */
function build(name){
  S = SCENES.find(s => s.name === name) || SCENES[0];
  W = S.dims[0]; H = S.dims[1];
  peList = S.pes.slice();
  maxBin = 1;
  for (const p of peList) for (const v of (p.bin||[])) if (v > maxBin) maxBin = v;
  maxFlight = 1;
  for (const t of S.templates) maxFlight = Math.max(maxFlight, t.d[t.d.length-1]);

  /* modal transit delay, measured on this scene's own route shapes */
  const hist = new Map(); let tot = 0;
  for (const t of S.templates)
    for (let i = 0; i < t.d.length-1; i++){
      const d = t.d[i+1]-t.d[i]; hist.set(d, (hist.get(d)||0)+1); tot++;
    }
  let bd = 2, bn = 0;
  for (const [d,n] of hist) if (n > bn){ bd = d; bn = n; }
  hopStat = {mode:bd, n:bn, tot:tot};

  decodeFine();
  peIdx = new Map(peList.map((p, i) => [p.x + ',' + p.y, i]));
  buildFlow();
  scafDirty = true;
  cyc = S.start || 0;
  sel = peList.find(p => p.role === 'application') || peList[0];
  fitCamera(true);
  drawRibbon(); renderInsp(); renderScenes();
}

function decodeFine(){
  fineRows = []; fineMax = 1;
  if (!S.fine){ return; }
  const bin = atob(S.fine), n = peList.length, m = S.fnb;
  for (let i = 0; i < n; i++){
    const r = new Uint8Array(m);
    for (let j = 0; j < m; j++){
      const v = bin.charCodeAt(i*m + j); r[j] = v; if (v > fineMax) fineMax = v;
    }
    fineRows.push(r);
  }
}

function buildFlow(){
  clearGroup(flowGrp);
  const sub = new THREE.Group();
  const plate = new THREE.Mesh(new THREE.PlaneGeometry(W + 0.6, H + 0.6),
                               new THREE.MeshBasicMaterial({color:P.plate}));
  plate.rotation.x = -Math.PI/2; plate.position.y = -0.03; sub.add(plate);
  const gl = [];
  for (let x = 0; x <= W; x++) gl.push(gx(x)-0.5, 0, gz(0)-0.5, gx(x)-0.5, 0, gz(H-1)+0.5);
  for (let y = 0; y <= H; y++) gl.push(gx(0)-0.5, 0, gz(y)-0.5, gx(W-1)+0.5, 0, gz(y)-0.5);
  const gg = new THREE.BufferGeometry();
  gg.setAttribute('position', new THREE.Float32BufferAttribute(gl, 3));
  sub.add(new THREE.LineSegments(gg, new THREE.LineBasicMaterial({color:P.grid})));
  flowGrp.add(sub);

  const bg = new THREE.BoxGeometry(BOX, 1, BOX);
  bg.translate(0, 0.5, 0);
  peMesh = peList.map(p => new THREE.Mesh(bg, new THREE.MeshLambertMaterial({
    color: 0x808080, emissive: 0x000000 })));
  peMesh.forEach(m => flowGrp.add(m));

  const lp = [], lc = [];
  let maxL = 1;
  for (const l of S.links) maxL = Math.max(maxL, l[4]);
  for (const [ax, ay, bx, by, n] of S.links){
    const t = Math.log1p(n) / Math.log1p(maxL);
    lp.push(gx(ax), 0.035, gz(ay), gx(bx), 0.035, gz(by));
    const c = new THREE.Color().setHSL(P.linkH, P.linkS, P.linkL(t));
    lc.push(c.r, c.g, c.b, c.r, c.g, c.b);
  }
  const lg = new THREE.BufferGeometry();
  lg.setAttribute('position', new THREE.Float32BufferAttribute(lp, 3));
  lg.setAttribute('color', new THREE.Float32BufferAttribute(lc, 3));
  linkMesh = new THREE.LineSegments(lg, new THREE.LineBasicMaterial({vertexColors:true}));
  flowGrp.add(linkMesh);

  headPts  = mkPoints(6000, 0.40, P.headOp);
  trailPts = mkPoints(18000, 0.26, P.trailOp);
  flowGrp.add(trailPts); flowGrp.add(headPts);
}

/* ---- trellis: one mesh layer per sampled cycle, hops bridge the layers ---- */
function buildScaffold(){
  if (!scafGrp){ scafGrp = new THREE.Group(); trelGrp.add(scafGrp); }
  clearGroup(scafGrp);
  const gap = layerH();
  const op = [], oc = [];
  const x0 = gx(0)-0.5, x1 = gx(W-1)+0.5, z0 = gz(0)-0.5, z1 = gz(H-1)+0.5;
  for (let k = 0; k < nLayers; k++){
    const y = k*gap;
    op.push(x0,y,z0, x1,y,z0,  x1,y,z0, x1,y,z1,  x1,y,z1, x0,y,z1,  x0,y,z1, x0,y,z0);
    for (let i = 0; i < 8; i++) oc.push(P.scaf[0], P.scaf[1], P.scaf[2]);
  }
  const og = new THREE.BufferGeometry();
  og.setAttribute('position', new THREE.Float32BufferAttribute(op, 3));
  og.setAttribute('color', new THREE.Float32BufferAttribute(oc, 3));
  scafGrp.add(new THREE.LineSegments(og, new THREE.LineBasicMaterial({vertexColors:true})));

  /* one square per PE per cycle layer; colour is refilled every frame */
  const HS = 0.34, np = peList.length;
  const tp = new Float32Array(nLayers*np*12), ti = [];
  let v = 0, o = 0;
  for (let k = 0; k < nLayers; k++){
    const y = k*gap - 0.014;
    for (const p of peList){
      const X = gx(p.x), Z = gz(p.y);
      tp[o++]=X-HS; tp[o++]=y; tp[o++]=Z-HS;
      tp[o++]=X+HS; tp[o++]=y; tp[o++]=Z-HS;
      tp[o++]=X+HS; tp[o++]=y; tp[o++]=Z+HS;
      tp[o++]=X-HS; tp[o++]=y; tp[o++]=Z+HS;
      ti.push(v, v+1, v+2, v, v+2, v+3); v += 4;
    }
  }
  const tg = new THREE.BufferGeometry();
  tg.setAttribute('position', new THREE.BufferAttribute(tp, 3));
  tg.setAttribute('color', new THREE.BufferAttribute(new Float32Array(nLayers*np*12), 3));
  tg.setIndex(ti);
  tileMesh = new THREE.Mesh(tg, new THREE.MeshBasicMaterial({
    vertexColors:true, transparent:true, opacity:0.66,
    side:THREE.DoubleSide, depthWrite:false }));
  tileMesh.renderOrder = 1;
  scafGrp.add(tileMesh);
  occ = new Int32Array(nLayers*np);

  if (hopSeg){ trelGrp.remove(hopSeg); hopSeg.geometry.dispose(); hopSeg.material.dispose(); }
  hopSeg = mkSegs(24000, P.hopOp); trelGrp.add(hopSeg);
  hopSeg.renderOrder = 2;

  const host = $('llab');
  host.innerHTML = '';
  labEls = []; labBase = null; labFocus = null;
  for (let k = 0; k < nLayers; k++){
    const d = document.createElement('button');
    d.className = 'llb'; d.type = 'button';
    d.onclick = () => { focusL = (focusL === k ? -1 : k); syncTrelUI(); };
    host.appendChild(d); labEls.push(d);
  }
  scafDirty = false;
}

function lower(arr, t){
  let lo = 0, hi = arr.length;
  while (lo < hi){ const m = (lo+hi)>>1; if (arr[m][1] < t) lo = m+1; else hi = m; }
  return lo;
}

/* Colour every PE square. "compute" reads the fine dispatch bins, whose
   resolution is S.fstride cycles; "fabric" counts wavelet observations at that
   PE on that exact cycle, which the hop loop just accumulated into occ[]. */
function paintTiles(base){
  const col = tileMesh.geometry.attributes.color.array;
  const np = peList.length, idle = P.tileIdle;
  const c3 = new THREE.Color();
  let occMax = 1;
  if (colorBy === 'fabric') for (let i = 0; i < occ.length; i++)
    if (occ[i] > occMax) occMax = occ[i];
  for (let k = 0; k < nLayers; k++){
    const dim = (focusL < 0 || k === focusL) ? 1 : 0.28;
    const fb = Math.max(0, Math.min(S.fnb-1, Math.floor((base + k*lStride)/S.fstride)));
    for (let i = 0; i < np; i++){
      let r = idle[0], g = idle[1], b = idle[2];
      let f = 0;
      if (colorBy === 'fabric'){
        f = occ[k*np + i] / occMax;
      } else if (fineRows.length){
        f = fineRows[i][fb] / fineMax;
      }
      if (f > 0.001){
        c3.setHSL(peList[i].role === 'application' ? P.tileHueC : P.tileHueS,
                  peList[i].role === 'application' ? 0.58 : 0.30, P.tileLit(f));
        r = c3.r; g = c3.g; b = c3.b;
      }
      const o = (k*np + i)*12;
      for (let q = 0; q < 4; q++){
        col[o+q*3] = r*dim + idle[0]*(1-dim);
        col[o+q*3+1] = g*dim + idle[1]*(1-dim);
        col[o+q*3+2] = b*dim + idle[2]*(1-dim);
      }
    }
  }
  tileMesh.geometry.attributes.color.needsUpdate = true;
}

function fillTrellis(){
  if (scafDirty) buildScaffold();
  const base = Math.round(cyc), gap = layerH();
  const hp = hopSeg.geometry.attributes.position.array;
  const hc = hopSeg.geometry.attributes.color.array;
  const hcap = hp.length/6;
  const np = peList.length;
  let hn = 0;
  occ.fill(0);
  const span = nLayers*lStride;
  const wv = S.waves, tm = S.templates;
  let i = lower(wv, base - maxFlight - lStride);
  for (; i < wv.length && hn < hcap; i++){
    const w = wv[i];
    if (w[1] > base + span) break;
    const T = tm[w[0]], col = WCOL[w[2] % WCOL.length], pts = T.p, D = T.d;
    for (let j = 0; j < pts.length-1 && hn < hcap; j++){
      const k0 = Math.round((w[1] + D[j]   - base)/lStride);
      const k1 = Math.round((w[1] + D[j+1] - base)/lStride);
      if (k0 < 0 || k1 < 0 || k0 >= nLayers || k1 >= nLayers) continue;
      const f = (focusL < 0 || k0 === focusL || k1 === focusL) ? 1 : 0.13;
      const o = hn*6;
      hp[o  ] = gx(pts[j][0]);   hp[o+1] = k0*gap; hp[o+2] = gz(pts[j][1]);
      hp[o+3] = gx(pts[j+1][0]); hp[o+4] = k1*gap; hp[o+5] = gz(pts[j+1][1]);
      hc[o  ] = col[0]*f; hc[o+1] = col[1]*f; hc[o+2] = col[2]*f;
      hc[o+3] = col[0]*f; hc[o+4] = col[1]*f; hc[o+5] = col[2]*f;
      hn++;
      const a = peIdx.get(pts[j][0] + ',' + pts[j][1]);
      if (a !== undefined) occ[k0*np + a]++;
      if (j === pts.length-2){
        const b = peIdx.get(pts[j+1][0] + ',' + pts[j+1][1]);
        if (b !== undefined) occ[k1*np + b]++;
      }
    }
  }
  hopSeg.geometry.setDrawRange(0, hn*2);
  hopSeg.geometry.attributes.position.needsUpdate = true;
  hopSeg.geometry.attributes.color.needsUpdate = true;
  paintTiles(base);

  /* layer captions, projected to screen; text only rewritten when the base moves */
  const rect = cv.getBoundingClientRect();
  const v = new THREE.Vector3();
  const retext = (base !== labBase || focusL !== labFocus);
  for (let k = 0; k < nLayers; k++){
    const el = labEls[k];
    v.set(gx(0)-0.75, k*gap, gz(H-1)+0.75).project(camera);
    const sx = (v.x*0.5+0.5)*rect.width, sy = (-v.y*0.5+0.5)*rect.height;
    el.style.transform = `translate(${sx.toFixed(1)}px, ${(sy-9).toFixed(1)}px)`;
    el.style.opacity = (v.z < 1 && sx > -60 && sx < rect.width+60) ? '1' : '0';
    if (retext){
      el.textContent = fmt(S.cycles[0] + base + k*lStride);
      el.classList.toggle('on', k === focusL);
    }
  }
  labBase = base; labFocus = focusL;
  return hn;
}

/* ============================ flow fill ================================ */
function posAt(T, age){
  const d = T.d, p = T.p;
  if (age <= 0) return p[0];
  for (let k = 0; k < d.length-1; k++){
    if (age <= d[k+1]){
      const f = (age - d[k]) / Math.max(1, d[k+1] - d[k]);
      return [p[k][0] + (p[k+1][0]-p[k][0])*f, p[k][1] + (p[k+1][1]-p[k][1])*f];
    }
  }
  return p[p.length-1];
}
const TRAIL_N = 3, TRAIL_DT = 1.4;
function fillWaves(){
  const wv = S.waves, tm = S.templates;
  const hp = headPts.geometry.attributes.position.array;
  const hc = headPts.geometry.attributes.color.array;
  const tp = trailPts.geometry.attributes.position.array;
  const tc = trailPts.geometry.attributes.color.array;
  const hcap = hp.length/3, tcap = tp.length/3;
  let hn = 0, tn = 0;
  const back = maxFlight + Math.max(0, speed) + TRAIL_N*TRAIL_DT;
  let i = lower(wv, cyc - back);
  for (; i < wv.length && hn < hcap; i++){
    const w = wv[i];
    if (w[1] > cyc) break;
    const T = tm[w[0]], life = T.d[T.d.length-1], age = cyc - w[1];
    if (age > life + 0.6) continue;
    const col = WCOL[w[2] % WCOL.length];
    const a = posAt(T, age);
    hp[hn*3] = gx(a[0]); hp[hn*3+1] = 0.30; hp[hn*3+2] = gz(a[1]);
    hc[hn*3] = col[0]; hc[hn*3+1] = col[1]; hc[hn*3+2] = col[2];
    hn++;
    if (!showTrails) continue;
    for (let k = 1; k <= TRAIL_N && tn < tcap; k++){
      const ag = age - k*TRAIL_DT;
      if (ag < 0) break;
      const b = posAt(T, ag), f = 1 - k/(TRAIL_N+1);
      tp[tn*3] = gx(b[0]); tp[tn*3+1] = 0.30; tp[tn*3+2] = gz(b[1]);
      tc[tn*3] = col[0]*f; tc[tn*3+1] = col[1]*f; tc[tn*3+2] = col[2]*f;
      tn++;
    }
  }
  headPts.geometry.setDrawRange(0, hn);
  trailPts.geometry.setDrawRange(0, showTrails ? tn : 0);
  headPts.geometry.attributes.position.needsUpdate = true;
  headPts.geometry.attributes.color.needsUpdate = true;
  trailPts.geometry.attributes.position.needsUpdate = true;
  trailPts.geometry.attributes.color.needsUpdate = true;
  return hn;
}
const binAt = c => Math.max(0, Math.min(S.nb-1, Math.floor(c / S.stride)));
function fillPEs(){
  const b = binAt(cyc);
  for (let i = 0; i < peList.length; i++){
    const p = peList[i], m = peMesh[i];
    const raw = (p.bin && p.bin.length) ? p.bin[b] : 0;
    const fpv = (p.fpbin && p.fpbin.length) ? p.fpbin[b] : 0;
    m.position.set(gx(p.x), 0, gz(p.y));
    m.scale.set(1, 0.09 + 2.5*Math.pow(raw/maxBin, 0.65), 1);
    const share = raw ? fpv/raw : 0, comp = share > 0.02;
    const lit = raw ? P.peLit(Math.pow(raw/maxBin, 0.5)) : P.peIdle;
    m.material.color.setHSL(comp ? P.peHueApp : P.peHueSup,
                            comp ? P.peSatApp : P.peSatSup, lit);
    m.material.emissive.setHex(sel && p.x === sel.x && p.y === sel.y ? P.sel : 0x000000);
  }
}

/* ============================ mode / camera ============================ */
function fitCamera(reset){
  const m = Math.max(W, H);
  if (mode === 'trellis'){
    const h = (nLayers-1)*layerH();
    orb.ty = h/2;
    if (reset){ orb.r = Math.max(m*1.6, h*1.5); orb.th = Math.PI*0.36; orb.ph = Math.PI*0.30; }
  } else {
    orb.ty = 0.6;
    if (reset){ orb.r = Math.max(11, m*1.9); orb.th = Math.PI*0.24; orb.ph = Math.PI*0.30; }
  }
  scene.fog.near = orb.r*1.05; scene.fog.far = orb.r*3.2;
  place();
}
function setMode(m){
  mode = m;
  flowGrp.visible = (m === 'flow');
  trelGrp.visible = (m === 'trellis');
  $('mFlow').setAttribute('aria-pressed', String(m === 'flow'));
  $('mTrel').setAttribute('aria-pressed', String(m === 'trellis'));
  $('flowOpts').hidden = (m !== 'flow');
  $('trelOpts').hidden = (m !== 'trellis');
  $('llab').style.display = (m === 'trellis') ? '' : 'none';
  if (m === 'trellis' && scafDirty) buildScaffold();
  fitCamera(true);
  syncTrelUI(); renderLegend(); renderScenes();
}
function syncTrelUI(){
  $('lN').textContent = nLayers + ' layers';
  $('lS').textContent = 'stride ' + lStride;
  $('cBy').textContent = 'colour: ' + colorBy;
  $('lClr').hidden = (focusL < 0);
}
$('cBy').onclick = () => { colorBy = (colorBy === 'compute' ? 'fabric' : 'compute');
  syncTrelUI(); renderLegend(); };
/* ---- viewport palette: follows the page theme until the reader overrides it ---- */
let viewOverride = null;
function pageDark(){
  const a = document.documentElement.getAttribute('data-theme');
  if (a === 'dark') return true;
  if (a === 'light') return false;
  return matchMedia('(prefers-color-scheme: dark)').matches;
}
function applyViewTheme(rebuild){
  const dark = (viewOverride == null) ? pageDark() : viewOverride;
  P = dark ? PAL.dark : PAL.light;
  WCOL = P.wcol;
  renderer.setClearColor(P.bg, 1);
  scene.fog.color.setHex(P.bg);
  amb.color.setHex(P.amb); amb.intensity = P.ambI;
  key.intensity = P.keyI; rim.intensity = P.rimI;
  const vb = $('viewbox');
  vb.classList.toggle('vdark', dark);
  vb.classList.toggle('vlight', !dark);
  $('vBright').setAttribute('aria-pressed', String(!dark));
  if (rebuild && S){
    buildFlow();
    scafDirty = true;
    if (mode === 'trellis') buildScaffold();
    labBase = null;
  }
}
$('vBright').onclick = () => {
  viewOverride = !((viewOverride == null) ? pageDark() : viewOverride);
  applyViewTheme(true);
};
matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
  if (viewOverride == null) applyViewTheme(true);
});
new MutationObserver(() => { if (viewOverride == null) applyViewTheme(true); })
  .observe(document.documentElement, {attributes:true, attributeFilter:['data-theme']});

$('mFlow').onclick = () => setMode('flow');
$('mTrel').onclick = () => setMode('trellis');
$('lN').onclick = () => { nLayers = ({8:16,16:24,24:32,32:8})[nLayers] || 16;
  focusL = -1; scafDirty = true; buildScaffold(); fitCamera(true); syncTrelUI(); };
$('lS').onclick = () => { lStride = ({1:2,2:4,4:8,8:1})[lStride] || 2; syncTrelUI(); };
$('lClr').onclick = () => { focusL = -1; syncTrelUI(); };

function camPreset(kind){
  const m = Math.max(W,H), h = (nLayers-1)*layerH();
  const R = mode === 'trellis' ? Math.max(m*1.6, h*1.5) : Math.max(11, m*1.9);
  if (kind === 'vTop'){  orb.th = 0.05; orb.ph = 0; orb.r = mode==='trellis' ? R*0.9 : m*1.55; }
  if (kind === 'vIso'){  orb.th = Math.PI*(mode==='trellis'?0.36:0.24); orb.ph = Math.PI*0.30; orb.r = R; }
  if (kind === 'vEdge'){ orb.th = Math.PI*0.492; orb.ph = Math.PI*0.5; orb.r = R*0.95; }
  ['vTop','vIso','vEdge'].forEach(k => $(k).setAttribute('aria-pressed', String(k === kind)));
  fitCamera(false);
}
['vTop','vIso','vEdge'].forEach(k => $(k).onclick = () => camPreset(k));

/* ============================ picking ================================== */
const ray = new THREE.Raycaster();
cv.addEventListener('click', e => {
  if (mode !== 'flow') return;
  const r = cv.getBoundingClientRect();
  const v = new THREE.Vector2(((e.clientX-r.left)/r.width)*2-1, -((e.clientY-r.top)/r.height)*2+1);
  ray.setFromCamera(v, camera);
  const hit = ray.intersectObjects(peMesh, false)[0];
  if (hit){ sel = peList[peMesh.indexOf(hit.object)]; renderInsp(); drawRibbon(); }
});

/* ============================ panels =================================== */
function renderScenes(){
  $('scenes').innerHTML = SCENES.map(s =>
    `<button class="sc" data-n="${s.name}" aria-current="${s.name===S.name}">${esc(s.title)}
       <em>${fmt(s.cycles[1]-s.cycles[0]+1)} cyc &middot; ${s.pes.length} PE &middot; ${fmt(s.counts.waves_kept)} pkt</em>
     </button>`).join('');
  $('scenes').querySelectorAll('.sc').forEach(b =>
    b.onclick = () => { tourIdx = -1; build(b.dataset.n); if (mode==='trellis') buildScaffold(); renderTour(); });
  $('hud1').innerHTML = `<b>${esc(S.title)}</b>`;
  $('tlabel').textContent = 'cycles ' + fmt(S.cycles[0]) + ' – ' + fmt(S.cycles[1]) +
    (S.counts.wave_decimation > 1 ? '  ·  drawing 1 packet in ' + S.counts.wave_decimation : '');
  $('rl0').textContent = fmt(S.cycles[0]);
  $('rl1').textContent = fmt(S.cycles[1]);
  $('rlmid').textContent = 'dispatches per ' + fmt(S.stride) + '-cycle bin, all PEs';
  $('rdhop').textContent = hopStat ? hopStat.mode.toFixed(1) : '--';
  $('rdcycl').textContent = mode === 'trellis' ? 'bottom layer' : 'cycle';
  $('rdflyl').textContent = mode === 'trellis' ? 'hops drawn' : 'in flight';
  renderLegend();
}
function renderLegend(){
  const sw = P.swatch;
  const res = S ? (colorBy === 'fabric'
        ? 'exact, that cycle'
        : 'dispatches per ' + S.fstride + '-cycle bin') : '';
  $('legend').innerHTML = mode === 'trellis'
    ? `<span><i class="bar" style="background:${sw[0]}"></i>one hop, cycle&nbsp;t to t+${hopStat?hopStat.mode:2}</span>
       <span><i style="background:${sw[1]}"></i>square = one PE on that cycle's plane, brighter is busier (${esc(res)})</span>
       <span>time runs upward &middot; click a cycle tag to isolate one plane</span>`
    : `<span><i style="background:${sw[0]}"></i>wavelet in flight</span>
       <span><i style="background:${sw[1]}"></i>PE doing FP arithmetic</span>
       <span><i style="background:${sw[2]}"></i>PE running memcpy / control</span>
       <span>bar height = dispatches this bin</span>`;
  $('hint').textContent = mode === 'trellis'
    ? 'drag rotate · wheel zoom · try Edge for a pure space-time view'
    : 'drag rotate · wheel zoom · shift-drag pan · click a PE';
}
function renderInsp(){
  if (!sel){ $('insp').innerHTML = ''; return; }
  const app = sel.role === 'application';
  const mx = sel.top.filter(t => t[0]), tot = mx.reduce((a,t)=>a+t[1],0) || 1;
  $('insp').innerHTML =
    `<div class="eyebrow">Selected PE</div>
     <h3 class="mono">(${sel.x},&nbsp;${sel.y})</h3>
     <div class="pill" style="color:${app?'var(--compute)':'var(--support)'}">${app?'application':'support / memcpy'}</div>
     <div style="margin-top:12px">
       <div class="kv"><span>dispatches</span><b>${fmt(sel.disp)}</b></div>
       <div class="kv"><span>FP arithmetic</span><b>${fmt(sel.fp)}</b></div>
       <div class="kv"><span>DSD elements</span><b>${fmt(sel.elem)}</b></div>
       <div class="kv"><span>wavelets seen</span><b>${fmt(sel.wav)}</b></div>
       <div class="kv"><span>decode&rarr;execute</span><b>${sel.stall==null?'--':sel.stall+' cyc'}</b></div>
     </div>
     <div class="eyebrow" style="margin-top:16px">Activity over the run</div>
     <canvas id="spark" style="width:100%;height:44px;display:block"></canvas>
     <div class="eyebrow" style="margin-top:14px">Instruction mix</div>
     <div>${mx.map(t => `<div class="mixrow"><div>${esc(t[0])}
        <div class="mixbar"><i style="width:${(100*t[1]/tot).toFixed(1)}%"></i></div></div>
        <b>${(100*t[1]/tot).toFixed(0)}%</b></div>`).join('') ||
        '<div class="mono" style="font-size:11px;color:var(--dim)">no dispatches</div>'}</div>`;
  drawSpark();
}
const css = v => getComputedStyle(document.documentElement).getPropertyValue(v).trim();
function drawSpark(){
  const c = $('spark'); if (!c || !sel) return;
  const dpr = devicePixelRatio || 1, w = c.clientWidth, h = 44;
  if (!w) return;
  c.width = w*dpr; c.height = h*dpr;
  const x = c.getContext('2d'); x.setTransform(dpr,0,0,dpr,0,0); x.clearRect(0,0,w,h);
  const b = sel.bin || [], f = sel.fpbin || [];
  if (!b.length){ x.fillStyle = css('--dim'); x.font = '10px "IBM Plex Mono",monospace';
    x.fillText('no dispatches', 0, 20); return; }
  let mx = 1; for (const v of b) if (v > mx) mx = v;
  const bw = w / b.length;
  for (let i = 0; i < b.length; i++){
    const hh = (b[i]/mx)*(h-8);
    x.fillStyle = css('--support'); x.fillRect(i*bw, h-hh, Math.max(1, bw-0.4), hh);
    if (f[i]){ const fh = (f[i]/mx)*(h-8);
      x.fillStyle = css('--compute'); x.fillRect(i*bw, h-fh, Math.max(1, bw-0.4), fh); }
  }
  const px = (binAt(cyc)/b.length)*w;
  x.strokeStyle = css('--live'); x.lineWidth = 1.5;
  x.beginPath(); x.moveTo(px, 0); x.lineTo(px, h); x.stroke();
}
function drawRibbon(){
  const c = $('ribcv'), box = $('ribbon');
  const dpr = devicePixelRatio || 1, w = box.clientWidth, h = box.clientHeight;
  if (!w) return;
  c.width = w*dpr; c.height = h*dpr; c.style.width = w+'px'; c.style.height = h+'px';
  const x = c.getContext('2d'); x.setTransform(dpr,0,0,dpr,0,0); x.clearRect(0,0,w,h);
  const nb = S.nb;
  const tot = new Array(nb).fill(0), fpt = new Array(nb).fill(0), selb = new Array(nb).fill(0);
  for (const p of peList){
    const b = p.bin || [], f = p.fpbin || [];
    const isS = sel && p.x === sel.x && p.y === sel.y;
    for (let i = 0; i < nb; i++){
      tot[i] += b[i]||0; fpt[i] += f[i]||0;
      if (isS) selb[i] += b[i]||0;
    }
  }
  let mx = 1; for (const v of tot) if (v > mx) mx = v;
  const bw = w/nb;
  for (let i = 0; i < nb; i++){
    const hh = (tot[i]/mx)*(h-4);
    x.fillStyle = css('--support'); x.fillRect(i*bw, h-hh, Math.max(0.6, bw-0.3), hh);
    if (fpt[i]){ const fh = (fpt[i]/mx)*(h-4);
      x.fillStyle = css('--compute'); x.fillRect(i*bw, h-fh, Math.max(0.6, bw-0.3), fh); }
  }
  if (sel){
    x.strokeStyle = css('--ink'); x.globalAlpha = .55; x.lineWidth = 1; x.beginPath();
    for (let i = 0; i < nb; i++){
      const yy = h - (selb[i]/mx)*(h-4);
      i ? x.lineTo(i*bw+bw/2, yy) : x.moveTo(i*bw+bw/2, yy);
    }
    x.stroke(); x.globalAlpha = 1;
  }
  const span = S.stride*S.nb;
  const px = (cyc/span)*w;
  if (mode === 'trellis'){
    const ww = Math.max(2, (nLayers*lStride/span)*w);
    x.fillStyle = css('--live'); x.globalAlpha = .22; x.fillRect(px, 0, ww, h); x.globalAlpha = 1;
  }
  x.strokeStyle = css('--live'); x.lineWidth = 2;
  x.beginPath(); x.moveTo(px, 0); x.lineTo(px, h); x.stroke();
  x.fillStyle = css('--live'); x.fillRect(px-3, 0, 6, 3);
}
function ribSeek(e){
  const r = $('ribbon').getBoundingClientRect();
  cyc = Math.max(0, Math.min(S.stride*S.nb-1, ((e.clientX-r.left)/r.width)*S.stride*S.nb));
  drawRibbon(); drawSpark();
}
$('ribbon').addEventListener('pointerdown', e => {
  ribSeek(e); try{$('ribbon').setPointerCapture(e.pointerId);}catch(_){}
  $('ribbon').onpointermove = ev => { if (ev.buttons) ribSeek(ev); };
});
$('ribbon').addEventListener('pointerup', e => {
  $('ribbon').onpointermove = null;
  try{$('ribbon').releasePointerCapture(e.pointerId);}catch(_){}
});

/* ============================ tour ===================================== */
function renderTour(){
  $('tour').innerHTML = TOURS.map((t,i) =>
    `<button class="tstep" data-i="${i}" aria-current="${i===tourIdx}">
       <b>${esc(t.tag)}</b>${esc(t.text)}</button>`).join('');
  $('tour').querySelectorAll('.tstep').forEach(b => b.onclick = () => goTour(+b.dataset.i));
}
function goTour(i){
  const t = TOURS[i]; if (!t) return;
  tourIdx = i;
  if (!S || S.name !== t.scene) build(t.scene);
  if (t.layers){ nLayers = t.layers; scafDirty = true; }
  if (t.stride){ lStride = t.stride; }
  focusL = -1;
  setMode(t.mode || 'flow');
  cyc = t.cycle - S.cycles[0];
  if (t.pe) sel = peList.find(p => p.x === t.pe[0] && p.y === t.pe[1]) || sel;
  if (t.cam){ orb.th = t.cam[0]; orb.ph = t.cam[1]; orb.r = t.cam[2]; place(); }
  if (t.speed != null) setSpeed(t.speed);
  playing = t.play !== false; $('play').textContent = playing ? 'Pause' : 'Play';
  renderTour(); renderInsp(); drawRibbon();
}

/* ============================ transport ================================ */
const SPEEDS = [0.25, 1, 4, 20, 100];
function setSpeed(v){
  speed = v;
  $('spd').querySelectorAll('button').forEach(b =>
    b.setAttribute('aria-pressed', String(+b.dataset.v === v)));
}
$('spd').innerHTML = SPEEDS.map(v => `<button data-v="${v}">${v}&times;</button>`).join('');
$('spd').querySelectorAll('button').forEach(b => b.onclick = () => setSpeed(+b.dataset.v));
$('play').onclick = () => { playing = !playing; $('play').textContent = playing ? 'Pause' : 'Play'; };
$('loop').onclick = () => { loopOn = !loopOn; $('loop').setAttribute('aria-pressed', String(loopOn)); };
$('tLinks').onclick = () => { showLinks = !showLinks; $('tLinks').setAttribute('aria-pressed', String(showLinks)); };
$('tTrails').onclick = () => { showTrails = !showTrails; $('tTrails').setAttribute('aria-pressed', String(showTrails)); };
addEventListener('keydown', e => {
  if (e.target.tagName === 'INPUT') return;
  if (e.code === 'Space'){ e.preventDefault(); $('play').click(); }
  const st = mode === 'trellis' ? lStride : 1;
  if (e.key === 'ArrowRight'){ cyc += e.shiftKey ? st*20 : st; playing = false; $('play').textContent='Play'; }
  if (e.key === 'ArrowLeft'){ cyc = Math.max(0, cyc - (e.shiftKey ? st*20 : st)); playing = false; $('play').textContent='Play'; }
});

/* ============================ loop ===================================== */
function resize(){
  const b = cv.parentElement.getBoundingClientRect();
  renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 2));
  renderer.setSize(b.width, b.height, false);
  camera.aspect = b.width / Math.max(1, b.height);
  camera.updateProjectionMatrix();
  drawRibbon(); drawSpark();
}
addEventListener('resize', resize);

let last = performance.now(), tick = 0;
function frame(now){
  const dt = Math.min(0.1, (now - last)/1000); last = now;
  if (playing){
    cyc += speed * dt * 60;
    const end = S.stride * S.nb;
    if (cyc > end){ cyc = loopOn ? 0 : end; if (!loopOn){ playing = false; $('play').textContent='Play'; } }
  }
  let n;
  if (mode === 'flow'){ fillPEs(); n = fillWaves(); if (linkMesh) linkMesh.visible = showLinks; }
  else { n = fillTrellis(); }
  $('rdcyc').textContent = fmt(S.cycles[0] + cyc);
  $('rdfly').textContent = fmt(n);
  if (mode === 'trellis'){
    const b = Math.round(cyc);
    $('hud2').textContent = nLayers + ' cycle layers · ' + fmt(S.cycles[0]+b) + ' to ' +
      fmt(S.cycles[0]+b+(nLayers-1)*lStride) + ' · stride ' + lStride +
      (focusL >= 0 ? ' · isolating layer ' + focusL : '');
  } else {
    $('hud2').textContent = S.dims[0] + ' × ' + S.dims[1] + ' fabric · ' +
      S.counts.templates + ' route shapes · ' + fmt(S.counts.wavelet) + ' observations';
  }
  renderer.render(scene, camera);
  if (++tick % 4 === 0){ drawRibbon(); drawSpark(); }
  requestAnimationFrame(frame);
}

/* ============================ boot ===================================== */
$('stbl').innerHTML =
  '<thead><tr><th>Scene</th><th>Fabric</th><th class="n">Cycles</th><th class="n">Dispatches</th>' +
  '<th class="n">Wavelet obs.</th><th class="n">Packets</th><th class="n">Route shapes</th></tr></thead><tbody>' +
  SCENES.map(s => `<tr><td>${esc(s.title)}</td><td class="mono">${s.dims[0]}×${s.dims[1]}</td>
    <td class="n">${fmt(s.cycles[1]-s.cycles[0]+1)}</td><td class="n">${fmt(s.counts.dispatch)}</td>
    <td class="n">${fmt(s.counts.wavelet)}</td><td class="n">${fmt(s.counts.idents)}</td>
    <td class="n">${fmt(s.counts.templates)}</td></tr>`).join('') + '</tbody>';
$('ftr').textContent = __STAMP__;

if (matchMedia('(prefers-reduced-motion: reduce)').matches) playing = false;
applyViewTheme(false);
build(__START__);
setMode('flow');
renderTour();
setSpeed(4);
$('play').textContent = playing ? 'Pause' : 'Play';
resize();
requestAnimationFrame(frame);
</script>
