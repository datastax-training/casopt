#!/bin/bash

# corrupt an SSTable on node4_ext

ssh node4_ext 'sudo bash -s ' <<ABC
#sstable manipulation
DIR=/mnt/ephemeral/cassandra/data/stock/trades_by_datehour*
TMPFILE=tmpsstable

cd \$DIR
ls -l
SST1=\`ls -l *Data* | head -n 1\`

SIZE=\`cut -d\  -f5,5 <<< \$SST1\`
FILENAME=\`cut -d\  -f9,9 <<< \$SST1\`

HALFSIZE=\$((SIZE/2))

head -c \$HALFSIZE \$FILENAME > \$TMPFILE

chown cassandra:cassandra \$TMPFILE
mv \$TMPFILE \$FILENAME
ABC

