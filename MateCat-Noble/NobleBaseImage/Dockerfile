FROM ubuntu:24.04 AS matecat-noble-base-image

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update
RUN apt-get -y install pcp # Install PCP first to avoid conflicts with other packages
# Install other packages
RUN apt-get -y --fix-missing --fix-broken install apt-utils vim locate iputils-ping git curl wget net-tools tree software-properties-common locales \
    psmisc screen dstat \
    traceroute whois perl perl-base perl-modules

RUN apt-get -y full-upgrade