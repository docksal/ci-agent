#!/bin/bash
set -e

if [[ "${COMMAND}" != "" ]]; then
	exec bash -c "${COMMAND}"
fi

exec "$@"
