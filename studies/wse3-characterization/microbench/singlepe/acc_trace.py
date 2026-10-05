import json, numpy as np, verify
meta = json.load(open("B/meta.json")); inp = verify.inputs("B", meta)
x, y = inp["x_arr"], inp["y_arr"]
print("max |x pair sum|:", float(np.abs(x[0::2] + x[1::2]).max()), " max |y pair diff|:", float(np.abs(y[0::2] - y[1::2]).max()))
S, sinks = verify.expect("B", meta, inp)
for v in meta["variants"]:
    print(f"  {v['name']:<13} sink = {sinks[v['name']]}")
