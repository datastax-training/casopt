#!/bin/bash

LOG=/dev/null

function usage() {
   echo
   echo "Usage: renamenodes.sh <node name stem> <any node in cluster>"
}

if [[ -z $1 ]]; then
    usage
    exit
fi
CLUSTER=$1

if [[ -z $2 ]]; then
    usage
    exit
fi
FIRSTNODE=$2

# Make sure C* is running
i=1
until ssh $FIRSTNODE nodetool info >/dev/null 2>&1
do
   echo "Waiting for Cassandra"
   sleep 10;
    i=$((i+1))
   if [ $i -gt 10 ] ; then
     echo "Cluster is not up";
     exit 1
   fi
done

#get nodes sorted by datacenter
#then by launch index

NODELIST0=`ssh $FIRSTNODE nodetool status | sed -n '/Datacenter/ { s/.*: // ; h }
/..  [0-9]/ { G ; s/[^0-9]*\([0-9.]*\).*\n\(.*\)/\2 \1/ ; p } ' `

export IFS=$'\n'

NODELIST=$( for NODEENTRY in $NODELIST0 ; do ip=`cut -f2,2 -d\  <<<$NODEENTRY`; echo `ssh $ip curl -s 169.254.169.254/latest/meta-data/ami-launch-index` $NODEENTRY; done  | sort -k 2,2 -k 1n,1 | cut -f 3,3 -d\   )

unset IFS

echo $NODELIST

echo Stopping services:

for ip in $NODELIST ; do
   echo ${ip}:
   ssh $ip bash -c "'sudo service datastax-agent stop; sudo service dse stop 2>$LOG; sudo service cassandra stop 2>$LOG; sudo service opscenterd stop 2>$LOG'"
done
echo

echo Renaming hosts:
i=0
for ip in $NODELIST; do
echo $ip
  ssh $ip 'newhost='$CLUSTER$i'; echo $newhost;  sudo bash -c '"'"'echo `curl -s http://169.254.169.254/latest/meta-data/local-ipv4` '"'"'$newhost'"'"' >> /etc/hosts'"'"'; sudo hostname $newhost;' ;
i=$((i+1))
done
echo

echo Starting services:
for ip in $NODELIST ; do
  echo $ip
   ssh $ip sudo service opscenterd start 2>$LOG
done

for ip in $NODELIST ; do
   echo $ip
   ssh $ip bash -c "'sudo service cassandra start 2>$LOG; sudo service dse start 2>$LOG; sleep 5; sudo service datastax-agent start'"
done

sleep 20

cluster2hosts.sh $FIRSTNODE

