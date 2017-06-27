FROM alpine:3.5

RUN apk add --update --no-cache \
    bash \
    curl \
    git \
    jq \
    openssh \
    sudo \
    && rm -rf /var/cache/apk/*

ARG GLIBC=2.25-r0
RUN \
    # Install glibc libraries needed for docker-compose
    apk update && apk add --no-cache openssl ca-certificates && \
    curl -L https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -L -O https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC/glibc-$GLIBC.apk && \
    apk add --no-cache glibc-$GLIBC.apk && rm glibc-$GLIBC.apk && \
    ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib

ARG DOCKER_VERSION=17.05.0-ce
ARG DOCKER_COMPOSE_VERSION=1.13.0
RUN \
    # Install docker cli
    curl -L -O https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar -xzf docker-${DOCKER_VERSION}.tgz && \
    mv docker/docker /usr/local/bin && \
    rm -rf docker docker-${DOCKER_VERSION}.tgz && \
    # Install docker-compose cli
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose && \
    # Make binaries executable
    chmod -R +x /usr/local/bin

ARG AGENT_USER=agent
ARG AGENT_HOME=/home/agent
RUN \
    # Create a non-root user with access to sudo
    adduser -h $AGENT_HOME -s /bin/bash -D $AGENT_USER && \
    echo "$AGENT_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# All further RUN commands will run as the "agent" user
USER $AGENT_USER
ENV HOME $AGENT_HOME

RUN \
    mkdir -p $AGENT_HOME/.ssh && \
    mkdir -p $AGENT_HOME/build

COPY bin /usr/local/bin
COPY config/.ssh/config $AGENT_HOME/.ssh/config
# Fix permissions after COPY
RUN sudo chown -R $AGENT_USER:$AGENT_USER $AGENT_HOME/.ssh/config

WORKDIR $AGENT_HOME/build
