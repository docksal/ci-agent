FROM alpine:3.8

RUN set -xe; \
	apk add --update --no-cache \
		bash \
		curl \
		git \
		jq \
		openssh \
		py2-pip \
		rsync \
		sudo \
		patch \
	; \
	rm -rf /var/cache/apk/*;

ARG DOCKER_VERSION=18.06.0-ce
ARG DOCKER_COMPOSE_VERSION=1.21.0
RUN set -xe; \
	# Install docker cli
	curl -sSL -O "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"; \
	tar zxf docker-${DOCKER_VERSION}.tgz && mv docker/docker /usr/local/bin && rm -rf docker-${DOCKER_VERSION}*; \
	docker --version; \
	# Install docker-compose cli (has to be installed via pip on Alpine)
	pip install "docker-compose==${DOCKER_COMPOSE_VERSION}" >/dev/null; \
	docker-compose --version; \
	# Install minio client (mc)
	curl -sSL https://dl.minio.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc; \
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
