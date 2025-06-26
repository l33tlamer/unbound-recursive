FROM debian:bookworm AS openssl

ENV VERSION_OPENSSL=openssl-3.5.0 \
    SHA256_OPENSSL=344d0a79f1a9b08029b0744e2cc401a43f9c90acd1044d09a530b4885a8e9fc0 \
    SOURCE_OPENSSL=https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz \
    ASC_OPENSSL=https://github.com/openssl/openssl/releases/download/openssl-3.5.0/openssl-3.5.0.tar.gz.asc

WORKDIR /tmp/src

RUN set -e -x && \
    build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev libssl-dev" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $build_deps && \
    curl -L $SOURCE_OPENSSL -o openssl.tar.gz && \
    echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c - && \
    curl -L $ASC_OPENSSL -o openssl.tar.gz.asc && \
    GNUPGHOME="$(mktemp -d)" && \
    export GNUPGHOME && \
    gpg --no-tty --auto-key-locate hkps://keys.openpgp.org --locate-keys openssl@openssl.org && \
    gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd $VERSION_OPENSSL && \
    ./config \
      --prefix=/opt/openssl \
      --openssldir=/opt/openssl \
      no-weak-ssl-ciphers \
      no-ssl3 \
      no-shared \
      enable-ec_nistp_64_gcc_128 \
      -DOPENSSL_NO_HEARTBEATS \
      -fstack-protector-strong && \
    make depend && \
    nproc | xargs -I % make -j% && \
    make install_sw && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

FROM debian:bookworm AS unbound

ENV NAME=unbound \
    UNBOUND_VERSION=1.23.0 \
    UNBOUND_SHA256=959bd5f3875316d7b3f67ee237a56de5565f5b35fc9b5fc3cea6cfe735a03bb8 \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.23.0.tar.gz

WORKDIR /tmp/src

COPY --from=openssl /opt/openssl /opt/openssl

RUN build_deps="curl gcc libc-dev libevent-dev libexpat1-dev libnghttp2-dev make" && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $build_deps \
      bsdmainutils \
      ca-certificates \
      ldnsutils \
      libevent-2.1-7 \
      libexpat1 \
      libprotobuf-c-dev \
      protobuf-c-compiler && \
    curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-$UNBOUND_VERSION && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /etc _unbound && \
    ./configure \
        --disable-dependency-tracking \
        --prefix=/opt/unbound \
        --with-pthreads \
        --with-username=_unbound \
        --with-ssl=/opt/openssl \
        --with-libevent \
        --with-libnghttp2 \
        --enable-dnstap \
        --enable-tfo-server \
        --enable-tfo-client \
        --enable-event-api \
        --enable-subnet && \
    make install && \
    mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/unbound.conf.example && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*


FROM debian:bookworm

ENV SUMMARY="unbound is a validating, recursive, and caching DNS resolver." \
    DESCRIPTION="unbound is a validating, recursive, and caching DNS resolver."

WORKDIR /tmp/src

COPY --from=unbound /opt /opt

RUN set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      bsdmainutils \
      ca-certificates \
      ldnsutils \
      libevent-2.1-7 \
      libnghttp2-14 \
      libexpat1 \
      libprotobuf-c1 && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /etc _unbound && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /opt/unbound/share/man \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

COPY data/ /

RUN chmod +x /unbound.sh

WORKDIR /opt/unbound/

ENV PATH /opt/unbound/sbin:"$PATH"

LABEL org.opencontainers.image.version=unbound-1.23.0-openssl-3.5.0-bookworm

EXPOSE 5353/tcp
EXPOSE 5353/udp

HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=3 CMD drill google.com @127.0.0.1 -p 5353 || exit 1

CMD ["/unbound.sh"]
