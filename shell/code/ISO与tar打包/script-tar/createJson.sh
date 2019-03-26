#!/bin/bash

OLD_VERSION_XML=script-iso/version.xml

VERSION_JSON=script-tar/version.json

CREATE_JSON_LOG=/report/log/createJson.log

cd ..

function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg " # >> $CREATE_JSON_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg "  #>>  $CREATE_JSON_LOG
	exit 1
}

function CHECK(){
   if [  $? -eq 0 ];then
      INFO "$1成功"
	else
	  ERROR "$1失败"
	  exit 1
   fi
}


UPGRADE_COMPONENTS=("rcos-rcdc-upgrade" "rcos-abslayer" "rcos-rcdc" "rcos-bt" "rcos-guesttool" "rcos-rco-linux-vdi")

if [ ! -e $OLD_VERSION_XML ] ;then
   ERROR "version.xml不存在"
fi 

if [ -e $VERSION_JSON ] ;then
   rm -rf $VERSION_JSON
fi 

echo "{" >> $VERSION_JSON

echo " \"version\":\"1.0.2\"," >> $VERSION_JSON

echo " \"base\":\"1.0.0\"," >> $VERSION_JSON

echo " \"1imit\":\"0.0.1\"," >> $VERSION_JSON

echo " \"componentInfoList\": [" >> $VERSION_JSON


for(( i=0;i<${#UPGRADE_COMPONENTS[@]};i++)) 
do
    component_name=${UPGRADE_COMPONENTS[i]};
	 INFO "遍历数组，取值：$component_name"
      while read line
       do  
			version=`echo $line | grep $component_name | grep -Eo  "([0-9])+\.([0-9])+\.([0-9])"`
                         if [ $version ] ;then
			 # echo $component_name:$version
			 if [ ! -e "$component_name/$component_name-$version.rpm" ] ;then
			   ERROR "$component_name/$component_name-$version.rpm不存在"
			 fi 
			  md5=`md5sum $component_name/$component_name-$version.rpm |cut -d ' ' -f1`
			  
			  name=`echo $component_name | sed "s/rcdc-//g"`
			  packageName=$component_name-$version.rpm
			  
			  echo "      { " >> $VERSION_JSON
			   echo "      \"md5\":\"$md5\"," >> $VERSION_JSON
			  echo "      \"name\":\"$component_name\"," >> $VERSION_JSON
			  echo "      \"version\":\"$version\"," >> $VERSION_JSON
			  echo "      \"packageName\":\"$packageName\"," >> $VERSION_JSON
			   echo "      \"shouldRestartRightNow\":false" >> $VERSION_JSON
			 # echo "   }" >> $NEW_VERSIO
                          num=${#UPGRADE_COMPONENTS[@]}    #个数
			 let subscript=$i
			  length=$(($subscript+1))
			 if [ $num -eq $length ];then
                          echo "   }" >> $VERSION_JSON
		        else 
		           echo "   }," >> $VERSION_JSON
		      fi
		fi
     done < $OLD_VERSION_XML
done
	  
echo "  ]" >> $VERSION_JSON
echo " }" >> $VERSION_JSON
INFO "生成version.json成功"



