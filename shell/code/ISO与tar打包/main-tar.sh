#!/bin/bash
NAME=$1
VERSION=$2
TIME=$(date +%s)
# 升级包根目录
UPGRADE_ROOT=/opt/upgrade
SCRIPT_TAR=script-tar
DIST_ROOT=/report
DIST_LOG=$DIST_ROOT/log
DIST_TMP=$DIST_ROOT/tmp
DIST_OUTPUT=$DIST_ROOT/output
LOG_BUILD=$DIST_LOG/build.log
LOG_RESULT=$DIST_LOG/result.log

VERSION_FILE=$SCRIPT_TAR/version.xml

VERSION_JSON=$SCRIPT_TAR/version.json

#打包文件名
TAR_FILE_NAME=$NAME-$VERSION.tar.gz

UPGRADE_COMPONENTS=("rcos-rcdc" "rcos-abslayer" "rcos-bt" "rcos-guesttool" "rcos-rco-linux-vdi")

SHELL_NAME=("-after-upgrade.sh" "-before-upgrade.sh" "-rollback.sh" "-upgrade.sh" "-validate.sh")

if [ ! -n "$NAME" ]; then
 echo "请输入第一个参数！参数为：文件名" 
 exit 1
fi
if [ ! -n "$VERSION" ]; then
 echo "请输入第二个参数！参数为：版本号"
 exit 1
fi


. ./$SCRIPT_TAR/packfun.sh

. ./$SCRIPT_TAR/packtar.sh>> $LOG_BUILD 2>&1

finish 0 "打包成功"


