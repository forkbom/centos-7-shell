#!/bin/bash
for i in `ls *.$1`
do
	x=${i%%.*}
	mv $i $x.$2
done
