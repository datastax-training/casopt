UW_NAME="DataStax Training User Workstation"
SOURCE_REGION="us-west-1"
MASTER_ACCOUNT="570516133972"


if [ -z "$1" ] || [ -n "$2" ] ; then
  echo "Usage: delete-uw.sh <target region>"
  echo "  Delete the User workstation AMI from the target region"
  exit 1;
fi

TARGET_REGION=$1

if ! aws iam get-user 2>&1 | grep $MASTER_ACCOUNT >/dev/null  ; then
 
   echo "This command must be run from the master datastax account "
   exit 1
fi

UW_IMAGE_TARGET=`aws ec2 --region $TARGET_REGION describe-images --filter "Name=name,Values='$UW_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

  if [[ -z $UW_IMAGE_TARGET ]] ; then
    echo "ERROR: There is no AMI with the name \"$UW_NAME\" in $TARGET_REGION"
    exit 1
  fi

UW_TARGET_SNAPSHOTS=`aws ec2 describe-images --region $TARGET_REGION --filter "Name=image-id,Values='$UW_IMAGE_TARGET'" | sed  '/SnapshotId/ !d ; s/.*": "\([^"]*\).*/\1/ ; p' | sort | uniq`

FORMATTED_SNAPSHOTS=`cat <<< $UW_TARGET_SNAPSHOTS`
echo
echo "Deleting \"$UW_NAME\", AMI: $UW_IMAGE_TARGET SNAPSHOTS: $FORMATTED_SNAPSHOTS from $TARGET_REGION"

aws ec2 --region $TARGET_REGION deregister-image --image-id $UW_IMAGE_TARGET

for SNAP in $UW_TARGET_SNAPSHOTS ; do 
  aws ec2 --region $TARGET_REGION delete-snapshot --snapshot-id $SNAP
done

