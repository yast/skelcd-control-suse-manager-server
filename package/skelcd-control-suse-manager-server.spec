#
# spec file for package skelcd-control-suse-manager-server
#
# Copyright (c) 2019 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


######################################################################
#
# IMPORTANT: Please do not change the control file or this spec file
#   in build service directly, use
#   https://github.com/yast/skelcd-control-suse-manager-server repository
#
#   See https://github.com/yast/skelcd-control-suse-manager-server/blob/master/CONTRIBUTING.md
#   for more details.
#
######################################################################

%define         skelcd_name suse-manager-server

Name:           skelcd-control-%{skelcd_name}
# xsltproc for converting SLES control file to SLES-for-VMware
BuildRequires:  libxslt-tools
# xmllint (for validation)
BuildRequires:  libxml2-tools
# Added skelcd macros
BuildRequires:  yast2-installation-control >= 4.1.5

# Original SLES control file (skip registration)
BuildRequires: skelcd-control-SLES >= 15.2.0
BuildRequires: diffutils

# for building we do not need all skelcd-control-SLES dependencies
#!BuildIgnore: yast2-registration yast2-theme yast2 autoyast2 yast2-add-on yast2-buildtools
#!BuildIgnore: yast2-devtools yast2-fcoe-client yast2-firewall yast2-installation
#!BuildIgnore: yast2-iscsi-client yast2-kdump yast2-multipath yast2-network yast2-nfs-client
#!BuildIgnore: yast2-ntp-client yast2-proxy yast2-services-manager yast2-configuration-management
#!BuildIgnore: yast2-packager yast2-slp yast2-trans-stats yast2-tune yast2-update
#!BuildIgnore: yast2-users yast2-x11 rubygem(%{rb_default_ruby_abi}:byebug) yast2-rdp

# Use FHS compliant path
Requires:       yast2 >= 4.1.41

Provides:       system-installation() = SUSE-Manager-Server

#
######################################################################

Url:            https://github.com/yast/skelcd-control-suse-manager-server
AutoReqProv:    off
# IMPORTANT: This needs to be 4.1.0 as it is the SUSE Manager version!
Version:        4.1.4
Release:        0
Summary:        SUSE Manager Server control file needed for installation
License:        MIT
Group:          Metapackages
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        installation.suse-manager-server.xsl

# SUSEConnect does not build for i586 and s390 and is not supported on those architectures
# bsc#1088552
ExcludeArch:    %ix86 s390

%description
SUSE Manager Server control file needed for installation

%prep

%build
# transform ("patch") the original SLES installation file
xsltproc %{SOURCE0} %{skelcd_control_datadir}/SLES.xml > installation.xml
diff -u %{skelcd_control_datadir}/SLES.xml installation.xml || :

%check
#
# Verify syntax
#
#xmllint --noout --relaxng /usr/share/YaST2/control/control.rng installation.xml

%install
#
# Add installation file
#
mkdir -p $RPM_BUILD_ROOT/%{skelcd_control_datadir}
install -m 644 installation.xml $RPM_BUILD_ROOT/%{skelcd_control_datadir}/%{skelcd_name}.xml

%files
%defattr(644,root,root,755)
%{skelcd_control_datadir}

%changelog
