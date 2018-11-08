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

@test "Base tests" {
	[[ $SKIP == 1 ]] && skip

	run bats tests/base.bats
	[[ "$status" == 0 ]]
	unset output
}

@test "Check binaries" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start

	### Tests ###
	run make exec COMMAND="php --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "PHP"
	unset output

	run make exec COMMAND="composer --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Composer version"
	unset output

	run make exec COMMAND="drush --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Drush Version"
	unset output

	run make exec COMMAND="drupal --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "Drupal Console Launcher"
	unset output

	run make exec COMMAND="wp --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "WP-CLI"
	unset output

	run make exec COMMAND="phpcs --version"
	[[ "$status" == 0 ]]
	echo "$output" | grep "PHP_CodeSniffer"
	unset output

	### Cleanup ###
	make clean
}

@test "Check PHP modules" {
	[[ $SKIP == 1 ]] && skip

	### Setup ###
	make start

	# Check PHP modules
	run bash -c "docker exec '${NAME}' php -m | diff tests/php-modules.txt -"
	[[ ${status} == 0 ]]
	unset output

	### Cleanup ###
	make clean
}
