#!/bin/bash


while [[ $1 == -* ]] ; do
  if [[ "$1" == "-q" ]]; then
      QUIET='--no-progress'
      shift
  fi
done

HOST=$1

trap "kill 0" SIGINT

if [ "$HOST" == "" ] ; then
   echo "loadsstables.sh [-q] <hostname>"
   echo "  -q  Run in quiet mode"
   exit 1
fi

time (for table in stock/trades stock/trades_by_datehour stock/trades_by_tickerday; do
  sstableloader $QUIET -d $HOST $table &
done
ps -f --ppid $$ | grep sstableloader
wait)

