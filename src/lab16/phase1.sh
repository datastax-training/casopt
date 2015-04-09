#!/bin/bash

set -v

# bring the nodes in

cluster2hosts.sh node0

# Screw up a token

ssh node4 'nodetool move \\-7378697629483820647'

# import the data

cd /CASOPT/SSTables

echo "create keyspace stock with replication = {'class':'NetworkTopologyStrategy','us-west-2':3,'ap-southeast':2 };" | cqlsh node0 

cat create* | cqlsh -k stock node0

echo "alter table stock.trades_by_tickerday WITH compaction = {'class': 'LeveledCompactionStrategy', 'sstable_size_in_mb': 10 };" | cqlsh -k stock node0
echo "alter table stock.trades with read_repair_chance=1;" | cqlsh -k stock node0


loadsstables.sh -q node0


