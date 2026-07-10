#!/bin/sh

if [ ! -f /opt/unbound/etc/unbound/unbound.conf ]; then
    cp /opt/unbound/etc/unbound/default.conf /opt/unbound/etc/unbound/unbound.conf
fi

mkdir -p /opt/unbound/etc/unbound/dev && \
cp -a /dev/random /dev/urandom /dev/null /opt/unbound/etc/unbound/dev/

mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
chown _unbound:_unbound /opt/unbound/etc/unbound/var && \
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
