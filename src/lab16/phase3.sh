#!/bin/bash

set -v

ssh node7_ext "sed '/stomp_interface/ !d' -i /var/lib/datastax-agent/conf/address.yaml"

ssh node7_ext service datastax-agent restart

