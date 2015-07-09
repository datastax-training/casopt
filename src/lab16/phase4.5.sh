#!/bin/bash

set -v

ssh node3_ext "if ! grep -q 'Dcassandra.replace_address' /etc/cassandra/cassandra-env.sh; then echo JVM_OPTS=\"\\\"\\\$JVM_OPTS -Dcassandra.replace_address=123.123.123.123\\\"\" >> /etc/cassandra/cassandra-env.sh; fi"

ssh node3_ext service cassandra restart

