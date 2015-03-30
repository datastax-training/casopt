#!/bin/bash

for REG in `aws --output json ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'`; do
   echo ${REG}:
   aws --output json --region $REG ec2 describe-instances --filters="Name=instance-state-name,Values=running" | sed '/"Value":/ !d; s/ *"Value": "\(.*\)",*/   \1/'
done
