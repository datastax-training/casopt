#!/bin/bash

set -v 

# create hugefile on node1_ext

ssh node1_ext 'sudo bash -s ' <<ABC
#!/bin/bash


DIR=/mnt/ephemeral/cassandra
cd \$DIR

FILENAME=.hugefile
SIZEK=\`df \$DIR | tail -n 1 | tr -s \  | cut -d\  -f4,4\`
fallocate -l \$((SIZEK-100))K \$FILENAME
ABC

