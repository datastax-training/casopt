#!/bin/bash

function usage() {
   echo
   echo "Usage: renamenodes.sh <newhostname> <any node in cluster>"
}

if [[ -z $1 ]]; then
    usage
    exit
fi
NEWHOST=$1

if [[ -z $2 ]]; then
    usage
    exit
fi
FIRSTNODE=$2

echo Stopping services:

ssh $FIRSTNODE bash -c "'sudo service datastax-agent stop; sudo service cassandra stop; sudo service dse stop; sudo service opscenterd stop'"

echo Renaming hosts:
ssh $FIRSTNODE 'newhost='$NEWHOST'; echo $newhost;  sudo bash -c '"'"'echo `curl -s http://169.254.169.254/latest/meta-data/local-ipv4` '"'"'$newhost'"'"' >> /etc/hosts'"'"'; sudo hostname $newhost;' ;
echo

echo Starting services:

ssh $FIRSTNODE bash -c "'sudo service cassandra start; sudo service dse start; sleep 5; sudo service datastax-agent start; sudo service opscenterd start'"

sudo bash -c "echo $FIRSTNODE $NEWHOST >> /etc/hosts" 

