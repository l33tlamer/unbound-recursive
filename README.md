# Unbound-Recursive

Simple Docker image for [Unbound](https://nlnetlabs.nl/projects/unbound/about/) as recursive DNS resolver with DNSSEC.

**This is heavily based on [mvance/unbound](https://hub.docker.com/r/mvance/unbound), all credit to them.**

This is simply for personal use to have a more up-to-date version of Unbound.

As at your own risk, i provide no support at all.

**NEWS:** There is now a **Alpine-based image** available under the `:alpine` image tag. So far it has been working without problems for myself. It will stay under that dedicated tag for a while and if there are no issues, it becomes the new default and the outdated and much larger Debian build becomes optional.

Image is available at:

* [Docker Hub](https://hub.docker.com/r/l33tlamer/unbound-recursive): `docker.io/l33tlamer/unbound-recursive:latest`

* [Github](https://github.com/l33tlamer/unbound-recursive/pkgs/container/unbound-recursive): `ghcr.io/l33tlamer/unbound-recursive:latest`

Available tags:

* `latest` equals `1.25.1`

* `1.25.1` Unbound v1.25.1 with OpenSSL v3.6.2 (Debian Bookworm)

* `alpine` Unbound v1.25.1 with OpenSSL v3.6.2 (Alpine 3.24)

* `1.24.1` Unbound v1.24.1 with OpenSSL v3.6.0 (Debian Bookworm)

* `1.24.0` Unbound v1.24.0 with OpenSSL v3.6.0 (Debian Bookworm)

Currently for `amd64` only, maybe `arm` later.

`unbound -V` output:
```
Version 1.25.1

Configure line: --disable-dependency-tracking --prefix=/opt/unbound --with-pthreads --with-username=_unbound --with-ssl=/opt/openssl --with-libevent --with-libnghttp2 --enable-dnstap --enable-tfo-server --enable-tfo-client --enable-event-api --enable-subnet
Linked libs: libevent 2.1.12-stable (it uses epoll), OpenSSL 3.6.2 7 Apr 2026
Linked modules: dns64 subnetcache respip validator iterator
TCP Fastopen feature available
````

**Note:** The image will check if `/opt/unbound/etc/unbound/unbound.conf` exists, and if it doesnt, it will
create a config by copying from `/opt/unbound/etc/unbound/default.conf`.

If you want to use your own **custom config**, i suggest you use a **bind mount** at container runtime:

`-v /your/own/unbound.conf:/opt/unbound/etc/unbound/unbound.conf`

You should also take a look at [optional performance tuning](https://unbound.docs.nlnetlabs.nl/en/latest/topics/core/performance.html):

For example: Number of `threads` and `slabs`, size of `rr_cache_size` and `msg_cache_size`.

Image source is available at:

* https://github.com/l33tlamer/unbound-recursive

Example Docker Compose setup to use this with [Pihole](https://pi-hole.net) can be found here:

* https://github.com/l33tlamer/pihole-unbound

Enjoy.
