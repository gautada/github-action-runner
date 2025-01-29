FROM docker.io/ubuntu:24.04
# FROM debian:bookworm-slim

RUN /usr/bin/apt-get update --yes \ 
 && /usr/bin/apt-get install --yes curl jq nano sudo unzip \
 && /usr/bin/apt-get install --yes libicu74 libssl3t64 

ARG GITHUB_ACTIONS_RUNNER_VERSION=2.322.0
ARG GITHUB_ACTIONS_RUNNER_OS=linux
ARG GITHUB_ACTIONS_RUNNER_ARCH=arm64

WORKDIR /opt/github-actions-runner
 
ARG URL="https://github.com/actions/runner/releases/download/v${GITHUB_ACTIONS_RUNNER_VERSION}/actions-runner-${GITHUB_ACTIONS_RUNNER_OS}-${GITHUB_ACTIONS_RUNNER_ARCH}-${GITHUB_ACTIONS_RUNNER_VERSION}.tar.gz" 

ADD ${URL} github-actions-runner.tgz
RUN /usr/bin/tar xzf github-actions-runner.tgz \
 && /usr/bin/rm github-actions-runner.tgz \
 && /opt/github-actions-runner/bin/installdependencies.sh
 
ARG USER=github
RUN useradd -m ${USER} \
 && usermod -aG sudo ${USER} \
 && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN chown -R github:github /opt/github-actions-runner
    
COPY entrypoint /etc/container/entrypoint

USER ${USER}

# ENTRYPOINT ["/actions-runner/entrypoint.sh"]