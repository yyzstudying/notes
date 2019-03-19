#!/bin/bash

JAR_VERSION=$1

MAVEN_ROOT=http://172.21.192.204:8081/nexus/content/repositories/public

# jar下载地址
NAME="c3p0-0.9.1.1"
OUTPUT_ROOT="/report/output/$NAME"
BACKEND_NAME="c3p0-0.9.1.1.jar"
BACKEND_JAR_ROOT=$MAVEN_ROOT"/c3p0/c3p0/0.9.1.1/"$BACKEND_NAME

SHELL_ROOT="/opt/build/base-rpm/BUILDROOT/data/web/rcdc/shell"
JAR_ROOT="/opt/build/base-rpm/BUILDROOT/data/web/upgrade"

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
function INFO(){
    local msg="$1"
    timeAndDate=`date "+%y-%m-%d %H:%M:%S"`
    bold "[$timeAndDate] [INFO]  $msg "
}

function ERROR(){
    local msg="$1"
    timeAndDate=`date "+%y-%m-%d %H:%M:%S"`
    underline "[$timeAndDate] [ERROR]  $msg "
}

#输入参数校验，这里需要输入两个参数
if [ ! -n "$JAR_VERSION" ]; then
 ERROR "请输入第一个参数！"
 exit 1
fi



#下载war包到临时文件夹
mkdir -p ./jar_tmp
wget  -P ./jar_tmp  $BACKEND_JAR_ROOT
jar_num=$(ls -lt ./jar_tmp | grep $BACKEND_NAME  | wc -l)
if [ $jar -eq 0 ];then
   ERROR "没有找到对应的jar包"
   exit 1
fi

if [ $jar -nq 1 ];then
   ERROR "jar数量有误：$jar_num"
   exit 1
fi

#解压该文件到指定目录
mkdir -p ./jar_unzip
rm -rf ./jar_unzip/*
unzip -q -o  "./jar_tmp/$BACKEND_NAME" -d ./jar_unzip/
INFO "$BACKEND_NAME解压成功 "

mkdir -p $SHELL_ROOT $JAR_ROOT

cp ./jar_unzip/shell/*  $SHELL_ROOT

cp ./jar_tmp/* $JAR_ROOT

rm -rf ./jar_unzip ./jar_tmp

INFO "复制shell和jar到工作目录成功！ "


#rpm打包
INFO "开始RPM打包......"
rpmbuild   --define="pkgname     ${NAME}"                           \
            --define="pkgversion  ${JAR_VERSION}"                        \
			--define="rcdc_rpm  ${RCDC_RPM}"                        \
			-bb "./rpm/rpm.spec"
!
INFO "RPM打包结束"

#将更新包拷贝到指定目录
if [ ! -d ${OUTPUT_ROOT} ]; then
    mkdir -pv ${OUTPUT_ROOT}
fi
INFO "将更新包拷贝到指定目录 : /report/output"
cp -f ~/rpmbuild/RPMS/x86_64/${NAME}-${JAR_VERSION}-1.x86_64.rpm ${OUTPUT_ROOT}/${NAME}-${JAR_VERSION}.rpm

# 清空rpmbuild文件夹
rm -rf ~/rpmbuild

INFO "success!"






