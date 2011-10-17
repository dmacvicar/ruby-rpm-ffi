Name:           simple
Version:        1.0
Release:        0
License:        GPL
Summary:        Simple dummy package
Url:            http://www.dummmy.com
Group:          Development
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Dummy package

%prep

%build
mkdir -p %{buildroot}%{_datadir}/%{name}
echo "Hello" > %{buildroot}%{_datadir}/%{name}/README

%install

%clean
%{?buildroot:%__rm -rf "%{buildroot}"}

%post

%postun

%files
%defattr(-,root,root)
%{_datadir}/%{name}/README

%changelog

