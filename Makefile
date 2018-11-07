-include env_make

VERSION ?= base

REPO = docksal/ci-agent
NAME = ci-agent

.PHONY: build test push shell run start stop logs clean release

build:
	docker build -t $(REPO):$(VERSION) $(VERSION)

test:
	IMAGE=$(REPO):$(VERSION) NAME=$(NAME) tests/$(VERSION).bats

push:
	docker push $(REPO):$(VERSION)

shell: clean
	docker run --rm --name $(NAME) -it $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) /bin/bash -oe pipefail

exec:
	# Note: variables defined inside COMMAND get interpreted on the host, unless escaped, e.g. \$${CI_SSH_KEY}.
	docker exec $(NAME) /bin/bash -oe pipefail -c "$(COMMAND)"

run: clean
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

start: clean
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) top -b

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	docker rm -f $(NAME) || true

release: build
	make push -e VERSION=$(VERSION)

default: build
