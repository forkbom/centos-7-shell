#!/bin/bash
a=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

for i in {1..8}
do
x=$[RANDOM%62]
b=${a:x:1}
pa=$pa$b
echo $pa
done


