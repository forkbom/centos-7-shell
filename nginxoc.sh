#!/bin/bash
#
function stat (){
	netstat -ntulp | grep -q nginx
}
function nginx () {
/usr/local/nginx/sbin/nginx
}
function cecho (){
	echo -e "\033[$1m$2\033[0m"
}
case $1 in
run)
	stat
	test $? -eq 0 && cecho 32 服务已经开过了 && exit
	nginx;;
sto)
	stat
	test $? -ne 0 && cecho 31 服务已经关过了 && exit
	nginx -s stop;;
restart)
	nginx -s stop
	sleep 2
	nginx
	echo "关闭 开启成功";;
status)
	netstat -ntulp | grep -q nginx 
	test $? -eq 0 && echo "服务已经开启" || echo "服务未开启";;
*)
	echo "请输入run 或 sto"
esac
