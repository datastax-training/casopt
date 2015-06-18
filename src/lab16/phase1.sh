#!/bin/bash

set -v

# Screw up a token

ssh node4 'nodetool move -- -7378697629483820647'


# import the data

cd /CASOPT/SSTables

# note - we need to strip off an ending "-1", 'cuz that's what the snitch does

PRIMARY_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
PRIMARY_REGION="`echo \"$PRIMARY_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:' | sed 's:-1$::'`"

SECONDARY_AVAIL_ZONE=`ssh node5 curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
SECONDARY_REGION="`echo \"$SECONDARY_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:' | sed 's:-1$::'`"


echo "create keyspace stock with replication = {'class':'NetworkTopologyStrategy','$PRIMARY_REGION':3,'$SECONDARY_REGION':2 };" | cqlsh node0 

cat create* | cqlsh -k stock node0

echo "alter table stock.trades_by_tickerday WITH compaction = {'class': 'LeveledCompactionStrategy', 'sstable_size_in_mb': 10 };" | cqlsh -k stock node0
echo "alter table stock.trades with read_repair_chance=1;" | cqlsh -k stock node0


loadsstables.sh -q node0


