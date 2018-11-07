#!/usr/bin/env bats

# Debugging
teardown() {
	echo
	echo "Last command status: $status"
	echo "Last command output:"
	echo "================================================================"
	echo "$output"
	echo "================================================================"
}

# To work on a specific test:
# run `export SKIP=1` locally, then comment skip in the test you want to debug

@test "Check binaries" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start

	### Tests ###
	run make exec COMMAND="docker --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Docker version"
	unset output

	run make exec COMMAND="docker-compose --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "docker-compose version"
	unset output

	run make exec COMMAND="mc --help"
	[[ "$status" == 0 ]]
	echo "$output" | grep "VERSION"
	unset output

	### Cleanup ###
	make clean
}

@test "Git settings" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start -e ENV='-e GIT_USER_EMAIL=git@example.com -e GIT_USER_NAME="Docksal CLI" -e GIT_REPO_URL="test-repo-url" -e GIT_BRANCH_NAME="test-branch-name" -e GIT_COMMIT_HASH="test-commit-hash"'

	### Tests ###
	# Check git settings were applied
	run make exec COMMAND="source build-env; git config --get --global user.email"
	[[ "$status" == 0 ]]
	echo "$output" | grep "git@example.com"
	unset output

	run make exec COMMAND="source build-env; git config --get --global user.name"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Docksal CLI"
	unset output

	### Cleanup ###
	make clean
}

@test "Check SSH agent and keys" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	CI_SSH_KEY="LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSUkxOElNMTZEMFVsS0U0VHVYeU1iQ3NEb3VHWU9TZC85SkJmSTcrenFCQ1JvQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFK1BSR2RQOUpSTmljbVQ1RjR1WFNEakV2TXFUczAxaVVOTXprTXAzUVdSM3hScWp5VFlYdAp0R1hRNE5BVWlxWEtlMnNaN0NZMmxqeGNrTUJCamU2OEhBPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQo="
	make start -e ENV="-e GIT_USER_EMAIL='git@example.com' -e GIT_USER_NAME='Docksal CLI' -e GIT_REPO_URL='test-repo-url' -e GIT_BRANCH_NAME='test-branch-name' -e GIT_COMMIT_HASH='test-commit-hash' -e CI_SSH_KEY='${CI_SSH_KEY}'"

	### Tests ###

	# Check private SSH key
	# COMMAND is wrapped in double quotes in Makefile, so variables defined inside it get interpreted on the host,
	# unless escaped, e.g. \$${CI_SSH_KEY}
	run make exec COMMAND='source build-env; echo \$${CI_SSH_KEY} | base64 -d | diff \$${HOME}/.ssh/id_rsa -'
	[[ "$status" == 0 ]]
	unset output

	# Check ssh-agent
	run make exec COMMAND="source build-env; ssh-add -l"
	[[ "$status" == 0 ]]
	unset output

	### Cleanup ###
	make clean
}
