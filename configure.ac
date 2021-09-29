#
# K2HDKC DBaaS on Kubernetes Command Line Interface - K2HR3 CLI Plugin
#
# Copyright 2021 Yahoo! Japan Corporation.
#
# K2HDKC DBaaS is a DataBase as a Service provided by Yahoo! JAPAN
# which is built K2HR3 as a backend and provides services in
# cooperation with Kubernetes.
# The Override configuration for K2HDKC DBaaS serves to connect the
# components that make up the K2HDKC DBaaS. K2HDKC, K2HR3, CHMPX,
# and K2HASH are components provided as AntPickax.
#
# For the full copyright and license information, please view
# the license file that was distributed with this source code.
#
# AUTHOR:   Takeshi Nakatani
# CREATE:   Wed Sep 15 2021
# REVISION:
#

#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
#
AC_PREREQ([2.63])
AC_INIT(k2hdkc-dbaas-k8s-cli, m4_esyscmd([tr -d '\n' < $(pwd)/RELEASE_VERSION]))
AM_INIT_AUTOMAKE()

#
# Checks for programs.
#
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

#
# Symbols for buildutils
#
AC_SUBST([GIT_DOMAIN], "github.com")
AC_SUBST([GIT_ORG], "yahoojapan")
AC_SUBST([GIT_REPO], "k2hdkc_dbaas_k8s_cli")
AC_SUBST([DEV_EMAIL], "`echo ${DEBEMAIL:-antpickax-support@mail.yahoo.co.jp}`")
AC_SUBST([DEV_NAME], "`echo ${DEBFULLNAME:-K2HR3_DEVELOPER}`")
#
AC_SUBST([RPMCHANGELOG], "`$(pwd)/buildutils/make_rpm_changelog.sh $(pwd)/ChangeLog`")
AC_SUBST([SHORTDESC], "K2HDKC DBaaS Command Line Interface(K2HR3 CLI Plugin)")
AC_SUBST([PKG_VERSION], "`$(pwd)/buildutils/make_variables.sh -pkg_version`")
AC_SUBST([PKGLICENSE], "`grep License COPYING | sed 's/ License//g'`")
AC_SUBST([DEBCOPYING], "`tail -n +5 COPYING | sed 's/^$/./g' | sed 's/^/ /g'`")
AC_SUBST([DEBHELPER_DEP], "`$(pwd)/buildutils/make_variables.sh -debhelper_dep`")
AC_SUBST([RPMPKG_GROUP], ["`$(pwd)/buildutils/make_variables.sh -rpmpkg_group | sed 's#NEEDRPMGROUP#Group: Applications/Other#g'`"])
AC_SUBST([CONFIGUREWITHOPT], "")
AM_SUBST_NOTMAKE([CURRENTREV])
AM_SUBST_NOTMAKE([RPMCHANGELOG])
AM_SUBST_NOTMAKE([SHORTDESC])
AM_SUBST_NOTMAKE([DEBCOPYING])
AM_SUBST_NOTMAKE([DEBHELPER_DEP])
AM_SUBST_NOTMAKE([RPMPKG_GROUP])
AM_SUBST_NOTMAKE([CONFIGUREWITHOPT])

#
# pkg-config for old version
#
AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
AS_IF([test "$PKG_CONFIG" = "no"], [AC_MSG_WARN(You have to install pkg-config to compile $PACKAGE_NAME v$PACKAGE_VERSION)])

#
# Config files
#
AC_CONFIG_FILES([Makefile
				src/Makefile
				src/libexec/Makefile
				src/libexec/database-k8s/Makefile
				test/Makefile
				test/snapshots/Makefile
				buildutils/Makefile
				buildutils/control
				buildutils/copyright
				buildutils/k2hdkc-dbaas-k8s-cli.spec])

AC_OUTPUT

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
