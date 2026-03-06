ARG TARGETARCH=amd64
FROM gautada/debian:13.3

# Install dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      jq \
      libicu-dev \
      libssl3 \
      ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and install GitHub Actions runner for the target arch
# Use ARG TARGETARCH to select correct tarball
ARG RUNNER_VERSION
RUN RUNNER_VERSION=$(curl -sSf https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/v//') \
 && ARCH=$(dpkg --print-architecture) \
 && case "$ARCH" in \
      amd64) RUNNER_ARCH=x64 ;; \
      arm64) RUNNER_ARCH=arm64 ;; \
      *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
    esac \
 && curl -sSfL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" \
      -o /tmp/runner.tar.gz \
 && mkdir -p /opt/github-actions-runner \
 && tar xzf /tmp/runner.tar.gz -C /opt/github-actions-runner \
 && rm /tmp/runner.tar.gz \
 && /opt/github-actions-runner/bin/installdependencies.sh

WORKDIR /opt/github-actions-runner

COPY version.sh /usr/bin/container-version
COPY latest.sh /usr/bin/container-latest
COPY appversion-check.sh /etc/container/health.d/appversion-check
COPY osversion.sh /usr/bin/container-osversion
COPY runner-running.sh /etc/container/health.d/runner-running
COPY runner-entrypoint.sh /usr/bin/runner-entrypoint

RUN chmod +x \
    /usr/bin/container-version \
    /usr/bin/container-latest \
    /etc/container/health.d/appversion-check \
    /usr/bin/container-osversion \
    /etc/container/health.d/runner-running \
    /usr/bin/runner-entrypoint

ENTRYPOINT ["/usr/bin/runner-entrypoint"]
