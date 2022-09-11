#!/usr/bin/env sh

echo "[DEBUG] ssh-tunnel $*" >&2
echo "[DEBUG] SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >&2

#	-o StrictHostKeyChecking=no \
/usr/bin/ssh \
	-NTC \
	-o ServerAliveInterval=60 \
	-o GatewayPorts=true \
	-o ExitOnForwardFailure=yes \
	"$@"
