#!/bin/bash

if [ -z $1 ] ;then
  printf "upgradeVersion can not be empty"
  exit
fi

systemctl stop postgresql-10
if [  $? -ne 0 ];then
    printf "error:stop postgresql-10 "
    exit
fi

postgresqlFile="/data/postgresql"
if [ -d $postgresqlFile ];then
    rm -rf $postgresqlFile
fi

mkdir -p $postgresqlFile
cp -ax /data/postgresql_$1/. $postgresqlFile


#rpm安装前的准备工作
if [ `rpm -qa | grep rcos-rcdc | wc -l` -eq 1 ];then
   service tomcat stop
   sleep 3
   rpm -e rcos-rcdc
   rm -rf /data/web/rcdc/webapps/*
fi

rpm -ivh rcos-rcdc-$1.rpm
if [  $? -ne 0 ];then
    printf "error:npm installation failed"
    exit 1
fi

systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    printf "error:start postgresql-10"
    exit 1
fi




