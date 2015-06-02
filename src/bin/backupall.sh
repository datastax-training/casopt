#!/bin/bash

BACKUP=backup

function usage() {
   echo
   echo "Usage: backupall.sh [-c <keyspace name>[.<table name>]] [-b <backup name> ] <any node in cluster>"
}

function getnodelist() {
  nodelist=`ssh $FIRSTNODE nodetool status |  sed '/[UD][NLJM]/!d ; s/..  \([0-9\.]*\) .*/\1/'`
}

while [[ $1 == -* ]] ; do 
  if [[ "$1" == "-h" ]]; then
      usage
      exit
  fi 

  if [[ "$1" == "-b" ]]; then
    shift
    BACKUP=$1
    shift 
 else
 if [[ "$1" == "-c" ]]; then
    shift
    KS_TABLE=$1
    shift
    KST=`sed 's/\./ -cf /' <<< $KS_TABLE`
    echo $KST
  else
    usage
    exit
  fi
 fi
  
 
done

if [[ -z $1 ]]; then
    usage
    exit
else
  FIRSTNODE=$1
fi

echo
echo 'Creating Backup: "'$BACKUP'" for cluster starting with: "'$FIRSTNODE'"'

getnodelist

for ip in $nodelist; do
 ssh $ip nodetool snapshot $KST -t $BACKUP
done

