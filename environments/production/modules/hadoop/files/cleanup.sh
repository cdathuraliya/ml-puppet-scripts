#!/bin/bash         

echo "----- Starting cleanup -----"
ps aux | grep -i wso2 | awk {'print $2'} | xargs kill -9
rm -rf /mnt/*
sed -i '/certname/d' /etc/puppet/puppet.conf
