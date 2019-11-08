#!/bin/bash
# 学习如何使用函数
colorecho (){
	echo -e "\033[$1m$2\033[0m"
}

colorecho  31 ABCD
colorecho  32 ABCD
colorecho  33 ABCD
colorecho  34 ABCD
colorecho  35 ABCD
colorecho  36 ABCD
colorecho  37 ABCD

