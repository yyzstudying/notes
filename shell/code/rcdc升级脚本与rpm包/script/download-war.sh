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
BACKEND_WAR_ROOT=$MAVEN_ROOT"/com/ruijie/rcos/rcdc/rco/module/rcdc-rco-module-deploy/"
DOWNLOAD_BACKEND_WAR=$BACKEND_WAR_ROOT"$WAR_VERSION-RELEASE/rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war"
# frontend下载地址
FRONTEND_WAR_ROOT=$MAVEN_ROOT"/com/ruijie/rcos/rcdc/rco/module/rcdc-rco-module-frontend/"
DOWNLOAD_FRONTEND_WAR=$FRONTEND_WAR_ROOT"$WAR_VERSION-RELEASE/rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war"
SCRIPT_LOG=/report/log/$WAR_NAME/build.log



function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> $SCRIPT_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg "  >>  $SCRIPT_LOG
}

function CHECK(){
   if [  $? -eq 0 ];then
      INFO "$1成功"
	else
	  ERROR "$1失败"
	  exit 1
   fi
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
wget  -np -nd  -r -A war -P ./deploy_tmp  $DOWNLOAD_BACKEND_WAR
deploy_num=$(ls -lt ./deploy_tmp | grep $WAR_VERSION  | wc -l)
if [ $deploy_num -eq 1 ];then
    #解压该文件到指定目录
	INFO "找到对应的deploy-RELEASE-war包,开始解压"
	mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/
	rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/*
	unzip -q -o  "./deploy_tmp/rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war" -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/
	INFO "rcdc-rco-module-deploy-$WAR_VERSION-RELEASE.war解压成功 "

else
    INFO "没有找到对应的deploy-RELEASE-war包"
    INFO "开始下载deploy-SNAPSHOT-war包"
    wget  -np -nd  -r -A war -P ./deploy_tmp  $BACKEND_WAR_ROOT
	#在临时文件夹中查找出修改时间最新的文件名
	ls -lt ./deploy_tmp | grep $WAR_VERSION- | head -n 1 |awk '{print $9}' > tmp.txt
	read tmp < tmp.txt
	rm -rf ./tmp.txt
	if [ ! -n "$tmp" ]; then
		 ERROR "找不到$WAR_VERSION 相关的war包！"
		 rm -rf ./deploy_tmp
		 exit 1
	fi
	INFO "找到$tmp文件" 
	#解压该文件到指定目录
	mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/
	rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/*
	unzip -q -o ./deploy_tmp/$tmp -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-deploy/  
	INFO "$tmp解压成功"
fi


mkdir -p ./frontend_tmp
wget  -np -nd  -r -A war -P ./frontend_tmp  $DOWNLOAD_FRONTEND_WAR
frontend_num=$(ls -lt ./frontend_tmp | grep $WAR_VERSION  | wc -l)
if [ $frontend_num -eq 1 ];then
    INFO "找到对应的frontend-RELEASEwar包"
	mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/
	rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/*
	unzip -q -o "./frontend_tmp/rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war" -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/
	INFO "rcdc-rco-module-frontend-$WAR_VERSION-RELEASE.war解压成功 " 
else
   INFO "没有找到对应的frontend-RELEASE war包"
   INFO "开始下载frontend-SNAPSHOT-war包"
   wget  -np -nd  -r -A war -P ./frontend_tmp  $FRONTEND_WAR_ROOT
	ls -lt ./frontend_tmp | grep $WAR_VERSION- | head -n 1 |awk '{print $9}' > tmp2.txt
	read tmp2 < tmp2.txt
	rm -rf ./tmp2.txt
	if [ ! -n "$tmp2" ]; then
		 ERROR "找不到$WAR_VERSION 相关的war包！"
		 rm -rf ./frontend_tmp
		 exit 1
	fi
	INFO "找到$tmp2文件"
	mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/
	rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/*
	unzip -q -o ./frontend_tmp/$tmp2 -d $RCDC_UPGRADE_WAR_ROOT/rcdc-rco-module-frontend/ 
	INFO "$tmp2解压成功"
fi


rm -rf ./deploy_tmp
rm -rf ./frontend_tmp








