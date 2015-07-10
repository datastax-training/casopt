#!/bin/bash

set -v

ssh node5_ext "sed 's/^broadcast_address/#&/' -i /etc/cassandra/cassandra.yaml "

ssh node5_ext service cassandra restart

