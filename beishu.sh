#!/bin/bash
for i in {1..20}
do
	x=$[i%6]
	test $x -eq 0 || continue 
	echo $[i*i]
done
