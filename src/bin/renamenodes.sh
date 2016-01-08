#!/bin/bash

LOG=/dev/null

function usage() {
   echo
   echo "Usage: renamenodes.sh <node name stem>"
}

if [[ -z $1 ]]; then
    usage
    exit
fi

# Read from the workstation's /etc/hosts, find IPs that have a node#
CLUSTER=$1
NEWHOST=""
NODELIST=""
declare -a NODENAME
re="^(([0-9]{1,3}.){3}[0-9]{1,3})((.*)node([0-9]+)$)"
i=0
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ $re ]]; then
      if [ -z "$NEWHOST" ]; then
        NEWHOST="${BASH_REMATCH[1]} $CLUSTER${BASH_REMATCH[5]}${BASH_REMATCH[3]}"
        NODELIST="${BASH_REMATCH[1]}"
      else
        NEWHOST="$NEWHOST\n${BASH_REMATCH[1]} $CLUSTER${BASH_REMATCH[5]}${BASH_REMATCH[3]}"
        NODELIST="$NODELIST ${BASH_REMATCH[1]}"
      fi
      NODENAME[$i]="$CLUSTER${BASH_REMATCH[5]}"
      i=$((i+1))
    else 
      if [ -z "$NEWHOST" ]; then
        NEWHOST="$line"
      else
        NEWHOST="$NEWHOST\n$line"
      fi 
    fi
done < /etc/hosts

echo -e $NEWHOST > /etc/hosts
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
  scp /etc/hosts root@$ip:/etc/hosts
  ssh $ip 'newhost='${NODENAME[$i]}'; echo $newhost;  sudo bash -c '"'"'echo `curl -s http://169.254.169.254/latest/meta-data/local-ipv4` '"'"'$newhost'"'"' >> /etc/hosts'"'"'; sudo hostname $newhost;' ;
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
