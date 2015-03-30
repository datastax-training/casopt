SNAPSHOT=RC3
SCRIPT=/raid0/CASOPT/scripts/wgetCASOPT.sh
dir=`/bin/pwd`
cd /raid0
function sync  {
  aws s3 sync CASOPT s3://datastax-training/CASOPT --grants read=URI=http://acs.amazonaws.com/groups/global/AllUsers --exclude '.*'
}
sync
cd $dir
./mkdownloadscript.sh > $SCRIPT 
cd /raid0
sync
