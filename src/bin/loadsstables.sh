#!/bin/bash
HOST=$1

trap "kill 0" SIGINT

if [ "$HOST" == "" ] ; then
   echo "loadsstables.sh <hostname>"
   exit 1
fi

time (for table in stock/trades stock/trades_by_datehour stock/trades_by_tickerday; do
  sstableloader -d $HOST $table &
done
ps -f --ppid $$ | grep sstableloader
wait)

