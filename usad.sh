#!/bin/bash
for i in `cat user.txt`
do 
	useradd $i
done
