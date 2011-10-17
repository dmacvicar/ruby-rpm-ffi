Name:           a
Version:        1.0
Release:        0
License:        GPLv2
Summary:        Minimal package example
Url:            http://www.a.com
Group:          Development
Source:         a-1.0.tar.gz
BuildRequires:  c d
Provides:       something
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Description

%package devel
Summary:        Development part
%description devel
Development headers

%prep
%setup -q

%build
%configure
make %{?_smp_mflags}

%install
%make_install

%clean
%{?buildroot:%__rm -rf "%{buildroot}"}

%post

%postun

%files
%defattr(-,root,root)
%doc ChangeLog README COPYING
%{_datadir}/a/README

%files devel
%{_includedir}/a.h



%changelog

