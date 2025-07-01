# Unbound-Recursive

Simple Docker image for [Unbound](https://nlnetlabs.nl/projects/unbound/about/) as recursive DNS resolver with DNSSEC.

**This is heavily based on [mvance/unbound](https://hub.docker.com/r/mvance/unbound), all credit to them.**

This is simply for personal use to have a more up-to-date version of Unbound.

As at your own risk, i provide no support at all.

Image is available at:

* [Docker Hub](https://hub.docker.com/r/l33tlamer/unbound-recursive): `docker.io/l33tlamer/unbound-recursive:latest`

* [Github](https://github.com/l33tlamer/unbound-recursive/pkgs/container/unbound-recursive): `ghcr.io/l33tlamer/unbound-recursive:latest`

Available tags:

* `1.23.0` Unbound v1.23.0 with OpenSSL v3.5.1

* `1.22.0` Unbound v1.22.0 with OpenSSL v3.4.1

* `1.21.0` Unbound v1.21.0 with OpenSSL v3.3.2

* `latest` equals `1.23.0`

Currently for `amd64` only, maybe `arm` later.

`unbound -V` output:
```
Version 1.23.0

Configure line: --disable-dependency-tracking --prefix=/opt/unbound --with-pthreads --with-username=_unbound --with-ssl=/opt/openssl --with-libevent --with-libnghttp2 --enable-dnstap --enable-tfo-server --enable-tfo-client --enable-event-api --enable-subnet
Linked libs: libevent 2.1.12-stable (it uses epoll), OpenSSL 3.5.0 8 Apr 2025
Linked modules: dns64 subnetcache respip validator iterator
TCP Fastopen feature available
````

**Note:** The image will check if `/opt/unbound/etc/unbound/unbound.conf` exists, and if it doesnt, it will
create its own with certain default values. Inspect the `/unbound.sh` script for those defaults.
If you want to use your own custom config, i suggest you use a bind mount at container runtime:

`-v /your/own/unbound.conf:/opt/unbound/etc/unbound/unbound.conf`

Image source is available at:

* https://github.com/l33tlamer/unbound-recursive

Example Docker Compose setup to use this with [Pihole](https://pi-hole.net) can be found here:

* https://github.com/l33tlamer/pihole-unbound

Enjoy.
