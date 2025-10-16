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
# Input variables by environment
#----------------------------------------------------------
# ANTPICKAX_ETC_DIR				Specify directory path for files ( /etc/antpickax )
# SEC_CA_MOUNTPOINT				Specify mount point for CA certificate file
# SEC_CERTS_MOUNTPOINT			Specify mount point for host certificate files
#

set -e

#----------------------------------------------------------
# Check enviroment values
#----------------------------------------------------------
if [ -z "${ANTPICKAX_ETC_DIR}" ]; then
	exit 1
fi

#
# Allow empty value
#
if [ -n "${SEC_CA_MOUNTPOINT}" ] && [ ! -d "${SEC_CA_MOUNTPOINT}" ]; then
	exit 1
fi
if [ -n "${SEC_CERTS_MOUNTPOINT}" ] && [ ! -d "${SEC_CERTS_MOUNTPOINT}" ]; then
	exit 1
fi

#----------------------------------------------------------
# Copy Certificates
#----------------------------------------------------------
SELF_HOSTNAME=$(hostname -f | sed 's/\(pod-[^-]*\)\(-.*\)$/\1/g')

if [ -n "${SEC_CA_MOUNTPOINT}" ]; then
	SECRET_CA_CERT_FILE=$(find "${SEC_CA_MOUNTPOINT}/" -name '*_CA.crt' | head -1)

	if [ -n "${SECRET_CA_CERT_FILE}" ]; then
		cp "${SECRET_CA_CERT_FILE}" "${ANTPICKAX_ETC_DIR}/ca.crt"	|| exit 1
		chmod 0444 "${ANTPICKAX_ETC_DIR}/ca.crt"					|| exit 1
	fi
fi

if [ -n "${SEC_CERTS_MOUNTPOINT}" ]; then
	SECRET_SELF_SERVER_CRT=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*server.crt" | head -1)
	SECRET_SELF_SERVER_KEY=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*server.key" | head -1)

	if [ -n "${SECRET_SELF_SERVER_CRT}" ] && [ -n "${SECRET_SELF_SERVER_KEY}" ]; then
		cp "${SECRET_SELF_SERVER_CRT}" "${ANTPICKAX_ETC_DIR}/server.crt"	|| exit 1
		cp "${SECRET_SELF_SERVER_KEY}" "${ANTPICKAX_ETC_DIR}/server.key"	|| exit 1
		chmod 0444 "${ANTPICKAX_ETC_DIR}/server.crt"						|| exit 1
		chmod 0400 "${ANTPICKAX_ETC_DIR}/server.key"						|| exit 1
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
