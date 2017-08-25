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

@test "Base tests" {
	[[ $SKIP == 1 ]] && skip

	run bats tests/base.bats
	[[ "$status" == 0 ]]
}

@test "Check binaries" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start

	### Tests ###
	run make exec COMMAND="php --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "PHP"

	run make exec COMMAND="composer --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Composer version"

	run make exec COMMAND="drush --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Drush Version"

	run make exec COMMAND="drupal --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Drupal Console Launcher"

	run make exec COMMAND="wp --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "WP-CLI"

	### Cleanup ###
	make clean
}
