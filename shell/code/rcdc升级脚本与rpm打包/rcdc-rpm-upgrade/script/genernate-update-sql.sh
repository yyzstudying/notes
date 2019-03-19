#!/usr/bin/sh
app_lib_dir="/opt/build/rcdc-rpm/BUILDROOT/data/web/rcdc/webapps/rcdc-rco-module-deploy/WEB-INF/lib"
shell_and_sql_temp_dir="/opt/build/rcdc-rpm/BUILDROOT/data/web/rcdc/webapps/shell_and_sql"
jar_temp="/opt/jar-temp"
app_shell_dir="/opt/jar-temp/shell"

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

# 创建shell和sql的临时存放文件夹
mkdir -p $shell_and_sql_temp_dir

# 解压jar
function FINDSCRIPT(){
 jar_file_1=$1
 # 判断是否是普通文件
 if [ -f $jar_file_1 ];then
    INFO "------开始：对$jar_file_1进行解压操作"
	unzip -o -q $jar_file_1 -d $jar_temp 
	INFO "成功解压JAR包$jar_file_1"
	   
	   #校验目录下是否有sql-script
        cd $jar_temp
		if [ `ls -l |grep "sql-script"|wc -l` -eq 1 ];then
			INFO "JAR包$jar_file内含有sql-script"
			# 进入sql-script文件夹
			cd $jar_temp"/sql-script"
			
			#遍历public和default文件夹
			for dir in "default" "public" 
			do
			    # 是否存在该文件夹
				if [ -d $dir ];then
				  INFO "目录$dir存在"
					cd $dir
					
					# 查看default或public中的目录 
					#如：1.0.0 2.0.0 
					for element in `ls -F | grep '/$'`
					do
					    # 创建对应版本的文件夹以及init.sql
						mkdir -p $shell_and_sql_temp_dir/sql/$element
						touch $shell_and_sql_temp_dir/sql/$element/init.sql
						init_sql_file=$shell_and_sql_temp_dir/sql/$element/init.sql
						
						#追加global-pre.sql
						#校验pre文件个数
						global_pre_num=`ls  |grep "global-pre.sql" | wc -l`
						if [ $global_pre_num -eq 1 ];then
							INFO "找到一个global-pre.sql文件"
						    echo "--------------global-pre.sql--------------" >> $init_sql_file
							cat global-pre.sql >> $init_sql_file
							INFO "在init.sql中追加global-pre.sql"
						fi
						
						#追加global-post.sql
						#校验post文件个数
						global_pre_num=`ls  |grep "global-post.sql" | wc -l`
						if [ $global_pre_num -eq 1 ];then
							INFO "找到一个global-post.sql文件"
							echo "--------------global-post.sql--------------" >> $init_sql_file
							cat global-post.sql >> $init_sql_file
							INFO "在init.sql中追加global-post.sql"
						fi
						# 追加对应版本的sql
						cd $element
						for sql_file in `ls`
						do
							echo "--------------sql_file--------------" >> $init_sql_file
							cat $sql_file >> $init_sql_file
							INFO "在init.sql中追加$sql_file"
						done
						cd ..
						
					done 
					
				else
					INFO "目录$dir不存在"
				fi
				
				
				
			done
		    # 存在sql-script文件夹，遍历后将其删除
		    rm -rf /opt/jar-temp/sql-script
		else
			INFO "JAR包$jar_file内不含sql-script，解压下一个jar"
		fi
		
 fi
 
 cd $app_lib_dir
}

cd $app_lib_dir
for jar_file in `ls *.jar`
do
	FINDSCRIPT $jar_file
done

#将shell文件考到rpm工作空间 -d:是否为目录
if [ -d $app_shell_dir ];then
	INFO "找到目录$app_shell_dir"
	cp -ax 	$app_shell_dir $shell_and_sql_temp_dir
	INFO "已复制$app_shell_dir到$shell_and_sql_temp_dir下"
fi

















