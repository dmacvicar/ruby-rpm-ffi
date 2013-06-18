Name:           simple_with_deps
Version:        1.0
Release:        0
License:        GPL
Summary:        Simple dummy package
Url:            http://www.dummmy.com
Group:          Development
Requires:       a
Requires:       b > 1.0
Conflicts:      c d
Obsoletes:      f
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Dummy package

%description -l es
Paquete de muestra

%prep

%build
mkdir -p %{buildroot}%{_datadir}/%{name}
echo "Hello" > %{buildroot}%{_datadir}/%{name}/README
echo "Hola" > %{buildroot}%{_datadir}/%{name}/README.es

%install

%clean
%{?buildroot:%__rm -rf "%{buildroot}"}

%files
%defattr(-,root,root)
%{_datadir}/%{name}/README
%{_datadir}/%{name}/README.es

%changelog
* Wed Nov 06 2011 Duncan Mac-Vicar P. <dmacvicar@suse.de>
- Fix something
* Tue Nov 05 2011 Duncan Mac-Vicar P. <dmacvicar@suse.de>
- Fix something else
