#!/bin/bash

NAME=$1
VERSION=$2

OUTPUT_ROOT="/report/output/$NAME"
SCRIPT_LOG="/report/log/$NAME/build.log"
RESULT_LOG="/report/log/$NAME/result.log"
EXECUTE_UPGRADE_SQL_DIR="/opt/build/rcdc-rpm/BUILDROOT/data/web/rcdc/webapps/shell_and_sql/execute-upgrade-sql"
if [ ! -n "$NAME" ]; then
 echo "请输入第一个参数！"
 exit
fi
if [ ! -n "$VERSION" ]; then
 echo "请输入第二个参数！"
 exit
fi
touch $RESULT_LOG
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
function SUCCESS(){
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);

	end_seconds=$(date --date="$endtime" +%s);
    touch /report/log/rcos-rcdc/result.log
    local msg="{\"status\":\"0\",\"taking\":\"$((end_seconds-start_seconds))s\",\"message\":\"$1\"}"
    echo $msg >> $RESULT_LOG
}
function FAILD(){
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date="$starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
    local msg="{\"status\":\"1\",\"taking\":\"$((end_seconds-start_seconds))s\",\"message\":\"$1\"}"
    echo $msg >> $RESULT_LOG
}

#下载war包

INFO "开始下载前后端war包..."
sh ./script/download-war.sh $NAME $VERSION
if [ $? -eq 0 ];then
	INFO "前后端war包下载成功"
else
  FAILD "download-war.sh 脚本出错"
 exit
fi


#提取war包中的sql和shell
INFO "开始提取war包中的sql和shell"
sh ./script/genernate-update-sql.sh  $VERSION
if [ $? -eq 0 ];then
	INFO "提取war包中的sql和shell成功"
else
  FAILD "genernate-update-sql.sh 脚本出错"
 exit
fi

# 复制 execute-upgrade-sql.sh到工作目录中
mkdir -p $EXECUTE_UPGRADE_SQL_DIR
cp script/execute-upgrade-sql.sh $EXECUTE_UPGRADE_SQL_DIR
if [ $? -eq 0 ];then
	INFO "复制execute-upgrade-sql.sh到工作目录成功"
 else
  FAILD "复制execute-upgrade-sql.sh 脚本出错"
 exit 1
fi


#rpm打包
INFO "开始RPM打包......"
rpmbuild   --define="pkgname     ${NAME}"                           \
            --define="pkgversion  ${VERSION}"                        \
			--define="rcdc_rpm  ${RCDC_RPM}"                        \
			-bb "./rpm/rpm.spec"
!
INFO "RPM打包结束"

#将更新包拷贝到指定目录
if [ ! -d ${OUTPUT_ROOT} ]; then
    mkdir -pv ${OUTPUT_ROOT}
fi
INFO "将更新包拷贝到指定目录 : /report/output"
cp -f ~/rpmbuild/RPMS/x86_64/${NAME}-${VERSION}-1.x86_64.rpm ${OUTPUT_ROOT}/${NAME}-${VERSION}.rpm

# 清空rpmbuild文件夹
rm -rf ~/rpmbuild
INFO "正在生成结果记录"

SUCCESS "打包成功"

INFO "success!"







