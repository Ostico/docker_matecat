FROM ostico/bionic-base:latest

ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_PASS "admin"

RUN apt-get update && apt-get -y full-upgrade

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl

COPY mysql.keyFile.asc /tmp/mysql.keyFile.asc
RUN gpg --import /tmp/mysql.keyFile.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5072E1F5

#RUN echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7" >> /etc/apt/sources.list.d/mysql.list
RUN echo "deb http://repo.mysql.com/apt/ubuntu/ trusty connector-python-2.0" >> /etc/apt/sources.list.d/mysql.list

RUN apt-get update && apt-get install -y mysql-server libev4 libgcrypt11-dev libcurl4-openssl-dev libdbd-mysql-perl rsync

WORKDIR /tmp
RUN wget https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/debian/bionic/x86_64/percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
RUN dpkg -i percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
RUN rm -f percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb

COPY my.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld && rm -rf /var/lib/mysql/auto.cnf
RUN rm -fr /var/lib/mysql
RUN /usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --initialize-insecure --user=mysql

WORKDIR /var/lib/mysql-files
RUN mkdir -p ./binlog && chown mysql:mysql ./binlog && find . -type d -exec chmod 770 '{}' \; && find . -type f -exec chmod 660 '{}' \; && find /var/lib/mysql -type f -exec touch {} \;

WORKDIR /tmp

CMD ["mysqld_safe", "--defaults-file=/etc/mysql/my.cnf", "--user=mysql", "--plugin-dir=/usr/lib/mysql/plugin"]
