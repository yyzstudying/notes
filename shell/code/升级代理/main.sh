#!/bin/bash
             #************** TODO 修改下载地址 *********************#
RPM_NAME=$1
VERSION=$2

MAVEN_ROOT="http://172.21.192.204:8081/nexus/content/repositories/public"

# rpm包地址
OUTPUT_ROOT="/report/output/$RPM_NAME"
# jar下载地址    
BACKEND_JAR_ROOT=$MAVEN_ROOT"/com/101tec/zkclient/0.10/zkclient-0.10.jar"

# 脚本工作目录
SHELL_ROOT="/opt/build/$RPM_NAME/BUILDROOT/data/web/rcdc/shell"
# jar工作目录
JAR_ROOT="/opt/build/$RPM_NAME/BUILDROOT/data/web/upgrade"

WAR_ROOT="/opt/build/$RPM_NAME/BUILDROOT/data/web/rcdc/webapps"

# rcdc-upgrade-frontend下载地址
FRONTEND_WAR_ROOT=$MAVEN_ROOT"/com/ruijie/rcos/rcdc/rco/module/rcdc-rco-module-frontend/"
DOWNLOAD_FRONTEND_WAR=$FRONTEND_WAR_ROOT"$VERSION-RELEASE/rcdc-rco-module-frontend-$VERSION-RELEASE.war"



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
if [ ! -n "$RPM_NAME" ]; then
 ERROR "请输入第一个参数！RPM_NAME"
 exit 1
fi

if [ ! -n "$VERSION" ]; then
 ERROR "请输入第二个参数！VERSION"
 exit 1
fi

# -----------------------jar-------------------------
#下载jar包到临时文件夹
INFO "开始下载jar包"
mkdir -p  jar_tmp
wget  -P ./jar_tmp  $BACKEND_JAR_ROOT
INFO "下载jar包结束"
jar_num=$(ls -lt ./jar_tmp | grep .jar  | wc -l)
if [ $jar_num -eq 0 ];then
   ERROR "没有找到对应的jar包"
   exit 1
fi

if [ $jar_num -ne 1 ];then
   ERROR "jar数量有误：$jar_num"
   exit 1
fi

DOWNLOAD_JAR_NAME=$(ls ./jar_tmp | grep .jar)

#解压该文件到指定目录
mkdir -p ./jar_unzip
rm -rf ./jar_unzip/*
unzip -q -o  "./jar_tmp/$DOWNLOAD_JAR_NAME" -d ./jar_unzip/
INFO "解压$DOWNLOAD_JAR_NAME 成功 "

mkdir -p $SHELL_ROOT $JAR_ROOT

if [ -d "jar_unzip/shell" ];then
   cp ./jar_unzip/shell/*  $SHELL_ROOT
else
    ERROR "脚本文件不存在"
    exit 1
fi



cp ./jar_tmp/* $JAR_ROOT

#rm -rf ./jar_unzip ./jar_tmp

INFO "复制shell和jar到工作目录成功！ "


# -----------------------war-------------------------
INFO "开始下载war包"
mkdir -p /report/log/$RPM_NAME
mkdir -p ./frontend_tmp
wget  -np -nd  -r -A war -P ./frontend_tmp -o /report/log/$RPM_NAME/build.log $DOWNLOAD_FRONTEND_WAR
frontend_num=$(ls -lt ./frontend_tmp | grep .war  | wc -l)
if [ $frontend_num -eq 1 ];then
    INFO "找到对应的RELEASE-war包"
	mkdir -p $WAR_ROOT/rcdc-upgrade-frontend/
	rm -rf $WAR_ROOT/rcdc-upgrade-frontend/*
	FILE_WAR_NAME=$(ls  ./frontend_tmp | grep .war )
	unzip -q -o ./frontend_tmp/$FILE_WAR_NAME -d $WAR_ROOT/rcdc-upgrade-frontend/
	INFO "$FILE_WAR_NAME解压成功 " 
else
    INFO "没有找到对应的RELEASE war包"
    INFO "开始下载SNAPSHOT-war包"
    wget  -np -nd  -r -A war -P ./frontend_tmp -o /report/log/$RPM_NAME/build.log $FRONTEND_WAR_ROOT
	ls -lt ./frontend_tmp | grep $VERSION- | head -n 1 |awk '{print $9}' > tmp.txt
	read tmp < tmp.txt
	rm -rf ./tmp.txt
	if [ ! -n "$tmp" ]; then
		 ERROR "找不到$VERSION 相关的war包！"
		 rm -rf ./frontend_tmp
		 exit 1
	fi
	INFO "找到$tmp文件"
	mkdir -p $RCDC_UPGRADE_WAR_ROOT/rcdc-upgrade-frontend/
	rm -rf $RCDC_UPGRADE_WAR_ROOT/rcdc-upgrade-frontend/*
	unzip -q -o ./frontend_tmp/$tmp -d $RCDC_UPGRADE_WAR_ROOT/rcdc-upgrade-frontend/ 
	INFO "$tmp解压成功"
fi
rm -rf frontend_tmp


#rpm打包
INFO "开始RPM打包......"
rpmbuild   --define="pkgname     ${RPM_NAME}"                           \
            --define="pkgversion  ${VERSION}"                        \
			--define="rcdc_rpm  ${RCDC_RPM}"                        \
			-bb "./rpm/rpm.spec"
!
INFO "RPM打包结束"

#将更新包拷贝到指定目录
if [ ! -d ${OUTPUT_ROOT} ]; then
    mkdir -pv ${OUTPUT_ROOT}
fi
INFO "将更新包拷贝到指定目录 : ${RPM_NAME}-${VERSION}.rpm -> $OUTPUT_ROOT"
cp -f ~/rpmbuild/RPMS/x86_64/${RPM_NAME}-${VERSION}-1.x86_64.rpm ${OUTPUT_ROOT}/${RPM_NAME}-${VERSION}.rpm

# 清空rpmbuild文件夹
INFO "清理rpmbuild和BUILDROOT"
rm -rf ~/rpmbuild
rm -rf /opt/build/$RPM_NAME/BUILDROOT

INFO "success!"






