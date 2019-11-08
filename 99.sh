#!/bin/bash
# 9  9 乘法表
for i in `seq 9`
do
	for j in  `seq $i`
	do
	echo -n "$i X $j=$[i*j]  "
	done
	echo
done
