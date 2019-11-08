#!/bin/bash
read -p "input user name:" n
useradd $n
read -p "input password:" p
echo ${p:-123456} | passwd --stdin $n
