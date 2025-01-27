FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy as build

RUN apt update -y && apt install curl unzip -y

ARG TARGETOS=linuc
ARG TARGETARCH=arm64
ARG RUNNER_VERSION=2.322.0
# ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.1
# ARG DOCKER_VERSION=27.4.1
# ARG BUILDX_VERSION=0.19.3
ARG URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${TARGETOS}-${TARGETARCH}-${RUNNER_VERSION}.tar.gz"

WORKDIR /actions-runner

RUN echo "${URL}"
RUN curl -f -L -o runner.tar.gz ${URL} \
 && tar xzf ./runner.tar.gz \
 && rm runner.tar.gz
 
 