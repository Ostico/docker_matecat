FROM ostico/trusty-base:latest

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV JAVA_OPTS '-Xmx256M'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update
RUN apt-get install -y --force-yes openjdk-8-jre

RUN cd /tmp/
RUN wget http://archive.apache.org/dist/activemq/5.13.2/apache-activemq-5.13.2-bin.tar.gz
RUN tar xzf apache-activemq-5.13.2-bin.tar.gz && rm apache-activemq-5.13.2-bin.tar.gz
RUN mv apache-activemq-5.13.2 /opt
RUN ln -sf /opt/apache-activemq-5.13.2/ /opt/activemq
RUN adduser -system activemq
RUN sed -i "s#activemq:/bin/false#activemq:/bin/bash#g" /etc/passwd
RUN chown -R activemq: /opt/apache-activemq-5.13.2/
RUN ln -sf /opt/activemq/bin/activemq /etc/init.d/


COPY installActivemq.sh /tmp/installActivemq.sh
RUN chmod +x /tmp/installActivemq.sh

CMD ["/tmp/installActivemq.sh"]