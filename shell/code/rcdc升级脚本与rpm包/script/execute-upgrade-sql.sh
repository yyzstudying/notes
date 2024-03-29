#!/bin/bash

#定义config.properties 中的变量
FILE=/data/web/config/rcdc/config.properties
SHELL_SQL_DIR=/data/web/rcdc/webapps/shell_and_sql
SHELL_SQL_DIR_SQL=/data/web/rcdc/webapps/shell_and_sql/sql
UPGRADE_LOG=/var/log/rcdc/upgrade/upgrade-rcdc-shell.log

SHELL_DIR=/data/web/rcdc/shell/

VERSION_FILE=/opt/upgrade/app/current/version.xml

UPGRADE_VERSION_DB_PROPERTIES=/data/web/rcdc/webapps/shell_and_sql/sql/version-db.properties
CURRENT_VERSION_DB_PROPERTIES=/data/web/rcdc/version-db.properties

B_VERSION=$1


function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> $UPGRADE_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg "  >>  $UPGRADE_LOG
}

function CHECK(){
   if [  $? -eq 0 ];then
      INFO "$1成功"
	else
	  ERROR "$1失败"
	  exit 1
   fi
}


#关闭sql和tomcat
systemctl stop postgresql-10
#service tomcat stop
sleep 1
rm -rf /data/postgresql/*

#原有数据
INFO "准备还原备份数据"

cp -ax /data/postgresql_$B_VERSION/. /data/postgresql/
CHECK "数据库恢复" 
cp -ax /opt/upgrade/app/temp/bak/rcdc/config  /data/web
CHECK "config恢复" 
cp -ax /opt/upgrade/app/temp/bak/rcdc/shell  /data/web/rcdc
CHECK "shell恢复" 

INFO "还原备份数据结束"


# 执行增量sql
INFO "准备执行增量sql与脚本替换"
systemctl start postgresql-10
CHECK "开启数据库" 
sleep 3



INFO "获取数据库配置信息"
if [ -f "$FILE" ] #判断文件是否存在
then
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
  ERROR  "$FILE 配置文件不存在"
  exit 1
fi


# 新增组件时
function execute_no_module_sql(){
    
    module_name=$1;
	upgrade_module_version=$2
	INFO "开始准备执行新增组件：$module_name 中的sql"
	cd $SHELL_SQL_DIR_SQL/$1/$2
	for sql_version in `ls | sort -V` 
	do
		#执行sql文件... 
		INFO "准备执行$sql_version文件中的init.sql"
		
		export PGPASSWORD=$Dpassword
		psql -h $Dip -p $Dport -U $Dusername -w   -d $Ddbname -f $sql_version/init.sql   >> $LOG_BUILD 2>&1
		CHECK "执行$sql_version文件中的init.sql"
		#export PGPASSWORD=$Ppassword
		#psql -h $Pip -p $Pport -U $Pusername -w   -d $Pdbname -f init.sql >> $SCRIPT_LOG
		
	done
	
}

# 比较版本号
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

# 升级组件
function execute_sql_fun(){
    
	module_name=$1;
	upgrade_module_version=$2
	current_module_version=$3
	INFO "开始准备执行升级组件：$module_name 的sql，升级版本号：$upgrade_module_version 当前版本号：$current_module_version"
	cd $SHELL_SQL_DIR_SQL/$1/$2
	for sql_version in `ls | sort -V`
	do
		# 判断版本
		if  version_gt $sql_version $current_module_version ;then
		  #执行sql文件... 
		  INFO "执行$sql_version文件中的init.sql"
		  export PGPASSWORD=$Dpassword
		  psql -h $Dip -p $Dport -U $Dusername -w   -d $Ddbname -f $sql_version/init.sql  >> $LOG_BUILD 2>&1
		  CHECK "执行$sql_version文件中的init.sql"
		fi

	done
	cd -
	
}

if [ -f $CURRENT_VERSION_DB_PROPERTIES ] ;then
	   INFO "开始对文件version-db.propertie进行遍历"
	   # 读取升级版本version-db.propertie的key和value
	    while read upgrade_line
	    do
			upgrade_key=`echo $upgrade_line | cut -d "=" -sf 1`
			upgrade_value=`echo $upgrade_line | cut -d "=" -sf 2-`
			
			# 状态
			status=1;
			
			while read current_line
			do
				current_key=`echo $current_line | cut -d "=" -sf 1`
				current_value=`echo $current_line | cut -d "=" -sf 2-`
				# 如果在目标系统version-db.propertie文件中找到对应的key，且value相等
				if [ $upgrade_key == $current_key -a  $current_value == $upgrade_value ];then 
				    status=0
					INFO "$upgrade_key 版本相同，无需升级"
				    break 
				fi
				
				if [ $upgrade_key == $current_key -a  $current_value != $upgrade_value ];then 
					execute_sql_fun $upgrade_key $upgrade_value $current_value
					status=0
				    break 
				fi
				
				 
			done < $CURRENT_VERSION_DB_PROPERTIES
			
			# 当前版本中没有对应的组件。即这个为新增组件
			if [ $status -eq 1 ];then
			 execute_no_module_sql $upgrade_key $upgrade_value
			fi
			 
		done < $UPGRADE_VERSION_DB_PROPERTIES
	   
	else
		ERROR "目标系统中$CURRENT_VERSION_DB_PROPERTIES文件不存在"
		exit 1
		
	fi

INFO "执行增量sql与脚本替换结束"

INFO "移动shell到工作目录"
if [ -d "$SHELL_SQL_DIR/shell"  ];then
	 cd $SHELL_SQL_DIR/shell
	 mv -f $SHELL_SQL_DIR/shell/* $SHELL_DIR
	 CHECK "移动shell到工作目录"
	 cd -
else
   ERROR "$SHELL_SQL_DIR/shell 不存在"
fi
INFO "移动新的version-db.properties到工作目录下"
mv -f $UPGRADE_VERSION_DB_PROPERTIES  /data/web/rcdc/
CHECK "移动version-db.properties失败"
rm -rf $SHELL_SQL_DIR

INFO "升级过程结束！"




