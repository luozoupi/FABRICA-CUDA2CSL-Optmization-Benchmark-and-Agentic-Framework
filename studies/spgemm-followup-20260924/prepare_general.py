"""Generate fixed one-PE full SpGEMM accumulator experiments."""
import datetime,hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent
if (ROOT/'general-registration.json').exists():raise RuntimeError('Already prepared')
registration=json.loads((ROOT/'registration.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for name,width in [('full_row',16),('tile4',4)]:
 d=ROOT/'general'/name;d.mkdir(parents=True)
 arrays=dict(ap=('u32',17),aj=('u32',256),av=('f32',256),bp=('u32',17),bj=('u32',256),bv=('f32',256),cp=('u32',17),cj=('u32',260),cv=('f32',260),count=('u16',1),status=('u16',1),limit=('u16',1),time_words=('u16',6))
 declarations='\n'.join(f'var {n} = @zeros([{size}]{typ});\nvar ptr_{n}: [*]{typ} = &{n};' for n,(typ,size) in arrays.items())
 exports='\n'.join(f'@export_symbol(ptr_{n}, "{n}");' for n in arrays)
 code='''param memcpy_params;
const sys = @import_module("<memcpy/memcpy>", memcpy_params);
const clock = @import_module("<time>");
const N: u16 = 16;
const WIDTH: u16 = WIDTH_VALUE;
DECLARATIONS
var acc = @zeros([WIDTH]f32);
var seen = @zeros([WIDTH]u16);
var t0 = @zeros([3]u16);
var t1 = @zeros([3]u16);
const acc_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |x|{WIDTH} -> acc[x] });
fn kernel() void {
status[0] = 0;
count[0] = 0;
var output_count: u16 = 0;
var i: u16 = 0;
while (i < N) : (i += 1) {
cp[i] = @as(u32,output_count);
var lo: u16 = 0;
while (lo < N) : (lo += WIDTH) {
@fmovs(acc_dsd, @as(f32,0.0));
var t: u16 = 0;
while (t < WIDTH) : (t += 1) { seen[t] = 0; }
var p: u16 = @as(u16,ap[i]);
const pe: u16 = @as(u16,ap[i+1]);
while (p < pe) : (p += 1) {
const k: u16 = @as(u16,aj[p]);
const aval: f32 = av[p];
var q: u16 = @as(u16,bp[k]);
const qe: u16 = @as(u16,bp[k+1]);
while (q < qe) : (q += 1) {
const j: u16 = @as(u16,bj[q]);
if (j >= lo and j < lo + WIDTH) {
const local_j: u16 = j - lo;
acc[local_j] += aval * bv[q];
seen[local_j] = 1;
}
}
}
t = 0;
while (t < WIDTH) : (t += 1) {
if (seen[t] != 0) {
if (output_count >= limit[0]) {
status[0] = 1;
count[0] = output_count;
return;
}
cj[output_count] = @as(u32,lo+t);
cv[output_count] = acc[t];
output_count += 1;
}
}
}
cp[i+1] = @as(u32,output_count);
}
count[0] = output_count;
}
fn stamp_out() void {
time_words[0]=t0[0]; time_words[1]=t0[1]; time_words[2]=t0[2];
time_words[3]=t1[0]; time_words[4]=t1[1]; time_words[5]=t1[2];
sys.unblock_cmd_stream();
}
fn enable_timer() void { clock.enable_tsc(); sys.unblock_cmd_stream(); }
fn compute() void { clock.get_timestamp(&t0); kernel(); clock.get_timestamp(&t1); stamp_out(); }
comptime {
EXPORTS
@export_symbol(compute);
@export_symbol(enable_timer);
}
'''.replace('WIDTH_VALUE',str(width)).replace('DECLARATIONS',declarations).replace('EXPORTS',exports)
 (d/'pe.csl').write_text(code)
 layout='const memcpy = @import_module("<memcpy/get_params>", .{ .width=1, .height=1 });\nlayout {\n@set_rectangle(1,1);\n@set_tile_code(0,0,"pe.csl", .{ .memcpy_params=memcpy.get_params(0) });\n'
 layout+='\n'.join(f'@export_name("{n}", [*]{typ}, true);' for n,(typ,size) in arrays.items())
 layout+='\n@export_name("compute", fn()void);\n@export_name("enable_timer", fn()void);\n}\n';(d/'layout.csl').write_text(layout)
 shutil.copy2(ROOT/'general_host.py',d/'host.py');shutil.copy2(ROOT/'inputs.py',d/'inputs.py')
 cfg=dict(id='general-'+name,variant=name,application_pes=1,M=16,K=16,N=16,tile_width=width,accumulator_bytes=width*6,output_capacity=256,guard_elements=4,patterns=registration['general_patterns'],repetitions=3)
 cfg['source_hashes']={f:sha(d/f) for f in ('pe.csl','layout.csl','host.py','inputs.py')};(d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
(ROOT/'general-registration.json').write_text(json.dumps(dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),parent_registration_sha256=sha(ROOT/'registration.json'),files={str(p.relative_to(ROOT)):sha(p) for p in (ROOT/'general').rglob('*') if p.is_file()}),indent=2)+'\n')
print('Prepared full SpGEMM with',16,'and',4,'accumulator slots')
