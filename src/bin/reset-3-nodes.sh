#!/bin/bash

set -v 

ssh node1 service cassandra stop
ssh node2 service cassandra stop
ssh node0 service cassandra stop
sleep 10
ssh node0 rm -rf /mnt/ephemeral/cassandra/*/*
ssh node0 'if [ -f /etc/cassandra/.cassandra.yaml ] ; then cd /etc/cassandra; else cd /etc/dse/cassandra; fi;  cp .cassandra.yaml cassandra.yaml; cp .cassandra-env.sh cassandra-env.sh'
ssh node0 service cassandra start
sleep 15
wipeandadd.sh node1 node0
wipeandadd.sh node2 node0
sleep 10
ssh node0 service opscenterd restart

ssh node0 service datastax-agent restart
ssh node1 service datastax-agent restart
ssh node2 service datastax-agent restart

