#!/bin/bash

function usage() {
   echo
   echo "Usage: tailnode.sh <node> "
   echo Tail the log file on the given node
   echo
}

if [[ -z $1 ]]; then
    usage
    exit
fi

ssh $1 tail -n 500 -f /var/log/cassandra/system.log

