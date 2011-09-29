%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define release %{rpm_release}%{?dist}

Summary: Eventmachine based file tailer
Name: typhon
Version: %{version}
Release: %{release}
Group: System Tools
License: Apache v2
URL: http://www.devco.net/
Source0: %{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: ruby
Requires: rubygem-eventmachine-tail
BuildArch: noarch
Packager: R.I.Pienaar <rip@devco.net>

%description
An Eventmachine based daemon that tails file and process lines using
custom logic

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
%{__install} -d -m0755  %{buildroot}/%{ruby_sitelib}/typhon
%{__install} -d -m0755  %{buildroot}/etc/typhon/heads
%{__install} -d -m0755  %{buildroot}/usr/sbin
%{__install} -d -m0755  %{buildroot}/etc/init.d
%{__install} -m0755 bin/typhon %{buildroot}/usr/sbin/typhon
%{__install} -m0755 typhon.init %{buildroot}/etc/init.d/typhon
cp lib/typhon.rb %{buildroot}/%{ruby_sitelib}/typhon.rb
cp -R lib/typhon %{buildroot}/%{ruby_sitelib}/
cp etc/typhon.yaml.dist %{buildroot}/etc/typhon/typhon.yaml

%clean
rm -rf %{buildroot}

%post
/sbin/chkconfig --add typhon

%preun
if [ "$1" = 0 ]; then
   /sbin/service typhon stop >/dev/null 2>&1 || :;
   /sbin/chkconfig --del typhon || :;
fi
:;

%postun
if [ "$1" -ge 1 ]; then
   /sbin/service typhon condrestart >/dev/null 2>&1 || :;
fi;
:;

%files
%{ruby_sitelib}/typhon.rb
%{ruby_sitelib}/typhon
%config(noreplace) /etc/typhon/typhon.yaml
%config /etc/typhon/heads
%config /etc/init.d/typhon
/usr/sbin/typhon


%changelog
* Thu Sep 18 2011 R.I.Pienaar <rip@devco.net> - 0.1
- First release
