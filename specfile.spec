Summary: @DESCR@
Name: @NAME@
Version: @VERSION@
Vendor: EDG / CERN
Release: @RELEASE@
License: http://www.eu-datagrid.org/license.html
Group: @GROUP@
Source: @TARFILE@
BuildArch: noarch
BuildRoot: /var/tmp/%{name}-build
Packager: @AUTHOR@

Requires: perl-CAF
Requires: perl-LC
Requires: ccm >= 1.1.6

%description
@DESCR@


%prep
%setup

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make PREFIX=$RPM_BUILD_ROOT install

# leave log file//
#%postun
#[ $1 = 0 ] && rm -f @NCM_ROTATED@/@NAME@
#exit 0

%files
%defattr(-,root,root)
@QTTR_BIN@/ncm-query
%doc @QTTR_DOC@/
%doc @QTTR_MAN@/man@MANSECT@/@COMP@.@MANSECT@.gz


%clean
rm -rf $RPM_BUILD_ROOT
