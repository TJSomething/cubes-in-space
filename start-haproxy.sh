#!/usr/bin/sh

set -e

echo "nameserver 1.1.1.2" >> /etc/resolv.conf

exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
