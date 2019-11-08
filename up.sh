#!/bin/bash
#
while :
do
read -p "user:" n
read -p "psd:" p
test $n == tom && test $p == 123456 && echo "登录成功" ||echo "重试" ; break
done
