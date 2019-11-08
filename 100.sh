#!/bin/bash
a=0
sum=0
while :
do
let a+=1
let sum+=a 
test $a == 100 && echo $sum &&  exit
done
