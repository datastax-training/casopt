#!/bin/bash
 
# number of 10 second periods before we fail
FAILWAIT=60

UW_NAME="DataStax Training User Workstation"
KPNAME="Training Key Pair"
SECGROUP="Training Security Group"
UW_INSTANCETYPE=m3.medium
CLUSTER_SIZE=3
C_NAME="DataStax Auto-Clustering AMI 2.5.1-pv"
C_INSTANCETYPE=m3.medium
C_DISTRIBUTION=community
C_CREDENTIALS=""

# The following parameters are only necessry if you want to pin the version

C_RELEASE=2.0.10
#DSE_RELEASE=<put dse_version here if you want to pin a version>


function usage {
  echo "Usage launch1.sh [options] <path to private key file> <Student Name>"
  echo
  echo "Options:"
  echo "       -p script to run at the end to set up a scenario (executed with .)"
  echo "       -d distribution <enterprise|community>       [default: community]"
  echo "       -t instance type       [default: m3.medium]"
  echo "       -k keypair name        [default: Training Key Pair]"
  echo "       -s cluster size        [default 3]"
  echo "       -h help "
  echo
  echo " For enterprise: you must have a file called dse_credentials with --username and --password in it"
  echo
}

#default C*
PRODUCT_RELEASE=$C_RELEASE

while [[ $1 == -* ]] ; do 
  if [[ "$1" == "-h" ]]; then
     usage
     exit;
  fi

  if [[ "$1" == "-s" ]]; then
    shift
    CLUSTER_SIZE=$1
    shift 
  fi

  if [[ "$1" == "-p" ]]; then
    shift
    POST_SCRIPT=$1
    shift 
  fi

  if [[ "$1" == "-k" ]]; then
    shift
    KPNAME=$1
    shift 
  fi

  if [[ "$1" == "-t" ]]; then
    shift
    C_INSTANCETYPE=$1
    UW_INSTANCETYPE=$1
    shift 
  fi

  if [[ "$1" == "-d" ]]; then
    shift
    C_DISTRIBUTION=$1
    shift 
 
    if [ "$C_DISTRIBUTION" == "enterprise" ] ; then
     PRODUCT_RELEASE=$DSE_RELEASE
     if [ -f dse_credentials ] ; then
       C_CREDENTIALS=`cat dse_credentials`
      else
        echo "credentials file dse_credentials not found - required for launching a enterprise cluster"
        echo "   file must contain --username <datastax.com userid> --password <datastax.com password>"
        exit 1
      fi
    else
       if [ "$C_DISTRIBUTION" != "community" ] ; then
          echo "\"$C_DISTRIBUTION\" is not a valid distribution"
          exit 1
       fi
    fi
  fi
  
done

if [ -z "$2" ] || [ -n "$3" ] ; then
  usage
  exit 1;
fi

#get parameters

PUBKEY=$1
STUDENT=$2

UW_TAG="$STUDENT User Workstation"
C_TAG="$STUDENT Cassandra"

# Ensure there are not any instance running
  if [ `aws --output json ec2 describe-instances --filters=Name=tag-value,Values="$C_TAG","$UW_TAG" | egrep -c 'running|pending'` -ne 0 ]; then
      echo "ERROR: $STUDENT Has instances running"
      exit 1
  fi

# Launch User Workstation

  UW_IMAGE=`aws --output json ec2 describe-images --filter "Name=name,Values='$UW_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

  if [ -z $UW_IMAGE ] ; then
    echo "ERROR: $STUDENT: No AMI found for $UW_NAME in" `grep region ~/.aws/config`
    exit 1
  fi

  echo "Launching User Workstation ..."

  UW_LAUNCH=`aws --output json ec2 run-instances --image-id $UW_IMAGE --security-groups "$SECGROUP" --key-name "$KPNAME" --instance-type $UW_INSTANCETYPE`
  echo STATUS=$?
  echo $LAUNCH
  
  UW_INSTANCEID=`sed 's/.*"InstanceId": "\([^"]*\).*/\1/' <<< $UW_LAUNCH`
  
  aws --output json ec2 create-tags --resources $UW_INSTANCEID --tags Key=Name,Value="$UW_TAG"

# Launch Cluster with AMI
 
  echo "Launching Cluster ..."

  C_IMAGE=`aws --output json ec2 describe-images --filter "Name=name,Values='$C_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

  if [ -z $C_IMAGE ] ; then
    echo "ERROR: $STUDENT: No Cassandra AMI found for $UW_NAME in" `grep region ~/.aws/config`
    exit 1
  fi

  C_LAUNCH=`aws --output json ec2 run-instances --image-id $C_IMAGE --count $CLUSTER_SIZE --security-groups "$SECGROUP" --key-name "$KPNAME" --instance-type $C_INSTANCETYPE --user-data " ${PRODUCT_RELEASE:+--release }$PRODUCT_RELEASE --version $C_DISTRIBUTION $C_CREDENTIALS --totalnodes $CLUSTER_SIZE  --clustername \"$STUDENT\""`

#  echo $C_LAUNCH

  L=$C_LAUNCH
  i=$CLUSTER_SIZE
  while [ $i -gt 0 ] ; do
    # Peel off the instance id 'cuz we have no JSON parser here
    L=${L#*InstanceId\": \"}
    C_INSTANCEIDS="$C_INSTANCEIDS ${L%%\"*}"
    i=$((i-1))
  done;
    
  #C_INSTANCEIDS=`sed 's/.*"InstanceId": "\([^"]*\).*"InstanceId": "\([^"]*\).*"InstanceId": "\([^"]*\).*/\1 \2 \3/g' <<< $C_LAUNCH`

  aws --output json ec2 create-tags --resources $C_INSTANCEIDS --tags Key=Name,Value="$C_TAG"

echo "Waiting for instances to initialize ..."

# wait 30 seconds for instances to spin up
  sleep 30

# wait for the instances to come up
  iter=0

   # Note: we get 2 entries per instance from this expression

   while [ `aws --output json ec2 describe-instance-status --instance-ids $UW_INSTANCEID $C_INSTANCEIDS --filters "Name=instance-status.status,Values=ok" | grep -c '"ok"'` -ne $(((CLUSTER_SIZE+1)*2)) ]  ; do  
    echo "$STUDENT: Waiting for launch ... "
    sleep 10
    iter=$((iter+1))    
    if [ $iter -gt $FAILWAIT ] ; then
       echo "ERROR: $STUDENT: Instances failed to launch"
       exit 1
    fi
   done

   UW_LAUNCH=`aws --output json ec2 describe-instances --instance-ids $UW_INSTANCEID --filters "Name=launch-index,Values=0"`
   C0_LAUNCH=`aws --output json ec2 describe-instances --instance-ids $C_INSTANCEIDS --filters "Name=launch-index,Values=0"`

   UW_PUBLIC=`sed 's/.*"PublicIpAddress": "\([^"]*\).*/\1/' <<< $UW_LAUNCH`
   C0_PUBLIC=`sed 's/.*"PublicIpAddress": "\([^"]*\).*/\1/' <<< $C0_LAUNCH`

echo "Configuring User Workstation..."

# copy keyfile to host
  
   scp -o StrictHostKeyChecking=no -i $PUBKEY $PUBKEY ubuntu@$UW_PUBLIC:.ssh/id_rsa

echo "Waiting for cluster to launch ..."

# wait for the cluster to come up

   ssh -o StrictHostKeyChecking=no -i $PUBKEY ubuntu@$C0_PUBLIC nodetool status
  
   iter=0
   while [ `ssh -o StrictHostKeyChecking=no -i $PUBKEY ubuntu@$C0_PUBLIC nodetool status | grep -c UN ` -ne $CLUSTER_SIZE ]  ; do  
     echo "$STUDENT: Waiting for Cassandra ..."
     iter=$((iter+1))
     if [ $iter -gt $FAILWAIT ] ; then
        echo "ERROR: $STUDENT: Cassandra failed to Start"
        exit 1
     fi
     sleep 10
   done

echo "Configuring Cluster"
sleep 10  # give opscenter a chance to settle down
# rename the nodes
  ssh -o StrictHostKeyChecking=no -i $PUBKEY ubuntu@$UW_PUBLIC 'export PATH=$PATH:labwork/bin; renamenodes.sh node '$C0_PUBLIC

# do post processing
echo "$STUDENT: Running Post Processing: $POST_SCRIPT"
if [ -n "$POST_SCRIPT" ] ; then
  . $POST_SCRIPT
fi

echo "Launch Complete"
echo "Student Workstation Opscenter"
echo $STUDENT $UW_PUBLIC $C0_PUBLIC


