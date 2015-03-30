#!/bin/bash

cat <<'EOF'

Welcome to the DataStax User Workstatation

USEFUL SCRIPTS:

wipenode.sh - Wipe out a node's configuration.  This will reset seed_node, cluster_name, rpc_address, and listen_address in the node's configuration file and delete the data directories.   Ensure the node is decommissioned or removed first.

wipeandadd.sh - Take an unused node and wipes it out as wipenode.sh, and then configures it to join an existing cluster.  You can choose to autobootstrap the new node.  It also sets up the opscenter configuration, and starts the services.

get0.sh - Return the public ip address of the node with AMI launch index 0.  In other words, it gives you the IP for opscenter.

renamecluster.sh - Rename the hosts in your cluster to <stem>0 - <stem>n.  It's used to name them node0 – node3, but can name it to anything you want.  It then calls cluster2hosts.sh to put the host aliases in the /etc/hosts file of the User Workstation

cluster2hosts.sh - Put the hostsnames of the nodes in your cluster in /etc/hosts.

taillog.sh - Tail the system.log file of the given node

backupall.sh / restoreall.sh - Backup and restore SSTables on all of the nodes in your cluster.  You can specify a table, keyspace, or everything.

reset-3-nodes.sh - Turn your cluster back to an empty 3-node cluster.

TIPS:

Logging into me with ssh and enabling X11

   ssh -i <private key file> ubuntu@<ip address> -X 

 OR

   putty -i <private key file> ubuntu@<ip address> -X 
  
Running jconsole over a slow X11 connection:

      jconsole -J-Dsun.java2d.xrender=True &

EOF

