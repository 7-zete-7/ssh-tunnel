# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.16

FROM alpine:${ALPINE_VERSION}
MAINTAINER Stanislau Kviatkouski <7zete7@gmail.com>

RUN --mount=type=cache,target=/var/cache/apk/ \
	apk add openssh-client

COPY ./entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

COPY ./healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

COPY ./ssh-tunnel.sh /usr/local/bin/ssh-tunnel
RUN chmod +x /usr/local/bin/ssh-tunnel

# Security fix for CVE-2016-0777 and CVE-2016-0778
RUN echo -e 'Host *\nUseRoaming no' >> /etc/ssh/ssh_config

ENTRYPOINT ["docker-entrypoint"]
HEALTHCHECK --interval=2s --timeout=1s --start-period=1s --retries=10 \
	CMD ["docker-healthcheck"]
CMD ["ssh-tunnel"]
