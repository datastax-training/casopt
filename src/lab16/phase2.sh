#!/bin/bash

set -v

# decommission node 8 and re-add it without a bootstrap

ssh node8_ext nodetool decommission

ssh node8_ext 'rm -rf /mnt/ephemeral/cassandra/*/* /var/log/cassandra/*'

ssh node8_ext "if ! grep -q 'auto_bootstrap: false' /etc/cassandra/cassandra.yaml; then echo 'auto_bootstrap: false' >> /etc/cassandra/cassandra.yaml; fi"

ssh node8_ext service cassandra restart

# Let compactions catch up for 45 minutes
sleep 2700

