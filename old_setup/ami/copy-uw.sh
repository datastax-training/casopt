UW_NAME="DataStax Training User Workstation"
SOURCE_REGION="us-west-1"
MASTER_ACCOUNT="570516133972"


if [ -z "$1" ] || [ -n "$2" ] ; then
  echo "Usage: copy-uw.sh <target region>"
  echo "  copy the User workstation AMI from $SOURCE_REGION to the target region"
  exit 1;
fi

TARGET_REGION=$1

if ! aws iam get-user 2>&1 | grep $MASTER_ACCOUNT >/dev/null  ; then
 
   echo "This command must be run from the master datastax account "
   exit 1
fi

UW_IMAGE=`aws ec2 --region $SOURCE_REGION describe-images --filter "Name=name,Values='$UW_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

  if [ -z $UW_IMAGE ] ; then
    echo "ERROR: No AMI found for $UW_NAME in" `grep region ~/.aws/config`
    exit 1
  fi

UW_IMAGE_TARGET=`aws ec2 --region $TARGET_REGION describe-images --filter "Name=name,Values='$UW_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

  if [[ -n $UW_IMAGE_TARGET ]] ; then
    echo "ERROR: An AMI with the name \"$UW_NAME\" and ID: \"$UW_IMAGE_TARGET\" already exists in $TARGET_REGION"
    exit 1
  fi

echo
echo "Copying \"$UW_NAME\", AMI: $UW_IMAGE to $TARGET_REGION"

aws ec2 copy-image --region $TARGET_REGION --source-region $SOURCE_REGION --source-image-id $UW_IMAGE

