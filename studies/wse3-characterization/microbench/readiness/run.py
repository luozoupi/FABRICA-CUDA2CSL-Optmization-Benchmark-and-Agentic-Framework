#!/usr/bin/env python3
"""One simulator execution; host payloads and readbacks retain exact f32 bits."""
import json
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def main():
    spec = json.loads(Path('case.json').read_text())
    n = spec['words']
    # Distinct finite signed values; nonzero low halves expose truncated decoders.
    payload = np.array([(0x3f800101 + i * 0x00100101) | ((i % 2) << 31)
                        for i in range(n)], np.uint32)
    local = np.array([8.0 + i / 8.0 for i in range(n)], np.float32).view(np.uint32)
    expected = (payload.view(np.float32) + local.view(np.float32)).astype(np.float32).view(np.uint32)
    rt = SdkRuntime('out')
    rt.load(); rt.run()
    options = dict(streaming=False, data_type=MemcpyDataType.MEMCPY_32BIT,
                   order=MemcpyOrder.ROW_MAJOR, nonblock=False)
    observed = {}
    try:
        rt.memcpy_h2d(rt.get_id('buf'), payload, 0, 0, 1, 1, n, **options)
        rt.memcpy_h2d(rt.get_id('loc'), local, 1, 0, 1, 1, n, **options)
        rt.call('run', [], nonblock=False)
        for name, x in [('buf', 0), ('buf', 1), ('loc', 1), ('res', 1)]:
            data = np.zeros(n, np.uint32)
            rt.memcpy_d2h(data, rt.get_id(name), x, 0, 1, 1, n, **options)
            observed[f'{name}_{x}'] = data.tolist()
    finally:
        rt.stop()
    correct = (observed['buf_0'] == observed['buf_1'] == payload.tolist()
               and observed['loc_1'] == local.tolist() and observed['res_1'] == expected.tolist())
    result = dict(schema='readiness-readback/1', evidence='simulator', case=spec,
                  payload_bits=payload.tolist(), local_bits=local.tolist(),
                  expected_bits=expected.tolist(), observed=observed, correct=correct)
    Path('result.json').write_text(json.dumps(result, indent=2) + '\n')
    print('READINESS', spec['id'], 'exact readbacks:', correct, flush=True)
    assert correct, 'Readback differs from independently computed f32 reference'


if __name__ == '__main__':
    main()
