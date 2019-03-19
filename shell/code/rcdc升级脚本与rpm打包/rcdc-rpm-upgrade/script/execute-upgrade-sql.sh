#!/bin/bash

#定义config.properties 中的变量
FILE="/data/web/config/rcdc/config.properties"
SHELL_SQL_DIR="/data/web/rcdc/webapps/shell_and_sql"

SHELL_DIR="/data/web/rcdc/shell/"

VERSION_FILE="/opt/upgrade/app/current/version.xml"


function INFO(){
    local msg="$1"
    printf "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg \n"
}


if [ -f "$FILE" ] #判断文件是否存在
then
  echo "$FILE found."

  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_') #shell 脚本无法识别 key值带. 的参数，所以使用_代替.
    eval "${key}='${value}'"
  done < "$FILE"
#将配置文件中的值赋值到变量中
   export Dip="${datasource_default_ip}"
   export Dport="${datasource_default_port}"
   export Ddbname="${datasource_default_dbname}"
   export Dusername="${datasource_default_username}"
   export Dpassword="${datasource_default_password}"
   export Pip="${datasource_public_ip}"
   export Pport="${datasource_public_port}"
   export Pdbname="${datasource_public_dbname}"
   export Pusername="${datasource_public_username}"
   export Ppassword="${datasource_public_password}"
else
  echo "$FILE not found."
  exit 1
fi
#设置密码值
{
export PGPASSWORD=$Dpassword
#创建配置文件中的database,若存在则重建
#psql -h $Dip -p $Dport -U $Dusername -w -c "drop database if exists  $Ddbname" >> $SCRIPT_LOG
#psql -h $Pip -p $Pport -U $Pusername -w -c "drop database if exists  $Pdbname" >> $SCRIPT_LOG
#psql -h $Dip -p $Dport -U $Dusername -w -c "create database $Ddbname" >> $SCRIPT_LOG
#psql -h $Pip -p $Pport -U $Pusername -w -c "create database $Pdbname" >> $SCRIPT_LOG
}||{
exit 1
}

INFO "移动新的shell到工作目录"
if [ -d "$SHELL_SQL_DIR/shell"  ];then
	 cd $SHELL_SQL_DIR/shell
	 mv -f $SHELL_SQL_DIR/shell/* $SHELL_DIR
fi


# 获取version
version_string=`cat $VERSION_FILE | grep "name=\"rcdc\" version=" | tail -n 1 | cut -d "=" -f3- | awk '{print $1}'`
version_string_len=${#version_string}
version=${version_string:1:$version_string_len-2}
INFO "获取当前版本号：$version"


if [ -d "$SHELL_SQL_DIR/sql"  ];then
    cd $SHELL_SQL_DIR/sql
	#处理sql
	for sql_file in `ls`
	do
	   # 判断是否是文件夹
	   if [ -d "$sql_file"  ] ;then
	        cd $sql_file
			# 判断版本
			if [  $sql_file \> $version ];then
			#执行sql文件... 
			INFO "执行$sql_file文件中的init.sql"
			{
				export PGPASSWORD=$Dpassword
				psql -h $Dip -p $Dport -U $Dusername -w   -d $Ddbname -f init.sql 
				
				#export PGPASSWORD=$Ppassword
				#psql -h $Pip -p $Pport -U $Pusername -w   -d $Pdbname -f init.sql >> $SCRIPT_LOG
				
			}|| {
			  exit 1
			}
			fi
		cd -
	
		fi
	done
fi

INFO "执行增量sql与脚本替换结束"

rm -rf $SHELL_SQL_DIR

INFO "升级过程结束！"




