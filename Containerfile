# ------------------------------------------------------------- [STAGE] BUILD
ARG BASE_IMAGE=gautada/debian:latest
FROM ${BASE_IMAGE} as build

# Install build-time dependencies
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    curl \
    ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install uv (standard Python toolchain)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && mv /root/.local/bin/uv /usr/bin/uv

# Install GitHub Actions Runner
ARG RUNNER_VERSION=2.321.0
ARG TARGETARCH=arm64
WORKDIR /home/debian/actions-runner
RUN curl -o actions-runner-linux.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz \
 && tar xzf ./actions-runner-linux.tar.gz \
 && rm actions-runner-linux.tar.gz \
 && ./bin/installdependencies.sh

# ------------------------------------------------------------- [STAGE] FINAL
FROM ${BASE_IMAGE}

# Metadata
LABEL org.opencontainers.image.title="github-action-runner"
LABEL org.opencontainers.image.description="Modernized GitHub Actions runner with uv and devpi support."
LABEL org.opencontainers.image.source="https://github.com/gautada/github-action-runner"

# Environment configuration
ENV UV_INDEX_URL="http://pypi.eurekafarms.com/root/pypi/+simple/"
ENV UV_CACHE_DIR="/mnt/volumes/data/uv-cache"

# System packages
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    git \
    jq \
    python3 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Tools and runner binaries
COPY --from=build /usr/bin/uv /usr/bin/uv
COPY --from=build --chown=debian:debian /home/debian/actions-runner /home/debian/actions-runner

# Version reporting
COPY scripts/container-version.sh /usr/bin/container-version

# s6 service definition
COPY services/runner/run /etc/services.d/runner/run
RUN chmod +x /usr/bin/container-version /etc/services.d/runner/run

# Persistence
RUN mkdir -p /mnt/volumes/data/uv-cache \
 && chown -R debian:debian /mnt/volumes/data

VOLUME /mnt/volumes/data
WORKDIR /home/debian/actions-runner
