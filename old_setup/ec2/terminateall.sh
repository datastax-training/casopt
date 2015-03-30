aws ec2 terminate-instances --instance-ids `aws ec2 describe-instances --filters="Name=instance-state-name,Values=running" | grep InstanceId | sed 's/.* "\(.*\)",/\1/' `
