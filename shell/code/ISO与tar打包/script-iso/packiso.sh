#!/bin/bash

echo ""
echo "*************开始构建ISO****************"
echo "构建时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""

modprobe nbd max_part=8

mkdirs $ISO_MOUNT_PATH
mkdirs $ISO_TMP_PATH

info "开始挂载zettaiso"
mount -o loop -o ro  $ISO_FILE $ISO_MOUNT_PATH
check "挂载zettaiso失败"

info "开始复制zettaiso中的文件到临时目录"
cp -r $ISO_MOUNT_PATH/* $ISO_TMP_PATH
check "复制zettaiso中的文件到临时目录失败"

info "开始卸载zettaiso"
umount $ISO_MOUNT_PATH
rmdirs $ISO_MOUNT_PATH


cd $ISO_TMP_PATH/LiveOS
info '解密zettakit.z开始'
openssl enc -d -des3 -a -salt -pass pass:zettapass -in zettakit.z -out zettakit.tgz
info '解密zettakit.z成功'

info '解压zettakit.tgz开始'
mkdirs zettakit
tar zxvf zettakit.tgz -C zettakit/
rm -rf zettakit.tgz
rm -rf zettakit.z
info '解压zettakit.tgz成功'
cd $ROOT

mkdirs $ISO_RUIJIE_SH_PATH
mkdirs $ISO_RUIJIE_RPM_PATH
mkdirs $ISO_3PT_RPM_PATH
mkdirs $ISO_TOOLS_PATH

info "开始复制锐捷的RPM"

rm -rf $ISO_RUIJIE_RPM_PATH/*

for component in ${ISO_RPM_ARR[@]};do
    package=$(getPackage $component "rpm")
    info "copy $package ..."
    cp ${component}/${package} $ISO_RUIJIE_RPM_PATH
    check "copy $package failed"
done

info "开始复制依赖的PRM"

rm -rf $ISO_3PT_RPM_PATH/*

cp $DEPEND_RPM_PATH/* $ISO_3PT_RPM_PATH
check "copy $DEPEND_RPM_PATH failed"

info "开始复制rcos-install.sh"
cp $SCRIPT_ISO/rcos-install.sh $ISO_RUIJIE_SH_PATH
check "copy rcos-install.sh failed"

info "开始复制guesttool"
info $GUESTTOOL_FILE
info $ISO_TOOLS_PATH
cp -rf $GUESTTOOL_FILE $ISO_TOOLS_PATH
check "copy $package failed"


info "开始复制qcow2"
cp -rf $QCOW2_TGZ_FILE $ISO_TOOLS_PATH
check "copy $QCOW2_TGZ_FILE failed"
info "开始执行zetta的iso打包"

name=${ISO_DIST##*/}
path=${ISO_DIST}

cd $ISO_TMP_PATH

if [ -d 'LiveOS/zettakit' ];then 
    cd LiveOS/zettakit
    info '生成zettakit.tgz开始'
    tar zcvf  ../zettakit.tgz  *
    info '生成zettakit.tgz结束'
    cd ..
    info '生成zettakit.z开始'
    openssl enc -des3 -a -salt -pass pass:zettapass -in zettakit.tgz -out zettakit.z
    info '生成zettakit.z完成'
    rm -rf zettakit
    rm -f zettakit.tgz
    cd ..
elif [ ! -f 'LiveOS/zettakit.z' ];then
    finish 2 "生成zettakit.z失败"
fi

info '更新数据仓库开始'
createrepo --update -g comps.xml .
check "更新数据仓库失败"

info '制作iso文件开始'
genisoimage -U -r -v -T -J -joliet-long -V "ServerOS" -volset "ServerOS" -A "ServerOS" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -o $path .
check "打包iso失败"

info '文件名为:'$name

cd $ROOT

echo ""
echo "*************构建ISO成功****************"
echo "构建成功:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""
