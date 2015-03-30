#!/bin/bash

function usage() {
   echo
   echo "Usage: wipeandadd.sh <-b [y|n]> <node to wipe and add> <any node in existing cluster>"
   echo "       -b (y/n) enable/disable autobootstrapping  "
   echo "Note:  The script always removes the auto_bootstrap setting"
   echo
}

AUTO_BOOTSTRAP=y

while [[ $1 == -* ]] ; do
  if [[ "$1" == "-h" ]]; then
      usage
      exit
  fi

  if [[ "$1" == "-b" ]]; then
     shift
     AUTO_BOOTSTRAP=$1
     shift
  fi

done

if [ -z "$2" ] || [ -n "$3" ] ; then
  usage
  exit 1;
fi

NEWNODE=$1
EXISTING=$2

ISDSE=n
ssh $NEWNODE dsetool>/dev/null 2>&1; if [ $? -eq 1 ] ; then ISDSE=y; fi

if [ $ISDSE == y ]; then
   CONF=/etc/dse/cassandra
   SERVICE=dse
else
   CONF=/etc/cassandra
   SERVICE=cassandra
fi

if [ $AUTO_BOOTSTRAP == n ] ; then
   AB='$ aauto_bootstrap: false'
fi

if  ssh $EXISTING grep -q ^initial_token $CONF/cassandra.yaml ; then
  INITIAL_TOKEN='/^# \? \?initial_token/ cinitial_token:'
fi

VARLIB=`ssh $EXISTING grep '^commitlog_directory' $CONF/cassandra.yaml | sed 's#.* \(.*\)/commitlog#\1#'`

#Copy the yamls from existing
scp $EXISTING:$CONF/cassandra.yaml $NEWNODE:$CONF/cassandra.yaml
scp $EXISTING:$CONF/cassandra-env.sh $NEWNODE:$CONF/cassandra-env.sh
scp $EXISTING:/var/lib/datastax-agent/conf/address.yaml $NEWNODE:/var/lib/datastax-agent/conf/address.yaml

ssh $NEWNODE 'sudo bash -s' <<EOF

service $SERVICE stop
service opscenterd stop
service datastax-agent stop

INET=\`ifconfig eth0 | sed '/^ *inet addr/ !d; s/ *inet addr:\([^ ]*\).*/\1/'\`
sed -i.bak -e "
/^rpc_address:/ crpc_address: \$INET
/^listen_address:/ clisten_address: \$INET
$INITIAL_TOKEN
/^auto_bootstrap/ d
$AB
" $CONF/cassandra.yaml

cd $VARLIB
rm -rf */*


service $SERVICE start
sleep 15
service datastax-agent start

EOF

