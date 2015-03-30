#!/bin/bash

set -v

# decommission node 8 and re-add it without a bootstrap

ssh node8 nodetool decommission

ssh node8 'rm -rf /mnt/ephemeral/cassandra/*/* /var/log/cassandra/*'

ssh node8 "if ! grep -q 'auto_bootstrap: false' /etc/cassandra/cassandra.yaml; then echo 'auto_bootstrap: false' >> /etc/cassandra/cassandra.yaml; fi"

ssh node8 service cassandra restart

# Let compactions catch up for 45 minutes
sleep 2700

