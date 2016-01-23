#!/bin/bash

# export ZOOKEEPER_CONNECT=$(echo $ZOOKEEPER_PORT_2181_TCP | sed -e 's|.*tcp://||')

java -cp /KafkaOffsetMonitor-assembly-0.2.1.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb --zk $ZOOKEEPER_CONNECT --port 8080 --refresh 10.seconds --retain 7.days &
KAFKA_MONITOR_PID=$!

wait $KAFKA_MONITOR_PID
