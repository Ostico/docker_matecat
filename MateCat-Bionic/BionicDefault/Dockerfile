FROM ubuntu:bionic

RUN apt-get update

RUN apt-get -y --fix-missing install ssh-client vim locate iputils-ping monit git curl wget net-tools tree software-properties-common locales \
    psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules

RUN apt-get -y full-upgrade