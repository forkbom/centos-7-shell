#!/bin/bash
case $1 in
t)
	touch $2;;
m)
	mkdir $2;;
r)
	rm -rf  $2;;
*)
	echo "please input T|M|R";;
esac

