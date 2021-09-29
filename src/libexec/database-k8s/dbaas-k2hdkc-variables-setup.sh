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

#------------------------------------------------------------------------------
# Environments
#
# This script expects the following environment variables to be set.
# These values are used as elements of CUK data when registering to K2HR3 Role members.
#
#	K2HR3_API_URL				k2hr3 api url
#	K2HR3_YRN_PREFIX			Specifies the prefix of the yrn path for k2hr3.
#								It specifies the prefix for "yrn:yahoo:::<namespace>:role:<cluster name>/{server|slave}".
#								If omitted, it will use ""yrn:yahoo:::".
#	K2HDKC_DOMAIN				base domain name
#	K2HKDC_CLUSTER_NAME			k2hdkc cluster name
#	K2HDKC_MODE					k2hdkc(chmpx) mode, server or slave
#
#	K2HDKC_NODE_NAME			node name on this container's node(spec.nodeName)
#	K2HDKC_NODE_IP				node host ip address on this container's node(status.hostIP)
#	K2HDKC_POD_NAME				pod name containing this container(metadata.name)
#	K2HDKC_NAMESPACE			pod namespace for this container(metadata.namespace)
#	K2HDKC_POD_SERVICE_ACCOUNT	pod service account for this container(spec.serviceAccountName)
#	K2HDKC_POD_ID				pod id containing this container(metadata.uid)
#	K2HDKC_POD_IP				pod ip address containing this container(status.podIP)
#
#------------------------------------------------------------------------------
# Load variables from system file
#
#	K2HDKC_CONTAINER_ID			This value is the <docker id> that this script reads from
#								'/proc/<pid>/cgroups'. (kubernetes uses this 'docker id'
#								as the 'container id'.)
#								This value is added to CUK data.
#
#------------------------------------------------------------------------------
# Output files
#
# This script outputs the following files under '/etc/antpickax' directory.
# These file contents can be used when accessing K2HR3 API.
#
#	K2HR3_FILE_API_URL			k2hr3 api url with path
#	K2HR3_FILE_ROLE				yrn full path to the role
#	K2HR3_FILE_RESOURCE			yrn full path to the resource
#	K2HR3_FILE_ROLE_TOKEN		symbolic link to role token file
#	K2HR3_FILE_CUK				cuk value for url argument to K2HR3 API(PUT/GET/DELETE/etc)
#	K2HR3_FILE_CUKENC			urlencoded cuk value
#	K2HR3_FILE_APIARG			packed cuk argument("extra=...&cuk=value") to K2HR3 API(PUT/GET/DELETE/etc)
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
SECRET_K2HR3_CERTS="/secret-certs"
SECRET_K2HR3_TOKEN_DIR="/secret-k2hr3-token"

K2HR3_FILE_CA_CERT="ca.crt"
K2HR3_FILE_SERVER_CERT="server.crt"
K2HR3_FILE_SERVER_KEY="server.key"
K2HR3_FILE_CLIENT_CERT="client.crt"
K2HR3_FILE_CLIENT_KEY="client.key"

K2HR3_FILE_API_URL="k2hr3-api-url"
K2HR3_FILE_REGISTER_URL="k2hr3-register-url"
K2HR3_FILE_ROLE="k2hr3-role"
K2HR3_FILE_ROLE_TOKEN="k2hr3-role-token"
K2HR3_FILE_RESOURCE="k2hr3-resource"
K2HR3_FILE_CUK="k2hr3-cuk"
K2HR3_FILE_CUKENC="k2hr3-cukencode"
K2HR3_FILE_APIARG="k2hr3-apiarg"

K2HR3_API_REGISTER_PATH="/v1/role"

#
# Variables
#
K2HDKC_CONTAINER_ID=""

#------------------------------------------------------------------------------
# Check Environments
#------------------------------------------------------------------------------
if [ "X${K2HR3_API_URL}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HR3_API_URL environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HR3_YRN_PREFIX}" = "X" ]; then
	K2HR3_YRN_PREFIX="yrn:yahoo:::"
fi
if [ "X${K2HDKC_DOMAIN}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_DOMAIN environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HKDC_CLUSTER_NAME}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HKDC_CLUSTER_NAME environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_MODE}" = "XSERVER" ] || [ "X${K2HDKC_MODE}" = "Xserver" ]; then
	K2HDKC_MODE="server"
elif [ "X${K2HDKC_MODE}" = "XSLAVE" ] || [ "X${K2HDKC_MODE}" = "Xslave" ]; then
	K2HDKC_MODE="slave"
else
	echo "[ERROR] ${PRGNAME} : K2HDKC_MODE environment is not set or wrong value, it must be set \"server\" or \"slave\"." 1>&2
	exit 1
fi
if [ "X${K2HDKC_NODE_NAME}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_NODE_NAME environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_NODE_IP}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_NODE_IP environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_POD_NAME}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_POD_NAME environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_NAMESPACE}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_NAMESPACE environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_POD_SERVICE_ACCOUNT}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_POD_SERVICE_ACCOUNT environment is not set." 1>&2
	exit 1
fi
if [ "X${K2HDKC_POD_ID}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_POD_ID environment is not set." 1>&2
	exit 1
fi
# shellcheck disable=SC2153
if [ "X${K2HDKC_POD_IP}" = "X" ]; then
	echo "[ERROR] ${PRGNAME} : K2HDKC_POD_IP environment is not set." 1>&2
	exit 1
fi

#------------------------------------------------------------------------------
# Create registration parameters
#------------------------------------------------------------------------------
#
# Make CONTAINER_ID with checking pod id
#
# shellcheck disable=SC2010
POC_FILE_NAMES=$(ls -1 /proc/ | grep -E "[0-9]+" 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "[ERROR] ${PRGNAME} : Could not find any /proc/<process id> directory." 1>&2
	exit 1
fi

CONTAINER_ID_UIDS=""
for local_procid in ${POC_FILE_NAMES}; do
	if [ ! -f /proc/"${local_procid}"/cgroup ]; then
		continue
	fi
	local_all_line=$(cat /proc/"${local_procid}"/cgroup)
	if [ $? -ne 0 ]; then
		continue
	fi
	for local_line in ${local_all_line}; do
		CONTAINER_ID_UIDS=$(echo "${local_line}" | sed -e 's#.*pod##g' -e 's#\.slice##g' -e 's#\.scope##g' -e 's#docker-##g' 2>/dev/null)
		if [ $? -ne 0 ]; then
			continue
		fi
		if [ "X${CONTAINER_ID_UIDS}" != "X" ]; then
			break
		fi
	done
	if [ "X${CONTAINER_ID_UIDS}" != "X" ]; then
		break
	fi
done

if [ "X${CONTAINER_ID_UIDS}" != "X" ]; then
	K2HDKC_TMP_POD_ID=$(echo "${CONTAINER_ID_UIDS}" | sed -e 's#/# #g' 2>/dev/null | awk '{print $1}' 2>/dev/null)
	K2HDKC_CONTAINER_ID=$(echo "${CONTAINER_ID_UIDS}" | sed -e 's#/# #g' 2>/dev/null | awk '{print $2}' 2>/dev/null)

	if [ "X${K2HDKC_POD_ID}" = "X" ]; then
		K2HDKC_POD_ID=${K2HDKC_TMP_POD_ID}
	else
		if [ "X${K2HDKC_POD_ID}" != "X${K2HDKC_TMP_POD_ID}" ]; then
			echo "[WARNING] ${PRGNAME} : Specified pod id(${K2HDKC_POD_ID}) is not correct, so that use current pod id(${K2HDKC_TMP_POD_ID}) instead of it." 1>&2
			K2HDKC_POD_ID=${K2HDKC_TMP_POD_ID}
		fi
	fi
fi
if [ -z "${K2HDKC_CONTAINER_ID}" ]; then
	echo "[ERROR] ${PRGNAME} : Could not get container id." 1>&2
	exit 1
fi

#
# Make CUK parameter
#
# The CUK parameter is a base64 url encoded value from following JSON object string(sorted keys by a-z).
#	{
#		"k8s_namespace":		${K2HDKC_NAMESPACE}
#		"k8s_service_account":	${K2HDKC_POD_SERVICE_ACCOUNT}
#		"k8s_node_name":		${K2HDKC_NODE_NAME},
#		"k8s_node_ip":			${K2HDKC_NODE_IP},
#		"k8s_pod_name":			${K2HDKC_POD_NAME},
#		"k8s_pod_id":			${K2HDKC_POD_ID}
#		"k8s_pod_ip":			${K2HDKC_POD_IP}
#		"k8s_container_id":		${K2HDKC_CONTAINER_ID}
#		"k8s_k2hr3_rand":		"random 32 byte value formatted hex string"
#	}
#
# Base64 URL encoding converts the following characters.
#	'+'				to '-'
#	'/'				to '_'
#	'='(end word)	to '%3d'
#
K2HDKC_REG_RAND=$(od -vAn -tx8 -N16 < /dev/urandom 2>/dev/null | tr -d '[:blank:]' 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "[ERROR] ${PRGNAME} : Could not make 64 bytes random value for CUK value." 1>&2
	exit 1
fi

# shellcheck disable=SC2089
CUK_STRING="{\
\"k8s_container_id\":\"${K2HDKC_CONTAINER_ID}\",\
\"k8s_k2hr3_rand\":\"${K2HDKC_REG_RAND}\",\
\"k8s_namespace\":\"${K2HDKC_NAMESPACE}\",\
\"k8s_node_ip\":\"${K2HDKC_NODE_IP}\",\
\"k8s_node_name\":\"${K2HDKC_NODE_NAME}\",\
\"k8s_pod_id\":\"${K2HDKC_POD_ID}\",\
\"k8s_pod_ip\":\"${K2HDKC_POD_IP}\",\
\"k8s_pod_name\":\"${K2HDKC_POD_NAME}\",\
\"k8s_service_account\":\"${K2HDKC_POD_SERVICE_ACCOUNT}\"\
}"

CUK_BASE64_STRING=$(echo "${CUK_STRING}" 2>/dev/null | tr -d '\n' | sed -e 's/ //g' 2>/dev/null | base64 2>/dev/null | tr -d '\n' 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "[ERROR] ${PRGNAME} : Could not make base64 string for CUK value." 1>&2
	exit 1
fi
CUK_BASE64_URLENC=$(echo "${CUK_BASE64_STRING}" 2>/dev/null | tr -d '\n' | sed -e 's/+/-/g' -e 's#/#_#g' -e 's/=/%3d/g' 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "[ERROR] ${PRGNAME} : Could not make base64 url encode string for CUK value." 1>&2
	exit 1
fi

#
# Make EXTRA parameter
#
# Currently, the value of "extra" is "k8s-auto-v1" only.
#
EXTRA_STRING='k8s-auto-v1'

#
# Make 'tag' paraemter which is used CUSTOM_ID_SEED value in k2hdkc configuration
#
TAG_STRING=${K2HDKC_POD_NAME}

#
# Make K2HR3 YRN for role and resource
#
K2HDKC_ROLE_YRN=${K2HR3_YRN_PREFIX}${K2HDKC_NAMESPACE}:role:${K2HKDC_CLUSTER_NAME}/${K2HDKC_MODE}
K2HDKC_RESOURCE_YRN=${K2HR3_YRN_PREFIX}${K2HDKC_NAMESPACE}:resource:${K2HKDC_CLUSTER_NAME}/${K2HDKC_MODE}

#------------------------------------------------------------------------------
# Save parameters for accessing to K2HR3
#------------------------------------------------------------------------------
#
# Make each parameters to files
#
echo "${K2HR3_API_URL}"													| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_API_URL}
echo "${K2HR3_API_URL}${K2HR3_API_REGISTER_PATH}"						| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_REGISTER_URL}
echo "${K2HDKC_ROLE_YRN}"												| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_ROLE}
echo "${K2HDKC_RESOURCE_YRN}"											| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_RESOURCE}
echo "${CUK_BASE64_STRING}"												| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CUK}
echo "${CUK_BASE64_URLENC}"												| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CUKENC}
echo "extra=${EXTRA_STRING}&cuk=${CUK_BASE64_URLENC}&tag=${TAG_STRING}"	| tr -d '\n' > ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_APIARG}

#
# Role token file is copied
#
cp ${SECRET_K2HR3_TOKEN_DIR}/role-token-${K2HDKC_MODE}        ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_ROLE_TOKEN}

#
# Certificate files are copied
#
stat "${SECRET_K2HR3_CERTS}/${K2HR3_FILE_CA_CERT}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
	cp ${SECRET_K2HR3_CERTS}/${K2HR3_FILE_CA_CERT} ${ANTPICKAX_ETC_DIR}/	|| exit 1
	chmod 0444 ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CA_CERT}					|| exit 1
fi

SELF_HOSTNAME=$(hostname)
# shellcheck disable=SC2012
SELF_SERVER_CRT=$(ls -1 "${SECRET_K2HR3_CERTS}"/"${SELF_HOSTNAME}".*server.crt | sed -e "s#${SECRET_K2HR3_CERTS}/##g" -e '/^$/d' | head -1)
# shellcheck disable=SC2012
SELF_SERVER_KEY=$(ls -1 "${SECRET_K2HR3_CERTS}"/"${SELF_HOSTNAME}".*server.key | sed -e "s#${SECRET_K2HR3_CERTS}/##g" -e '/^$/d' | head -1)
# shellcheck disable=SC2012
SELF_CLIENT_CRT=$(ls -1 "${SECRET_K2HR3_CERTS}"/"${SELF_HOSTNAME}".*client.crt | sed -e "s#${SECRET_K2HR3_CERTS}/##g" -e '/^$/d' | head -1)
# shellcheck disable=SC2012
SELF_CLIENT_KEY=$(ls -1 "${SECRET_K2HR3_CERTS}"/"${SELF_HOSTNAME}".*client.key | sed -e "s#${SECRET_K2HR3_CERTS}/##g" -e '/^$/d' | head -1)

if [ "X${SELF_SERVER_CRT}" != "X" ] && [ "X${SELF_SERVER_KEY}" != "X" ] && [ "X${SELF_CLIENT_CRT}" != "X" ] && [ "X${SELF_CLIENT_KEY}" != "X" ]; then
	cp "${SECRET_K2HR3_CERTS}/${SELF_SERVER_CRT}" "${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_SERVER_CERT}"	|| exit 1
	cp "${SECRET_K2HR3_CERTS}/${SELF_SERVER_KEY}" "${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_SERVER_KEY}"	|| exit 1
	cp "${SECRET_K2HR3_CERTS}/${SELF_CLIENT_CRT}" "${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CLIENT_CERT}"	|| exit 1
	cp "${SECRET_K2HR3_CERTS}/${SELF_CLIENT_KEY}" "${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CLIENT_KEY}"	|| exit 1
	chmod 0444 ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_SERVER_CERT}									|| exit 1
	chmod 0400 ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_SERVER_KEY}									|| exit 1
	chmod 0444 ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CLIENT_CERT}									|| exit 1
	chmod 0400 ${ANTPICKAX_ETC_DIR}/${K2HR3_FILE_CLIENT_KEY}									|| exit 1
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
