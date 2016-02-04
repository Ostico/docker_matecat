FROM ostico/matecatprecise:latest

ENV JAVA_OPTS '-Xmx256M'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# Oracle java is bulkier but avoids boot2docker/aufs docker issue 18180
RUN apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default


RUN cd /tmp/
RUN wget http://archive.apache.org/dist/activemq/5.13.0/apache-activemq-5.13.0-bin.tar.gz
RUN tar xzf apache-activemq-5.13.0-bin.tar.gz && rm apache-activemq-5.13.0-bin.tar.gz
RUN mv apache-activemq-5.13.0 /opt
RUN ln -sf /opt/apache-activemq-5.13.0/ /opt/activemq
RUN adduser -system activemq
RUN sed -i "s#activemq:/bin/false#activemq:/bin/bash#g" /etc/passwd
RUN chown -R activemq: /opt/apache-activemq-5.13.0/
RUN ln -sf /opt/activemq/bin/activemq /etc/init.d/


COPY installActivemq.sh /tmp/installActivemq.sh
RUN chmod +x /tmp/installActivemq.sh

CMD ["/tmp/installActivemq.sh"]