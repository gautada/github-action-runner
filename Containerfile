ARG CONTAINER_VERSION=13.3

# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ STAGE 1: Download and extract GitHub Actions Runner                      │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM docker.io/gautada/debian:${CONTAINER_VERSION} AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl jq \
 && rm -rf /var/lib/apt/lists/*

# Resolve the latest runner release and download the matching tarball for the
# target architecture. The TARGETARCH build-arg is injected by buildah/podman.
ARG TARGETARCH
RUN RUNNER_VERSION=$(curl -sL "https://api.github.com/repos/actions/runner/releases/latest" \
      | jq -r '.tag_name' | sed 's/^v//' | tr -d '[:space:]') \
 && { [ -n "$RUNNER_VERSION" ] && [ "$RUNNER_VERSION" != "null" ] \
      || { echo "ERROR: could not resolve latest runner version" >&2; exit 1; }; } \
 && case "$TARGETARCH" in \
      amd64) ARCH=x64 ;; \
      arm64) ARCH=arm64 ;; \
      *)     echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
 && URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz" \
 && echo "Downloading runner ${RUNNER_VERSION} for ${ARCH} from ${URL}" \
 && mkdir -p /opt/github-actions-runner \
 && curl -fsSL "$URL" | tar -xz -C /opt/github-actions-runner

# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ STAGE 2: Final container image                                           │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM docker.io/gautada/debian:${CONTAINER_VERSION} AS container

ARG IMAGE_NAME=github-action-runner

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="GitHub Actions self-hosted runner on gautada/debian with uv and devpi."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.license="MIT"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl jq git \
      libicu72 libkrb5-3 libssl3 zlib1g \
      lsb-release sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install uv — the standard Python toolchain for the gautada stack.
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=runner
RUN /usr/sbin/usermod -l $USER debian \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER debian \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd \
 && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=builder /opt/github-actions-runner /opt/github-actions-runner

# Install any OS-level runner dependencies (non-interactive).
RUN DEBIAN_FRONTEND=noninteractive /opt/github-actions-runner/bin/installdependencies.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN chown -R $USER:$USER /opt/github-actions-runner

# ╭――――――――――――――――――――╮
# │ UV / devpi config  │
# ╰――――――――――――――――――――╯
# Pre-configure devpi as the default Python index so workflows don't need to
# set an explicit index URL. Override at runtime via UV_INDEX_URL if needed.
ENV UV_INDEX_URL=https://pypi.eurekafarms.com/root/pypi/+simple/ \
    UV_EXTRA_INDEX_URL=https://pypi.org/simple/

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
COPY version.sh /usr/bin/container-version
RUN chmod +x /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ LATEST             │
# ╰――――――――――――――――――――╯
COPY latest.sh /usr/bin/container-latest
RUN chmod +x /usr/bin/container-latest

# ╭――――――――――――――――――――╮
# │ HEALTH             │
# ╰――――――――――――――――――――╯
COPY appversion-check.sh /etc/container/health.d/appversion-check
RUN chmod +x /etc/container/health.d/appversion-check
COPY runner-running.sh /etc/container/health.d/runner-running
RUN chmod +x /etc/container/health.d/runner-running

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY runner.s6 /etc/services.d/github-runner/run
RUN chmod +x /etc/services.d/github-runner/run

VOLUME /mnt/volumes/data

WORKDIR /opt/github-actions-runner
