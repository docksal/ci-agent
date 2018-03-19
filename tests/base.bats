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

# Global skip
# Uncomment below, then comment skip in the test you want to debug. When done, reverse.
#SKIP=1

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
