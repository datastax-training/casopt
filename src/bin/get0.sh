#!/bin/bash

function usage() {
   echo
   echo "Usage: get0.sh <any node in cluster>"
   echo "Return the public ip for opscenter"
   echo
}

if [[ -z $1 ]]; then
    usage
    exit
fi

FIRSTNODE=$1

nodelist=`nodetool -h $FIRSTNODE status |  sed '/[UD][NLJM]/!d ; s/..  \([0-9\.]*\) .*/\1/'`

for ip in $nodelist; do
    ssh $ip 'if [ `curl -s http://169.254.169.254/latest/meta-data/ami-launch-index` == 0 ]; then curl -s http://169.254.169.254/latest/meta-data/public-ipv4; echo; fi'
done
 
