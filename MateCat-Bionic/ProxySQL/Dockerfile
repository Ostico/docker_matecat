FROM renecannao/proxysql:build-ubuntu16

RUN apt-get update
RUN apt-get  -y --fix-missing install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules

RUN apt-get  -y full-upgrade

WORKDIR /tmp
RUN wget https://github.com/sysown/proxysql/releases/download/v2.0.2/proxysql_2.0.2-dbg-ubuntu16_amd64.deb
RUN dpkg -i proxysql_2.0.2-dbg-ubuntu16_amd64.deb

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]