FROM ubuntu:bionic

MAINTAINER Peter Rehley <peter_rehley@yahoo.com>

RUN apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install bind9 && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

COPY util/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
