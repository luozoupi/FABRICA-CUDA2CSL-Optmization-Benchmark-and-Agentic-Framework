#!/usr/bin/env cs_python
"""Run the DSD extent probe. Correctness is not the point; the trace is."""
import argparse
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

parser = argparse.ArgumentParser()
parser.add_argument("--name", default="out")
parser.add_argument("--cmaddr")
args = parser.parse_args()

runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
runner.load()
runner.run()
runner.call("compute", [], nonblock=False)
# memcpy is 32-bit only, so read the f16 array as packed u32 pairs.
raw = np.zeros(1024, dtype=np.uint32)
runner.memcpy_d2h(raw, runner.get_id("C"), 0, 0, 1, 1, 1024,
                  streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
                  order=MemcpyOrder.ROW_MAJOR, nonblock=False)
runner.stop()
print("ran; C[0:8] =", raw.view(np.float16)[:8])
