#!/usr/bin/env sh

if [ "${1#-}" != "$1" ]
then
	set -- ssh-tunnel "$@"
fi

if [ "$1" = 'ssh' ] || [ "$1" = 'ssh-tunnel' ]; then
	if [ ! -d ~/.ssh ]; then
		mkdir -p ~/.ssh
		chmod 0700 ~/.ssh
	fi

	if [ -z ${SSH_SERVER_HOST+x} ]; then
		echo '[ERROR] The required environment variable SSH_SERVER_HOST has not been set.' >&2
		exit 1
	fi

	if [ -z ${SSH_SERVER_PORT+x} ]; then
		echo ' [INFO] The standard port 22 for SSH server will be used. To set a custom port, set the SSH_SERVER_PORT environment variable.' >&2
		SSH_SERVER_PORT=22
	fi

	if [ ! -f ~/.ssh/known_hosts ]; then
		ssh-keyscan -p "${SSH_SERVER_PORT}" -H "${SSH_SERVER_HOST}" 1>> ~/.ssh/known_hosts 2>/dev/null
		chmod 0600 ~/.ssh/known_hosts
	fi

	if [ -z ${SSH_SERVER_USER+x} ]; then
		echo '[ERROR] The required environment variable SSH_SERVER_USER has not been set.' >&2
		exit 1
	fi

	if [ -z ${REMOTE_SERVER_HOST+x} ]
	then
		echo ' [INFO] The standard host "localhost" for remote server will be used. To set a custom host, set the REMOTE_SERVER_HOST environment variable.' >&2
		REMOTE_SERVER_HOST=localhost
	fi

	if [ -z ${REMOTE_SERVER_PORT+x} ]
	then
		echo '[ERROR] The required environment variable REMOTE_SERVER_PORT has not been set.' >&2
		exit 1
	fi

	if [ -z ${LOCAL_PORT+x} ]
	then
		echo " [INFO] The similar port ${REMOTE_SERVER_PORT} for local tunnel will be used. To set a custom port, set then LOCAL_PORT environment variable." >&2
		LOCAL_PORT=${REMOTE_SERVER_PORT}
	fi

	echo "[DEBUG] Set args: -L ${LOCAL_PORT}:${REMOTE_SERVER_HOST}:${REMOTE_SERVER_PORT} -p ${SSH_SERVER_PORT} ${SSH_SERVER_USER}@${SSH_SERVER_HOST}" >&2
	set -- "$@" -L "${LOCAL_PORT}:${REMOTE_SERVER_HOST}:${REMOTE_SERVER_PORT}" -p "${SSH_SERVER_PORT}" "${SSH_SERVER_USER}@${SSH_SERVER_HOST}"
fi

exec "$@"