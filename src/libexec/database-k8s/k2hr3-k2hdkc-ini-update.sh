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
# CHMPX_INI_TEMPLATE_FILE		Specify chmpx ini template file path ( /configmap/k2hr3-k2hdkc.ini.templ )
# CHMPX_INI_DIR					Specify directory path for generated ini file ( /etc/antpickax )
#
# CHMPX_MODE					Specify chmpx mode ( SERVER / SLAVE )
# CHMPX_SERVER_PORT				Specify chmpx port number for server node ( 8020 )
# CHMPX_SERVER_CTLPORT			Specify chmpx control port number for server node ( 8021 )
# CHMPX_SLAVE_CTLPORT			Specify chmpx control port number for slave node ( 8022 )
#
# CHMPX_SERVER_COUNT			Specify chmpx server nodes count ( 2... )
# CHMPX_SERVER_NAMEBASE			Specify chmpx server name base ( r3dkc )
#								Based on this value, the server name, FQDN parts, etc. are assembled.
#								ex) svc-r3dkc, pod-r3dkc-0
# CHMPX_SLAVE_COUNT				Specify chmpx slave nodes count ( 2... )
# CHMPX_SLAVE_NAMEBASE			Specify chmpx slave name base ( r3api )
#								Based on this value, the slave name, FQDN parts, etc. are assembled.
#								ex) svc-r3api, pod-r3api-0
#
# CHMPX_POD_NAMESPACE			Specify kubernetes namespace for k2hdkc cluster ( default )
# CHMPX_DEFAULT_DOMAIN			Specify default local domain name ( svc.cluster.local )
# CHMPX_SELF_HOSTNAME			Specify self node hostname : Unused ( pod-r3dkc-X / pod-r3api-X )
#
# SEC_CA_MOUNTPOINT				Specify mount point for CA certification file
# SEC_CERTS_MOUNTPOINT			Specify mount point for host certification files
#
#----------------------------------------------------------
# Variables created internally
#----------------------------------------------------------
# CHMPX_SELFPORT				Set self control port by this script
# CHMPX_INI_FILENAME			Set ini file name ( server.ini / slave.ini )
# CHMPX_SSL_SETTING				Set SSL(TLS) mode and certifications
#

set -e

#----------------------------------------------------------
# Common values
#----------------------------------------------------------
CHMPX_SELFPORT=0
CHMPX_INI_FILENAME=""
DATE=$(date -R)

#----------------------------------------------------------
# Check enviroment values
#----------------------------------------------------------
if [ -z "${CHMPX_INI_TEMPLATE_FILE}" ]; then
	exit 1
fi
if [ -z "${CHMPX_INI_DIR}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SERVER_PORT}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SERVER_CTLPORT}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SLAVE_CTLPORT}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SERVER_COUNT}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SERVER_NAMEBASE}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SLAVE_COUNT}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SLAVE_NAMEBASE}" ]; then
	exit 1
fi
if [ -z "${CHMPX_POD_NAMESPACE}" ]; then
	exit 1
fi
if [ -z "${CHMPX_DEFAULT_DOMAIN}" ]; then
	exit 1
fi
if [ -z "${CHMPX_SELF_HOSTNAME}" ]; then
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
# Check ini template file
#----------------------------------------------------------
if [ ! -f "${CHMPX_INI_TEMPLATE_FILE}" ]; then
	exit 1
fi

#----------------------------------------------------------
# Check and Create directory
#----------------------------------------------------------
mkdir -p "${CHMPX_INI_DIR}"

#----------------------------------------------------------
# Set chmpx mode and set common values
#----------------------------------------------------------
if [ -z "${CHMPX_MODE}" ]; then
	exit 1
elif [ "${CHMPX_MODE}" = "SERVER" ] || [ "${CHMPX_MODE}" = "server" ]; then
	CHMPX_MODE="SERVER"
	CHMPX_SELFPORT=${CHMPX_SERVER_CTLPORT}
	CHMPX_INI_FILENAME="server.ini"
elif [ "${CHMPX_MODE}" = "SLAVE" ] || [ "${CHMPX_MODE}" = "slave" ]; then
	CHMPX_MODE="SLAVE"
	CHMPX_SELFPORT=${CHMPX_SLAVE_CTLPORT}
	CHMPX_INI_FILENAME="slave.ini"
else
	exit 1
fi

#----------------------------------------------------------
# For certifications
#----------------------------------------------------------
GLOBAL_PART_SSL="SSL = no"
GLOBAL_PART_SSL_VERIFY_PEER=""
GLOBAL_PART_CAPATH=""
GLOBAL_PART_SERVER_CERT=""
GLOBAL_PART_SERVER_PRIKEY=""
GLOBAL_PART_SLAVE_CERT=""
GLOBAL_PART_SLAVE_PRIKEY=""

SELF_HOSTNAME=$(hostname -f)

if [ -n "${SEC_CA_MOUNTPOINT}" ]; then
	SECRET_CA_CERT_FILE=$(find "${SEC_CA_MOUNTPOINT}/" -name '*_CA.crt' | head -1)

	if [ -n "${SECRET_CA_CERT_FILE}" ]; then
		cp "${SECRET_CA_CERT_FILE}" "${CHMPX_INI_DIR}/ca.crt"	|| exit 1
		chmod 0444 "${CHMPX_INI_DIR}/ca.crt"					|| exit 1

		GLOBAL_PART_CAPATH="CAPATH = ${CHMPX_INI_DIR}/ca.crt"
	fi
fi

if [ -n "${SEC_CERTS_MOUNTPOINT}" ]; then
	SECRET_SELF_SERVER_CRT=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*server.crt" | head -1)
	SECRET_SELF_SERVER_KEY=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*server.key" | head -1)
	SECRET_SELF_CLIENT_CRT=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*client.crt" | head -1)
	SECRET_SELF_CLIENT_KEY=$(find "${SEC_CERTS_MOUNTPOINT}/" -name "${SELF_HOSTNAME}.*client.key" | head -1)

	if [ -n "${SECRET_SELF_SERVER_CRT}" ] && [ -n "${SECRET_SELF_SERVER_KEY}" ] && [ -n "${SECRET_SELF_CLIENT_CRT}" ] && [ -n "${SECRET_SELF_CLIENT_KEY}" ]; then
		cp "${SECRET_SELF_SERVER_CRT}" "${CHMPX_INI_DIR}/server.crt"	|| exit 1
		cp "${SECRET_SELF_SERVER_KEY}" "${CHMPX_INI_DIR}/server.key"	|| exit 1
		cp "${SECRET_SELF_CLIENT_CRT}" "${CHMPX_INI_DIR}/client.crt"	|| exit 1
		cp "${SECRET_SELF_CLIENT_KEY}" "${CHMPX_INI_DIR}/client.key"	|| exit 1
		chmod 0444 "${CHMPX_INI_DIR}/server.crt"						|| exit 1
		chmod 0400 "${CHMPX_INI_DIR}/server.key"						|| exit 1
		chmod 0444 "${CHMPX_INI_DIR}/client.crt"						|| exit 1
		chmod 0400 "${CHMPX_INI_DIR}/client.key"						|| exit 1

		GLOBAL_PART_SSL="SSL = on"
		GLOBAL_PART_SSL_VERIFY_PEER="SSL_VERIFY_PEER = on"
		GLOBAL_PART_SERVER_CERT="SERVER_CERT = ${CHMPX_INI_DIR}/server.crt"
		GLOBAL_PART_SERVER_PRIKEY="SERVER_PRIKEY = ${CHMPX_INI_DIR}/server.key"
		GLOBAL_PART_SLAVE_CERT="SLAVE_CERT = ${CHMPX_INI_DIR}/client.crt"
		GLOBAL_PART_SLAVE_PRIKEY="SLAVE_PRIKEY = ${CHMPX_INI_DIR}/client.key"
	fi
fi

CHMPX_SSL_SETTING="${GLOBAL_PART_SSL}\\n${GLOBAL_PART_SSL_VERIFY_PEER}\\n${GLOBAL_PART_CAPATH}\\n${GLOBAL_PART_SERVER_CERT}\\n${GLOBAL_PART_SERVER_PRIKEY}\\n${GLOBAL_PART_SLAVE_CERT}\\n${GLOBAL_PART_SLAVE_PRIKEY}"

#----------------------------------------------------------
# Create file
#----------------------------------------------------------
{
	#
	# Create Base parts
	#
	sed -e "s#%%CHMPX_DATE%%#${DATE}#g"						\
		-e "s#%%CHMPX_MODE%%#${CHMPX_MODE}#g"				\
		-e "s#%%CHMPX_SELFPORT%%#${CHMPX_SELFPORT}#g"		\
		-e "s#%%CHMPX_SSL_SETTING%%#${CHMPX_SSL_SETTING}#g"	\
		"${CHMPX_INI_TEMPLATE_FILE}"

	#
	# Set server nodes
	#
	echo ""
	echo "#"
	echo "# SERVER NODES SECTION"
	echo "#"

	for counter in $(seq "${CHMPX_SERVER_COUNT}"); do
		NODE_NUMBER=$((counter - 1))
		NODE_NAME="pod-${CHMPX_SERVER_NAMEBASE}-${NODE_NUMBER}.svc-${CHMPX_SERVER_NAMEBASE}.${CHMPX_POD_NAMESPACE}.${CHMPX_DEFAULT_DOMAIN}"

		echo "[SVRNODE]"
		echo "NAME           = ${NODE_NAME}"
		echo "PORT           = ${CHMPX_SERVER_PORT}"
		echo "CTLPORT        = ${CHMPX_SERVER_CTLPORT}"
		echo "CUSTOM_ID_SEED = ${NODE_NAME}"
		echo ""
	done

	#
	# Set slave nodes
	#
	echo "#"
	echo "# SLAVE NODES SECTION"
	echo "#"

	for counter in $(seq "${CHMPX_SLAVE_COUNT}"); do
		NODE_NUMBER=$((counter - 1))
		NODE_NAME="pod-${CHMPX_SLAVE_NAMEBASE}-${NODE_NUMBER}.svc-${CHMPX_SLAVE_NAMEBASE}.${CHMPX_POD_NAMESPACE}.${CHMPX_DEFAULT_DOMAIN}"

		echo "[SLVNODE]"
		echo "NAME           = ${NODE_NAME}"
		echo "CTLPORT        = ${CHMPX_SLAVE_CTLPORT}"
		echo "CUSTOM_ID_SEED = ${NODE_NAME}"
		echo ""
	done

	#
	# Footer
	#
	echo "#"
	echo "# Local variables:"
	echo "# tab-width: 4"
	echo "# c-basic-offset: 4"
	echo "# End:"
	echo "# vim600: noexpandtab sw=4 ts=4 fdm=marker"
	echo "# vim<600: noexpandtab sw=4 ts=4"
	echo "#"

} >> "${CHMPX_INI_DIR}/${CHMPX_INI_FILENAME}"

#----------------------------------------------------------
# Adjustment of startup timing
#----------------------------------------------------------
set +e

WAIT_SEC=10
POD_NUMBER=$(echo "${CHMPX_SELF_HOSTNAME}" | sed 's/-/ /g' | awk '{print $NF}')

if [ -z "${POD_NUMBER}" ] || [ "${POD_NUMBER}" = "0" ]; then
	WAIT_SEC=0
fi

sleep "${WAIT_SEC}"

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
