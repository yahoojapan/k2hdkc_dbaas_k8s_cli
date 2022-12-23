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

SLEEP_LONG_MANUAL=3600000

#----------------------------------------------------------
# Configuration files for K2HR3 APP
#----------------------------------------------------------
K2HR3_APP_DIR="/usr/lib/node_modules/k2hr3_app"
RUN_SCRIPT="${K2HR3_APP_DIR}/bin/run.sh"
PRODUCTION_FILE="${K2HR3_APP_DIR}/config/production.json"
CONFIGMAP_PRODUCTION_FILE="/configmap/k2hr3-app-production.json"

if [ ! -f "${CONFIGMAP_PRODUCTION_FILE}" ]; then
	exit 1
fi

if ! ln -s "${CONFIGMAP_PRODUCTION_FILE}" "${PRODUCTION_FILE}"; then
	exit 1
fi

#----------------------------------------------------------
# Certificate files for K2HR3 APP
#----------------------------------------------------------
K2HR3_CA_CERT_ORG_FILE="ca.crt"
K2HR3_CA_CERT_ORG_FILE_PATH="${ANTPICKAX_ETC_DIR}/${K2HR3_CA_CERT_ORG_FILE}"

SYSTEM_CA_CERT_DIR="/usr/local/share/ca-certificates"
SYSTEM_CA_CERT_K2HR3_FILE="k2hr3-system-ca.crt"
SYSTEM_CA_CERT_K2HR3_FILE_PATH="${SYSTEM_CA_CERT_DIR}/${SYSTEM_CA_CERT_K2HR3_FILE}"

if [ -f "${K2HR3_CA_CERT_ORG_FILE_PATH}" ]; then
	if ! cp "${K2HR3_CA_CERT_ORG_FILE_PATH}" "${SYSTEM_CA_CERT_K2HR3_FILE_PATH}"; then
		exit 1
	fi
	if ! update-ca-certificates; then
		exit 1
	fi
fi

#----------------------------------------------------------
# Main processing
#----------------------------------------------------------
#
# Run K2HR3 APP
#
set -e

if [ -n "${K2HR3_MANUAL_START}" ] && [ "${K2HR3_MANUAL_START}" = "1" ]; then
	while true; do
		sleep ${SLEEP_LONG_MANUAL}
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
