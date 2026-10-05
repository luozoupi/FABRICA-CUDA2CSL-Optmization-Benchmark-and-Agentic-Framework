# Recovery after the chat interruption

The supervisor stopped during the 256×256 one-PE case. Its SDK child continued and completed all 40 numerical launches and four communication controls, reporting 3,895.30 seconds of simulator execution. This exceeded the registered 2,400-second limit after its watchdog was lost. There is no supervisor exit status or outer-process duration to recover.

The complete child observations, binaries and logs are preserved under `interrupted-attempts/strong-m256-k256-n256-p1-d3-full-attempt1`; compact observations are in `interrupted-observations.json.gz`. They are excluded from primary timing tables and configuration success counts. The outcome remains an additional interrupted attempt, independently of the recovery outcome.

The same configuration is repeated with unchanged registered source hashes, inputs, repetitions and watchdog. The six untouched configurations then continue in their original order. A detached supervisor keeps the watchdog alive independently of the chat turn. No source or performance selection was made using the unsupervised results.

## Queue admission revision on September 26

The September 25 recovery waited for the shared SDK lock for ten minutes and exited before compilation. That coordination failure is retained under `coordination-failures/20260925-queue-timeout`; it produced no new numerical measurements.

Administrative revision `queue-admission-v2` retains each 600-second admission timeout and retries only admission. Total waiting before SDK launch is now open-ended and recorded separately. Once admitted, the original frozen runner enforces the same 600-second compile and 2,400-second simulator watchdogs. No SDK execution failure is automatically retried. Source/configuration hashes, matrices and timing repetitions remain fixed. A heartbeat records whether the worker is waiting, compiling or running, and a study-specific lock prevents duplicate supervisors.
