#!/bin/bash
#声明rpm工作目录
RPM_TOP_DIR="/opt/build/rcdc-rpm"
#声明rcdc目录
RCDC_ROOT=${RPM_TOP_DIR}"/BUILDROOT/data/web/rcdc"
RCDC_UPGRADE_WAR_ROOT=${RPM_TOP_DIR}"/BUILDROOT/data/web/rcdc/webapps"
WAR_NAME=$1
WAR_VERSION=$2
MAVEN_ROOT=http://172.21.192.204:8081/nexus/content/repositories/public
# deploy下载地址
BACKEND_WAR_ROOT=$MAVEN_ROOT"/com/ruijie/rcos/rcdc/rco/module/rcdc-rco-module-deploy"
DOWNLOAD_BACKEND_WAR=$BACKEND_WAR_ROOT"/$WAR_VERSION-RELEASE/rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war"
# frontend下载地址
FRONTEND_WAR_ROOT=$MAVEN_ROOT"/com/ruijie/rcos/rcdc/rco/module/rcdc-rco-module-frontend"
DOWNLOAD_FRONTEND_WAR=$FRONTEND_WAR_ROOT"/$WAR_VERSION-RELEASE/rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war"



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
    bold "[$timeAndDate] [INFO]  $msg "|tee -a $SCRIPT_LOG
}

function ERROR(){
    local msg="$1"
    timeAndDate=`date "+%y-%m-%d %H:%M:%S"`
    underline "[$timeAndDate] [ERROR]  $msg"|tee -a $SCRIPT_LOG
}

#输入参数校验，这里需要输入两个参数
if [ ! -n "$WAR_NAME" ]; then
 ERROR "请输入第一个参数！"
 exit 1
fi
if [ ! -n "$WAR_VERSION" ]; then
 ERROR "请输入第二个参数！"
 exit 1
fi
if [ ! -d  "/report/log/$WAR_NAME" ]; then
    mkdir -pv /report/log/$WAR_NAME
fi

#下载war包到临时文件夹
mkdir -p ./deploy_tmp
wget  -np -nd  -r -A war -P ./deploy_tmp -o /report/log/$WAR_NAME/build.log $DOWNLOAD_BACKEND_WAR
deploy_num=$(ls -lt ./deploy_tmp | grep $WAR_VERSION  | wc -l)
if [ $deploy_num -eq 0 ];then
   ERROR "没有找到对应的deploy war包"
   exit 1
fi

#解压该文件到指定目录
mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/
rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/*
unzip -q -o  "./deploy_tmp/rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war" -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/
INFO "rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war解压成功 "

mkdir -p ./frontend_tmp
wget  -np -nd  -r -A war -P ./frontend_tmp -o /report/log/$WAR_NAME/build.log $DOWNLOAD_FRONTEND_WAR

frontend_num=$(ls -lt ./frontend_tmp | grep $WAR_VERSION  | wc -l)
if [ $frontend_num -eq 0 ];then
   ERROR "没有找到对应的frontend war包"
   exit 1
fi

mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/
rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/*
unzip -q -o "./frontend_tmp/rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war" -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/
INFO "rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war解压成功 " 

rm -rf ./deploy_tmp
rm -rf ./frontend_tmp








