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


sh /data/web/rcdc/webapps/shell_and_sql/execute-upgrade-sql/execute-upgrade-sql.sh %{pkgversion}

%preun
    
%postun
    
%clean

 
%files
%defattr(-,root,root,-)
/data/web/rcdc/webapps/rcdc-rco-module-deploy
/data/web/rcdc/webapps/rcdc-rco-module-frontend
/data/web/rcdc/webapps/shell_and_sql

%changelog



