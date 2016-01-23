#!/bin/bash

set -e

# Add logstash as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- logstash "$@"
fi

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
	set -- gosu logstash "$@"
        if [ "$KAFKA_URL" -o "$KAFKA_PORT" ]; then
                : ${KAFKA_URL=`echo $KAFKA_PORT | sed -e 's|tcp://||'`}
                sed -ri "s#^(\s+broker_list).*#\1 => '$KAFKA_URL'#g" /etc/logstash/conf.d/main.conf
        else
                echo >&2 'warning: missing KAFKA_URL or KAFKA_PORT'
                echo >&2 '  Did you forget to --link some-kafka:kafka'
                echo >&2 '  or -e KAFKA_URL=some-kakfa:9092 ?'
                echo >&2
        fi
fi

exec "$@"
