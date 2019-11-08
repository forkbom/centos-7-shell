#!/bin/bash

for i in `seq 9`
do
	for j in  `seq $i`
	do
	echo -n "$i X $j=$[i*j]  "
	done
	echo
done
