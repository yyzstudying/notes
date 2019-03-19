#!/bin/bash

ROOT=$(pwd)
TIME=$(date +%s)
VERSION_TIME=$(date +%Y%m%d%H%M%S)
DIST_ROOT=/report
DIST_LOG=$DIST_ROOT/log
DIST_TMP=$DIST_ROOT/tmp
DIST_OUTPUT=$DIST_ROOT/output

LOG_BUILD=$DIST_LOG/build.log
LOG_RESULT=$DIST_LOG/result.log

PRE_SCRIPT=rpm-other

#脚本目录
SCRIPT_ISO="script-iso"
VERSION_FILE=$SCRIPT_ISO/version.xml

ISO_FILE=zeta-iso/zeta.iso
ISO_FILE_MD5=zeta-iso/md5

QCOW2_FILE=rcdc-qcow2/rcos-rcdc.qcow2
QCOW2_FILE_MD5=rcdc-qcow2/md5

ISO_MOUNT_PATH=/mnt/iso

ISO_TMP_PATH=$DIST_TMP/iso
ISO_RUIJIE_SH_PATH=$ISO_TMP_PATH/LiveOS/zettakit/ruijie
ISO_RUIJIE_RPM_PATH=$ISO_TMP_PATH/LiveOS/zettakit/ruijie/model
ISO_3PT_RPM_PATH=$ISO_TMP_PATH/LiveOS/zettakit/ruijie/depend
ISO_TOOLS_PATH=$ISO_TMP_PATH/LiveOS/zettakit/tools

ISO_DIST=$DIST_OUTPUT/$1-$2-build$VERSION_TIME.iso

DEPEND_RPM_PATH=./rpm-dep

QCOW2_MOUNT_PATH=/mnt/rcdc
QCOW2_RUIJIE_RPM_PATH=/data/install_rcdcos
GUESTTOOL_FILE=./rcos-guesttool/rcos-guesttool.iso
QCOW2_TGZ_FILE=$DIST_TMP/rcos-rcdc.qcow2.tgz
QCOW2_TMP_FILE=$DIST_TMP/rcos-rcdc.qcow2
RCO_TOOL_FILE=$ISO_TOOLS_PATH/rcos-guesttool.iso
TOOL_FILE=$ISO_TOOLS_PATH/tools.iso 
ISO_RPM_ARR=("rcos-qemu" "rcos-libvirt" "rcos-vmtools" "rcos-est-server" "rcos-est-usbredir")
QCOW2_RPM_ARR=("rcos-rcdc" "rcos-bt" "rcos-abslayer" "rcos-rco-linux-vdi")

. ./$SCRIPT_ISO/packfun.sh

## . ./$SCRIPT_ISO/packpre.sh >> $LOG_BUILD 2>&1
. ./$SCRIPT_ISO/packqcow2.sh >> $LOG_BUILD 2>&1
. ./$SCRIPT_ISO/packiso.sh >> $LOG_BUILD 2>&1


rmdirs $DIST_TMP >> $LOG_BUILD 2>&1

finish 0 "构建成功"
