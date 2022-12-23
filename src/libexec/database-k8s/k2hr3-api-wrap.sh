#!/bin/sh
#
# K2HDKC DBaaS on Kubernetes Command Line Interface - K2HR3 CLI Plugin
#
# Copyright 2021 Yahoo Japan Corporation.
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

#----------------------------------------------------------
# Common variables
#----------------------------------------------------------
#PRGNAME=$(basename "$0")
#SCRIPTDIR=$(dirname "$0")
#SCRIPTDIR=$(cd "${SRCTOP}" || exit 1; pwd)

ANTPICKAX_ETC_DIR="/etc/antpickax"

RETRYCOUNT=30
SLEEP_SHORT=10
SLEEP_LONG_MANUAL=3600000

#----------------------------------------------------------
# Configuration file for CHMPX
#----------------------------------------------------------
INI_FILE="slave.ini"
INI_FILE_PATH="${ANTPICKAX_ETC_DIR}/${INI_FILE}"

#----------------------------------------------------------
# Configuration files for K2HR3 API
#----------------------------------------------------------
K2HR3_API_DIR="/usr/lib/node_modules/k2hr3_api"
RUN_SCRIPT="${K2HR3_API_DIR}/bin/run.sh"
PRODUCTION_FILE="${K2HR3_API_DIR}/config/production.json"
CONFIGMAP_PRODUCTION_FILE="/configmap/k2hr3-api-production.json"

if [ ! -f "${CONFIGMAP_PRODUCTION_FILE}" ]; then
	exit 1
fi

if ! ln -s "${CONFIGMAP_PRODUCTION_FILE}" "${PRODUCTION_FILE}"; then
	exit 1
fi

#----------------------------------------------------------
# Main processing
#----------------------------------------------------------
#
# Wait CHMPX up
#
CHMPX_UP=0
while [ "${CHMPX_UP}" -eq 0 ]; do
	if chmpxstatus -conf "${INI_FILE_PATH}" -self -wait -live up -ring slave -nosuspend -timeout "${SLEEP_SHORT}" >/dev/null 2>&1; then
		CHMPX_UP=1
	else
		sleep "${SLEEP_SHORT}"
		RETRYCOUNT=$((RETRYCOUNT - 1))
		if [ "${RETRYCOUNT}" -le 0 ]; then
			break;
		fi
	fi
done
if [ "${CHMPX_UP}" -eq 0 ]; then
	exit 1
fi

#
# Run K2HR3 API
#
set -e

if [ -n "${K2HR3_MANUAL_START}" ] && [ "${K2HR3_MANUAL_START}" = "1" ]; then
	while true; do
		sleep "${SLEEP_LONG_MANUAL}"
	done
else
	"${RUN_SCRIPT}" --production -fg
fi

exit $?

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
