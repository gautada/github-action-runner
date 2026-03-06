# github-action-runner

GitHub Actions self-hosted runner container based on `gautada/debian`.

## Overview

A plain, minimal self-hosted runner image. No language toolchains or
additional runtimes are included by design. Language-specific runners
(e.g., Python + uv + devpi) will be separate images built on top of
this base.

## Usage

Run with the required environment variables:

```shell
docker run \
  -e RUNNER_URL=https://github.com/your-org/your-repo \
  -e RUNNER_TOKEN=your-registration-token \
  gautada/github-action-runner:latest
```

### Environment Variables

- `RUNNER_URL` — The URL of the repository or organization to register with.
- `RUNNER_TOKEN` — A short-lived registration token obtained from GitHub.

## Health Checks

- `appversion-check` — Compares the running runner version against the
  latest release on GitHub.
- `runner-running` — Verifies the `Runner.Listener` process is active.

## References

- [GitHub Actions Runner](https://github.com/actions/runner)
- [Creating a registration token](https://docs.github.com/en/rest/actions/self-hosted-runners)
