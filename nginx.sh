#!/bin/bash
#
yum -y install gcc openssl-devel pcre-devel 
sleep 10
tar -xf nginx-1.10.3.tar.gz
cd nginx-1.10.3
./configure
make
make install
