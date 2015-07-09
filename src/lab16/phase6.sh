#!/bin/bash

set -v

ssh node5_ext "sed '/^endpoint_snitch/ cendpoint_snitch: Ec2Snitch' -i /etc/cassandra/cassandra.yaml"

ssh node5_ext service cassandra restart

