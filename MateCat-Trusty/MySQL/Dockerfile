FROM ostico/trusty-base:latest

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
RUN echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7" >> /etc/apt/sources.list.d/mysql.list
RUN echo "deb http://repo.mysql.com/apt/ubuntu/ trusty connector-python-2.0" >> /etc/apt/sources.list.d/mysql.list
RUN apt-get update
RUN apt-get install -y mysql-server

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

COPY my.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

ENV MYSQL_PASS "admin"
COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

CMD ["/tmp/run.sh"]

