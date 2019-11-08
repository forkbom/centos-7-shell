#!/bin/bash
lujing=/etc/passwd
test -w $lujing && echo 当前用户对$lujing 有-读-权限 || echo 当前用户对$lujing 没有-读权限
test -r $lujing && echo 当前用户对$lujing 有-写-权限 || echo 当前用户对$lunjing 没有-写权限
test -x $lujing && echo 当前用户对$lujing 有-执行-权限 || echo 当前用户对$lujing 没有-执行权限
