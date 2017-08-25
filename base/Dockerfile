FROM alpine:3.6

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

ARG DOCKER_VERSION=17.06.0-ce
ARG DOCKER_COMPOSE_VERSION=1.14.0
RUN \
    # Install docker cli
    curl -sSL -O "https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz" && \
    tar zxf docker-$DOCKER_VERSION.tgz && mv docker/docker /usr/local/bin && rm -rf docker-$DOCKER_VERSION* && \
    # Install docker-compose cli
    curl -sSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    # Install minio client (mc)
    curl -sSL https://dl.minio.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

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
