# github-action-runner

GitHub Actions self-hosted runner container built on `gautada/debian`.

## Features

- Debian 13 (trixie) base via `gautada/debian`
- GitHub Actions Runner agent (latest stable, auto-resolved at build time)
- `uv` — Python toolchain (resolve, install, build, publish)
- devpi pre-configured as the default Python index via `UV_INDEX_URL`
- Standard gautada container health scripts
- s6 process supervision

## Usage

```sh
podman run -d \
  -e GITHUB_OWNER=gautada \
  -e GITHUB_REPOSITORY=myrepo \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx \
  -v runner-data:/mnt/volumes/data \
  docker.io/gautada/github-action-runner:latest
```

Set `GITHUB_REPOSITORY` for repo-scoped runners or omit for org-level runners.

## Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `GITHUB_OWNER` | Yes | GitHub org or user |
| `GITHUB_REPOSITORY` | No | Repo name (omit for org runner) |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | Yes | PAT with `admin:org` or repo scope |
| `RUNNER_LABELS` | No | Extra labels (default: `debian,uv`) |
| `RUNNER_NAME` | No | Runner name (default: hostname) |
| `UV_INDEX_URL` | No | Override devpi index URL |
