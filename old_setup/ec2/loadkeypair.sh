#!/bin/bash

#get public key file

KPNAME="Training Key Pair"

if [ -z $1 ] ; then
  echo "Usage loadkeypair.sh <path to public key>"
  exit 1;
fi

PUBLIC=$1 

# Remove old keypair

echo "Deleting Key Pairs:"

for REGION in `aws --output json ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'` ; do 
  echo $REGION
  aws --region $REGION --output json ec2 delete-key-pair --key-name "$KPNAME"
done

# load keypair

echo "Importing Key Pairs:"

for REGION in `aws --output json ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'` ; do 
  echo $REGION
  aws --region $REGION --output json ec2 import-key-pair --key-name "$KPNAME" --public-key-material file://$PUBLIC
done


