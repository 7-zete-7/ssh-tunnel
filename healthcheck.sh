#!/usr/bin/env sh

if [ -z ${LOCAL_PORT+x} ]; then
	LOCAL_PORT=${REMOTE_SERVER_PORT}
fi

nc -w 0 -n -z 127.0.0.1 "${LOCAL_PORT}" >/dev/null 2>&1
