FROM ostico/matecat-noble-base-image:latest
ARG DOCKER_PLATFORM=linux/amd64

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
RUN export DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y full-upgrade && \
    apt -y install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois perl perl-base perl-modules

WORKDIR /tmp
RUN PROXYSQL_ARCH="${DOCKER_PLATFORM##*/}" && \
    wget "https://github.com/sysown/proxysql/releases/download/v2.1.1/proxysql_2.1.1-ubuntu20_${PROXYSQL_ARCH}.deb" && \
    dpkg -i "proxysql_2.1.1-ubuntu20_${PROXYSQL_ARCH}.deb"

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]
