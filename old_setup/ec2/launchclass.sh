#!/bin/bash

# This ensures that if this script is killed, all of its children are killed too

trap "kill 0" SIGINT

if [ -z "$3" ] || [ -n "$4" ] ; then
  echo "Usage launchclass.sh <admin|perf|simple>  <path to private key file> <path to roster file>"
  exit 1;
fi

#get parameters

if [ $1 == "admin" ] ; then
   PARMS="-s 4 -p admincluster.sh"
elif [ $1 == "perf" ] ; then
   PARMS="-s 3 -t m3.large"
elif [ $1 == "simple" ] ; then
   PARMS="-s 3 -t m3.medium"
else
   echo "\"$1\" is an invalid scenario."
   exit 1
fi

PUBKEY=$2
ROSTER=$3

while read STUDENT ; do
 #sleep 20
 (
  echo Launching "$STUDENT"
  ./launch1.sh $PARMS $PUBKEY "$STUDENT" 
  echo Completed "$STUDENT"
 ) &
done < $ROSTER

sleep 5
echo "Waiting for Class to Launch"

wait

