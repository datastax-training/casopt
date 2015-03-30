#!/bin/bash

# use python to parse the json
# eventually change this to pure python with a signed webservice call

aws ec2 describe-instances | python -c 'import sys, json; x=json.load(sys.stdin)["Reservations"];
for y in x:
  for z in y["Instances"]:
     if z["AmiLaunchIndex"] == 0 and z["State"]["Name"] == "running" :
      ip=z["NetworkInterfaces"][0]["Association"]["PublicIp"]
      for w in z["Tags"]:
         if w["Key"] == "Name":
           name=w["Value"]
      
      if "Cassandra" in name:
         print name.replace("Cassandra","OpsCenter") + "\thttp://" + ip + ":8888"
      else:
         print name + "\t" + ip
' | sort

