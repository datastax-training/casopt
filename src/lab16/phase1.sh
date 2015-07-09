#!/bin/bash

set -v

# Screw up a token

ssh node4_ext 'nodetool move -- -7378697629483820647'


# import the data

cd /CASOPT/SSTables

# note - we need to strip off an ending "-1", 'cuz that's what the snitch does

echo "create keyspace stock with replication = {'class':'NetworkTopologyStrategy','nearby':3,'faraway':2 };" | cqlsh node0_ext 

cat create* | cqlsh -k stock node0_ext

echo "alter table stock.trades_by_tickerday WITH compaction = {'class': 'LeveledCompactionStrategy', 'sstable_size_in_mb': 10 };" | cqlsh -k stock node0_ext
echo "alter table stock.trades with read_repair_chance=1;" | cqlsh -k stock node0_ext


loadsstables.sh -q node0_ext


