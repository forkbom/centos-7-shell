#!/bin/bash
while :
do
test $( ps -aux | wc -l ) -gt 100 && echo 100+++++++ | mail -s 100+ root && exit
done
