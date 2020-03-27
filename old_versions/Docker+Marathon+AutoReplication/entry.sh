#!/bin/bash
systemd-tmpfiles --create
/usr/sbin/sshd
docker-entrypoint.sh mysqld
