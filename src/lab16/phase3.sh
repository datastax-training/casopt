#!/bin/bash

set -v

ssh node7 "sed '/stomp_interface/ !d' -i /var/lib/datastax-agent/conf/address.yaml"

ssh node7 service datastax-agent restart

