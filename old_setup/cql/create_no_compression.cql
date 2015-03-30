create keyspace stocknc with replication = {'class':'SimpleStrategy', 'replication_factor':2 } ;
use stocknc;
source 'create_trades.cql'
source 'create_trades_by_tickerday.cql'
source 'create_trades_by_datehour.cql'

alter table trades with compression = {'sstable_compression':''};
alter table trades_by_tickerday with compression = {'sstable_compression':''};
alter table trades_by_datehour with compression = {'sstable_compression':''};

