import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
    manifest=json.loads((ROOT/'inputs/manifest.json').read_text());builds=[]
    for n in (1,4,16,64):
        for variant in ('scalar','descriptor','hoisted'):
            name=f'{variant}-n{n}';d=ROOT/'wse'/name;d.mkdir(parents=True,exist_ok=False)
            c=dict(id=name,M=32,K=64,N=n,capacity=1024,variant=variant,inputs=[])
            buffers=dict(row_ptr=('u32',33),col_idx=('u32',1024),values=('f32',1024),B=('f32',64*n),C=('f32',32*n),time_words=('u16',6))
            pe='param memcpy_params;\nconst sys=@import_module("<memcpy/memcpy>",memcpy_params);\nconst clock=@import_module("<time>");\n'+f'const N:u16={n};\n'
            pe+='\n'.join(f'var {b}=@zeros([{size}]{typ});\nvar ptr_{b}:[*]{typ}=&{b};'for b,(typ,size)in buffers.items())
            pe+='\nvar t0=@zeros([3]u16);\nvar t1=@zeros([3]u16);\nconst all_c=@get_dsd(mem1d_dsd,.{.tensor_access=|x|{32*N}->C[x]});\n'
            cd='var cd=@get_dsd(mem1d_dsd,.{.base_address=&C,.extent=N});\ncd=@increment_dsd_offset(cd,@as(i16,i*N),f32);\n'
            inner='const k:u16=@as(u16,col_idx[p]);\n'
            if variant=='scalar':inner+='var j:u16=0;while(j<N):(j+=1){C[i*N+j]+=values[p]*B[k*N+j];}\n'
            else:
                if variant=='descriptor':inner+=cd
                inner+='var bd=@get_dsd(mem1d_dsd,.{.base_address=&B,.extent=N});\nbd=@increment_dsd_offset(bd,@as(i16,k*N),f32);\n@fmacs(cd,cd,bd,values[p]);\n'
            pe+='fn compute() void {\nclock.get_timestamp(&t0);\n@fmovs(all_c,@as(f32,0.0));\nvar i:u16=0;while(i<32):(i+=1){\n'
            if variant=='hoisted':pe+=cd
            pe+='var p:u16=@as(u16,row_ptr[i]);\nconst end:u16=@as(u16,row_ptr[i+1]);\nwhile(p<end):(p+=1){\n'+inner+'}\n}\nclock.get_timestamp(&t1);\n'
            pe+='\n'.join(f'time_words[{i}]=t{0 if i<3 else 1}[{i%3}];'for i in range(6))+'\nsys.unblock_cmd_stream();\n}\nfn enable_timer() void {clock.enable_tsc();sys.unblock_cmd_stream();}\ncomptime {\n'
            pe+='\n'.join(f'@export_symbol(ptr_{b},"{b}");'for b in buffers)+'\n@export_symbol(compute);@export_symbol(enable_timer);}\n'
            layout='const memcpy=@import_module("<memcpy/get_params>",.{.width=1,.height=1});\nlayout {\n@set_rectangle(1,1);\n@set_tile_code(0,0,"pe.csl",.{.memcpy_params=memcpy.get_params(0)});\n'
            layout+='\n'.join(f'@export_name("{b}",[*]{typ},true);'for b,(typ,size)in buffers.items())+'\n@export_name("compute",fn()void);@export_name("enable_timer",fn()void);}\n'
            (d/'pe.csl').write_text(pe);(d/'layout.csl').write_text(layout);shutil.copy2(ROOT/'wse_host.py',d/'host.py')
            for case in manifest['cases']:
                if not case['shared_wse'] or case['N']!=n:continue
                dest=d/'inputs'/case['id'];dest.mkdir(parents=True)
                for src in list((ROOT/case['matrix_path']).glob('*.bin'))+list((ROOT/case['dense_path']).glob('*.bin')):shutil.copy2(src,dest/src.name)
                c['inputs'].append(dict(id=case['id'],family=case['family'],input_hashes={p.name:sha(p)for p in dest.glob('*.bin')}))
            c['source_hashes']={f:sha(d/f)for f in ('pe.csl','layout.csl','host.py')}
            (d/'case.json').write_text(json.dumps(c,indent=2)+'\n');builds.append(c)
    (ROOT/'wse-manifest.json').write_text(json.dumps(builds,indent=2)+'\n');print(len(builds),'builds')
if __name__=='__main__':main()
