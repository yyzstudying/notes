#!/bin/bash
NAME=$1
VERSION=$2
SELECT=$3


if [ ! -n "$NAME" ]; then
 echo "请输入第一个参数！参数为：文件名"
 exit 1
fi
if [ ! -n "$VERSION" ]; then
 echo "请输入第二个参数！参数为：版本号"
 exit 1
fi
if [ ! -n "$SELECT" ]; then
 echo "请输入第三个参数！参数为：iso 、tar 、all"
 exit 1
fi

if [ "$SELECT" ==  "iso" ];then
	sh main-iso.sh $NAME $VERSION
elif [ "$SELECT" ==  "tar" ];then
	sh main-tar.sh $NAME $VERSION
elif [ "$SELECT" ==  "all" ];then
	sh main-iso.sh $NAME $VERSION
	sh main-tar.sh $NAME $VERSION
else
    echo "第三个参数错误！参数为：iso 、tar 、all"
	exit 1
fi



