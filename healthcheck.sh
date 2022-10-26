#!/usr/bin/env sh

if [ -z ${LOCAL_PORT+x} ]; then
	if [ -z ${REMOTE_SERVER_PORT} ]; then
		echo '[ERROR] The required LOCAL_PORT or REMOTE_SERVER_PORT environment variable has not been set.' >&2
		exit 1
	fi

	LOCAL_PORT=${REMOTE_SERVER_PORT}
fi

case "${HEALTHCHECK:-'soft'}" in
	'none')
		exit 0
		;;
	'soft')
		netstat -ltn | grep -q "${LOCAL_PORT}"
		exit $?
		;;
	'hard')
		nc -w 0 -n -z 127.0.0.1 "${LOCAL_PORT}" >/dev/null 2>&1
		exit $?
		;;
	*)
		echo "[ERROR] Unknown HEALTHCHECK \"${HEALTHCHECK}\" value." >&2
		exit 1
esac
