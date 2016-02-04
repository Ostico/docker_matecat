FROM ostico/matecatprecise:latest

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

ENV MYSQL_FILE mysql-5.6.16-debian6.0-x86_64.deb
ENV MYSQL_BASE /opt/mysql/server-5.6
ENV MYSQL_DATA /var/lib/mysql
ENV MYSQL_LOGS /var/log/mysql
ENV MYSQL_PID_DIR /var/run/mysqld

RUN (cd /tmp/ && wget http://dev.mysql.com/get/Downloads/MySQL-5.6/${MYSQL_FILE})
#COPY ./mysql-5.6.16-debian6.0-x86_64.deb /tmp/${MYSQL_FILE}
RUN (dpkg -i /tmp/${MYSQL_FILE} && rm /tmp/${MYSQL_FILE})
RUN (groupadd mysql && useradd -r -g mysql mysql)
RUN mkdir -p ${MYSQL_DATA}
RUN chown mysql:mysql ${MYSQL_DATA}

RUN mkdir -p ${MYSQL_PID_DIR}
RUN chown -R mysql:mysql ${MYSQL_PID_DIR}

ENV PATH ${PATH}:${MYSQL_BASE}/bin

RUN mkdir -p /etc/mysql/conf.d/
RUN chown -R mysql:mysql /etc/mysql/conf.d/
RUN mkdir -p ${MYSQL_LOGS}
RUN touch ${MYSQL_LOGS}/error.log
RUN chown -R mysql:mysql ${MYSQL_LOGS}
RUN ln -s ${MYSQL_BASE}/share/english/ /usr/share/mysql
RUN ln -s ${MYSQL_BASE}/bin/mysqld_safe /usr/bin/mysqld_safe

RUN echo "${MYSQL_BASE}/scripts/mysql_install_db --user=mysql --ldata=${MYSQL_DATA} --basedir=${MYSQL_BASE}/"
RUN ${MYSQL_BASE}/scripts/mysql_install_db --user=mysql --ldata=${MYSQL_DATA} --basedir=${MYSQL_BASE}/

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

ENV MYSQL_PASS "admin"
COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

COPY my.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

CMD ["/tmp/run.sh"]

