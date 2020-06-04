FROM alpine:3.9

RUN set -xe; \
	apk add --update --no-cache \
		bash \
		curl \
		git \
		jq \
		make \
		openssh \
		py2-pip \
		rsync \
		sudo \
		patch \
	; \
	rm -rf /var/cache/apk/*;

ARG DOCKER_VERSION=18.09.2
ARG DOCKER_COMPOSE_VERSION=1.23.2
ARG MINIO_VERSION="RELEASE.2020-05-28T23-43-36Z"
RUN set -xe; \
	# Install docker cli
	curl -fsSL -O "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"; \
	tar zxf docker-${DOCKER_VERSION}.tgz && mv docker/docker /usr/local/bin && rm -rf docker-${DOCKER_VERSION}*; \
	docker --version; \
	# Install docker-compose cli (has to be installed via pip on Alpine)
	pip install "docker-compose==${DOCKER_COMPOSE_VERSION}" >/dev/null; \
	docker-compose --version; \
	# Install minio client (mc)
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
