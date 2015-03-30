create keyspace stocklc with replication = {'class':'SimpleStrategy', 'replication_factor':2 } ;
use stocklc;

source 'create_trades_by_datehour.cql'

alter table trades_by_datehour with compaction = {'class':'LeveledCompactionStrategy'};

