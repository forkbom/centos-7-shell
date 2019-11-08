#!/bin/bash
for i in `seq 2000`
do
test $[i%177] -eq 0 && echo $i
done
