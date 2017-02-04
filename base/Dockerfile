FROM alpine:3.5

RUN apk add --update --no-cache \
    bash \
    curl \
    git \
    jq \
    openssh \
    sudo \
    && rm -rf /var/cache/apk/*

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

COPY config/.ssh/config $AGENT_HOME/.ssh/config
COPY bin/build-env /usr/local/bin/build-env
COPY bin/build-init /usr/local/bin/build-init
COPY bin/slack /usr/local/bin/slack
# Fix permissions after COPY
RUN sudo chown -R $AGENT_USER:$AGENT_USER $AGENT_HOME

WORKDIR $AGENT_HOME/build
