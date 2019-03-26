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
cp -rf /opt/build/%{pkgname}/BUILDROOT/data/ $RPM_BUILD_ROOT

%check


%post



%preun
    
%postun
    
%clean

 
%files
%defattr(-,root,root,-)
/data/

%changelog



