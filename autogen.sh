#!/bin/sh
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

#
# Usage: autogen.sh [-noupdate_version_file] [-no_aclocal_force] [-no_check_ver_diff]
#
AUTOGEN_NAME=$(basename "$0")
AUTOGEN_DIR=$(dirname "$0")
SRCTOP=$(cd "${AUTOGEN_DIR}" || exit 1; pwd)

echo "** run autogen.sh"

#
# Parameter
#
NOUPDATE="no"
FORCEPARAM="--force"
PARAMETERS=""
while [ $# -ne 0 ]; do
	if [ "X$1" = "X-noupdate_version_file" ]; then
		NOUPDATE="yes"
		FORCEPARAM=""	# do not need force
	elif [ "X$1" = "X-no_aclocal_force" ]; then
		FORCEPARAM=""
	elif [ "X$1" = "X-no_check_ver_diff" ]; then
		PARAMETERS="${PARAMETERS} $1"
	elif [ "X$1" = "X-h" ] || [ "X$1" = "X--help" ]; then
		echo "Usage: ${AUTOGEN_NAME} [-noupdate_version_file] [-no_aclocal_force] [-no_check_ver_diff]"
		exit 1
	else
		echo "ERROR: Unknown option $1"
		echo "Usage: ${AUTOGEN_NAME} [-noupdate_version_file] [-no_aclocal_force] [-no_check_ver_diff]"
		exit 1
	fi
	shift
done

#
# update RELEASE_VERSION file
#
if [ "X${NOUPDATE}" = "Xno" ]; then
	echo "--- run make_release_version_file.sh"
	/bin/sh -c "${SRCTOP}/buildutils/make_release_version_file.sh" "${PARAMETERS}"
	if [ $? -ne 0 ]; then
		echo "ERROR: update RELEASE_VERSION file"
		exit 1
	fi
fi

#
# Check files
#
if [ ! -f "${SRCTOP}/NEWS" ]; then
	touch "${SRCTOP}/NEWS"
fi
if [ ! -f "${SRCTOP}/README" ]; then
	touch "${SRCTOP}/README"
fi
if [ ! -f "${SRCTOP}/AUTHORS" ]; then
	touch "${SRCTOP}/AUTHORS"
fi
if [ ! -f "${SRCTOP}/ChangeLog" ]; then
	touch "${SRCTOP}/ChangeLog"
fi

#
# Build configure and Makefile
#
echo "--- run aclocal ${FORCEPARAM}"
aclocal ${FORCEPARAM}
if [ $? -ne 0 ]; then
	echo "ERROR: something error occurred in aclocal ${FORCEPARAM}"
	exit 1
fi

echo "--- run automake -c --add-missing"
automake -c --add-missing
if [ $? -ne 0 ]; then
	echo "ERROR: something error occurred in automake -c --add-missing"
	exit 1
fi

echo "--- run autoconf"
autoconf
if [ $? -ne 0 ]; then
	echo "ERROR: something error occurred in autoconf"
	exit 1
fi

echo "** SUCCEED: autogen"
exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
