#!/bin/bash

for REG in `aws --output json ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'`; do
   echo -n ${REG}: " "
    aws --output json ec2 --region $REG describe-account-attributes --attribute-names max-instances | sed -n '/max-instances/ { n ; n; n; s/.*": "\([^"]*\)"/\1/; p ; } ; d ' 
done
