#!/usr/bin/env bash

# Generates docker images tags for the docker/build-push-action@v2 action depending on the branch/tag.
# Image tag format:
#   develop     => image:[version-]edge[-flavor]
#   master      => image:[version][-][flavor]
#   semver tag  => image:[version-]major.minor[-flavor]

# Registries
declare -a registryArr
registryArr+=("docker.io") # Docker Hub
registryArr+=("ghcr.io") # GitHub Container Registry

# Image tags
declare -a imageTagArr

# Join arguments with hyphen (-) as a delimiter
# Usage: join <arg1> [<argn>]
join() {
  local IFS='-' # join delimiter
  echo "$*"
}

# feature/* => sha-xxxxxxx
# Note: disabled
#if [[ "${GITHUB_REF}" =~ "refs/heads/feature/" ]]; then
#	GIT_SHA7=$(echo ${GITHUB_SHA} | cut -c1-7) # Short SHA (7 characters)
#	imageTagArr+=("${IMAGE}:${VERSION}-sha-${GIT_SHA7}")
#fi

# develop => version-edge
if [[ "${GITHUB_REF}" == "refs/heads/develop" ]]; then
	tag=$(join ${VERSION} edge ${FLAVOR})
	imageTagArr+=("${IMAGE}:${tag}")
fi

# master => version
if [[ "${GITHUB_REF}" == "refs/heads/master" ]]; then
	tag=$(join ${VERSION} ${FLAVOR})
	imageTagArr+=("${IMAGE}:${tag}")
fi

# tags/v1.0.0 => 1.0
if [[ "${GITHUB_REF}" =~ "refs/tags/" ]]; then
	# Extract version parts from release tag
	IFS='.' read -a release_arr <<< "${GITHUB_REF#refs/tags/}"
	releaseMajor=${release_arr[0]#v*}  # 2.7.0 => "2"
	releaseMinor=${release_arr[1]}  # "2.7.0" => "7"
	imageTagArr+=("${IMAGE}:$(join ${VERSION} ${FLAVOR})")
	imageTagArr+=("${IMAGE}:$(join ${VERSION} ${releaseMajor} ${FLAVOR})")
	imageTagArr+=("${IMAGE}:$(join ${VERSION} ${releaseMajor}.${releaseMinor} ${FLAVOR})")
fi

# Build an array of registry/image:tag values
declare -a repoImageTagArr
for registry in ${registryArr[@]}; do
	for imageTag in ${imageTagArr[@]}; do
		repoImageTagArr+=("${registry}/${imageTag}")
	done
done

# Print with new lines for output in build logs
(IFS=$'\n'; echo "${repoImageTagArr[*]}")
# Using newlines in outputs variables does not seem to work, so we'll use comas
(IFS=$','; echo "::set-output name=tags::${repoImageTagArr[*]}")
