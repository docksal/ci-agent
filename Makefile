-include env_make

VERSION ?= base

REPO = docksal/bitbucket-pipelines-agent
NAME = bitbucket-pipelines-agent

.PHONY: build test push shell run start stop logs clean release

build:
	fin docker build -t $(REPO):$(VERSION) $(VERSION)

test:
	IMAGE=$(REPO):$(VERSION) NAME=$(NAME) tests/$(VERSION).bats

push:
	fin docker push $(REPO):$(VERSION)

shell: clean
	fin docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) /bin/bash

exec:
	fin docker exec $(NAME) $(COMMAND)

run: clean
	fin docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

start: clean
	fin docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) top -b

stop:
	fin docker stop $(NAME)

logs:
	fin docker logs $(NAME)

clean:
	fin docker rm -f $(NAME) || true

release: build
	make push -e VERSION=$(VERSION)

default: build
