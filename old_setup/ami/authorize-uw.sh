UW_NAME="DataStax Training User Workstation"
SOURCE_REGION="us-west-1"
MASTER_ACCOUNT="570516133972"


if ! [[ -f authorized-accounts ]] ; then
   echo "The file authorized-accounts does not exist"
   exit 1
fi

if ! aws iam get-user 2>&1 | grep $MASTER_ACCOUNT >/dev/null  ; then
 
   echo "This command must be run from the master datastax account "
   exit 1
fi

for TARGET_REGION in `aws ec2 describe-regions | sed '/RegionName/ !d; s/.*: "\([^"]*\)"/\1/'`; do

   UW_IMAGE_TARGET=`aws ec2 --region $TARGET_REGION describe-images --filter "Name=name,Values='$UW_NAME'" | sed '/"ImageId"/ !d; s/.*: "\([^"]*\).*/\1/'`

     if [[ -z $UW_IMAGE_TARGET ]] ; then
       echo "ERROR: There is no AMI with the name \"$UW_NAME\" in $TARGET_REGION"
       continue 
     fi
   
   echo
   echo "Authorizing \"$UW_NAME\", AMI: $UW_IMAGE_TARGET in $TARGET_REGION"
   
   for USER in `cat authorized-accounts | sed 's/ .*//' ` ; do
      echo $USER
      aws ec2 modify-image-attribute --region $TARGET_REGION --image-id $UW_IMAGE_TARGET --launch-permission "{\"Add\": [{\"UserId\":\"$USER\"}]}"
   done

done
