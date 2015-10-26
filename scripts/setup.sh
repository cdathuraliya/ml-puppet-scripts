#!/bin/bash
echo "----- Starting cleanup -----"
ps aux | grep -i wso2 | awk {'print $2'} | xargs kill -9
rm -rf /mnt/*
sed -i '/certname/d' /etc/puppet/puppet.conf
#sed -i '/server = puppet/a environment=production' /etc/puppet/puppet.conf
echo "----- Setting up environment -----"
rm -f /etc/facter/facts.d/deployment_pattern.txt
#rm /etc/facter/facts.d/deployment_pattern.txt
mkdir -p /etc/facter/facts.d

#deployment_pattern=$(<deployment.conf)

while read -r line; do declare  $line; done < deployment.conf
echo deployment=$deployment >> /etc/facter/facts.d/deployment_pattern.txt
echo deployment_pattern=$deployment_pattern >> /etc/facter/facts.d/deployment_pattern.txt

echo "----- Installing -----"
for (( i=1; i <= 2; i++ ))
do
 puppet agent --enable
 puppet agent -vt
 puppet agent --disable
done

