"""Retry only pre-launch admission; never retry an SDK phase or overwrite evidence."""
import time

def run_with_admission_retry(directory, operation, record_wait, before_try=lambda: None, monotonic=time.monotonic):
    while True:
        before_try()
        started = monotonic()
        try:
            return operation(directory)
        except TimeoutError as error:
            if str(error) != 'simulator queue wait':
                raise
            artifacts = [name for name in ('compile.log', 'run.log', 'out', 'observations.partial.json', 'observations.json', 'result.json') if (directory / name).exists()]
            if artifacts:
                raise RuntimeError(f'Admission retry refused: SDK artifacts exist: {artifacts}') from error
            record_wait(dict(case=directory.name, status='queue_timeout_before_launch', phase_launched=False, wait_seconds=monotonic()-started))
