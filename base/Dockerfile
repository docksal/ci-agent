FROM alpine:3.19.1

# Install basic pacakges
RUN set -xe; \
	apk add --update --no-cache \
		bash \
		curl \
		git \
		jq \
		make \
		openssh \
		rsync \
		sudo \
		patch \
	; \
	rm -rf /var/cache/apk/*;

# Install docker packages
# Lookup available version for Alpine at
# https://pkgs.alpinelinux.org/packages?name=docker*&branch=v3.19&arch=x86_64
ARG DOCKER_VERSION=25.0.3-r0
ARG DOCKER_COMPOSE_VERSION=2.23.3-r0
RUN set -xe; \
	apk add --update --no-cache \
		docker-cli=${DOCKER_VERSION} \
		docker-compose=${DOCKER_COMPOSE_VERSION} \
	; \
	rm -rf /var/cache/apk/*;

# Install minio client (mc)
ARG MINIO_VERSION="RELEASE.2024-02-14T21-19-52Z"
RUN set -xe; \
	curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MINIO_VERSION} -o /usr/local/bin/mc; \
	chmod +x /usr/local/bin/mc

ENV AGENT_USER=agent
ENV AGENT_HOME=/home/agent
RUN set -xe; \
	# Create a non-root user with access to sudo
	adduser -h $AGENT_HOME -s /bin/bash -D $AGENT_USER; \
	echo "$AGENT_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers;

# All further RUN commands will run as the "agent" user
USER $AGENT_USER

RUN set -xe; \
	mkdir -p $AGENT_HOME/.ssh; \
	mkdir -p $AGENT_HOME/build;

COPY bin /usr/local/bin
COPY config/.ssh/config $AGENT_HOME/.ssh/config
# Fix permissions after COPY (could use COPY --chown, but will still need to run chmod)
RUN set -xe; \
	sudo chown $AGENT_USER:$AGENT_USER $AGENT_HOME/.ssh/config; \
	sudo chmod 600 $AGENT_HOME/.ssh/config;

WORKDIR $AGENT_HOME/build
