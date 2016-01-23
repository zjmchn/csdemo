FROM java

ADD http://mirrors.gigenet.com/apache/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz /opt/

RUN cd /opt && tar zxvf kafka_2.10-0.8.2.1.tgz && rm kafka_2.10-0.8.2.1.tgz

ENV KAFKA_HOME /opt/kafka_2.10-0.8.2.1
ADD start-kafka.sh /usr/bin/start-kafka.sh
CMD start-kafka.sh
