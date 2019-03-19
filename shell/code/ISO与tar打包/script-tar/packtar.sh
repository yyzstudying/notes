#!/bin/bash

echo ""
echo "*************开始打包tar****************"
echo "时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""

mkdirs $UPGRADE_ROOT

cp $VERSION_FILE $UPGRADE_ROOT

#判断一个文件夹中是否含有一个$2文件
function ifExistFile(){
  cd $1
  file=$2
  file_num=`ls | grep $file | wc -l`
  echo $file_num
  cd ..
}

#判断一个文件夹中是否只有一个rpm文件，已经如果没有升级脚本这默认生成一个
function rpmAndShCheck(){
  rpm_num=`ls $1 | grep .rpm | wc -l`
  if [ $rpm_num -ne 1 ];then
     error "$2中的rpm数量错误"
	 exit 1
  fi
  
  sh_num=`ls $1| grep .sh | wc -l`
  if [ $sh_num -eq 1 ];then
     info "$1文件中含有升级脚本文件"
  else
     info "$1文件没有升级脚本文件，创建默认升级文件"
	 touch $1/$2"-upgrade-"$VERSION".sh"
	 echo "#!/bin/bash" >> $1/$2"-upgrade-"$VERSION".sh"
	 echo "printf \"success\"" >> $1/$2"-upgrade-"$VERSION".sh"
  fi

}

info "开始准备文件"
for component_name in ${UPGRADE_COMPONENTS[@]};do
   mkdirs $UPGRADE_ROOT/$component_name
    if [  -d $component_name ];then 
	       # 文件夹中rpm和sh文件校验
		   # 如果存在upgrade-file.list文件，则复制upgrade-file.list中的列出的文件，不存在则全部复制
		   if [ $(ifExistFile $component_name "upgrade-file.list") -eq 1 ];then
		    info "$component_name中存在upgrade-file.list文件"
			info "读取$component_name/upgrade-file.list的内容"
				while read line
				do
					info "读取：$line"
					if [ -e $component_name/$line ];then
					   info "copy：$line"
					   cp $component_name/$line $UPGRADE_ROOT/$component_name
					else
					   info "$line文件不存在"
					fi
				done < $component_name/upgrade-file.list
			info "读取$component_name/upgrade-file.list完毕"
		   else
		        info "$component_name中不存在upgrade-file.list文件，copy *"
		        cp $component_name/* $UPGRADE_ROOT/$component_name

		   fi
		    rpmAndShCheck $UPGRADE_ROOT/$component_name $component_name
    else
      error "$component_name 组件不存在"
	  exit 1
    fi
   # version=$(getVersion $component_name)
	#echo $component_name-$version."rpm"
done

cd $UPGRADE_ROOT
info "开始压缩文件"
tar zcvf $TAR_FILE_NAME *

info "压缩文件成功，文件名：$TAR_FILE_NAME"

mkdirs $DIST_OUTPUT

cp $TAR_FILE_NAME $DIST_OUTPUT
info "复制文件到：$DIST_OUTPUT"

rm -rf $UPGRADE_ROOT
info "清理$UPGRADE_ROOT目录"

echo ""
echo "*************打包tar成功****************"
echo "时间:$(date "+%Y-%m-%d %H:%M:%S")"
echo "****************************************"
echo ""


