FROM renecannao/proxysql:build-ubuntu14

RUN apt-get update
RUN apt-get -y --fix-missing install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules

RUN apt-get -y upgrade

WORKDIR /tmp
RUN wget https://github.com/sysown/proxysql/releases/download/v1.3.1/proxysql_1.3.1-dbg-ubuntu14_amd64.deb
RUN dpkg -i proxysql_1.3.1-dbg-ubuntu14_amd64.deb

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]