#!/bin/bash

export KAFKA_ADVERTISED_HOST_NAME=$(hostname -i)
export KAFKA_ADVERTISED_PORT=$KAFKA_SERVICE_PORT
export KAFKA_PORT=$KAFKA_SERVICE_PORT

# TODO: query Kafka cluster meta data from zookeeper!
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    # Use container's IP address as broker ID - which means the data will lost when container crashed (or IP changed)!
    export KAFKA_BROKER_ID=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}' | sed -r 's/\.//g')
fi

if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$KAFKA_BROKER_ID"
fi

# TODO: query Zookeeper cluster meta data from Kubernetes ApiServer!
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    # Currently only support single zookeeper node - which should be OK because it's via the Zookeeper service - kube will dispatch the traffic.
    export KAFKA_ZOOKEEPER_CONNECT=$(echo $ZOOKEEPER_PORT_2181_TCP | sed -e 's|.*tcp://||')
fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    fi
  fi
done

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
KAFKA_SERVER_PID=$!

FAILURE_COUNT=60
while ss -lnt | awk '$4 ~ /:9092$/ {exit 1}';
do
  sleep 1
  FAILURE_COUNT=`expr $FAILURE_COUNT - 1`
  if [[ $FAILURE_COUNT -eq 0 ]]; then
    exit 1;
  fi
done

if [[ -n $KAFKA_CREATE_TOPICS ]]; then
    IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
        IFS=':' read -a topicConfig <<< "$topicToCreate"
        $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}"
    done
fi

wait $KAFKA_SERVER_PID
