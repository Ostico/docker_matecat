FROM ostico/matecat-focal-base-image:latest

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get full-upgrade && \
    apt-get -y install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules

WORKDIR /tmp
RUN wget https://github.com/sysown/proxysql/releases/download/v2.0.2/proxysql_2.0.2-dbg-ubuntu16_amd64.deb
RUN dpkg -i proxysql_2.0.2-dbg-ubuntu16_amd64.deb

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]