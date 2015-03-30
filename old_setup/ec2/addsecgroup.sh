#!/bin/bash

TRAINING_GROUP="Training Security Group"

function addTrainingGroup () {

REGION=$1

aws --region $REGION --output json ec2 create-security-group --group-name "$TRAINING_GROUP" --description "Security Group"
if [ $? != 0 ] ; then
 echo Script Ending
 return
fi

sleep 3

OUTPUT=`aws ec2 --output json --region $REGION describe-security-groups --group-names "Training Security Group"`

GROUPID=`sed 's/.*"GroupId": "\([^"]*\).*/\1/' <<< $OUTPUT`
OWNERID=`sed 's/.*"OwnerId": "\([^"]*\).*/\1/' <<< $OUTPUT`
echo GroupId: $GROUPID
echo OwnerId: $OWNERID

read -r -d '' PERMS <<EOF
   [
       {
           "ToPort": 9160, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 9160
       }, 
       {
           "ToPort": 9042, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 9042
       }, 
       {
           "ToPort": 50031, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 50031
       }, 
       {
           "ToPort": 65535, 
           "IpProtocol": "tcp", 
           "UserIdGroupPairs": [
               {
                   "UserId": "$OWNERID", 
                   "GroupId": "$GROUPID"
               }
           ], 
           "FromPort": 1024
       }, 
       {
           "ToPort": 8888, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 8888
       }, 
       {
           "ToPort": 50030, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 50030
       }, 
       {
           "ToPort": 7199, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 7199
       }, 
       {
           "ToPort": 61621, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 61621
       }, 
       {
           "ToPort": 8012, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 8012
       }, 
       {
           "ToPort": 7000, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 7000
       }, 
       {
           "ToPort": 8983, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 8983
       }, 
       {
           "ToPort": 9290, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 9290
       }, 
       {
           "ToPort": 22, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 22
       }, 
       {
           "ToPort": 50060, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 50060
       }, 
       {
           "ToPort": 61620, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 61620
       }, 
       {
           "ToPort": 7001, 
           "IpProtocol": "tcp", 
           "IpRanges": [
               {
                   "CidrIp": "0.0.0.0/0"
               }
           ], 
           "FromPort": 7001
       },
       {
           "ToPort": -1, 
           "IpProtocol": "icmp", 
           "UserIdGroupPairs": [
               {
                   "UserId": "$OWNERID", 
                   "GroupId": "$GROUPID"
               }
           ], 
           "FromPort": -1
       } 
   ] 
EOF

aws --output json ec2 --region $REGION authorize-security-group-ingress  --group-name  "Training Security Group" --ip-permissions "$PERMS"

}

function deleteTrainingGroup () {
  REGION=$1
  aws --region $REGION --output json ec2 delete-security-group --group-name "$TRAINING_GROUP"
}


for REG in `aws --output json ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'`; do
   echo Processing Region: $REG
   deleteTrainingGroup $REG
   sleep 5
   addTrainingGroup $REG
done
