#!/usr/bin/env python3
"""Wrap a probe body into the standard memcpy pe skeleton."""
import sys
body = open(sys.argv[1]).read()
open("p.csl", "w").write(f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
{body}
fn compute() void {{ f(); @activate(EXIT); }}
task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}
comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(compute);
}}
""")
