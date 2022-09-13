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

#=====================================================================
# Common variables
#=====================================================================
# [NOTE]
# This file is a temporary file and will be deleted after output, so 
# don't expect it to exist.
#
_DBAAS_K8S_OPENSSL_OUTPUT_FILE="/tmp/.${BINNAME}.${K2HR3CLI_MODE}.$$.log"

#=====================================================================
# Functions for certificates
#=====================================================================

#---------------------------------------------------------------------
# Output all certificates in K2HDKC DBaaS K8S domain directory
#
# $?		: result(0/1)
# Output	: two type
#			  1) not JSON type
#				-------------------------------------
#				[CA cert]
#				certificate name
#				[node certs]
#				certificate name
#				...
#				-------------------------------------
#			  2) JSON type
#				-------------------------------------
#				{
#					"CA cert": [
#						"certificate name",
#						...
#					]
#					"node certs": [
#						"certificate name",
#						...
#					]
#				}
#				-------------------------------------
#
# Using Variables
#	K2HR3CLI_OPT_JSON
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
get_dbaas_k8s_domain_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# CA cert
	#
	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		#
		# JSON
		#
		_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="{\"CA cert\":["

		_DBAAS_K8S_CERT_TMP_SEP=""
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}\"${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}\""
			_DBAAS_K8S_CERT_TMP_SEP=","
		fi
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}" ]; then
			_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}${_DBAAS_K8S_CERT_TMP_SEP}\"${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}\""
		fi

		_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}],"

	else
		#
		# Not JSON
		#
		pecho "[CA cert]"
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			pecho "${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		fi
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}" ]; then
			pecho "${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"
		fi
		pecho ""
	fi

	#
	# node certs
	#
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST=""
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"/*"${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}" 2>/dev/null)
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST="${_DBAAS_K8S_CONFIG_TMP_FILE_LIST} ${_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP}"
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"/*"${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}" 2>/dev/null)
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST="${_DBAAS_K8S_CONFIG_TMP_FILE_LIST} ${_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP}"
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"/*"${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}" 2>/dev/null)
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST="${_DBAAS_K8S_CONFIG_TMP_FILE_LIST} ${_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP}"
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"/*"${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}" 2>/dev/null)
	_DBAAS_K8S_CONFIG_TMP_FILE_LIST="${_DBAAS_K8S_CONFIG_TMP_FILE_LIST} ${_DBAAS_K8S_CONFIG_TMP_FILE_LIST_TMP}"
	_DBAAS_K8S_CONFIG_TMP_RESULT=$(echo "${_DBAAS_K8S_CONFIG_TMP_FILE_LIST}" | sed -e "s#${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/##g" -e 's#/$##g' 2>/dev/null)

	if [ "X${K2HR3CLI_OPT_JSON}" = "X1" ]; then
		_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}\"node certs\":["

		_DBAAS_K8S_CERT_TMP_FIRST=1
		for _one_element in ${_DBAAS_K8S_CONFIG_TMP_RESULT}; do
			if [ "X${_one_element}" != "X" ]; then
				if [ "${_DBAAS_K8S_CERT_TMP_FIRST}" -eq 1 ]; then
					_DBAAS_K8S_CERT_TMP_SEP=""
					_DBAAS_K8S_CERT_TMP_FIRST=0
				else
					_DBAAS_K8S_CERT_TMP_SEP=","
				fi
				_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}${_DBAAS_K8S_CERT_TMP_SEP}\"${_one_element}\""
			fi
		done
		_DBAAS_K8S_CERT_TMP_OUTPUT_JSON="${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}]}"

		pecho "${_DBAAS_K8S_CERT_TMP_OUTPUT_JSON}"

	else
		pecho "[node certs]"
		for _one_element in ${_DBAAS_K8S_CONFIG_TMP_RESULT}; do
			if [ "X${_one_element}" != "X" ]; then
				pecho "${_one_element}"
			fi
		done
		pecho ""
	fi

	return 0
}

#---------------------------------------------------------------------
# Output a certificate content
#
# $1		: file name
# $?		: result(0/1)
# Output	: certificate file content
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#
print_dbaas_k8s_domain_certificate()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	_DBAAS_K8S_CERT_TMP_TARGETFILE=$1

	#
	# Check file
	#
	if [ "X${_DBAAS_K8S_CERT_TMP_TARGETFILE}" = "X${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		#
		# CA certificate
		#
		if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} file is not existed."
			return 1
		fi
		cat "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
	else
		#
		# Search file in certs directory
		#
		if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_CERT_TMP_TARGETFILE}" ]; then
			prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_CERT_TMP_TARGETFILE} file is not existed."
			return 1
		fi
		cat "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_CERT_TMP_TARGETFILE}"
	fi

	return 0
}

#---------------------------------------------------------------------
# Set certificates into K2HDKC DBaaS K8S domain directory
#
# $1		: Certificate file 1(path)
# $2		: Certificate secret key file 1(path)
# $3		: Certificate file 2(path)
# $4		: Certificate secret key file 2(path)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_CERT_TYPE
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#	K2HR3CLI_DBAAS_K8S_HOST_NUM
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
set_dbaas_k8s_domain_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	_DBAAS_K8S_CERT_TMP_CERT_1=$1
	_DBAAS_K8S_CERT_TMP_KEY_1=$2
	_DBAAS_K8S_CERT_TMP_CERT_2=$3
	_DBAAS_K8S_CERT_TMP_KEY_2=$4

	#
	# Check source file exist
	#
	if [ ! -f "${_DBAAS_K8S_CERT_TMP_CERT_1}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_KEY_1}" ]; then
		prn_err "${_DBAAS_K8S_CERT_TMP_CERT_1} or ${_DBAAS_K8S_CERT_TMP_KEY_1} file is not existed"
		return 1
	fi
	if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] || [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
		if [ ! -f "${_DBAAS_K8S_CERT_TMP_CERT_2}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_KEY_2}" ]; then
			prn_err "${_DBAAS_K8S_CERT_TMP_CERT_2} or ${_DBAAS_K8S_CERT_TMP_KEY_2} file is not existed"
			return 1
		fi
	fi

	#
	# distination file name(with sub directory)
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ]; then
		#
		# ca.crt
		# private/ca.key
		#
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"

		if [ -f "${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1}" ]; then
			rm -f "${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1}"
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
		#
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_2="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_2="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
		#
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_2="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_2="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
		#
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.key
		#
		_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
	fi

	#
	# Copy files
	#
	cp "${_DBAAS_K8S_CERT_TMP_CERT_1}" "${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to copy ${_DBAAS_K8S_CERT_TMP_CERT_1} to ${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1}"
		return 1
	else
		prn_info "Copied ${_DBAAS_K8S_CERT_TMP_CERT_1} to ${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_1}"
	fi

	cp "${_DBAAS_K8S_CERT_TMP_KEY_1}" "${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to copy ${_DBAAS_K8S_CERT_TMP_KEY_1} to ${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1}"
		return 1
	else
		prn_info "Copied ${_DBAAS_K8S_CERT_TMP_KEY_1} to ${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_1}"
	fi

	if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] || [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
		cp "${_DBAAS_K8S_CERT_TMP_CERT_2}" "${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_2}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to copy ${_DBAAS_K8S_CERT_TMP_CERT_2} to ${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_2}"
			return 1
		else
			prn_info "Copied ${_DBAAS_K8S_CERT_TMP_CERT_2} to ${_DBAAS_K8S_CERT_TMP_CERT_FILENAME_2}"
		fi

		cp "${_DBAAS_K8S_CERT_TMP_KEY_2}" "${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_2}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to copy ${_DBAAS_K8S_CERT_TMP_KEY_2} to ${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_2}"
			return 1
		else
			prn_info "Copied ${_DBAAS_K8S_CERT_TMP_KEY_2} to ${_DBAAS_K8S_CERT_TMP_KEY_FILENAME_2}"
		fi
	fi

	return 0
}

#---------------------------------------------------------------------
# Create openssl.cnf
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_FORCE
#
create_openssl_cnf_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}"
		if [ $? -ne 0 ]; then
			prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH} directory."
			return 1
		fi
		prn_dbg "(create_openssl_cnf_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH} directory."
	fi

	if [ ! -f "${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF}" ]; then
		prn_err "${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF} file is not existed."
		return 1
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		prn_err "Kubernetes domain name is not set."
		return 1
	fi

	#
	# If force update, remove current file at first.
	#
	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" = "X1" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
			prn_dbg "(create_openssl_cnf_file) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file."
		else
			prn_dbg "(create_openssl_cnf_file) Already have ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}, then do not remake it."
			return 0
		fi
	fi

	#
	# Create openssl.cnf from /etc/pki/tls/openssl.cnf
	# Modify values
	#	unique_subject	= no							in [ CA_default ] section
	#	dir      		= <K2HDKC DBaaS K8S domain>		in [ CA_default ] section
	#	keyUsage 		= cRLSign, keyCertSign			in [ v3_ca ] section
	#	[ v3_server ]									add section
	#													 - "##K2HDKC_DBAAS_K8S_SAN_SETTING##" line in this section for SAN
	#	[ v3_client ]									add section
	#
	sed -e 's/\[[[:space:]]*CA_default[[:space:]]*\]/\[ CA_default ]\nunique_subject = no/g'				\
		-e 's/\[[[:space:]]*v3_ca[[:space:]]*\]/\[ v3_ca ]\nkeyUsage = cRLSign, keyCertSign/g'				\
		-e "s#^dir[[:space:]]*=[[:space:]]*.*CA.*#dir = ${_DBAAS_K8S_CLUSTER_DIRPATH}#g"					\
		-e "s#/cacert.pem#/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}#g"										\
		-e "s#/cakey.pem#/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}#g"											\
		"${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF}"															\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}"

	{
		echo ""
		echo "[ v3_server ]"
		echo "basicConstraints=CA:FALSE"
		echo "keyUsage = digitalSignature, keyEncipherment"
		echo "extendedKeyUsage = serverAuth"
		echo "subjectKeyIdentifier=hash"
		echo "authorityKeyIdentifier=keyid,issuer"
		echo "##K2HDKC_DBAAS_K8S_SAN_SETTING##"
	} >> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}"

	{
		echo ""
		echo "[ v3_client ]"
		echo "basicConstraints=CA:FALSE"
		echo "keyUsage = digitalSignature, keyAgreement"
		echo "extendedKeyUsage = clientAuth"
		echo "subjectKeyIdentifier=hash"
		echo "authorityKeyIdentifier=keyid,issuer"
	} >> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}"

	prn_dbg "(create_openssl_cnf_file) Created the temporary openssl.cnf file(\"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}\")."

	#
	# Check old file, if it is existed
	#
	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		_DBAAS_K8S_CERT_TMP_OLD_CONTENTS=$(sed -e 's/#.*$//g' -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e 's/[[:space:]]*=[[:space:]]*/=/g' -e '/^$/d' "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}")
		_DBAAS_K8S_CERT_TMP_NEW_CONTENTS=$(sed -e 's/#.*$//g' -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e 's/[[:space:]]*=[[:space:]]*/=/g' -e '/^$/d' "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}")

		if [ "X${_DBAAS_K8S_CERT_TMP_OLD_CONTENTS}" = "X${_DBAAS_K8S_CERT_TMP_NEW_CONTENTS}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}"
			prn_dbg "(create_openssl_cnf_file) Nothing to update."
		else
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
			mv "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
			prn_dbg "(create_openssl_cnf_file) Overwrite ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file."
		fi
	else
		mv "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
		prn_dbg "(create_openssl_cnf_file) Created new ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file."
	fi

	return 0
}

#---------------------------------------------------------------------
# Create CA certificate
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME
#	K2HR3CLI_DBAAS_K8S_INDEX_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME
#	K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME
#	K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_FORCE
#
create_ca_certificate_files()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check opsnssl.cnf file and create it if not exists
	#
	create_openssl_cnf_file
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# If already have CA certificate, nothing to do.
	#
	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
			prn_dbg "(create_ca_certificate_files) Already have ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}, then do not remake it."
			return 0
		fi
	fi

	#
	# Cleanup directories and files
	#
	if [ -n "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"

		# shellcheck disable=SC2115
		rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
		# shellcheck disable=SC2115
		rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"
		# shellcheck disable=SC2115
		rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME}"
		# shellcheck disable=SC2115
		rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}"

		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME}"

		prn_dbg "(create_ca_certificate_files) Deleted CA certificate related files and certificate storage directories."
	fi
	prn_dbg "(create_ca_certificate_files) Removed all directories and files for certificates."

	mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME} directory."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME} directory."

	mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME} directory."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME} directory."

	mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME} directory."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME} directory."

	mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME} directory."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME} directory."

	echo "1000" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME} file."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME} file."

	touch "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}"
	if [ $? -ne 0 ]; then
		prn_err "Coult nod create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME} file."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME} file."

	#
	# Check paramters and set deafult value if not specified
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		prn_info "Not specify period years for certificate, thus use default value(5 year)."
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
	fi
	_DBAAS_K8S_CERT_TMP_PERIOD_DAYS=$((K2HR3CLI_DBAAS_K8S_CERT_EXPIRE * 365))

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
		prn_info "Not specify country in subject for certificate, thus use default value(JP)."
		K2HR3CLI_DBAAS_K8S_CERT_C="JP"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
		prn_info "Not specify state in subject for certificate, thus use default value(Tokyo)."
		K2HR3CLI_DBAAS_K8S_CERT_S="Tokyo"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
		prn_info "Not specify organaization in subject for certificate, thus use default value(AntPickax)."
		K2HR3CLI_DBAAS_K8S_CERT_O="AntPickax"
	fi

	#
	# Create CA certificates
	#
	# [NOTE]
	# If a passphrase is specified, it will be set in an environment variable.
	# If no passphrase is specified, use the "-nodes" option.
	# Since this option cannot be passed as a variable(ppenssl command gives an
	# error that an empty option is specified), it is divided into cases. 
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		export CA_PASSPHRASE="${K2HR3CLI_DBAAS_K8S_CA_PASS}"
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="env:CA_PASSPHRASE"

		"${OPENSSL_BIN}" req																										\
			-new																													\
			-x509																													\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"																		\
			-keyout		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"	\
			-out		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"										\
			-passout	"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"																		\
			-subj		"/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" \
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"											\
			-extensions	v3_ca																										\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

	else
		CA_PASSPHRASE=""
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="pass:"

		"${OPENSSL_BIN}" req																										\
			-new																													\
			-x509																													\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"																		\
			-keyout		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"	\
			-out		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"										\
			-passout	"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"																		\
			-subj		"/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" \
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"											\
			-extensions	v3_ca																										\
			-nodes																													\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1
	fi

	if [ $? -ne 0 ]; then
		prn_err "Failed to create self-signed CA certificate and private key."
		pecho ""
		cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
		pecho ""

		return 1
	fi
	rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
	prn_dbg "(create_ca_certificate_files) Succeed creating ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} file."

	#
	# Set private file permission
	#
	chmod 0400 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"
	if [ $? -ne 0 ]; then
		prn_err "Could not set permission(0400) to ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}."
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Succeed to set permission(0400) to ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME} file."

	#
	# Check and print CA certificate
	#
	"${OPENSSL_BIN}" x509															\
		-in "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"	\
		-text																		\
		> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

	if [ $? -ne 0 ]; then
		prn_err "Failed to dump self-signed CA certificate(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME})."
		cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Succeed checking and showing self-signed CA certificate(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}) file."
	rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

	#
	# Check and print CA private key
	#
	"${OPENSSL_BIN}" rsa																										\
		-in			"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"	\
		-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"																		\
		-text																													\
		> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

	if [ $? -ne 0 ]; then
		prn_err "Failed to dump self-signed CA private key(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME})."
		cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
		return 1
	fi
	prn_dbg "(create_ca_certificate_files) Succeed checking and showing self-signed CA private key(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}) file."
	rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

	#
	# Save value to configuration
	#
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE'	"${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_C'		"${K2HR3CLI_DBAAS_K8S_CERT_C}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_S'		"${K2HR3CLI_DBAAS_K8S_CERT_S}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_O'		"${K2HR3CLI_DBAAS_K8S_CERT_O}"
	if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CA_PASS'	"${K2HR3CLI_DBAAS_K8S_CA_PASS}"
	fi
	prn_dbg "(create_ca_certificate_files) Saved information for self-signed CA certificate to configuration."

	return 0
}

#---------------------------------------------------------------------
# Create SAN value string from hotnames and ip addresses
#
# $1		: hostanme(s) and IP address(es)
# $?		: result(0/1)
# Output	: SAN string
#
create_san_value_strings()
{
	_DBAAS_K8S_TMP_VALUE=$(echo "$1" | sed -e 's/,/ /g')
	_DBAAS_K8S_TMP_SAN_RESULT=""
	for _one_hostname in ${_DBAAS_K8S_TMP_VALUE}; do
		#
		# Check type
		#
		echo "${_one_hostname}" | grep -q -E -o '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' 2>/dev/null
		if [ $? -eq 0 ]; then
			#
			# IPv4
			#
			_DBAAS_K8S_TMP_SAN_PREFIX="IP:"
		else
			echo "${_one_hostname}" | grep -q -E -o '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
			if [ $? -eq 0 ]; then
				#
				# IPv6
				#
				_DBAAS_K8S_TMP_SAN_PREFIX="IP:"
			else
				#
				# hostname
				#
				_DBAAS_K8S_TMP_SAN_PREFIX="DNS:"
			fi
		fi

		_DBAAS_K8S_TMP_SAN_PART="${_DBAAS_K8S_TMP_SAN_PREFIX}${_one_hostname}"

		if [ "X${_DBAAS_K8S_TMP_SAN_RESULT}" != "X" ]; then
			_DBAAS_K8S_TMP_SAN_RESULT="${_DBAAS_K8S_TMP_SAN_RESULT}, ${_DBAAS_K8S_TMP_SAN_PART}"
		else
			_DBAAS_K8S_TMP_SAN_RESULT="${_DBAAS_K8S_TMP_SAN_PART}"
		fi
	done

	pecho -n "${_DBAAS_K8S_TMP_SAN_RESULT}"
	return 0
}

#---------------------------------------------------------------------
# Create certificates for K2HDKC in K2HR3
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#	K2HR3CLI_DBAAS_K8S_FORCE
#
create_k2hdkc_certificate_files()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check parameters
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ]; then
		prn_err "The replicas value for K2HDKC in K2HR3 system is not set."
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		prn_info "Not specify period years for certificate, thus use default value(5 year)."
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
	fi
	_DBAAS_K8S_CERT_TMP_PERIOD_DAYS=$((K2HR3CLI_DBAAS_K8S_CERT_EXPIRE * 365))

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
		prn_info "Not specify country in subject for certificate, thus use default value(JP)."
		K2HR3CLI_DBAAS_K8S_CERT_C="JP"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
		prn_info "Not specify state in subject for certificate, thus use default value(Tokyo)."
		K2HR3CLI_DBAAS_K8S_CERT_S="Tokyo"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
		prn_info "Not specify organaization in subject for certificate, thus use default value(AntPickax)."
		K2HR3CLI_DBAAS_K8S_CERT_O="AntPickax"
	fi

	#
	# Set CA Passphrase to environment
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		export CA_PASSPHRASE="${K2HR3CLI_DBAAS_K8S_CA_PASS}"
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="env:CA_PASSPHRASE"
	else
		CA_PASSPHRASE=""
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="pass:"
	fi

	#
	# Check files
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file is not exsted."
		return 1
	fi

	#
	# Loop : Create certificates
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		#
		# Make file path
		#
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.csr
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.csr
		# certs/pod-<r3dkc>-<num>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		#
		# If already have all certificate, nothing to do.
		#
		if [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}" ]; then
			if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
				prn_dbg "(create_k2hdkc_certificate_files) Already have ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}, ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} and ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}, then do not remake it."
				continue
			fi
		fi

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"

		#
		# Make CN hostname(without domain name):
		#	pod-<r3dkc>-<num>.svc-<r3dkc>
		#
		_DBAAS_K8S_CERT_TMP_HOST_CN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"

		#
		# Make another hostanmes(full FQDN and DNSRR name):
		#	pod-<r3dkc>-<num>.svc-<r3dkc>.<k8s namespace>.<k8s domain>
		#	svc-<r3dkc>
		#	svc-<r3dkc>.<k8s namespace>.<k8s domain>
		#
		_DBAAS_K8S_CERT_TMP_HOST_FULL="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR="${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL="${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

		#
		# Make SAN parameter from other hostnames/IP addresses
		#
		_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS=$(create_san_value_strings "${_DBAAS_K8S_CERT_TMP_HOST_FULL},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL},${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}")
		if [ $? -ne 0 ]; then
			prn_err "Something error occurred in making SAN parameter."
			return 1
		fi

		#
		# Make SANs parameter:
		# 	"subjectAltName = DNS:subname.antpickax, IP:172.0.0.1, ...."
		#
		if [ "X${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}" = "X" ]; then
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}"
		else
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}, ${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}"
		fi

		#
		# Create custom openssl.cnf for this host
		#
		# Replace "##K2HDKC_DBAAS_K8S_SAN_SETTING##" in the base "openssl.cnf" and save it as "node_openssl.cnf".
		#
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		fi
		sed "s/##K2HDKC_DBAAS_K8S_SAN_SETTING##/${_DBAAS_K8S_CERT_TMP_SANS}/g" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"

		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} file."

		#
		# Make server secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} file."

		#
		# Make server CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make server certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_server									\
			-out		"${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} file."

		#
		# Make client CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_client									\
			-out		"${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"/*
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		prn_dbg "(create_k2hdkc_certificate_files) Cleanup ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}, ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}/* and ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} files."
	done

	#
	# Save value to configuration
	#
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3DKC_NAME'	"${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3DKC_REPS'	"${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_NODE_IPS'	"${K2HR3CLI_DBAAS_K8S_NODE_IPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE'	"${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_C'		"${K2HR3CLI_DBAAS_K8S_CERT_C}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_S'		"${K2HR3CLI_DBAAS_K8S_CERT_S}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_O'		"${K2HR3CLI_DBAAS_K8S_CERT_O}"
	if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CA_PASS'	"${K2HR3CLI_DBAAS_K8S_CA_PASS}"
	fi
	prn_dbg "(create_k2hdkc_certificate_files) Saved information for self-signed CA certificate to configuration."

	return 0
}

#---------------------------------------------------------------------
# Create certificates for K2HR3 API
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_EP
#	K2HR3CLI_DBAAS_K8S_R3API_IPS
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#	K2HR3CLI_DBAAS_K8S_FORCE
#
create_k2hr3api_certificate_files()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check parameters
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
		prn_err "The replicas value for K2HR3 API system is not set."
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		prn_info "Not specify period years for certificate, thus use default value(5 year)."
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
	fi
	_DBAAS_K8S_CERT_TMP_PERIOD_DAYS=$((K2HR3CLI_DBAAS_K8S_CERT_EXPIRE * 365))

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
		prn_info "Not specify country in subject for certificate, thus use default value(JP)."
		K2HR3CLI_DBAAS_K8S_CERT_C="JP"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
		prn_info "Not specify state in subject for certificate, thus use default value(Tokyo)."
		K2HR3CLI_DBAAS_K8S_CERT_S="JP"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
		prn_info "Not specify organaization in subject for certificate, thus use default value(AntPickax)."
		K2HR3CLI_DBAAS_K8S_CERT_O="AntPickax"
	fi

	#
	# Set CA Passphrase to environment
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		export CA_PASSPHRASE="${K2HR3CLI_DBAAS_K8S_CA_PASS}"
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="env:CA_PASSPHRASE"
	else
		CA_PASSPHRASE=""
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="pass:"
	fi

	#
	# Check files
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file is not exsted."
		return 1
	fi

	#
	# Get NodePort ClusterIP
	#
	_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP=$(get_k2hr3_nodeport_cluster_ip 0 "${K2HR3CLI_DBAAS_K8S_R3API_NAME}")
	if [ $? -ne 0 ]; then
		prn_err "K2HR3 API NodePort Service is not existed, The NodePort service must be started and the Cluster IP must be present to create the certificate. First, start the NodePort service."
		return 1
	fi

	#
	# Loop : Create certificates
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_R3API_REPS}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		#
		# Make file path
		#
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.csr
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.csr
		# certs/pod-<r3api>-<num>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		#
		# If already have all certificate, nothing to do.
		#
		if [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}" ]; then
			if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
				prn_dbg "(create_k2hr3api_certificate_files) Already have ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}, ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} and ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}, then do not remake it."
				continue
			fi
		fi

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"

		#
		# Make CN hostname(without domain name):
		#	pod-<r3api>-<num>.svc-<r3api>
		#
		_DBAAS_K8S_CERT_TMP_HOST_CN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"

		#
		# Make another hostanmes(full FQDN and DNSRR name):
		#	pod-<r3api>-<num>.svc-<r3api>.<k8s namespace>.<k8s domain>
		#	svc-<r3api>
		#	svc-<r3api>.<k8s namespace>.<k8s domain>
		#
		_DBAAS_K8S_CERT_TMP_HOST_FULL="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR="${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL="${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

		#
		# Make SAN parameter from other hostnames/IP addresses
		#
		_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_HOST_FULL},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL}"

		if [ "X${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}"
		fi
		if [ "X${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}"
		fi
		# shellcheck disable=SC2153
		if [ "X${K2HR3CLI_DBAAS_K8S_R3API_EP}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_R3API_EP}"
		fi
		if [ "X${K2HR3CLI_DBAAS_K8S_NODE_IPS}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_NODE_IPS}"
		fi

		_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS=$(create_san_value_strings "${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_LOCAL_HOSTNAMES}")
		if [ $? -ne 0 ]; then
			prn_err "Something error occurred in making SAN parameter."
			return 1
		fi

		#
		# Make SANs parameter:
		# 	"subjectAltName = DNS:subname.antpickax, IP:172.0.0.1, ...."
		#
		if [ "X${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}" = "X" ]; then
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}"
		else
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}, ${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}"
		fi

		#
		# Create custom openssl.cnf for this host
		#
		# Replace "##K2HDKC_DBAAS_K8S_SAN_SETTING##" in the base "openssl.cnf" and save it as "node_openssl.cnf".
		#
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		fi
		sed "s/##K2HDKC_DBAAS_K8S_SAN_SETTING##/${_DBAAS_K8S_CERT_TMP_SANS}/g" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"

		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} file."

		#
		# Make server secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} file."

		#
		# Make server CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make server certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_server									\
			-out		"${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} file."

		#
		# Make client CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_client									\
			-out		"${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3api_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"/*
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		prn_dbg "(create_k2hr3api_certificate_files) Cleanup ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}, ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}/* and ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} files."
	done

	#
	# Save value to configuration
	#
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_NAME'	"${K2HR3CLI_DBAAS_K8S_R3API_NAME}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_REPS'	"${K2HR3CLI_DBAAS_K8S_R3API_REPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_EP'	"${K2HR3CLI_DBAAS_K8S_R3API_EP}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_NODE_IPS'	"${K2HR3CLI_DBAAS_K8S_NODE_IPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE'	"${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_C'		"${K2HR3CLI_DBAAS_K8S_CERT_C}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_S'		"${K2HR3CLI_DBAAS_K8S_CERT_S}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_O'		"${K2HR3CLI_DBAAS_K8S_CERT_O}"
	if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CA_PASS'	"${K2HR3CLI_DBAAS_K8S_CA_PASS}"
	fi
	prn_dbg "(create_k2hr3api_certificate_files) Saved information for self-signed CA certificate to configuration."

	return 0
}

#---------------------------------------------------------------------
# Create certificates for K2HR3 APP
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_EP
#	K2HR3CLI_DBAAS_K8S_R3API_IPS
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS
#	K2HR3CLI_DBAAS_K8S_FORCE
#
create_k2hr3app_certificate_files()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check parameters
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
		prn_err "The replicas value for K2HR3 API system is not set."
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		prn_info "Not specify period years for certificate, thus use default value(5 year)."
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
	fi
	_DBAAS_K8S_CERT_TMP_PERIOD_DAYS=$((K2HR3CLI_DBAAS_K8S_CERT_EXPIRE * 365))

	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
		prn_info "Not specify country in subject for certificate, thus use default value(JP)."
		K2HR3CLI_DBAAS_K8S_CERT_C="JP"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
		prn_info "Not specify state in subject for certificate, thus use default value(Tokyo)."
		K2HR3CLI_DBAAS_K8S_CERT_S="Tokyo"
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
		prn_info "Not specify organaization in subject for certificate, thus use default value(AntPickax)."
		K2HR3CLI_DBAAS_K8S_CERT_O="AntPickax"
	fi

	#
	# Set CA Passphrase to environment
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		export CA_PASSPHRASE="${K2HR3CLI_DBAAS_K8S_CA_PASS}"
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="env:CA_PASSPHRASE"
	else
		CA_PASSPHRASE=""
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="pass:"
	fi

	#
	# Check files
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file is not exsted."
		return 1
	fi

	#
	# Get NodePort ClusterIP
	#
	_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP=$(get_k2hr3_nodeport_cluster_ip 1 "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}")
	if [ $? -ne 0 ]; then
		prn_err "K2HR3 API NodePort Service is not existed, The NodePort service must be started and the Cluster IP must be present to create the certificate. First, start the NodePort service."
		return 1
	fi

	#
	# Loop : Create certificates
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_R3APP_REPS}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))

		#
		# Make file path
		#
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.csr
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.key
		#
		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"

		#
		# If already have all certificate, nothing to do.
		# (The private key is not required for the K2HR3 APP system)
		#
		if [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ]; then
			if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
				prn_dbg "(create_k2hr3app_certificate_files) Already have ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} then do not remake it."
				continue
			fi
		fi

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"

		#
		# Make CN hostname(without domain name):
		#	pod-<r3app>.svc-<r3app>
		#
		_DBAAS_K8S_CERT_TMP_HOST_CN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"

		#
		# Make another hostanmes(full FQDN):
		#	pod-<r3app>.svc-<r3app>.<k8s namespace>.<k8s domain>
		#
		_DBAAS_K8S_CERT_TMP_HOST_FULL="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

		#
		# Make SAN parameter from other hostnames/IP addresses
		#
		_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_HOST_FULL},${_DBAAS_K8S_CERT_TMP_LOCAL_HOSTNAMES}"

		if [ "X${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}"
		fi
		if [ "X${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}"
		fi
		# shellcheck disable=SC2153
		if [ "X${K2HR3CLI_DBAAS_K8S_R3APP_EP}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_R3APP_EP}"
		fi
		if [ "X${K2HR3CLI_DBAAS_K8S_NODE_IPS}" != "X" ]; then
			_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES="${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${K2HR3CLI_DBAAS_K8S_NODE_IPS}"
		fi

		_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS=$(create_san_value_strings "${_DBAAS_K8S_CERT_TMP_SAN_HOSTNAMES},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_LOCAL_HOSTNAMES}")
		if [ $? -ne 0 ]; then
			prn_err "Something error occurred in making SAN parameter."
			return 1
		fi

		#
		# Make SANs parameter:
		# 	"subjectAltName = DNS:subname.antpickax, IP:172.0.0.1, ...."
		#
		if [ "X${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}" = "X" ]; then
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}"
		else
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}, ${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}"
		fi

		#
		# Create custom openssl.cnf for this host
		#
		# Replace "##K2HDKC_DBAAS_K8S_SAN_SETTING##" in the base "openssl.cnf" and save it as "node_openssl.cnf".
		#
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		fi
		sed "s/##K2HDKC_DBAAS_K8S_SAN_SETTING##/${_DBAAS_K8S_CERT_TMP_SANS}/g" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"

		prn_dbg "(create_k2hr3app_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} file."

		#
		# Make server secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_k2hr3app_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} file."

		#
		# Make server CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3app_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make server certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_server									\
			-out		"${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_k2hr3app_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"/*
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		prn_dbg "(create_k2hr3app_certificate_files) Cleanup ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}, ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}/* and ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} files."
	done

	#
	# Save value to configuration
	#
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_NAME'	"${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_REPS'	"${K2HR3CLI_DBAAS_K8S_R3APP_REPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_EP'	"${K2HR3CLI_DBAAS_K8S_R3APP_EP}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_NODE_IPS'	"${K2HR3CLI_DBAAS_K8S_NODE_IPS}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE'	"${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_C'		"${K2HR3CLI_DBAAS_K8S_CERT_C}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_S'		"${K2HR3CLI_DBAAS_K8S_CERT_S}"
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_O'		"${K2HR3CLI_DBAAS_K8S_CERT_O}"
	if [ "X${K2HR3CLI_OPT_SAVE_PASS}" = "X1" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CA_PASS'	"${K2HR3CLI_DBAAS_K8S_CA_PASS}"
	fi
	prn_dbg "(create_k2hr3app_certificate_files) Saved information for self-signed CA certificate to configuration."

	return 0
}

#---------------------------------------------------------------------
# Create all K2HR3 system certificates into K2HDKC DBaaS K8S domain directory
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CERT_TYPE
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_HOST_NUM
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_EP
#	K2HR3CLI_DBAAS_K8S_R3APP_EP
#	K2HR3CLI_DBAAS_K8S_NODE_IPS
#	K2HR3CLI_DBAAS_K8S_MINIKUBE
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#
create_dbaas_k8s_domain_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory "1")
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check target 
	#
	_DBAAS_K8S_CERT_TMP_CREATE_CA=0
	_DBAAS_K8S_CERT_TMP_CREATE_R3DKC=0
	_DBAAS_K8S_CERT_TMP_CREATE_R3API=0
	_DBAAS_K8S_CERT_TMP_CREATE_R3APP=0

	if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}" ]; then
		_DBAAS_K8S_CERT_TMP_CREATE_CA=1
		_DBAAS_K8S_CERT_TMP_CREATE_R3DKC=1
		_DBAAS_K8S_CERT_TMP_CREATE_R3API=1
		_DBAAS_K8S_CERT_TMP_CREATE_R3APP=1
	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ]; then
		_DBAAS_K8S_CERT_TMP_CREATE_CA=1
	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
		_DBAAS_K8S_CERT_TMP_CREATE_R3DKC=1
	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
		_DBAAS_K8S_CERT_TMP_CREATE_R3API=1
	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
		_DBAAS_K8S_CERT_TMP_CREATE_R3APP=1
	else
		prn_err "There is an error in the type(${K2HR3CLI_DBAAS_K8S_CERT_TYPE}) of certificate to be set."
		return 1
	fi

	#
	# Create certificates
	#
	if [ "${_DBAAS_K8S_CERT_TMP_CREATE_CA}" -eq 1 ]; then
		create_ca_certificate_files
		if [ $? -ne 0 ]; then
			prn_err "Failed to create CA certificate and provate key."
			return 1
		fi
	fi
	if [ "${_DBAAS_K8S_CERT_TMP_CREATE_R3DKC}" -eq 1 ]; then
		create_k2hdkc_certificate_files
		if [ $? -ne 0 ]; then
			prn_err "Failed to create K2HDKC in K2HR3 system certificates and provate keys."
			return 1
		fi
	fi
	if [ "${_DBAAS_K8S_CERT_TMP_CREATE_R3API}" -eq 1 ]; then
		create_k2hr3api_certificate_files
		if [ $? -ne 0 ]; then
			prn_err "Failed to create K2HR3 API system certificates and provate keys."
			return 1
		fi
	fi
	if [ "${_DBAAS_K8S_CERT_TMP_CREATE_R3APP}" -eq 1 ]; then
		create_k2hr3app_certificate_files
		if [ $? -ne 0 ]; then
			prn_err "Failed to create K2HR3 APP system certificates and provate keys."
			return 1
		fi
	fi

	return 0
}

#---------------------------------------------------------------------
# Delete all K2HR3 system certificates from K2HDKC DBaaS K8S domain directory
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_CERT_TYPE
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL
#	K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME
#	K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME
#	K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME
#	K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API
#	K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_HOST_NUM
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#
delete_dbaas_k8s_domain_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# distination file name(with sub directory)
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}" ]; then
		#
		# all certificates, it means all directories/files is removed
		#
		if [ -n "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"

			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME}"

			# shellcheck disable=SC2115
			rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
			# shellcheck disable=SC2115
			rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"
			# shellcheck disable=SC2115
			rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME}"
			# shellcheck disable=SC2115
			rm -rf "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}"

			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME} directory."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME} directory."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME} directory."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME} directory."
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ]; then
		#
		# Remove all files related to CA
		#
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME}"

		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME} files."

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
		#
		# certs/pod-<r3dkc>-<num|*>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3dkc>-<num|*>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3dkc>-<num|*>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3dkc>-<num|*>.svc-<r3dkc>.<k8snamespace>.<k8sdomain>.client.key
		#
		if [ -z "${K2HR3CLI_DBAAS_K8S_HOST_NUM}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
		else
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
		#
		# certs/pod-<r3api>-<num|*>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3api>-<num|*>.svc-<r3api>.<k8snamespace>.<k8sdomain>.server.key
		# certs/pod-<r3api>-<num|*>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/pod-<r3api>-<num|*>.svc-<r3api>.<k8snamespace>.<k8sdomain>.client.key
		#
		if [ -z "${K2HR3CLI_DBAAS_K8S_HOST_NUM}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
		else
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
			prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${K2HR3CLI_DBAAS_K8S_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
		#
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/pod-<r3app>.svc-<r3app>.<k8snamespace>.<k8sdomain>.server.key
		#
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"

		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
		prn_dbg "(delete_dbaas_k8s_domain_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
	fi

	return 0
}

#---------------------------------------------------------------------
# Check CA certificates
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#
check_dbaas_k8s_domain_ca_ertification()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ] || \
	   [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}" ] || \
	   [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}" ] || \
	   [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}" ] || \
	   [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME}" ] || \
	   [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}" ] || \
	   [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME}" ] || \
	   [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		return 1
	fi
	return 0
}

#---------------------------------------------------------------------
# Check all K2HR3 system certificates exist
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#
check_dbaas_k8s_all_domain_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
		return 1
	fi

	#
	# CA
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		return 1
	fi

	#
	# K2HDKC
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"

		if [ ! -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ]; then
			return 1
		fi
	done

	#
	# K2HR3 API
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_R3API_REPS}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"

		if [ ! -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ]; then
			return 1
		fi
	done

	#
	# K2HR3 APP
	#
	_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
	if [ ! -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ]; then
		return 1
	fi

	return 0
}

#---------------------------------------------------------------------
# Create K2HDKC DBaaS certificates
#
# $1		: type(all, server, slave)
# $2		: overwrite(1)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL
#	K2HR3CLI_DBAAS_K8S_FORCE
#
#	K2HR3CLI_DBAAS_K8S_CLUSTER_NAME
#
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF
#	K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#	K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME
#
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX
#
create_dbaas_k2hdkc_certificate_files()
{
	if [ "X$1" = "Xall" ] || [ "X$1" = "XALL" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=1
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=1
	elif [ "X$1" = "Xserver" ] || [ "X$1" = "XSERVER" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=1
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=0
	elif [ "X$1" = "Xslave" ] || [ "X$1" = "XSLAVE" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=0
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=1
	else
		prn_err "The first parameter is not specified, or wrong value."
		return 1
	fi
	if [ "X$2" = "X1" ]; then
		_DBAAS_K8S_CLUSTER_TMP_OVERWRITE=1
	else
		_DBAAS_K8S_CLUSTER_TMP_OVERWRITE=0
	fi

	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check parameters
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ] || [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" -le 0 ]; then
		prn_err "The server in K2HDKC DBaaS K8S cluster count is wrong."
		return 1
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ] || [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" -le 0 ]; then
		prn_err "The server in K2HDKC DBaaS K8S cluster count is wrong."
		return 1
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		prn_info "Not specify period years for certificate, thus use default value(5 year)."
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
	fi
	_DBAAS_K8S_CERT_TMP_PERIOD_DAYS=$((K2HR3CLI_DBAAS_K8S_CERT_EXPIRE * 365))

	#
	# Set CA Passphrase to environment
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		export CA_PASSPHRASE="${K2HR3CLI_DBAAS_K8S_CA_PASS}"
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="env:CA_PASSPHRASE"
	else
		CA_PASSPHRASE=""
		_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL="pass:"
	fi

	#
	# Check files
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" ]; then
		prn_err "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF} file is not exsted."
		return 1
	fi

	#
	# Loop : Create K2HDKC server certificates
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
	while [ "${_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER}" -eq 1 ] && [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		#
		# Make file path
		#
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.csr
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.csr
		# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		#
		# If already have all certificate, nothing to do.
		#
		if [ "${_DBAAS_K8S_CLUSTER_TMP_OVERWRITE}" -ne 1 ]; then
			if [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}" ]; then
				if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
					prn_dbg "(create_dbaas_k2hdkc_certificate_files) Already have ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}, ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} and ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}, then do not remake it."
					continue
				fi
			fi
		fi

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"

		#
		# Make CN hostname(without domain name):
		#	svrpod-<cluster name>-<num>.svrsvc-<cluster name>
		#
		_DBAAS_K8S_CERT_TMP_HOST_CN="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

		#
		# Make another hostanmes(full FQDN and DNSRR name):
		#	svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8s namespace>.<k8s domain>
		#	svrsvc-<cluster name>
		#	svrsvc-<cluster name>.<k8s namespace>.<k8s domain>
		#
		_DBAAS_K8S_CERT_TMP_HOST_FULL="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

		#
		# Make SAN parameter from other hostnames/IP addresses
		#
		_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS=$(create_san_value_strings "${_DBAAS_K8S_CERT_TMP_HOST_FULL},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL},${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}")
		if [ $? -ne 0 ]; then
			prn_err "Something error occurred in making SAN parameter."
			return 1
		fi

		#
		# Make SANs parameter:
		# 	"subjectAltName = DNS:subname.antpickax, IP:172.0.0.1, ...."
		#
		if [ "X${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}" = "X" ]; then
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}"
		else
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}, ${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}"
		fi

		#
		# Create custom openssl.cnf for this host
		#
		# Replace "##K2HDKC_DBAAS_K8S_SAN_SETTING##" in the base "openssl.cnf" and save it as "node_openssl.cnf".
		#
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		fi
		sed "s/##K2HDKC_DBAAS_K8S_SAN_SETTING##/${_DBAAS_K8S_CERT_TMP_SANS}/g" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"

		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} file."

		#
		# Make server secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} file."

		#
		# Make server CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make server certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_server									\
			-out		"${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} file."

		#
		# Make client CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_client									\
			-out		"${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"/*
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Cleanup ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}, ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}/* and ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} files."
	done

	#
	# Loop : Create K2HDKC slave certificates
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
	while [ "${_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE}" -eq 1 ] && [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		#
		# Make file path
		#
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.csr
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.csr
		# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
		#
		_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX}"
		_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		#
		# If already have all certificate, nothing to do.
		#
		if [ "${_DBAAS_K8S_CLUSTER_TMP_OVERWRITE}" -ne 1 ]; then
			if [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ] && [ -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}" ]; then
				if [ "X${K2HR3CLI_DBAAS_K8S_FORCE}" != "X1" ]; then
					prn_dbg "(create_dbaas_k2hdkc_certificate_files) Already have ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}, ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} and ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}, then do not remake it."
					continue
				fi
			fi
		fi

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"

		#
		# Make CN hostname(without domain name):
		#	slvpod-<cluster name>-<num>.slvsvc-<cluster name>
		#
		_DBAAS_K8S_CERT_TMP_HOST_CN="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

		#
		# Make another hostanmes(full FQDN and DNSRR name):
		#	slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8s namespace>.<k8s domain>
		#	slvsvc-<cluster name>
		#	slvsvc-<cluster name>.<k8s namespace>.<k8s domain>
		#
		_DBAAS_K8S_CERT_TMP_HOST_FULL="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
		_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

		#
		# Make SAN parameter from other hostnames/IP addresses
		#
		_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS=$(create_san_value_strings "${_DBAAS_K8S_CERT_TMP_HOST_FULL},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR},${_DBAAS_K8S_CERT_TMP_HOST_DNSRR_FULL},${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}")
		if [ $? -ne 0 ]; then
			prn_err "Something error occurred in making SAN parameter."
			return 1
		fi

		#
		# Make SANs parameter:
		# 	"subjectAltName = DNS:subname.antpickax, IP:172.0.0.1, ...."
		#
		if [ "X${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}" = "X" ]; then
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}"
		else
			_DBAAS_K8S_CERT_TMP_SANS="subjectAltName = DNS:${_DBAAS_K8S_CERT_TMP_HOST_CN}, ${_DBAAS_K8S_CERT_TMP_SAN_OTHER_PARAMS}"
		fi

		#
		# Create custom openssl.cnf for this host
		#
		# Replace "##K2HDKC_DBAAS_K8S_SAN_SETTING##" in the base "openssl.cnf" and save it as "node_openssl.cnf".
		#
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" ]; then
			rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		fi
		sed "s/##K2HDKC_DBAAS_K8S_SAN_SETTING##/${_DBAAS_K8S_CERT_TMP_SANS}/g" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}" > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"

		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} file."

		#
		# Make server secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE} file."

		#
		# Make server CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_SERVER_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make server certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_server									\
			-out		"${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client secret key(2048 bit) without passphrase
		#
		"${OPENSSL_BIN}" genrsa								\
			-out "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			2048											\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		chmod 0400 "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to set permission(0400) to ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} private key."
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE} file."

		#
		# Make client CSR file
		#
		"${OPENSSL_BIN}" req								\
			-new											\
			-key  "${_DBAAS_K8S_CERT_TMP_CLIENT_KEY_FILE}"	\
			-out  "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			-subj "/C=${K2HR3CLI_DBAAS_K8S_CERT_C}/ST=${K2HR3CLI_DBAAS_K8S_CERT_S}/O=${K2HR3CLI_DBAAS_K8S_CERT_O}/CN=${_DBAAS_K8S_CERT_TMP_HOST_CN}" \
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} CSR file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Make client certificate
		#
		"${OPENSSL_BIN}" ca											\
			-batch													\
			-extensions	v3_client									\
			-out		"${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}"	\
			-days		"${_DBAAS_K8S_CERT_TMP_PERIOD_DAYS}"		\
			-passin		"${_DBAAS_K8S_CERT_TMP_PASS_OPT_VAL}"		\
			-config		"${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}" \
			-infiles	"${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"	\
			> "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed to create ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} certificate file."
			pecho ""
			cat "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}" 1>&2
			rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"
			pecho ""
			return 1
		fi
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Created ${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE} file."
		rm -f "${_DBAAS_K8S_OPENSSL_OUTPUT_FILE}"

		#
		# Cleanup files
		#
		rm -f "${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}"/*
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		prn_dbg "(create_dbaas_k2hdkc_certificate_files) Cleanup ${_DBAAS_K8S_CERT_TMP_SERVER_CSR_FILE}, ${_DBAAS_K8S_CERT_TMP_CLIENT_CSR_FILE}, ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME}/* and ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP} files."
	done

	return 0
}

#---------------------------------------------------------------------
# Delete all K2HDKC DBaaS certificates
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#
#	K2HR3CLI_DBAAS_K8S_CLUSTER_NAME
#
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX
#
# [NOTE]
# This function is currently unused.
# If you want to delete the certificate of K2HDKC cluster on a cluster-by-cluster
# basis, use it.
#
delete_dbaas_k2hdkc_certificates()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# K2HDKC DBaaS server certificates
	#
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
	done

	#
	# K2HDKC DBaaS slave certificates
	#
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
	#
	_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
	while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
		_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX} files."
		prn_dbg "(delete_dbaas_k2hdkc_certificates) Removed ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX} files."
	done

	return 0
}

#---------------------------------------------------------------------
# Check all K2HDKC DBaaS certificates exist
#
# $1		: type(all, server, slave)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#
#	K2HR3CLI_DBAAS_K8S_CLUSTER_NAME
#
#	K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME
#	K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME
#
#	K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX
#
check_dbaas_k2hdkc_certificates()
{
	if [ "X$1" = "Xall" ] || [ "X$1" = "XALL" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=1
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=1
	elif [ "X$1" = "Xserver" ] || [ "X$1" = "XSERVER" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=1
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=0
	elif [ "X$1" = "Xslave" ] || [ "X$1" = "XSLAVE" ]; then
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER=0
		_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE=1
	else
		prn_err "The first parameter is not specified, or wrong value."
		return 1
	fi

	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
		return 1
	fi

	#
	# CA
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		return 1
	fi

	#
	# K2HDKC DBaaS server
	#
	if [ "${_DBAAS_K8S_CLUSTER_TMP_TYPE_SERVER}" -eq 1 ]; then
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
		while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
			_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
			_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

			_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"

			if [ ! -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ]; then
				return 1
			fi
		done
	fi

	#
	# K2HDKC DBaaS slave
	#
	if [ "${_DBAAS_K8S_CLUSTER_TMP_TYPE_SLAVE}" -eq 1 ]; then
		_DBAAS_K8S_CERT_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
		while [ "${_DBAAS_K8S_CERT_TMP_LOOP_CNT}" -gt 0 ]; do
			_DBAAS_K8S_CERT_TMP_LOOP_CNT=$((_DBAAS_K8S_CERT_TMP_LOOP_CNT - 1))
			_DBAAS_K8S_CERT_TMP_HOST_NUM=${_DBAAS_K8S_CERT_TMP_LOOP_CNT}

			_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_CERT_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"

			if [ ! -f "${_DBAAS_K8S_CERT_TMP_SERVER_CERT_FILE}" ] || [ ! -f "${_DBAAS_K8S_CERT_TMP_CLIENT_CERT_FILE}" ]; then
				return 1
			fi
		done
	fi

	return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
