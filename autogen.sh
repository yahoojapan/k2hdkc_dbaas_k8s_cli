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
# Common variables
#
AUTOGEN_NAME=$(basename "${0}")
AUTOGEN_DIR=$(dirname "${0}")
SRCTOP=$(cd "${AUTOGEN_DIR}" || exit 1; pwd)

#
# Run
#
echo "[RUN] autogen.sh"
echo ""

#
# Parse parameters
#
UPDATE_VERSION_FILE=1
FORCEPARAM="--force"
PARAMETERS=""
while [ $# -ne 0 ]; do
	if [ -z "$1" ]; then
		echo "[ERROR] Parameters are something wrong."
		exit 1

	elif [ "$1" = "-h" ] || [ "$1" = "-H" ] || [ "$1" = "--help" ] || [ "$1" = "--HELP" ]; then
		echo "Usage: ${AUTOGEN_NAME} [--help(-h)] [--no_update_version_file(-nu)] [--no_aclocal_force(-na)] [--no_check_ver_diff(-nc)]"
		exit 0

	elif [ "$1" = "-nu" ] || [ "$1" = "-NU" ] || [ "$1" = "--no_update_version_file" ] || [ "$1" = "--NO_UPDATE_VERSION_FILE" ]; then
		UPDATE_VERSION_FILE=0
		FORCEPARAM=""			# do not need force

	elif [ "$1" = "-na" ] || [ "$1" = "-NA" ] || [ "$1" = "--no_aclocal_force" ] || [ "$1" = "--NO_ACLOCAL_FORCE" ]; then
		FORCEPARAM=""

	elif [ "$1" = "-nc" ] || [ "$1" = "-NC" ] || [ "$1" = "--no_check_ver_diff" ] || [ "$1" = "--NO_CHECK_VER_DIFF" ]; then
		PARAMETERS="$1"

	else
		echo "[ERROR] Unknown option $1"
		echo "Usage: ${AUTOGEN_NAME} [--help(-h)] [--no_update_version_file(-nu)] [--no_aclocal_force(-na)] [--no_check_ver_diff(-nc)]"
		exit 1
	fi
	shift
done

#
# update RELEASE_VERSION file
#
if [ "${UPDATE_VERSION_FILE}" -eq 1 ] && [ -f "${SRCTOP}/buildutils/make_release_version_file.sh" ]; then
	echo "    [INFO] run make_release_version_file.sh"
	if ! /bin/sh -c "${SRCTOP}/buildutils/make_release_version_file.sh" "${PARAMETERS}" 2>&1 | sed -e 's|^|        |g'; then
		echo "[ERROR] update RELEASE_VERSION file"
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
# Auto scan
#
if [ ! -f configure.scan ] || [ -n "${FORCEPARAM}" ]; then
	echo "    [INFO] run autoscan"
	if ! autoscan 2>&1 | sed -e 's|^|        |g'; then
		echo "[ERROR] something error occurred in autoscan"
		exit 1
	fi
fi

#
# Copy libtools
#
if grep -q 'LT_INIT' configure.ac configure.scan; then
	if ! libtoolize --force --copy 2>&1 | sed -e 's|^|        |g'; then
		echo "[ERROR] something error occurred in libtoolize"
		exit 1
	fi
fi

#
# Build configure and Makefile
#
echo "    [INFO] run aclocal ${FORCEPARAM}"
if ! /bin/sh -c "aclocal ${FORCEPARAM}" 2>&1 | sed -e 's|^|        |g'; then
	echo "[ERROR] something error occurred in aclocal ${FORCEPARAM}"
	exit 1
fi

if grep -q 'AC_CONFIG_HEADERS' configure.ac configure.scan; then
	echo "    [INFO] run autoheader"
	if ! autoheader 2>&1 | sed -e 's|^|        |g'; then
		echo "[ERROR] something error occurred in autoheader"
		exit 1
	fi
fi

echo "    [INFO] run automake -c --add-missing"
if ! automake -c --add-missing 2>&1 | sed -e 's|^|        |g'; then
	echo "[ERROR] something error occurred in automake -c --add-missing"
	exit 1
fi

echo "    [INFO] run autoconf"
if ! autoconf 2>&1 | sed -e 's|^|        |g'; then
	echo "[ERROR] something error occurred in autoconf"
	exit 1
fi

#
# Finish
#
echo ""
echo "[SUCCEED] autogen.sh"
exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
