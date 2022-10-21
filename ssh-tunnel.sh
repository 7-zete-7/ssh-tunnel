#!/usr/bin/env sh

if [ -z ${LOCAL_PORT+x} ]; then
	LOCAL_PORT=${REMOTE_SERVER_PORT}
fi

if [ -z ${SSH_AUTH_SOCK+x} ]; then
	echo "[INFO] SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >&2
fi

echo "[DEBUG] ssh-tunnel $*" >&2

#	-o StrictHostKeyChecking=no \
/usr/bin/ssh \
	-NTC \
	-o ServerAliveInterval=60 \
	-o GatewayPorts=true \
	-o ExitOnForwardFailure=yes \
	"$@" &

SSH_PID=$!
trap "kill -SIGINT ${SSH_PID}" SIGINT
trap "kill -SIGTERM ${SSH_PID}" SIGTERM
trap "kill -SIGSTOP ${SSH_PID}" SIGSTOP
wait ${SSH_PID}
