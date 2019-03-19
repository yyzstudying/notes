#!/bin/bash

function mountQcow2(){

    modprobe nbd max_part=8

    info "开始挂载qcow2文件"
    qemu-nbd -c /dev/nbd0 $QCOW2_TMP_FILE
    check "挂载qcow2文件失败"

	info $QCOW2_TMP_FILE
	lsblk
	
    mkdirs $QCOW2_MOUNT_PATH
    info "开始挂载/dev/nbd0p3到$QCOW2_MOUNT_PATH"
    mount /dev/nbd0p3 $QCOW2_MOUNT_PATH
    check "挂载/dev/nbd0p3失败"

    info "开始挂载/dev/nbd0p5到$QCOW2_MOUNT_PATH/data"
    mount /dev/nbd0p2 $QCOW2_MOUNT_PATH/data
    check "挂载/dev/nbd0p2失败"

    info "挂载qcow2成功"
}

function umountQcow2(){

    info "开始卸载$QCOW2_MOUNT_PATH/data"
    umount $QCOW2_MOUNT_PATH/data
    info "开始卸载$QCOW2_MOUNT_PATH"
    umount $QCOW2_MOUNT_PATH
    rmdirs $QCOW2_MOUNT_PATH
    info "开始卸载qcow2文件"
    qemu-nbd -d /dev/nbd0
    check "卸载qcow2文件失败"
    info "卸载qcow2成功"
}

echo ""
echo "************开始构建QCOW2***************"
echo "构建时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""

info "开始校验:$VERSION_FILE"

checkFile $VERSION_FILE

checkMd5 $QCOW2_FILE $QCOW2_FILE_MD5
checkMd5 $ISO_FILE $ISO_FILE_MD5

mkdirs $DIST_LOG
mkdirs $DIST_OUTPUT
mkdirs $DIST_TMP

info "开始复制qcow2模板到临时目录"
cp $QCOW2_FILE $QCOW2_TMP_FILE
check "复制qcow2模板到临时目录失败"

mountQcow2

info "开始安装rpm到qcow2模板"

chroot $QCOW2_MOUNT_PATH mknod /dev/urandom c 1 9

for component in ${QCOW2_RPM_ARR[@]};do

    package=$(getPackage $component "rpm")
    packfile=${component}/${package}

    checkFile $packfile

    info "拷贝文件: $packfile"
    cp $packfile $QCOW2_MOUNT_PATH/$QCOW2_RPM_PATH

    info "开始安装: $package"
    chroot $QCOW2_MOUNT_PATH rpm -ivh $QCOW2_RPM_PATH/$package --force --nodeps

    #check "安装: $package 失败"
done

umountQcow2

info "开始压缩qcow2文件到tgz格式"

cd $DIST_TMP

tar -zcvf $QCOW2_TGZ_FILE  ${QCOW2_TMP_FILE##*/}
check "压缩qcow2文件失败"

cd $ROOT

echo ""
echo "************构建QCOW2成功***************"
echo "构建成功:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""
