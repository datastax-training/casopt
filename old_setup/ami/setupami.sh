#!/bin/bash

echo "Running AMI Setup Script"

#SSH CONFIG:
cat > ~ubuntu/.ssh/config <<'EOF'
Host *
    StrictHostKeyChecking no
EOF

chmod 600 ~ubuntu/.ssh/config 
chown ubuntu:ubuntu ~ubuntu/.ssh/config 

#JDK
#apt-get -q -y install python-software-properties 
add-apt-repository -y ppa:webupd8team/java
apt-get -q -y update

echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
 
apt-get -q -y install oracle-java7-installer

#GIT (if we need to download stuff from the git repo)
apt-get -y install git

#AWS TOOLS
apt-get install unzip
cd /tmp
wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip 
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# SHELLINABOX

# install it
apt-cache search shellinabox
apt-get install openssl shellinabox

# configure it to run on port 443
echo SHELLINABOX_PORT=443 >> /etc/default/shellinabox

# CASSANDRA
echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update
apt-get -y install dsc20


# disable cassandra
service cassandra stop
rm -rf /var/lib/cassandra/*
rm -rf /var/log/cassandra/*
update-rc.d -f cassandra disable
mv /usr/sbin/cassandra /usr/sbin/cassandra_dont_runme

# important utilities
apt-get -y install sysstat
apt-get -y install dstat

# X Support (not critical):
apt-get -y install libxrender1
apt-get -y install libxtst6
apt-get -y install libxi6


# Gedit
apt-get -y install gedit

# Put AMI startup script there.
cat > /etc/init.d/start-ami-script.sh <<'EOF'
echo "Running UW setup Script"
mkdir /EBS
mount `ls /dev/xvd? | tail -n 1` /EBS
chmod 755 /EBS

ln -T -s /EBS /CASOPT

# get latest utilities
git clone http://github.com/slowenthal/labwork /home/ubuntu/labwork
cd /home/ubuntu/labwork
git pull
chown -R ubuntu:ubuntu /home/ubuntu/labwork
echo 'source /home/ubuntu/labwork/bin/labworkrc' >> /home/ubuntu/.bashrc

# git rm -rf labwork/.git*  -- detach it from git

echo "Done UW Setup Script"

EOF

# Setup AMI Script to start on boot. Keep the runlevels, otherwise the sub-script may run during creation.
chmod 755 /etc/init.d/start-ami-script.sh
update-rc.d -f start-ami-script.sh start 99 2 3 4 5 .

# Putty Tools Keep these last - sometimes cause a wonky issue where script stops.
add-apt-repository "deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse"
apt-get update
apt-get install putty-tools

