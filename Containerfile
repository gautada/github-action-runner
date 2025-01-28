# FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-jammy as build
# 
# RUN apt update -y && apt install curl unzip -y
# 
# ARG TARGETOS=linuc
# ARG TARGETARCH=arm64
# ARG RUNNER_VERSION=2.322.0
# # ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.1
# # ARG DOCKER_VERSION=27.4.1
# # ARG BUILDX_VERSION=0.19.3
# ARG URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${TARGETOS}-${TARGETARCH}-${RUNNER_VERSION}.tar.gz"
# 
# WORKDIR /actions-runner
# 
# RUN echo "${URL}"
# RUN curl -f -L -o runner.tar.gz ${URL} \
#  && tar xzf ./runner.tar.gz \
#  && rm runner.tar.gz
 
 FROM debian:bookworm-slim
 
 ARG RUNNER_VERSION="2.302.1"
 
 ENV GITHUB_PERSONAL_TOKEN ""
 ENV GITHUB_OWNER ""
 ENV GITHUB_REPOSITORY ""
 
 # Install Docker -> https://docs.docker.com/engine/install/debian/
 
 # Add Docker's official GPG key:
 RUN apt-get update && \
     apt-get install -y ca-certificates curl gnupg
 RUN install -m 0755 -d /etc/apt/keyrings
 RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 RUN chmod a+r /etc/apt/keyrings/docker.gpg
 
 # Add the repository to Apt sources:
 RUN echo \
   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
 RUN apt-get update
 
 # I only install the CLI, we will run docker in another container!
 RUN apt-get install -y docker-ce-cli
 
 # Install the GitHub Actions Runner 
 RUN apt-get update && apt-get install -y sudo jq
 
 RUN useradd -m github && \
   usermod -aG sudo github && \
   echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
 
 USER github
 WORKDIR /actions-runner
 RUN curl -Ls https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz | tar xz \
   && sudo ./bin/installdependencies.sh
 
 COPY --chown=github:github entrypoint.sh  /actions-runner/entrypoint.sh
 RUN sudo chmod u+x /actions-runner/entrypoint.sh
 
 #working folder for the runner 
 RUN sudo mkdir /work 
 
 ENTRYPOINT ["/actions-runner/entrypoint.sh"]