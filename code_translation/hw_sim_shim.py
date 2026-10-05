#!/usr/bin/env python3
"""Compatibility shim so a kernel's own run.py can drive the appliance SDK.

Kernel run.py files are written against the LOCAL SDK 1.4.0 binding:

    from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder
    runner = SdkRuntime(args.name, cmaddr=args.cmaddr)
    runner.load(); runner.run()
    ... memcpy_h2d / launch / memcpy_d2h ...
    runner.stop()

The appliance SDK 2.10 client exposes nearly the same surface
(`get_id`, `memcpy_h2d`, `memcpy_d2h`, `launch`, `call`, `stop`) but is
constructed from a compiled artifact path and uses `start()` in place of
`load()`/`run()`. It also does not ship `cerebras.sdk.runtime.sdkruntimepybind`
at all, so the enums have to be supplied.

install_shim() registers a fake module under that import path. The kernel's
run.py then executes unmodified against whichever arm (simulator or hardware)
the driver selected, which is the whole point: the SAME host code and the SAME
device bundle are used for both arms, so a hw-vs-sim delta cannot be an
artifact of differing host logic.
"""

from __future__ import annotations

import sys
import types
from typing import Any, Optional


# Proto enum values from cerebras/pb/sdk/appliance/sdk_common.proto.
class MemcpyDataType:  # noqa: D101
    MEMCPY_32BIT = 0
    MEMCPY_16BIT = 1


class MemcpyOrder:  # noqa: D101
    ROW_MAJOR = 0
    COL_MAJOR = 1


class ShimRuntime:
    """Wraps an appliance SdkRuntime behind the local binding's interface.

    The artifact path and arm are bound by install_shim(); the `name` and
    `cmaddr` a run.py passes to the constructor are accepted and ignored,
    since the appliance client resolves the program from the artifact.

    Lifecycle mapping is the fiddly part. The appliance client does its real
    setup in __enter__ -- upload the artifact, create the runtime on the
    worker, read out_rpc.json for launch-parameter validation, then start().
    Until that has run, .stub() raises "SdkRuntime must be created using a
    'with' statement", and kernel run.py files call get_id() *before* their
    load()/run() pair. So __enter__ is driven eagerly from the constructor,
    and load()/run() become no-ops -- start() may be called only once and
    __enter__ already called it.
    """

    def __init__(self, name: Optional[str] = None, cmaddr: Optional[str] = None,
                 **kwargs: Any) -> None:
        from cerebras.sdk.client import SdkRuntime as _ApplianceRuntime

        cfg = _SHIM_CONFIG
        if cfg is None:
            raise RuntimeError("hw_sim_shim.install_shim() was never called")
        self._impl = _ApplianceRuntime(
            cfg["artifact"],
            simulator=cfg["simulator"],
            disable_version_check=True,
        )
        self._impl.__enter__()
        self._active = True
        # A run.py that raises before stop() would otherwise leave the runtime
        # holding a cluster job.
        import atexit
        atexit.register(self._safe_stop)

    # -- lifecycle -------------------------------------------------------
    def load(self) -> None:
        """No-op: __enter__ already uploaded and instantiated the program."""

    def run(self) -> None:
        """No-op: __enter__ already called start(); it is once-per-object."""

    def start(self) -> None:
        """No-op for the same reason as run()."""

    def stop(self) -> None:
        if self._active:
            self._active = False
            self._impl.__exit__(None, None, None)

    def _safe_stop(self) -> None:
        try:
            self.stop()
        except Exception:
            pass

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.stop()
        return False

    # -- passthrough -----------------------------------------------------
    def __getattr__(self, item: str) -> Any:
        # Anything not overridden above (get_id, memcpy_h2d, memcpy_d2h,
        # launch, call, task_wait, is_task_done, ...) goes straight through.
        return getattr(self._impl, item)


_SHIM_CONFIG: Optional[dict] = None


def install_shim(artifact_path: str, simulator: bool) -> None:
    """Register the fake sdkruntimepybind module for this process."""
    global _SHIM_CONFIG
    _SHIM_CONFIG = {"artifact": artifact_path, "simulator": simulator}

    mod = types.ModuleType("cerebras.sdk.runtime.sdkruntimepybind")
    mod.SdkRuntime = ShimRuntime          # type: ignore[attr-defined]
    mod.MemcpyDataType = MemcpyDataType   # type: ignore[attr-defined]
    mod.MemcpyOrder = MemcpyOrder         # type: ignore[attr-defined]

    # Build the intermediate package nodes so `import cerebras.sdk.runtime...`
    # resolves. cerebras.sdk already exists (the appliance client lives there),
    # so only the .runtime subtree needs synthesizing.
    runtime_pkg = sys.modules.get("cerebras.sdk.runtime")
    if runtime_pkg is None:
        runtime_pkg = types.ModuleType("cerebras.sdk.runtime")
        runtime_pkg.__path__ = []  # type: ignore[attr-defined]
        sys.modules["cerebras.sdk.runtime"] = runtime_pkg
    runtime_pkg.sdkruntimepybind = mod  # type: ignore[attr-defined]
    sys.modules["cerebras.sdk.runtime.sdkruntimepybind"] = mod

    import cerebras.sdk as _sdk
    _sdk.runtime = runtime_pkg  # type: ignore[attr-defined]


def uninstall_shim() -> None:
    global _SHIM_CONFIG
    _SHIM_CONFIG = None
    sys.modules.pop("cerebras.sdk.runtime.sdkruntimepybind", None)
    sys.modules.pop("cerebras.sdk.runtime", None)
