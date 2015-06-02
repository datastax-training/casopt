#!/bin/bash

DATADIR=/var/lib/cassandra/data
function usage() {
   echo
   echo "Usage: restoreall.sh [-t] [-c <keyspace name>[.<table name>]] [-b <backup name> ] <any node in cluster>"
}

function getnodelist() {
nodelist=`ssh $FIRSTNODE nodetool status |  sed '/[UD][NLJM]/!d ; s/..  \([0-9\.]*\) .*/\1/'`
}


function getbackuplist() {
   backuplist=`ssh $FIRSTNODE "find $DATADIR/$KS_TABLE"' -path *snapshots/* -type d -not -name [0-9]*' | \
      sed "s#$DATADIR/\([^/]*\)/\([^/]*\)/snapshots/\([^/]*\)#\3 \1.\2#" | sort`
}


function offerbackupmenu() {

   read -a names <<< `cut -d" " -f 1 <<< "$backuplist" | uniq`
  
   if [ ${#names} -eq 0 ] ; then
      echo "No backups found"
      exit
   fi

echo ${#names[@]} "backups found"
echo "select the backup you wish to restore from the list below"
echo

until [[ $x -gt 0 ]] && [[ $x -le $i ]] ; do
   i=1
   for name in ${names[@]} ; do
    echo $i")" $name":"
    sed "/^$name/ !d;  s/^[^ ]*/   /" <<< "$backuplist"
    echo
    i=$((i+1))
   done
echo "x) Exit"
echo
   read x
   if [[ "$x" == "x" ]]; then
      exit
   fi

done

x=$((x-1))
BACKUP=${names[x]}
backuplist=`sed "/^$BACKUP/ !d; "'s/.* //' <<< "$backuplist"`
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
    KS_TABLE=`sed 's#\.#/#' <<< $KS_TABLE`
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

getbackuplist

if [[ -z $BACKUP ]]; then
   offerbackupmenu
fi

echo
echo 'Restoring: "'$BACKUP'" for cluster starting with: "'$FIRSTNODE'"'

getnodelist

# Truncate the tables
   sed 's/\(.*\)/truncate \1;/' <<< "$backuplist" | cqlsh $FIRSTNODE


# Restore the backup

for ip in $nodelist; do
   echo "Node: " $ip
   ssh ubuntu@$ip 'for dir in '$backuplist'; do echo "Restoring: " $dir; sudo ln '$DATADIR'/${dir%.*}"/"${dir#*.}/snapshots/'$BACKUP'/*' $DATADIR'/${dir%.*}"/"${dir#*.}; nodetool refresh ${dir%.*} ${dir#*.}; done' ; done

