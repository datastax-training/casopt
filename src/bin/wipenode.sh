#!/bin/bash

# close stdin - cuz ssh will grab it

exec <&-

function usage() {
   echo
   echo "Usage: wipenode.sh <node to wipe>"
   echo "Note:  The script always removes the auto_bootstrap setting"
   echo
}

while [[ $1 == -* ]] ; do
  if [[ "$1" == "-h" ]]; then
      usage
      exit
  fi
done

if [ -z "$1" ] || [ -n "$2" ] ; then
  usage
  exit 1;
fi

NEWNODE=$1

ISDSE=n
ssh $NEWNODE dsetool>/dev/null 2>&1; if [ $? -eq 1 ] ; then ISDSE=y; fi

if [ $ISDSE == y ]; then
   CONF=/etc/dse/cassandra
   SERVICE=dse
else
   CONF=/etc/cassandra
   SERVICE=cassandra
fi

VARLIB=`ssh $NEWNODE grep '^commitlog_directory' $CONF/cassandra.yaml | sed 's#.* \(.*\)/commitlog#\1#'`


ssh $NEWNODE 'sudo bash -s' <<EOF

service $SERVICE stop
service opscenterd stop
service datastax-agent stop

sed -i.bak -e '/^cluster_name/ ccluster_name: '"'"'Test Cluster'"'"'
/ seeds:/ c\ \ \ \ \ \ \ \ \ \ - seeds: "127.0.0.1"
/^rpc_address:/ crpc_address: 127.0.0.1
/^listen_address:/ clisten_address: 127.0.0.1
/^auto_bootstrap/ d' $CONF/cassandra.yaml

cd $VARLIB
rm -rf */*
EOF

