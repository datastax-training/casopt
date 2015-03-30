#!/bin/bash

set -v

ssh node5 "sed '/^endpoint_snitch/ cendpoint_snitch: Ec2Snitch' -i /etc/cassandra/cassandra.yaml"

ssh node5 service cassandra restart

