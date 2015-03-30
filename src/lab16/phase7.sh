#!/bin/bash

set -v

for i in {0..4}; do
ssh node$i "sed '/^#MAX_HEAP_SIZE/ cMAX_HEAP_SIZE=6G
/^#HEAP_NEWSIZE/ cHEAP_NEWSIZE=4G' -i /etc/cassandra/cassandra-env.sh"

ssh node$i service cassandra restart

done

