#!/bin/bash

LOG=/dev/null

function usage() {
   echo
   echo "Usage: renamenodes.sh <node name stem>"
}

STEM=$1

echo Stopping services:

NODELIST="0 1 2"

for i in $NODELIST ; do
   ssh node$i bash -c "'sudo service datastax-agent stop; sudo service dse stop 2>$LOG; sudo service cassandra stop 2>$LOG; sudo service opscenterd stop 2>$LOG'"
done
echo

echo Renaming hosts:
for i in $NODELIST; do
  ssh node$i  hostname $STEM$i
  ssh node$i sed -i "'s/node$i/$STEM$i/'" /etc/hosts
done
echo

echo Starting services:
for i in $NODELIST ; do
   ssh node$i sudo service opscenterd start 2>$LOG
done

for i in $NODELIST ; do
   ssh node$i bash -c "'sudo service cassandra start 2>$LOG; sudo service dse start 2>$LOG; sleep 5; sudo service datastax-agent start'"
done

sleep 20

cluster2hosts.sh node0
