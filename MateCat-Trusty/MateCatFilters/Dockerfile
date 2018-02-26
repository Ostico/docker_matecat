FROM maven:3.3.3-jdk-8

RUN apt-get update
RUN apt-get install -y git

COPY filters-1.2.2.jar /tmp/filters-1.2.2.jar
CMD ["/tmp/startFilter.sh"]

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
