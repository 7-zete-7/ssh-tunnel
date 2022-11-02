# ssh-tunnel

## Configuration

### Environment variables

- `SSH_SERVER_HOST` — Target SSH server host for connection. Can be hostname or IP address. Required.
- `SSH_SERVER_PORT` — Target SSH server port for connection. Must be valid integer port number. Optional. Default value `22`.
- `SSH_SERVER_USER` — Target SSH server username. Must be valid username. Required.
- `REMOTE_SERVER_HOST` — Target service host for tunneling it. Can be hostname or IP address. Optional. Default value `localhost`.
- `REMOTE_SERVER_PORT` — Target service port for tunneling it. Must be valid integer port number. Required.
- `LOCAL_PORT` — Tunneled service port number of container. Must be valid integer port number. Optional. Default value same as `REMOTE_SERVER_PORT`.
- `HEALTHCHECK` — Set healthcheck level for forwarded port. Optional. Default value `soft`.
  Possible values:
  - `none` — Disables healthcheck by always saying _"health"_.
  - `soft` — Checks port listening (by using `netstat`).
  - `hard` — Checks port opening (by using `nc`). Can emit handshake issues on authorize-able services.

Also, can be added additional environment variables for `ssh` command. See _Environment_ article [ssh(1)](https://linux.die.net/man/1/ssh) manual page.

### Command arguments

All command arguments be attached to `ssh` command. See [ssh(1)](https://linux.die.net/man/1/ssh) manual page.

Default command arguments is `-N`, `-T`, `-C`, `-o ServerAliveInterval=60`, `-o GatewayPorts=true` and `-o ExitOnForwardFailure=yes`.

### Additional files

`config` and keys can be mounted to `/ssh` directory.

## Usage

### Simple Docker example

```sh
docker run --rm \
    -e SSH_SERVER_HOST=my-host.example \
    -e SSH_SERVER_USER=my-user \
    -e REMOTE_SERVER_PORT=3306 \
    -v '~/.ssh:/ssh:ro' \
    -p '127.0.0.1:3306:3306/tcp' \
    7-zete-7/ssh-tunnel:latest
```

### Simple Docker Compose example

```yaml
services:
  mysql-proxy:
    image: 7-zete-7/ssh-tunnel:latest
    volumes:
      - type: bind
        target: /ssh
        source: ${HOME}/.ssh
        read_only: true
    environment:
      SSH_SERVER_HOST: my-host.example
      SSH_SERVER_USER: my-user
      REMOTE_SERVER_PORT: 3306
    ports:
      - target: 3306
        published: 3306
        protocol: tcp
        host_ip: 127.0.0.1

  app:
    image: ...
    depends_on:
      - mysql-proxy
    environment:
      MYSQL_DSN: mysql://${MYSQL_USER:-app}:${MYSQL_PASSWORD:-!ChangeMe!}@mysql-proxy/${MYSQL_DATABASE:-app}
    ...
```

### Extended Docker Compose example

```yaml
services:
  mysql-proxy:
    image: 7-zete-7/ssh-tunnel:latest
    volumes:
      - type: bind
        target: /var/run/ssh/agent.sock
        source: ${SSH_AGENT_SOCK}
        read_only: true
    environment:
      SSH_AGENT_SOCK: /var/run/ssh/agent.sock
      SSH_SERVER_HOST: my-host.example
      SSH_SERVER_PORT: 2222
      SSH_SERVER_USER: my-user
      REMOTE_SERVER_HOST: deep-private-server.example
      REMOTE_SERVER_PORT: 3306
      LOCAL_PORT: 1234
    ports:
      - target: 1234
        published: 3306
        protocol: tcp

  app:
    image: ...
    depends_on:
      - mysql-proxy
    environment:
      MYSQL_DSN: mysql://${MYSQL_USER:-app}:${MYSQL_PASSWORD:-!ChangeMe!}@mysql-proxy:1234/${MYSQL_DATABASE:-app}
    ...
```
