FROM java

RUN cd / && \
    curl -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.tar.gz && \
    tar xf elasticsearch-1.7.2.tar.gz && \
    rm elasticsearch-1.7.2.tar.gz

ADD pkgs/head.tar.gz /elasticsearch-1.7.2/plugins/

COPY pkgs/elasticsearch_discovery /
COPY elasticsearch.yml /elasticsearch-1.7.2/config/elasticsearch.yml
COPY run.sh /

EXPOSE 9200 9300

CMD ["/run.sh"]
