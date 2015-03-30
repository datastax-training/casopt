#!/bin/bash

set -v

ssh node3 "if ! grep -q 'Dcassandra.replace_address' /etc/cassandra/cassandra-env.sh; then echo JVM_OPTS=\"\\\"\\\$JVM_OPTS -Dcassandra.replace_address=123.123.123.123\\\"\" >> /etc/cassandra/cassandra-env.sh; fi"

ssh node3 service cassandra restart

