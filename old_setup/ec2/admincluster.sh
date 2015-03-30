
# stuff to run on the user workstation

ssh -i $PUBKEY ubuntu@$UW_PUBLIC  'bash -s ' <<EOF
# tear down nodes 2 and 3
export PATH=$PATH:~/labwork/bin
nodetool -h node2 decommission
nodetool -h node3 decommission
wipenode.sh node2 
wipenode.sh node3 
# This is because of a bug in cassandra
ssh node0 sudo service cassandra restart
EOF

