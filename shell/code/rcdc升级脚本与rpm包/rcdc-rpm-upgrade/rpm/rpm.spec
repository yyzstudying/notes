%define __jar_repack 0
Name:		%{pkgname}
Version:	%{pkgversion}
Release:    1
Summary:	A part of RCOS
License:	GPLv2+ and LGPLv2+ and BSD
URL:		http://www.ruijie.com.cn/

%description
    
%prep
#Normally this involves unpacking the sources and applying any patches.

%build
#This generally involves the equivalent of a "make".

%install
cp -rf /opt/build/rcdc-rpm/BUILDROOT/data/ $RPM_BUILD_ROOT

%check



%post

#关闭sql和tomcat
systemctl stop postgresql-10
service tomcat stop
sleep 1
rm -rf /data/postgresql/*

#原有数据
printf "[`date "+%y-%m-%d %H:%M:%S"`][INFO] 还原原有数据库数据 \n"
cp -ax /data/postgresql_%{pkgversion}/. /data/postgresql/
cp -ax /opt/upgrade/app/temp/bak/rcdc/config  /data/web
cp -ax /opt/upgrade/app/temp/bak/rcdc/shell  /data/web/rcdc

# 执行增量sql
printf "[`date "+%y-%m-%d %H:%M:%S"`][INFO] 准备执行增量sql与脚本替换 \n"
systemctl start postgresql-10
sleep 3
sh /data/web/rcdc/webapps/shell_and_sql/execute-upgrade-sql/execute-upgrade-sql.sh %{pkgname}
#开启tomcat
service tomcat start
%preun
    
%postun
    
%clean

 
%files
%defattr(-,root,root,-)
/data/web/rcdc/webapps/rcdc-rco-module-deploy
/data/web/rcdc/webapps/rcdc-rco-module-frontend
/data/web/rcdc/webapps/shell_and_sql

%changelog



