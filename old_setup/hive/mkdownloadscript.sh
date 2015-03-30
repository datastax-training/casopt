PREFIX=http://s3.amazonaws.com/datastax-training/
FOLDER=CASOPT
DESTINATION=/raid0/$FOLDER
echo sudo mkdir $DESTINATION
echo sudo chmod 777 $DESTINATION 
echo cd $DESTINATION 
echo 'parallel -j 8 wget -x -nH --cut-dirs=2 -- `cat <<EOF' 
aws s3 ls --recursive s3://datastax-training/$FOLDER | sort -nrk 3,3 |  sed -e '\#/$# d;   s#.* \(.*\)#'$PREFIX'\1#' 
echo 'EOF `' 

