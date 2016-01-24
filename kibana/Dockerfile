FROM debian:jessie

RUN groupadd -r kibana && useradd -r -g kibana kibana

ADD pkgs/gosu-amd64 /usr/local/bin/gosu

ADD http://download.elastic.co/kibana/kibana/kibana-4.1.4-linux-x64.tar.gz /opt/

RUN cd /opt && tar zxvf kibana-4.1.4-linux-x64.tar.gz && \
    mv kibana-4.1.4-linux-x64 kibana && \
    rm kibana-4.1.4-linux-x64.tar.gz

ENV PATH /opt/kibana/bin:$PATH

COPY ./docker-entrypoint.sh /

EXPOSE 5601
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kibana"]
