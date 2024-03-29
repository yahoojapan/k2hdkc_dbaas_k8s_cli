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

#------------------------------------------------------------------------------
# Options
#
#	--register(-reg)			If specified, register with K2HR3 Role
#	--delete(-del)				If specified, remove from K2HR3 Role
#
#------------------------------------------------------------------------------
# Input files
#
# This script loads the following files under '/etc/antpickax' directory.
# These file contents can be used when accessing K2HR3 API.
#
#	K2HR3_FILE_REGISTER_URL		k2hr3 api url with path for registration/deletion
#	K2HR3_FILE_ROLE				yrn full path to the role
#	K2HR3_FILE_RESOURCE			yrn full path to the resource
#	K2HR3_FILE_ROLE_TOKEN		role token file
#	K2HR3_FILE_APIARG			packed cuk argument("extra=...&cuk=value") to K2HR3 API(PUT/GET/DELETE/etc)
#
# CA cert file to K2HR3 API is in secret directory.
#
#	K2HR3_CA_FILE				If the K2HR3 API is HTTPS and is a self-signed certificate,
#								a self-signed CA certificate is required.
#								In this case, this file exists.
#
#------------------------------------------------------------------------------

#
# Program information
#
PRGNAME=$(basename "$0")
SRCTOP=$(dirname "$0")
SRCTOP=$(cd "${SRCTOP}" || exit 1; pwd)

#
# Common Variables
#
ANTPICKAX_ETC_DIR="/etc/antpickax"
K2HR3_CA_FILE="ca.crt"
K2HR3_FILE_REGISTER_URL="k2hr3-register-url"
K2HR3_FILE_ROLE="k2hr3-role"
K2HR3_FILE_ROLE_TOKEN="k2hr3-role-token"
K2HR3_FILE_APIARG="k2hr3-apiarg"

#
# Check CA cert
#
if [ -f "${ANTPICKAX_ETC_DIR}/${K2HR3_CA_FILE}" ]; then
	K2HR3_CA_CERT_OPTION="--cacert"
	K2HR3_CA_CERT_OPTION_VALUE="${ANTPICKAX_ETC_DIR}/${K2HR3_CA_FILE}"
else
	K2HR3_CA_CERT_OPTION=""
	K2HR3_CA_CERT_OPTION_VALUE=""
fi

#
# Get K2HR3 ROLE TOKEN
#
if ! K2HDKC_ROLE_TOKEN=$(cat ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_ROLE_TOKEN} 2>/dev/null); then
	echo "[ERROR] ${PRGNAME} : Could not load role token from secret." 1>&2
	exit 1
fi

#
# Get Parameters from files
#
K2HR3_REGISTER_URL=$(cat ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_REGISTER_URL} 2>/dev/null)
K2HR3_ROLE=$(cat ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_ROLE} 2>/dev/null)
K2HR3_APIARG=$(cat ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_APIARG} 2>/dev/null)

#
# Check curl command
#
if ! CURL_COMMAND=$(command -v curl | tr -d '\n'); then
	echo "[WARNING] ${PRGNAME} : curl command is not existed, then try to install." 1>&2

	if ! APK_COMMAND=$(command -v apk | tr -d '\n'); then
		echo "[ERROR] ${PRGNAME} : This container it not ALPINE, It does not support installations other than ALPINE, so exit." 1>&2
		exit 1
	fi

	if ! ${APK_COMMAND} add -q --no-progress --no-cache curl; then
		echo "[ERROR] ${PRGNAME} : Failed to install curl by apk(ALPINE)." 1>&2
		exit 1
	fi

	if ! CURL_COMMAND=$(command -v curl | tr -d '\n'); then
		echo "[ERROR] ${PRGNAME} : Failed to install curl by apk(ALPINE)." 1>&2
		exit 1
	fi
fi

#------------------------------------------------------------------------------
# Parse options
#------------------------------------------------------------------------------
REGISTER_MODE=
while [ $# -ne 0 ]; do
	if [ -z "$1" ]; then
		break

	elif [ "$1" = "-reg" ] || [ "$1" = "-REG" ] || [ "$1" = "--register" ] || [ "$1" = "--REGISTER" ]; then
		if [ -n "${REGISTER_MODE}" ]; then
			echo "[ERROR] ${PRGNAME} : already set \"--register(-reg)\" or \"--delete(-del)\" option." 1>&2
			exit 1
		fi
		REGISTER_MODE=1

	elif [ "$1" = "-del" ] || [ "$1" = "-DEL" ] || [ "$1" = "--delete" ] || [ "$1" = "--DELETE" ]; then
		if [ -n "${REGISTER_MODE}" ]; then
			echo "[ERROR] ${PRGNAME} : already set \"--register(-reg)\" or \"--delete(-del)\" option." 1>&2
			exit 1
		fi
		REGISTER_MODE=0

	else
		echo "[ERROR] ${PRGNAME} : unknown option($1) is specified." 1>&2
		exit 1
	fi
	shift
done

if [ -z "${REGISTER_MODE}" ]; then
	echo "[ERROR] ${PRGNAME} : specify \"--register(-reg)\" or \"--delete(-del)\" option." 1>&2
	exit 1
fi

#------------------------------------------------------------------------------
# Main process
#------------------------------------------------------------------------------
#
# Call K2HR3 REST API
#
# These file values are used for registration/deletion as follows.
# 	Registration:	curl -s -S ${K2HR3_CA_CERT_OPTION} ${K2HR3_CA_CERT_OPTION_VALUE} -X PUT -H "x-auth-token: R=${K2HDKC_ROLE_TOKEN}" "${K2HR3_REGISTER_URL}/${K2HR3_ROLE}?${K2HR3_APIARG}"
# 	Deletion:		curl -s -S ${K2HR3_CA_CERT_OPTION} ${K2HR3_CA_CERT_OPTION_VALUE} -X DELETE "${K2HR3_REGISTER_URL}/${K2HR3_ROLE}?${K2HR3_APIARG}"
#
if [ "${REGISTER_MODE}" -eq 1 ]; then
	#
	# Registration
	#
	if ! "${CURL_COMMAND}" -s -S "${K2HR3_CA_CERT_OPTION}" "${K2HR3_CA_CERT_OPTION_VALUE}" -X PUT -H "x-auth-token: R=${K2HDKC_ROLE_TOKEN}" "${K2HR3_REGISTER_URL}/${K2HR3_ROLE}?${K2HR3_APIARG}"; then
		echo "[ERROR] ${PRGNAME} : Failed registration to role member." 1>&2
		exit 1
	fi
else
	#
	# Deletion
	#
	# The Pod(Container) has been registered, so we can access K2HR3 without token to delete it.
	#
	if ! "${CURL_COMMAND}" -s -S "${K2HR3_CA_CERT_OPTION}" "${K2HR3_CA_CERT_OPTION_VALUE}" -X DELETE "${K2HR3_REGISTER_URL}/${K2HR3_ROLE}?${K2HR3_APIARG}"; then
		echo "[ERROR] ${PRGNAME} : Failed deletion from role member." 1>&2
		exit 1
	fi
fi

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
