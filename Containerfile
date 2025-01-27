ARG ALPINE_VERSION=latest

# │ STAGE: CONTAINER
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/github-action-runner-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for self-hosted GitHub Action Runner"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=github
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
# COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# COPY backup /etc/container/backup


# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
# COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION
# ╰――――――――――――――――――――
RUN /sbin/apk add --no-cache bash lttng-ust openssl krb5 zlib icu-libs
ARG CONTAINER_VERSION="2.332.0"
ARG ACTION_RUNNER_VERSION="${CONTAINER_VERSION}"

RUN mkdir /home/$USER/actions-runner && cd /home/$USER/actions-runner \
 && curl -O -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-arm64-2.322.0.tar.gz \
 && tar xzf ./actions-runner-linux-arm64-2.322.0.tar.gz \
 && rm ./actions-runner-linux-arm64-2.322.0.tar.gz

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER

USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
VOLUME /mnt/volumes/source

WORKDIR /home/$USER

 

