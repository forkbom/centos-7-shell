#!/bin/bash
x=0
while :
do
	read -p "please input a number:" n
	test -z $n && exit
	test $n -eq 0   && break
	let x+=n
done
echo $x
