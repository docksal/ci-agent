-include env_make

IMAGE ?= docksal/ci-agent
FLAVOR ?= base
BUILD_TAG ?= $(FLAVOR)-build

NAME = docksal-ci-agent-$(FLAVOR)

.EXPORT_ALL_VARIABLES:

.PHONY: build test push shell run start stop logs clean release

build:
	docker build -t $(IMAGE):$(BUILD_TAG) ./$(FLAVOR)

test:
	IMAGE=$(IMAGE) BUILD_TAG=$(BUILD_TAG) NAME=$(NAME) ./tests/$(FLAVOR).bats

push:
	docker push $(IMAGE):$(BUILD_TAG)

shell: clean
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(IMAGE):$(BUILD_TAG) /bin/bash

exec:
	# Note: variables defined inside COMMAND get interpreted on the host, unless escaped, e.g. \$${CI_SSH_KEY}.
	docker exec $(NAME) /bin/bash -oe pipefail -c "$(COMMAND)"

run: clean
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(IMAGE):$(BUILD_TAG)

start: clean
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(IMAGE):$(BUILD_TAG) top -b

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	docker rm -f $(NAME) >/dev/null 2>&1 || true

tags:
	@.github/scripts/docker-tags.sh

default: build
