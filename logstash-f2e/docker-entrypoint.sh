#!/bin/bash

set -e

if [ -n "$ELASTICSEARCH_SERVICE_CLUSTER" ]; then
        sed -ri "s#ELASTICSEARCH_CLUSTER#$ELASTICSEARCH_SERVICE_CLUSTER#g" /etc/logstash/conf.d/main.conf
fi

if [ -n "$ELASTICSEARCH_SERVICE_HOST" ]; then
        sed -ri "s#ELASTICSEARCH_HOST#$ELASTICSEARCH_SERVICE_HOST#g" /etc/logstash/conf.d/main.conf
fi

if [ -n "$ELASTICSEARCH_SERVICE_PORT" ]; then
        sed -ri "s#ELASTICSEARCH_PORT#$ELASTICSEARCH_SERVICE_PORT#g" /etc/logstash/conf.d/main.conf
fi

# Add logstash as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- logstash "$@"
fi

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
	set -- gosu logstash "$@"
fi

exec "$@"
