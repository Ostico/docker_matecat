FROM ostico/matecat-focal-base-image:latest

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

RUN wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

RUN apt-get update
RUN apt-get -y full-upgrade
RUN apt-get install -y libev4 libcurl4-openssl-dev libdbd-mysql-perl rsync gnupg2 percona-server-server-5.7

WORKDIR /tmp
#RUN wget https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/debian/bionic/x86_64/percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
#RUN dpkg -i percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

RUN mkdir -p /var/lib/mysql-files/binlog
RUN chown -R mysql:mysql /var/lib/mysql-files/binlog

ARG _type_
ENV _type_=$_type_
ENV MYSQL_PASS "admin"

COPY my-${_type_}.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

RUN rm -rf /var/lib/mysql/auto.cnf

VOLUME ["/var/lib/mysql/"]

CMD ["/tmp/run.sh"]

