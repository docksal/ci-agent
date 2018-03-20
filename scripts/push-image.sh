#!/bin/bash

# Pushes an image to Docker Hub

VERSION=$1

[[ "${TRAVIS_BRANCH}" == "develop" ]] && TAG="edge-${VERSION}"
[[ "${TRAVIS_BRANCH}" == "master" ]] && TAG="${VERSION}"
[[ "${TRAVIS_TAG}" != "" ]] && TAG="${TRAVIS_TAG:1:3}-${VERSION}"

if [[ "$TAG" != "" ]]; then
	docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"
	# Push edge, stable and release tags
	docker tag ${REPO}:${VERSION} ${REPO}:${TAG}
	docker push ${REPO}:${TAG}

	# Push "latest" tag
	if [[ "${TRAVIS_BRANCH}" == "master" ]] && [[ "${VERSION}" == "base" ]]; then
	docker tag ${REPO}:${VERSION} ${REPO}:latest
	docker push ${REPO}:latest
	fi
fi
