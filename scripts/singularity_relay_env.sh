#!/usr/bin/env bash
# A `singularity` relay for login nodes that forwards the environment the SDK wrappers
# and the xkernel harness rely on. Install by hand (it is YOUR ~/bin/singularity):
#
#     cp ~/bin/singularity ~/bin/singularity.bak && cp scripts/singularity_relay_env.sh ~/bin/singularity
#
# Why: ~/bin/singularity (2026-09-07) execs `ssh user-node-1 /usr/bin/singularity ...`, and
# ssh forwards no environment. So SINGULARITYENV_*/APPTAINERENV_* never reach the remote
# singularity, the container never sees XKERNEL_EVAL_SEED, and every held-out run made
# through the relay silently re-used the train seed (verified 2026-09-16 with
# `cs_python -c 'import os; print(os.environ.get("XKERNEL_EVAL_SEED"))'` -> None).
# The harness now also hands the seed over through a file in the bundle directory
# (benchmark_csl._run_step_command / sparse_inputs.resolve_eval_seed) and checks the
# runner's `eval_seed = N` echo, so the v2 sparse tasks are safe either way; legacy
# runners that read only the environment need this relay.
#
# The target node is XKERNEL_RELAY_HOST (default user-node-1). One container job at a time
# per NODE: two accounts sharing a login node must relay to different nodes (user-node-1 and
# user-node-2 both carry /software/cerebras/cs_sdk-2.10), and the appliance client is only
# usable on those nodes, not through this relay.
#
# Arguments are %q-quoted so the remote shell re-parses them exactly as given (the SDK
# wrappers pass python source to `cs_python -c`). Selected variables are re-established on
# the remote side with `env`, quoted the same way.
fwd=()
while IFS='=' read -r -d '' name value; do
  case "$name" in
    SINGULARITYENV_*|APPTAINERENV_*|XKERNEL_*|CSL_IMPORT_PATH|CEREBRAS_SDK_PATH|TMPDIR|CS_SDK_SIF)
      fwd+=("$name=$value");;
  esac
done < <(env -0)
if [ ${#fwd[@]} -gt 0 ]; then
  remote="$(printf '%q ' env "${fwd[@]}" /usr/bin/singularity "$@")"
else
  remote="$(printf '%q ' /usr/bin/singularity "$@")"
fi
exec ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 "${XKERNEL_RELAY_HOST:-user-node-1}" "$remote"
