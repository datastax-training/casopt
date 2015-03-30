#!/bin/bash

function usage() {
   echo
   echo "Put the nodes in your cluster in /etc/hosts."
   echo
   echo "Usage: cluster2hosts: <<ip of any node in cluster>"
   echo
}

if [[ -z $1 ]]; then
    usage
    exit
fi
FIRSTNODE=$1

i=1
until nodetool -h $FIRSTNODE info >/dev/null 2>&1
do
   echo "Waiting for Cassandra"
   sleep 10;
    i=$((i+1))
   if [ $i -gt 10 ] ; then
     echo "Cluster is not up";
     exit 1
   fi
done

HOSTS=`nodetool -h $FIRSTNODE status 2>/dev/null |  sed '/[UD][NLJM]/!d ; s/..  \([0-9\.]*\) .*/\1/' `
 for ip in $HOSTS; do
    hostnm=`ssh -o StrictHostKeyChecking=no $ip hostname`
    hostline="$ip $hostnm"
    echo 'Adding:  ' $hostline
    sudo sed -i "$ a$hostline
    /$hostnm/ d" /etc/hosts
    #sudo bash -c "echo $hostline >> /etc/hosts"
 done

