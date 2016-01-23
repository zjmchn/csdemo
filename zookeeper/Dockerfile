FROM java

RUN cd /opt && \
    curl -O http://mirror.olnevhost.net/pub/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz && \
    tar zxvf zookeeper-3.4.6.tar.gz && mv zookeeper-3.4.6  zookeeper && \
    cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg && \
    mkdir -p /tmp/zookeeper && rm /opt/zookeeper-3.4.6.tar.gz

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper

ENTRYPOINT ["/opt/zookeeper/bin/zkServer.sh"]

CMD ["start-foreground"]
