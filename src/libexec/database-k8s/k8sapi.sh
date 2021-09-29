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

#==============================================================
# Functions for Kubernetes
#==============================================================
#
# Get NodePort Service Port number
#
# $1		: nodeport name
# $?		: result(0/1)
# 
get_k8s_one_nodeport_port_number()
{
	_DBAAS_K8S_TMP_NODEPORT_NAME=$1

	if [ -z "${_DBAAS_K8S_TMP_NODEPORT_NAME}" ]; then
		prn_err "NodePort name is empty."
		pecho -n ""
		return 1
	fi

	_DBAAS_K8S_TMP_NODEPORT_PORTNUM=$("${KUBECTL_BIN}" get services "${_DBAAS_K8S_TMP_NODEPORT_NAME}" 2>/dev/null | grep "${_DBAAS_K8S_TMP_NODEPORT_NAME}" | awk '{print $5}' | sed -e 's/:/ /g' -e 's#/# #g' | awk '{print $2}')
	if [ $? -ne 0 ] || [ -z "${_DBAAS_K8S_TMP_NODEPORT_PORTNUM}" ]; then
		prn_err "Could not get NodePort port number."
		pecho -n ""
		return 1
	fi
	prn_dbg "(get_k8s_one_nodeport_port_number) Got NodePort number = \"${_DBAAS_K8S_TMP_NODEPORT_PORTNUM}\""

	pecho -n "${_DBAAS_K8S_TMP_NODEPORT_PORTNUM}"

	return 0
}

#--------------------------------------------------------------
# Get NodePort Service Cluster IP
#
# $1		: nodeport name
# $?		: result(0/1)
# 
get_k8s_one_nodeport_cluster_ip()
{
	_DBAAS_K8S_TMP_NODEPORT_NAME=$1

	if [ -z "${_DBAAS_K8S_TMP_NODEPORT_NAME}" ]; then
		prn_err "NodePort name is empty."
		pecho -n ""
		return 1
	fi

	#
	# Check NodePort exist
	#
	"${KUBECTL_BIN}" get services "${_DBAAS_K8S_TMP_NODEPORT_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "${_DBAAS_K8S_TMP_NODEPORT_NAME} NordPord service on kubernetes cluster is not existed."
		pecho -n ""
		return 1
	fi

	#
	# Get Cluster IP address
	#
	_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP=$("${KUBECTL_BIN}" describe services "${_DBAAS_K8S_TMP_NODEPORT_NAME}" 2>/dev/null | grep '^IP:' | awk '{print $2}')
	if [ $? -ne 0 ] || [ -z "${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}" ]; then
		prn_err "Could not get NodePort Cluster IP."
		pecho -n ""
		return 1
	fi
	prn_dbg "(get_k8s_one_nodeport_cluster_ip) Got Cluster IP = \"${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}\""

	pecho -n "${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}"

	return 0
}

#--------------------------------------------------------------
# Get NodePort ClusterIP for K2HR3 API/APP
#
# $1		: A flag that indicates the type of K2HR3 API(0) or K2HR3 APP(1).
# $2		: name
#
# Output	: NodePort Cluster IP
# $?		: result(0/1)
# 
get_k2hr3_nodeport_cluster_ip()
{
	if [ "X$1" = "X1" ]; then
		_DBAAS_K8S_TMP_NODEPORT_NAME="${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}$2"
	else
		_DBAAS_K8S_TMP_NODEPORT_NAME="${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}$2"
	fi

	_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP=$(get_k8s_one_nodeport_cluster_ip "${_DBAAS_K8S_TMP_NODEPORT_NAME}")
	if [ $? -ne 0 ] || [ "X${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}" = "X" ]; then
		prn_err "Could not get IP address for ${_DBAAS_K8S_TMP_NODEPORT_NAME} NordPord service Cluster IP."
		pecho -n ""
		return 1
	fi
	prn_dbg "(get_k2hr3_nodeport_cluster_ip) Got NodePort Cluster IP = \"${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}\""

	pecho -n "${_DBAAS_K8S_TMP_NODEPORT_CLUSTERIP}"
	return 0
}

#--------------------------------------------------------------
# Create NodePort service yaml file
#
# $1		: template yaml file
# $2		: output yaml file
# $3		: nodeport service base name
# $4		: port number(allow empty)
# $5		: type: k2hr3 api(0) / k2hr3 app(1)
# $?		: result(0/1)
# 
create_k8s_one_nodeport()
{
	_DBAAS_K8S_TMP_NODEPORT_TEMPL_FILE=$1
	_DBAAS_K8S_TMP_NODEPORT_YAML_FILE=$2
	_DBAAS_K8S_TMP_NODEPORT_NAMEBASE=$3
	_DBAAS_K8S_TMP_NODEPORT_PORT=$4
	if [ "X$5" = "X1" ]; then
		_DBAAS_K8S_TMP_NODEPORT_TYPE_APP=1
	else
		_DBAAS_K8S_TMP_NODEPORT_TYPE_APP=0
	fi

	if [ ! -f "${_DBAAS_K8S_TMP_NODEPORT_TEMPL_FILE}" ]; then
		prn_err "${_DBAAS_K8S_TMP_NODEPORT_TEMPL_FILE} is not existed."
		return 1
	fi
	if [ -z "${_DBAAS_K8S_TMP_NODEPORT_NAMEBASE}" ]; then
		prn_err "NodePort name is empty."
		return 1
	fi
	if [ -z "${_DBAAS_K8S_TMP_NODEPORT_PORT}" ]; then
		# for debug message
		_DBAAS_K8S_DBG_NODEPORT_PORT="auto"

		_DBAAS_K8S_DBG_NODEPORT_PORT=""
	else
		# for debug message
		_DBAAS_K8S_TMP_NODEPORT_PORT=${_DBAAS_K8S_TMP_NODEPORT_PORT}

		_DBAAS_K8S_TMP_NODEPORT_PORT="      nodePort: ${_DBAAS_K8S_TMP_NODEPORT_PORT}"
	fi

	if [ ${_DBAAS_K8S_TMP_NODEPORT_TYPE_APP} -eq 1 ]; then
		sed	-e "s#%%K2HR3_APP_NAMEBASE%%#${_DBAAS_K8S_TMP_NODEPORT_NAMEBASE}#g"	\
			-e "s#%%K2HR3_APP_NODEPORT_STR%%#${_DBAAS_K8S_TMP_NODEPORT_PORT}#g"	\
			"${_DBAAS_K8S_TMP_NODEPORT_TEMPL_FILE}" > "${_DBAAS_K8S_TMP_NODEPORT_YAML_FILE}"

		# for debug message
		_DBAAS_K8S_DBG_NODEPORT_NAMEFULL="${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${_DBAAS_K8S_TMP_NODEPORT_NAMEBASE}"
	else
		sed	-e "s#%%K2HR3_API_NAMEBASE%%#${_DBAAS_K8S_TMP_NODEPORT_NAMEBASE}#g"	\
			-e "s#%%K2HR3_API_NODEPORT_STR%%#${_DBAAS_K8S_TMP_NODEPORT_PORT}#g"	\
			"${_DBAAS_K8S_TMP_NODEPORT_TEMPL_FILE}" > "${_DBAAS_K8S_TMP_NODEPORT_YAML_FILE}"

		# for debug message
		_DBAAS_K8S_DBG_NODEPORT_NAMEFULL="${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${_DBAAS_K8S_TMP_NODEPORT_NAMEBASE}"
	fi

	if [ $? -ne 0 ]; then
		prn_err "Failed to create NodePort service yaml file(${_DBAAS_K8S_TMP_NODEPORT_YAML_FILE})."
		return 1
	fi
	prn_dbg "(create_k8s_one_nodeport) Succeed creating NodePort(name=\"${_DBAAS_K8S_DBG_NODEPORT_NAMEFULL}\", port=\"${_DBAAS_K8S_DBG_NODEPORT_PORT}\")"

	return 0
}


#--------------------------------------------------------------
# Create/Apply NodePort for K2HR3 API/APP
#
# $?		: result(0/1)
# 
create_k8s_k2hr3_nodeports()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	_DBAAS_K8S_TMP_R3API_NODEPORT_NAME="${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"
	"${KUBECTL_BIN}" get services "${_DBAAS_K8S_TMP_R3API_NODEPORT_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		#
		# Create NodePort for K2HR3 API
		#
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NP_YAML_TEMPL}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_R3API_NP_YAML_TEMPL}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_R3API_NP_YAML_TEMPL} file is not existed."
			return 1
		fi

		create_k8s_one_nodeport "${K2HR3CLI_DBAAS_K8S_R3API_NP_YAML_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_NP_YAML_FILE}" "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" "${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}" "0"
		if [ $? -ne 0 ]; then
			prn_err "Could not get K2HR3 API NodePort yaml template from configuration."
			return 1
		fi

		#
		# Try to apply
		#
		"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_NP_YAML_FILE}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_err "Could not create(apply) K2HR3 API NodePort."
			return 1
		fi
		prn_dbg "(create_k8s_k2hr3_nodeports) Created(applied) K2HR3 API NodePort(${_DBAAS_K8S_TMP_R3API_NODEPORT_NAME})."
	else
		prn_dbg "(create_k8s_k2hr3_nodeports) Already set K2HR3 API NodePort(${_DBAAS_K8S_TMP_R3API_NODEPORT_NAME})."
	fi

	_DBAAS_K8S_TMP_R3APP_NODEPORT_NAME="${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"
	"${KUBECTL_BIN}" get services "${_DBAAS_K8S_TMP_R3APP_NODEPORT_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		#
		# Create NodePort for K2HR3 APP
		#
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NP_YAML_TEMPL}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_R3APP_NP_YAML_TEMPL}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_R3APP_NP_YAML_TEMPL} file is not existed."
			return 1
		fi

		create_k8s_one_nodeport "${K2HR3CLI_DBAAS_K8S_R3APP_NP_YAML_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NP_YAML_FILE}" "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" "${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}" "1"
		if [ $? -ne 0 ]; then
			prn_err "Could not get K2HR3 APP NodePort yaml template from configuration."
			return 1
		fi

		#
		# Try to apply
		#
		"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NP_YAML_FILE}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_err "Could not create(apply) K2HR3 APP NodePort."
			return 1
		fi
		prn_dbg "(create_k8s_k2hr3_nodeports) Created(applied) K2HR3 APP NodePort(${_DBAAS_K8S_TMP_R3APP_NODEPORT_NAME})."
	else
		prn_dbg "(create_k8s_k2hr3_nodeports) Already set K2HR3 APP NodePort(${_DBAAS_K8S_TMP_R3APP_NODEPORT_NAME})."
	fi

	return 0
}

#--------------------------------------------------------------
# Create k2hr3-api-production.json
#
# $1		: NodePort port number
#
# Output	: production.json file path
# $?		: result(0/1)
# 
create_k2hr3_api_production_json_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi
	_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM=$1

	#
	# Check template json file(if it is not existed, create it)
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL}" ]; then
		prn_err "${K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL} or ${K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL} file is not existed."
		return 1
	fi

	#
	# Expand template variables
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}" ]; then
		prn_warn "No options related to OpenID Connect(OIDC) have been specified. You will not be able to log in via the K2HR3 APP."
	fi
	sed	-e "s#%%K2HR3_API_EXTERNAL_HOST%%#${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}#g"	\
		-e "s#%%K2HR3_API_NODE_PORT%%#${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}#g"		\
		-e "s#%%OIDC_ISSUER_URL%%#${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}#g"				\
		-e "s#%%OIDC_CLIENT_ID%%#${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}#g"				\
		-e "s#%%OIDC_USERNAME_KEY%%#${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}#g"			\
		-e "s#%%K8S_API_URL%%#${K2HR3CLI_DBAAS_K8S_K8S_API_URL}#g"						\
		-e "s#%%K8S_CA_CERT%%#${K2HR3CLI_DBAAS_K8S_K8S_CA_CERT}#g"						\
		-e "s#%%K8S_SA_TOKEN%%#${K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN}#g"					\
		"${K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL}"									\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE}."
		return 1
	fi
	prn_dbg "(create_k2hr3_api_production_json_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE}."

	return 0
}

#--------------------------------------------------------------
# Create k2hr3-app-production.json
#
# $1		: NodePort port number for K2HR3 APP
# $2		: NodePort port number for K2HR3 API
#
# Output	: production.json file path
# $?		: result(0/1)
# 
create_k2hr3_app_production_json_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi
	_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM=$1
	_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM=$2

	#
	# Check template json file(if it is not existed, create it)
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL}" ]; then
		prn_err "${K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL} or ${K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL} file is not existed."
		return 1
	fi

	#
	# Expand template variables
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}" ]; then
		prn_warn "No options related to OpenID Connect(OIDC) have been specified. You will not be able to log in via the K2HR3 APP."
	fi
	sed	-e "s#%%K2HR3_APP_EXTERNAL_HOST%%#${K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST}#g"	\
		-e "s#%%K2HR3_APP_NODE_PORT%%#${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}#g"		\
		-e "s#%%K2HR3_API_EXTERNAL_HOST%%#${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}#g"	\
		-e "s#%%K2HR3_API_NODE_PORT%%#${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}#g"		\
		-e "s#%%OIDC_ISSUER_URL%%#${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}#g"				\
		-e "s#%%OIDC_CLIENT_SECRET%%#${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}#g"		\
		-e "s#%%OIDC_CLIENT_ID%%#${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}#g"				\
		-e "s#%%OIDC_USERNAME_KEY%%#${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}#g"			\
		-e "s#%%OIDC_COOKIENAME%%#${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}#g"				\
		-e "s#%%OIDC_COOKIE_EXPIRE%%#${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}#g"		\
		"${K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL}"									\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE}."
		return 1
	fi
	prn_dbg "(create_k2hr3_app_production_json_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE}."

	return 0
}

#--------------------------------------------------------------
# Check local k2hr3-kustomization.yaml template
#
# $?		: result(0/1)
# 
create_k2hr3_kustomization_yaml_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check template yaml file(if it is not existed, create it)
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL}" ]; then
		prn_err "${K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL} or ${K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL} file is not existed."
		return 1
	fi

	#
	# Expand template variables
	#
	{
		sed -e 's/^#.*$//g' -e '/^$/d' "${K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL}"

		#
		# Secret
		#
		echo "secretGenerator:"

		#
		# Secret for CA certificate
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			#
			# Specify CA certificate
			#
			# shellcheck disable=SC2039
			echo "- name: ${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME}"
			echo "  files:"
			echo "    - ${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CA_CERT_UB_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
			echo "  type: Opaque"
		else
			#
			# Empty CA certificate
			#
			# shellcheck disable=SC2039
			echo "- name: ${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME}"
			echo "  type: Opaque"
		fi

		#
		# Each host certificates
		#
		_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY=0
		# shellcheck disable=SC2039
		echo "- name: ${K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME}"

		#
		# for k2hdkc
		#
		for _k2hdkc_num in $(seq "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}"); do
			if [ ${_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY} -eq 0 ]; then
				_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY=1
				echo "  files:"
			fi
			_k2hdkc_num=$((_k2hdkc_num - 1))
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-${_k2hdkc_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"
		done

		#
		# for k2hr3 api
		#
		for _api_num in $(seq "${K2HR3CLI_DBAAS_K8S_R3API_REPS}"); do
			if [ ${_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY} -eq 0 ]; then
				_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY=1
				echo "  files:"
			fi
			_api_num=$((_api_num - 1))
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
			echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-${_api_num}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"
		done

		#
		# for k2hr3 app
		#
		if [ ${_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY} -eq 0 ]; then
			_DBAAS_K8S_TMP_IS_OUTPUT_FILE_KEY=1
			echo "  files:"
		fi
		echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
		echo "    - ${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}=${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
		echo "  type: Opaque"

		#
		# End of Secret
		#
		echo "generatorOptions:"
		echo "  disableNameSuffixHash: true"

	} > "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML}"

	prn_dbg "(create_k2hr3_kustomization_yaml_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML}"

	#
	# Delete old file
	#
	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}" ]; then
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	fi

	#
	# Create symbolic link
	#
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	ln -s "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to make symbolic link to ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
		return 1
	fi
	prn_dbg "(create_k2hr3_kustomization_yaml_file) Created symbolic link ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"

	return 0
}

#--------------------------------------------------------------
# Create K2HDKC, K2HR3 API, and K2HR3 APP Pods yaml files
#
# $?		: result(0/1)
# 
create_all_k2hr3_pods_yaml_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check template json file(if it is not existed, create it)
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_POD_YAML_TEMPL}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_POD_YAML_TEMPL}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_POD_YAML_TEMPL}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3_SA_YAML_TEMPL}" ]; then
		prn_err "${K2HR3CLI_DBAAS_K8S_R3DKC_POD_YAML_TEMPL}, ${K2HR3CLI_DBAAS_K8S_R3API_POD_YAML_TEMPL}, ${K2HR3CLI_DBAAS_K8S_R3APP_POD_YAML_TEMPL}, or ${K2HR3CLI_DBAAS_K8S_R3_SA_YAML_TEMPL} file is not existed."
		return 1
	fi

	#
	# Expand k2hr3-k2hdkc.yaml template variables
	#
	sed	-e "s#%%CONFIGMAP_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT}#g"	\
		-e "s#%%SEC_CA_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CA_MOUNTPOINT}#g"			\
		-e "s#%%SEC_CERTS_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT}#g"	\
		-e "s#%%ANTPICKAX_ETC_DIR%%#${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}#g"	\
		-e "s#%%K2HDKC_REPLICAS%%#${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}#g"					\
		-e "s#%%K2HDKC_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}#g"					\
		-e "s#%%K2HR3_API_REPLICAS%%#${K2HR3CLI_DBAAS_K8S_R3API_REPS}#g"				\
		-e "s#%%K2HR3_API_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3API_NAME}#g"				\
		-e "s#%%K2HR3_DOMAIN%%#${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}#g"						\
		-e "s#%%OIDC_ISSUER_URL%%#${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}#g"				\
		-e "s#%%OIDC_CLIENT_ID%%#${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}#g"				\
		"${K2HR3CLI_DBAAS_K8S_R3DKC_POD_YAML_TEMPL}"									\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}."
		return 1
	fi
	prn_dbg "(create_all_k2hr3_pods_yaml_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}."

	#
	# Expand k2hr3-k2hapi.yaml template variables
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_SUSPEND}" = "X1" ]; then
		_DBAAS_K8S_TMP_MANUAL_START=1
	else
		_DBAAS_K8S_TMP_MANUAL_START=0
	fi
	sed	-e "s#%%CONFIGMAP_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT}#g"	\
		-e "s#%%SEC_CA_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CA_MOUNTPOINT}#g"			\
		-e "s#%%SEC_CERTS_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT}#g"	\
		-e "s#%%ANTPICKAX_ETC_DIR%%#${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}#g"	\
		-e "s#%%K2HDKC_REPLICAS%%#${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}#g"					\
		-e "s#%%K2HDKC_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}#g"					\
		-e "s#%%K2HR3_API_REPLICAS%%#${K2HR3CLI_DBAAS_K8S_R3API_REPS}#g"				\
		-e "s#%%K2HR3_API_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3API_NAME}#g"				\
		-e "s#%%K2HR3_DOMAIN%%#${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}#g"						\
		-e "s#%%K2HR3_MANUAL_START%%#${_DBAAS_K8S_TMP_MANUAL_START}#g"					\
		"${K2HR3CLI_DBAAS_K8S_R3API_POD_YAML_TEMPL}"									\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}."
		return 1
	fi
	prn_dbg "(create_all_k2hr3_pods_yaml_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}."

	#
	# Expand k2hr3-k2happ.yaml template variables
	#
	sed	-e "s#%%CONFIGMAP_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT}#g"	\
		-e "s#%%SEC_CA_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CA_MOUNTPOINT}#g"			\
		-e "s#%%SEC_CERTS_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT}#g"	\
		-e "s#%%ANTPICKAX_ETC_DIR%%#${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}#g"	\
		-e "s#%%K2HR3_APP_REPLICAS%%#${K2HR3CLI_DBAAS_K8S_R3APP_REPS}#g"				\
		-e "s#%%K2HR3_APP_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3APP_NAME}#g"				\
		-e "s#%%K2HR3_MANUAL_START%%#${_DBAAS_K8S_TMP_MANUAL_START}#g"					\
		"${K2HR3CLI_DBAAS_K8S_R3APP_POD_YAML_TEMPL}"									\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}."
		return 1
	fi
	prn_dbg "(create_all_k2hr3_pods_yaml_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}."

	#
	# Expand k2hr3-sa.yaml template variables
	#
	sed	-e "s#%%K8S_NAMESPACE%%#${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}#g"		\
		-e "s#%%K2HR3_API_NAMEBASE%%#${K2HR3CLI_DBAAS_K8S_R3API_NAME}#g"	\
		"${K2HR3CLI_DBAAS_K8S_R3_SA_YAML_TEMPL}"							\
		> "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}."
		return 1
	fi
	prn_dbg "(create_all_k2hr3_pods_yaml_file) Created ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}."

	return 0
}

#--------------------------------------------------------------
# Create configMap, Secret, K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA)
#
# $?		: result(0/1)
# 
create_all_k2hr3_pods_file()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Create configMap and Secret
	#
	"${KUBECTL_BIN}" apply -k "${_DBAAS_K8S_CLUSTER_DIRPATH}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to create configMap and Secert from kustomization.yaml."
		return 1
	fi
	prn_dbg "(create_all_k2hr3_pods_file) Created(Applied) configMap and Secert from ${_DBAAS_K8S_CLUSTER_DIRPATH}."

	#
	# Create ServiceAccount(SA)
	#
	"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to create ServiceAccount(SA) from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}."
		exit 1
	fi
	prn_dbg "(create_all_k2hr3_pods_file) Created(Applied) ServiceAccount(SA) from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}."

	#
	# Create K2HDKC servers
	#
	"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to create K2HDKC server from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}."
		exit 1
	fi
	prn_dbg "(create_all_k2hr3_pods_file) Created K2HDKC server from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}."
	sleep 10

	#
	# Create K2HR3 API Pod
	#
	"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to create K2HR3 API pods from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}."
		exit 1
	fi
	prn_dbg "(create_all_k2hr3_pods_file) Created K2HR3 API pods from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}."
	sleep 10

	#
	# Create K2HR3 APP Pod
	#
	"${KUBECTL_BIN}" apply -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to create K2HR3 APP pods from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}."
		exit 1
	fi
	prn_dbg "(create_all_k2hr3_pods_file) Created K2HR3 APP pods from ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}."
	sleep 10

	return 0
}

#--------------------------------------------------------------
# Run socat on minikube
#
# $?		: result(0/1)
# 
run_socat_on_minikube()
{
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" != "X1" ]; then
		#
		# Not minikube
		#
		return 0
	fi

	#
	# Check socat program
	#
	check_socat_program
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Get port number
	#
	_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}")
	if [ $? -ne 0 ]; then
		prn_err "Could not get port number K2HR3 API NodePort."
		return 1
	fi
	_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}")
	if [ $? -ne 0 ]; then
		prn_err "Could not get port number K2HR3 APP NodePort."
		return 1
	fi

	#
	# Run socat for K2HR3 API
	#
	"${SOCAT_BIN}" "TCP-LISTEN:${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM},fork" "TCP:${K2HR3CLI_DBAAS_K8S_R3API_EP}:${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}" >/dev/null 2>&1 &
	if [ $? -ne 0 ]; then
		prn_err "Failed to run ${SOCAT_BIN} for K2HR3 API."
		return 1
	fi
	_DBAAS_K8S_TMP_R3API_SOCAT_PID=$!
	prn_dbg "(run_socat_on_minikube) Stared to run ${SOCAT_BIN} process(PID=${_DBAAS_K8S_TMP_R3API_SOCAT_PID}) for K2HR3 API proxy : IN:\"${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}\" -> TO:\"${K2HR3CLI_DBAAS_K8S_R3API_EP}:${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}\"."

	#
	# Run socat for K2HR3 APP
	#
	"${SOCAT_BIN}" "TCP-LISTEN:${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM},fork" "TCP:${K2HR3CLI_DBAAS_K8S_R3APP_EP}:${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}" >/dev/null 2>&1 &
	if [ $? -ne 0 ]; then
		prn_err "Failed to run ${SOCAT_BIN} for K2HR3 APP."
		return 1
	fi
	_DBAAS_K8S_TMP_R3APP_SOCAT_PID=$!
	prn_dbg "(run_socat_on_minikube) Stared to run ${SOCAT_BIN} process(PID=${_DBAAS_K8S_TMP_R3APP_SOCAT_PID}) for K2HR3 APP proxy : IN:\"${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}\" -> TO:\"${K2HR3CLI_DBAAS_K8S_R3APP_EP}:${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}\"."

	return 0
}

#--------------------------------------------------------------
# Output K2HR3 system overview
#
# $?		: result(0/1)
# 
print_k2hr3_system_overview()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
		prn_err "Some K2HDKC, K2HR3 API, and K2HR3 APP names are not set."
		return 1
	fi

	#
	# Get Cluster IP/Port number
	#
	_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}")
	_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}")
	if [ -z "${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}" ] || [ -z "${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}" ]; then
		prn_err "Could not get K2HR3 API/APP NodePorts Cluster IP"
		return 1
	fi

	#
	# Print overview
	#
	_DBAAS_K8S_TMP_R3API_MAX_HOSTNUM=$((K2HR3CLI_DBAAS_K8S_R3API_REPS - 1))
	_DBAAS_K8S_TMP_R3API_NP_CLUSTERIP=$(get_k2hr3_nodeport_cluster_ip "0" "${K2HR3CLI_DBAAS_K8S_R3API_NAME}")
	_DBAAS_K8S_TMP_R3APP_NP_CLUSTERIP=$(get_k2hr3_nodeport_cluster_ip "1" "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}")

	prn_msg ""
	prn_msg "[K2HDKC DBaaS K8S : K2HR3 APP/API information]"
	prn_msg ""
	prn_msg "* CA certificate file"
	prn_msg "    ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
	prn_msg ""
	prn_msg "* K2HR3 API URL"
	prn_msg "    Pods:       https://${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-[0-${_DBAAS_K8S_TMP_R3API_MAX_HOSTNUM}].${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}:443"
	prn_msg "    Pods(RR):   https://${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}:443"
	prn_msg "    Cluster:    https://${_DBAAS_K8S_TMP_R3API_NP_CLUSTERIP}:8443"
	prn_msg "    Endpoint:   https://${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}:${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}"
	prn_msg ""
	prn_msg "* K2HR3 APP URL"
	prn_msg "    Cluster:    https://${_DBAAS_K8S_TMP_R3APP_NP_CLUSTERIP}:8443"
	prn_msg "    Endpoint:   https://${K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST}:${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}"
	prn_msg ""

	return 0
}

#--------------------------------------------------------------
# Create/Apply K2HR3 system
#
# $?		: result(0/1)
# 
create_k2hr3_system()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		#
		# There is not base directory, then try to create it here.
		#
		_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory "1")
		if [ $? -ne 0 ]; then
			return 1
		fi

		#
		# After creating, need to load configuration(if not exist, create the configuration file)
		#
		load_dbaas_k8s_k2hr3_configuration
		if [ $? -ne 0 ]; then
			prn_err "Failed to load the configuration for K2HR3 system"
			return 1
		fi
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
		prn_err "Some K2HDKC, K2HR3 API, and K2HR3 APP names are not set."
		return 1
	fi

	#
	# (1) Check and Create(Apply) nodeport, and get Cluster IP/Port number
	#
	create_k8s_k2hr3_nodeports
	if [ $? -ne 0 ]; then
		prn_err "Could not create K2HR3 API/APP NodePorts"
		return 1
	fi

	_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}")
	_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM=$(get_k8s_one_nodeport_port_number "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}")
	if [ -z "${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}" ] || [ -z "${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}" ]; then
		prn_err "Could not get K2HR3 API/APP NodePorts Cluster IP"
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : K2HR3 API/APP NodePorts(Cluster IP)."

	#
	# (2) Check certificates
	#
	check_dbaas_k8s_all_domain_certificates
	if [ $? -ne 0 ]; then
		prn_dbg "(create_k2hr3_system) Some certificates are not existed."

		check_dbaas_k8s_domain_ca_ertification
		if [ $? -ne 0 ]; then
			#
			# Create all certificates because CA certificate is not safe
			#
			prn_dbg "(create_k2hr3_system) Try to create all certificates with CA certificate."

			# shellcheck disable=SC2034
			K2HR3CLI_DBAAS_K8S_CERT_TYPE=${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}
			create_dbaas_k8s_domain_certificates
			if [ $? -ne 0 ]; then
				prn_err "Failed to create all certificates"
				return 1
			fi
			prn_dbg "(create_k2hr3_system) Created all certificates with CA certificate."
		else
			#
			# Create all certificates without CA certificate
			#
			prn_dbg "(create_k2hr3_system) Try to create all certificates without CA certificate."

			# shellcheck disable=SC2034
			K2HR3CLI_DBAAS_K8S_CERT_TYPE=${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}
			create_dbaas_k8s_domain_certificates
			if [ $? -ne 0 ]; then
				prn_err "Failed to create K2HDKC certificates"
				return 1
			fi

			# shellcheck disable=SC2034
			K2HR3CLI_DBAAS_K8S_CERT_TYPE=${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}
			create_dbaas_k8s_domain_certificates
			if [ $? -ne 0 ]; then
				prn_err "Failed to create K2HR3 API certificates"
				return 1
			fi

			# shellcheck disable=SC2034
			K2HR3CLI_DBAAS_K8S_CERT_TYPE=${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}
			create_dbaas_k8s_domain_certificates
			if [ $? -ne 0 ]; then
				prn_err "Failed to create K2HR3 APP certificates"
				return 1
			fi
			prn_dbg "(create_k2hr3_system) Created all certificates without CA certificate."
		fi
	fi
	prn_msg "${CGRN}Checked${CDEF} : All certificates."

	#
	# (3) Create H2HR3 API/APP production.json
	#
	create_k2hr3_api_production_json_file "${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}"
	if [ $? -ne 0 ]; then
		prn_err "Could not create K2HR3 API prpduction json file."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The prpduction json file for K2HR3 API."

	create_k2hr3_app_production_json_file "${_DBAAS_K8S_TMP_R3APP_NODEPORT_PORTNUM}" "${_DBAAS_K8S_TMP_R3API_NODEPORT_PORTNUM}"
	if [ $? -ne 0 ]; then
		prn_err "Could not create K2HR3 APP prpduction json file."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The prpduction json file for K2HR3 APP."

	#
	# (4) Create kustomization.yaml
	#
	create_k2hr3_kustomization_yaml_file
	if [ $? -ne 0 ]; then
		prn_err "Failed to make kustomization.yaml."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The ${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML} for K2HR3 system."

	#
	# (5) Create K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA)
	#
	create_all_k2hr3_pods_yaml_file
	if [ $? -ne 0 ]; then
		prn_err "Failed to make K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA)."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The yaml files for K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA)."

	#
	# (6) Create All Pods and configMap and Secret
	#
	create_all_k2hr3_pods_file
	if [ $? -ne 0 ]; then
		prn_err "Failed to create K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA)."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : All Pods, configMap, Secret, and ServiceAccount(SA) for K2HR3 system."

	#
	# (7) Run socat if run on minikube
	#
	run_socat_on_minikube
	if [ $? -ne 0 ]; then
		prn_err "Something error occurred."
		return 1
	fi
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" != "X1" ]; then
		prn_msg "${CGRN}Run${CDEF} : ${SOCAT_BIN} for proxy K2HR3 APP/API."
	fi

	#
	# (8) Print information
	#
	prn_msg "${CGRN}K2HR3 system Information${CDEF}"
	print_k2hr3_system_overview
	if [ $? -ne 0 ]; then
		prn_err "Something error occurred during printing overview."
		return 1
	fi

	#
	# (9) Save variables to configuration file
	#
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3DKC_NAME' "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3DKC_NAME) and the value(${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_NAME' "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3API_NAME) and the value(${K2HR3CLI_DBAAS_K8S_R3API_NAME}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_NAME' "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3APP_NAME) and the value(${K2HR3CLI_DBAAS_K8S_R3APP_NAME}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3DKC_REPS' "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3DKC_REPS) and the value(${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_REPS' "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3API_REPS) and the value(${K2HR3CLI_DBAAS_K8S_R3API_REPS}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_REPS' "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3APP_REPS) and the value(${K2HR3CLI_DBAAS_K8S_R3APP_REPS}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "X1" ] && [ "X${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}" != "X" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_EP' "${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}"
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3API_EP) and the value(${K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
			return 1
		fi
	else
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_EP' "${K2HR3CLI_DBAAS_K8S_R3API_EP}"
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3API_EP) and the value(${K2HR3CLI_DBAAS_K8S_R3API_EP}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
			return 1
		fi
	fi
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "X1" ] && [ "X${K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST}" != "X" ]; then
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_EP' "${K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST}" 
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3APP_EP) and the value(${K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
			return 1
		fi
	else
		save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_EP' "${K2HR3CLI_DBAAS_K8S_R3APP_EP}" 
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3APP_EP) and the value(${K2HR3CLI_DBAAS_K8S_R3APP_EP}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
			return 1
		fi
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3API_NPNUM' "${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3API_NPNUM) and the value(${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_R3APP_NPNUM' "${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_R3APP_NPNUM) and the value(${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_NODE_IPS' "${K2HR3CLI_DBAAS_K8S_NODE_IPS}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_NODE_IPS) and the value(${K2HR3CLI_DBAAS_K8S_NODE_IPS}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_C' "${K2HR3CLI_DBAAS_K8S_CERT_C}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_CERT_C) and the value(${K2HR3CLI_DBAAS_K8S_CERT_C}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_S' "${K2HR3CLI_DBAAS_K8S_CERT_S}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_CERT_S) and the value(${K2HR3CLI_DBAAS_K8S_CERT_S}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_O' "${K2HR3CLI_DBAAS_K8S_CERT_O}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_CERT_O) and the value(${K2HR3CLI_DBAAS_K8S_CERT_O}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE' "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_CERT_EXPIRE) and the value(${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET' "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID' "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL' "${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY' "${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME' "${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi
	save_dbaas_k8s_k2hr3_configuration 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE' "${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}" 
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the key(K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE) and the value(${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}) the K2HR3 system configuration for K2HDKC DBaaS K8S(${K2HR3CLI_DBAAS_K8S_DOMAIN})."
		return 1
	fi

	prn_msg "${CGRN}Saved${CDEF} : The information for K2HR3 system to the configuration file(${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME})"

	return 0
}

#--------------------------------------------------------------
# Print all kubernetes resource for K2HR3 system
#
# $?		: result(0/1)
# 
print_k2hr3_k8s_resource_overview()
{
	pecho "-----------------------------------------------------------"
	pecho " PODs"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get pods 2>/dev/null | grep -e 'NAME'										\
		-e "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"				\
		-e "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"				\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"				\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"				\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " Services"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get services 2>/dev/null | grep -e 'NAME'									\
		-e "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"				\
		-e "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " Deployments"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get deployments 2>/dev/null | grep -e 'NAME'	\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " StatefulSets"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get statefulset 2>/dev/null | grep -e 'NAME'					\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " Secrets"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get secrets 2>/dev/null | grep -e 'NAME'		\
		-e "${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME}"					\
		-e "${K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME}"					\

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " ConfigMaps"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get configmaps 2>/dev/null | grep -e 'NAME'	\
		-e "${K2HR3CLI_DBAAS_K8S_CONFIGMAP_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " ServiceAccount"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get serviceaccount 2>/dev/null | grep -e 'NAME'							\
		-e "${K2HR3CLI_DBAAS_K8S_SERVICE_ACCOUNT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"		\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLEBINDING_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLE_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}"

	pecho ""

	return 0
}

#--------------------------------------------------------------
# Stop socat on minikube
#
# $?		: result(0/1)
# 
stop_socat_on_minikube()
{
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" != "X1" ]; then
		#
		# Not minikube
		#
		return 0
	fi

	#
	# Stop socat on this host
	#
	# [NOTE]
	# Since the startup is not linked, find the target socat and stop it.
	#
	_DBAAS_K8S_TMP_SOCAT_PROCS=$(pgrep -f "${SOCAT_BIN}")
	if [ "X${_DBAAS_K8S_TMP_SOCAT_PROCS}" != "X" ]; then
		kill -HUP "${_DBAAS_K8S_TMP_SOCAT_PROCS}"
		prn_dbg "(stop_socat_on_minikube) Stopped ${SOCAT_BIN} processes(PID: ${_DBAAS_K8S_TMP_SOCAT_PROCS})."
	else
		prn_dbg "(stop_socat_on_minikube) Any ${SOCAT_BIN} is running on this host."
	fi
	return 0
}

#--------------------------------------------------------------
# Delete K2HR3 system
#
# $?		: result(0/1)
# 
delete_k2hr3_system()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
		prn_err "Some K2HDKC, K2HR3 API, and K2HR3 APP names are not set."
		return 1
	fi

	#
	# If minikube and socat is running, stop it
	#
	stop_socat_on_minikube
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ "X${K2HR3CLI_DBAAS_K8S_MINIKUBE}" != "X1" ]; then
		prn_msg "${CGRN}Stopped${CDEF} : ${SOCAT_BIN} for proxy K2HR3 APP/API."
	fi

	#
	# Delete NodePort for K2HR3 APP
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 APP NodePort Service(${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HR3 APP NodePort Service(${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
	fi

	#
	# Delete NodePort for K2HR3 API
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 API NodePort Service(${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HR3 API NodePort Service(${K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	#
	# Delete Deployment for K2HR3 APP
	#
	"${KUBECTL_BIN}" delete deployments "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 APP Deployment Service(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HR3 APP Deployment Service(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
	fi

	#
	# Delete Service for K2HR3 API
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 API Service(${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HR3 API Service(${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	#
	# Delete StatefulSet for K2HR3 API
	#
	"${KUBECTL_BIN}" delete statefulset "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 API StatefulSet(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HR3 API StatefusSet(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	#
	# Delete Service for K2HDKC
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HDKC Service(${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HDKC Service(${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
	fi

	#
	# Delete StatefulSet for K2HDKC
	#
	"${KUBECTL_BIN}" delete statefulset "${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HDKC StatefulSet(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
	else
		prn_msg "${CGRN}Stopped${CDEF} : K2HDKC StatefusSet(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
	fi

	#
	# Delete Pods for K2HR3 APP
	#
	_DBAAS_K8S_TMP_PODS_LIST=$("${KUBECTL_BIN}" get pods 2>/dev/null | grep "^${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" | awk '{print $1}')
	for _pod_name in ${_DBAAS_K8S_TMP_PODS_LIST}; do
		"${KUBECTL_BIN}" delete pods "${_pod_name}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 APP Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
		else
			prn_msg "${CGRN}Stopped${CDEF} : K2HR3 APP Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME})"
		fi
	done

	#
	# Delete Pods for K2HR3 API
	#
	_DBAAS_K8S_TMP_PODS_LIST=$("${KUBECTL_BIN}" get pods 2>/dev/null | grep "^${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" | awk '{print $1}')
	for _pod_name in ${_DBAAS_K8S_TMP_PODS_LIST}; do
		"${KUBECTL_BIN}" delete pods "${_pod_name}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HR3 API Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
		else
			prn_msg "${CGRN}Stopped${CDEF} : K2HR3 API Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
		fi
	done

	#
	# Delete Pods for K2HDKC
	#
	_DBAAS_K8S_TMP_PODS_LIST=$("${KUBECTL_BIN}" get pods 2>/dev/null | grep "^${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" | awk '{print $1}')
	for _pod_name in ${_DBAAS_K8S_TMP_PODS_LIST}; do
		"${KUBECTL_BIN}" delete pods "${_pod_name}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_msg "${CGRN}Failed${CDEF} : Could not stop K2HDKC Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
		else
			prn_msg "${CGRN}Stopped${CDEF} : K2HDKC Pod(${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME})"
		fi
	done

	#
	# Delete Secrets
	#
	"${KUBECTL_BIN}" delete secrets "${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove Secret CA(${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : Secret CA(${K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME})"
	fi

	"${KUBECTL_BIN}" delete secrets "${K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove Secret Certs(${K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : Secret Certs(${K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME})"
	fi

	#
	# Delete configMap
	#
	"${KUBECTL_BIN}" delete configmaps "${K2HR3CLI_DBAAS_K8S_CONFIGMAP_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove configMap(${K2HR3CLI_DBAAS_K8S_CONFIGMAP_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : configMap(${K2HR3CLI_DBAAS_K8S_CONFIGMAP_NAME})"
	fi

	#
	# Delete ServiceAccount etc
	#
	"${KUBECTL_BIN}" delete serviceaccount "${K2HR3CLI_DBAAS_K8S_SERVICE_ACCOUNT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove ServiceAccount for K2HR3 API(${K2HR3CLI_DBAAS_K8S_SERVICE_ACCOUNT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : ServiceAccount for K2HR3 API(${K2HR3CLI_DBAAS_K8S_SERVICE_ACCOUNT_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	"${KUBECTL_BIN}" delete clusterrolebinding "${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLEBINDING_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove Cluster Rolebinding for K2HR3 API(${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLEBINDING_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : Cluster Rolebinding for K2HR3 API(${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLEBINDING_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	"${KUBECTL_BIN}" delete clusterrole "${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLE_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not remove Cluster Role for K2HR3 API(${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLE_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : Cluster Role for K2HR3 API(${K2HR3CLI_DBAAS_K8S_CLUSTER_ROLE_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME})"
	fi

	#
	# Delete files(without certificates)
	#
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_NP_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_NP_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_FILE}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_FILE_TEMPL}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}"

	#
	# Delete all certificates
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_RM_CERTS}" = "X1" ]; then
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME}"
		rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_INDEX_BASE_FILENAME}"
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
	fi
	prn_msg "${CGRN}Removed${CDEF} : Files related to K2HR3 systems"

	return 0
}

#--------------------------------------------------------------
# Get K2HR3 Role Token for K2HDKC Cluster
#
# $?		: result(0/1)
#
# Output Variables:
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_TOKEN
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_TOKEN
# 
get_k2hdkc_role_tokens()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Get current K2HDKC cluster directory path and configuration file path
	#
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		#
		# cluster configuration file is not existed
		#
		prn_err "The configuration file for the \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" is not existed."
		return 1
	fi

	#
	# Server Role Token
	#
	_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT=$(									\
		K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
		K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
		K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
		K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
		K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
		K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
		K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
		K2HR3CLI_OPT_INTERACTIVE=0											\
		"${K2HR3CLIBIN}" role token create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server" --expire "0")

	if [ $? -ne 0 ] || [ -z "${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}" ]; then
		prn_err "Failed getting the K2HR3 Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."
		return 1
	fi
	prn_dbg "(get_k2hdkc_role_tokens) Got the K2HR3 Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "Failed to parse Role Token from result(${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}) for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" role."
		return 1
	fi
	jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ] || [ -z "${JSONPARSER_FIND_STR_VAL}" ]; then
		prn_dbg "Failed to Role Token result(${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}) for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" role is wrong format."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_TOKEN=${JSONPARSER_FIND_STR_VAL}
	prn_dbg "(get_k2hdkc_role_tokens) Succeed parsed the server K2HR3 Role Token string(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_TOKEN}\") from K2HR3 API result."

	#
	# Slave Role Token
	#
	_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT=$(									\
		K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
		K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
		K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
		K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
		K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
		K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
		K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
		K2HR3CLI_OPT_INTERACTIVE=0											\
		"${K2HR3CLIBIN}" role token create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave" --expire "0")

	if [ $? -ne 0 ] || [ -z "${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}" ]; then
		prn_err "Failed getting K2HR3 Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."
		return 1
	fi
	prn_dbg "(get_k2hdkc_role_tokens) Got the K2HR3 Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."

	#
	# Parse Result
	#
	jsonparser_parse_json_string "${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}"
	if [ $? -ne 0 ]; then
		prn_dbg "Failed to parse Role Token from result(${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}) for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" role."
		return 1
	fi
	jsonparser_get_key_value '%"token"%' "${JP_PAERSED_FILE}"
	if [ $? -ne 0 ] || [ -z "${JSONPARSER_FIND_STR_VAL}" ]; then
		prn_dbg "Failed to Role Token result(${_DBAAS_K8S_TMP_K2HDKC_TOKEN_RESULT}) for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" role is wrong format."
		rm -f "${JP_PAERSED_FILE}"
		return 1
	fi
	rm -f "${JP_PAERSED_FILE}"

	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_TOKEN=${JSONPARSER_FIND_STR_VAL}
	prn_dbg "(get_k2hdkc_role_tokens) Succeed parsed the slave K2HR3 Role Token string(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_TOKEN}\") from K2HR3 API result."

	#
	# Save Role Tokens to files
	#
	pecho -n "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_TOKEN}" > "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SVR_TOKEN_FILENAME}"
	pecho -n "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_TOKEN}" > "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SLV_TOKEN_FILENAME}"

	prn_dbg "(get_k2hdkc_role_tokens) Succeed creating the K2HR3 Role Token files for server/slave."

	return 0
}

#--------------------------------------------------------------
# Setup K2HR3 resources/policies/roles for K2HDKC Cluster
#
# $?		: result(0/1)
# 
setup_k2hdkc_k2hr3_data()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Check and Get Scoped Token for this kubernetes namespace
	#
	# [NOTE]
	# K2HR3CLI_SCOPED_TOKEN is cleared and recreated.
	# The CURL_CA_BUNDLE environment variable is specified if a self-signed CA certificate for the K2HR3 API exists.
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_EP}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}" ]; then
		prn_err "The EndPoint of the K2HR3 API server for this \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" is unknown."
		return 1
	fi
	K2HR3CLI_SCOPED_TOKEN=""
	K2HR3CLI_API_URI="https://${K2HR3CLI_DBAAS_K8S_R3API_EP}:${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}"
	# shellcheck disable=SC2034
	K2HR3CLI_TENANT=${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}

	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		export CURL_CA_BUNDLE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
	fi

	#
	# Check K2HR3 unscoped token
	#
	complement_dbaas_k2hr3_unscoped_token
	# shellcheck disable=SC2153
	if [ $? -ne 0 ] || [ -z "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
		prn_err "Use the K2HR3 system for \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" kubernetes cluster to execute this command. However, no scoped token for \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\" namespace(tenant) was created to operate the K2HR3 system."
		return 1
	fi
	prn_dbg "(setup_k2hdkc_k2hr3_data) Setup unscoped Token(\"${K2HR3CLI_UNSCOPED_TOKEN}\")"

	#
	# Check K2HR3 Scoped token
	#
	complement_scoped_token
	if [ $? -ne 0 ]; then
		prn_err "Use the K2HR3 system for \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" kubernetes cluster to execute this command. However, no scoped token for \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\" namespace(tenant) was created to operate the K2HR3 system."
		return 1
	fi
	prn_dbg "(setup_k2hdkc_k2hr3_data) Got scoped Token(\"${K2HR3CLI_SCOPED_TOKEN}\")"

	#-----------------------------------------------------------
	# (1) Check / Create / Load K2HDKC cluster configuration
	#-----------------------------------------------------------
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		#
		# Already cluster existed
		#
		prn_err "The \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster already exists, or the files used in the work remain. Clean up with the \"${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}\" command, and then re-execute."
		return 1
	fi

	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" "1"
	if [ $? -ne 0 ]; then
		prn_err "Failed initializing \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster configuration."
		return 1
	fi
	prn_dbg "(setup_k2hdkc_k2hr3_data) Succeed loading the configuration for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HKDC Cluster."

	#-----------------------------------------------------------
	# (2) Create k2hdkc.ini template file
	#-----------------------------------------------------------
	# [NOTE]
	# In the current version, SSL(TSL) is always used.
	#
	_DBAAS_K8S_TMP_K2HDKC_INI_SSL="SSL             = on"
	_DBAAS_K8S_TMP_K2HDKC_INI_CAPATH="CAPATH          = ${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}/ca.crt"
	_DBAAS_K8S_TMP_K2HDKC_INI_SSL_VERIFY_PEER="SSL_VERIFY_PEER = on"
	_DBAAS_K8S_TMP_K2HDKC_INI_SERVER_CERT="SERVER_CERT     = ${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}/server.crt"
	_DBAAS_K8S_TMP_K2HDKC_INI_SERVER_PRIKEY="SERVER_PRIKEY   = ${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}/server.key"
	_DBAAS_K8S_TMP_K2HDKC_INI_SLAVE_CERT="SLAVE_CERT      = ${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}/client.crt"
	_DBAAS_K8S_TMP_K2HDKC_INI_SLAVE_PRIKEY="SLAVE_PRIKEY    = ${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}/client.key"

	_DBAAS_K8S_TMP_K2HDKC_INI_SSL_SETTING="${_DBAAS_K8S_TMP_K2HDKC_INI_SSL}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_CAPATH}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_SSL_VERIFY_PEER}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_SERVER_CERT}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_SERVER_PRIKEY}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_SLAVE_CERT}\\n${_DBAAS_K8S_TMP_K2HDKC_INI_SLAVE_PRIKEY}"

	sed	-e "s#%%K2HR3_TENANT_NAME%%#${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}#g"			\
		-e "s#%%K2HDKC_DBAAS_CLUSTER_NAME%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}#g"	\
		-e "s#%%CHMPX_SSL_SETTING%%#${_DBAAS_K8S_TMP_K2HDKC_INI_SSL_SETTING}#g"		\
		"${K2HR3CLI_DBAAS_K8S_K2HDKC_INI_TEMPL}"									\
		> "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INI_FILE}"

	prn_msg "${CGRN}Created${CDEF} : The configuration template file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INI_FILE}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC Cluster"

	#-----------------------------------------------------------
	# (3) Set RESOURCE(main) to K2HR3
	#-----------------------------------------------------------
	# [NOTE]
	# Below is an example of KEYS to set:
	#		cluster-name			mycluster
	#		chmpx-server-port		8020
	#		chmpx-server-ctlport	8021
	#		chmpx-slave-ctlport		8022
	#
	_DBAAS_K8S_TMP_K2HDKC_RES_MAIN_KEYS="{\"cluster-name\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\",\"chmpx-server-port\":${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT},\"chmpx-server-ctlport\":${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT},\"chmpx-slave-ctlport\":${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}}"

	#
	# Run k2hr3
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" -type string --datafile "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INI_FILE}" --keys "${_DBAAS_K8S_TMP_K2HDKC_RES_MAIN_KEYS}" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (4) Set RESOURCE(server/slave) to K2HR3
	#-----------------------------------------------------------
	# [NOTE]
	# Below is an example of KEYS to set:
	#	for server resource:
	#		chmpx-mode		SERVER
	#	for slave resource:
	#		chmpx-mode		SLAVE
	#
	_DBAAS_K8S_TMP_K2HDKC_RES_SERVER_KEYS="{\"chmpx-mode\":\"SERVER\"}"
	_DBAAS_K8S_TMP_K2HDKC_RES_SLAVE_KEYS="{\"chmpx-mode\":\"SLAVE\"}"

	#
	# Run k2hr3 for server resource
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server" --keys "${_DBAAS_K8S_TMP_K2HDKC_RES_SERVER_KEYS}" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Run k2hr3 for slave resource
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave" --keys "${_DBAAS_K8S_TMP_K2HDKC_RES_SLAVE_KEYS}" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (4) Set POLICY to K2HR3
	#-----------------------------------------------------------
	#
	# Resource YRN path in POLICY
	#
	_DBAAS_K8S_TMP_K2HDKC_POL_RESVAL="[\"yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:resource:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\",\"yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:resource:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\"]"

	#
	# Run k2hr3
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" policy create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" --effect 'allow' --action 'yrn:yahoo::::action:read' --resource "${_DBAAS_K8S_TMP_K2HDKC_POL_RESVAL}" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Policy \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Policy \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (5) Set ROLE(main) to K2HR3
	#-----------------------------------------------------------
	#
	# Policies YRN path in ROLE
	#
	_DBAAS_K8S_TMP_K2HDKC_ROLE_POLVAL="yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:policy:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	#
	# Run k2hr3
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" --policies "${_DBAAS_K8S_TMP_K2HDKC_ROLE_POLVAL}" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (6) Set ROLE(server/slave) to K2HR3
	#-----------------------------------------------------------
	#
	# Run k2hr3 for server role
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Run k2hr3 for slave role
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role create "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed setup K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (7) Create and Setup ROLE Token(server/slave) to K2HR3
	#-----------------------------------------------------------
	#
	# Create Role Tokens
	#
	get_k2hdkc_role_tokens
	if [ $? -ne 0 ]; then
		prn_err "Failed setup Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Setup${CDEF} : The Role Token for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (8) Save variables to configuration file
	#-----------------------------------------------------------
	save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT'		"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}"
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Server port(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT})."
		return 1
	fi
	save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT'	"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}"
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Server control port(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT})."
		return 1
	fi
	save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT'	"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}"
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Slave control port(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT})."
		return 1
	fi
	prn_msg "${CGRN}Saved${CDEF} : The configuration(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	return 0
}

#--------------------------------------------------------------
# Create K2HDKC DBaaS Cluster
#
# $?		: result(0/1)
# 
create_k2hdkc_cluster()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#-----------------------------------------------------------
	# (1) Check / Create / Load K2HDKC cluster configuration
	#-----------------------------------------------------------
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		#
		# Cluster information dose not exist
		#
		prn_err "The \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster is not setup yet, you should setup up with the \"${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SETUP}\" command before this command."
		return 1
	fi

	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" "1"
	if [ $? -ne 0 ]; then
		prn_err "Failed initializing \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster configuration."
		return 1
	fi

	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SVR_TOKEN_FILENAME}" ] || [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_SLV_TOKEN_FILENAME}" ]; then
		prn_err "Server or Slave Role Token for K2HDKC Cluster(${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}) is not existed."
		return 1
	fi
	prn_dbg "(create_k2hdkc_cluster) Succeed loading the configuration for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HKDC Cluster."

	#-----------------------------------------------------------
	# (2) Create K2HDKC cluster server/slave certificates
	#-----------------------------------------------------------
	check_dbaas_k2hdkc_certificates "all"
	if [ $? -ne 0 ]; then
		#
		# Missing some certificate, thus create those
		#
		create_dbaas_k2hdkc_certificate_files "all" "0"
		if [ $? -ne 0 ]; then
			prn_err "Failed creating some certificates for K2HDKC DBaaS Ckuster."
			return 1
		fi
	fi
	prn_msg "${CGRN}Created${CDEF} : The all certificates for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (3) Create kustomaization.yaml
	#-----------------------------------------------------------
	#
	# CA Certificates which must be under kustomizatino.yaml current directory
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} file is not existed."
	else
		cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}\"."
			return 1
		fi
	fi
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}" ]; then
		mkdir -p "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to create \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}\" directory."
			return 1
		fi
	fi
	prn_dbg "(create_k2hdkc_cluster) Checked the CA certificate file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}\") and certificates diretcory(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}\")."

	#
	# Output kustomization.yaml
	#
	{
		sed -e "s#%%K2HKDC_CLUSTER_NAME%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}#g" -e 's/^#.*$//g' -e '/^$/d' "${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOM_YAML_TEMPL}"

		#
		# Start secret certificates
		#
		echo "secretGenerator:"
		# shellcheck disable=SC2039
		echo "- name: secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs"
		echo "  files:"

		#
		# Secret for certificates
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			#
			# Specify CA certificate
			#
			echo "    - ${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}=./${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"

			#
			# K2HDKC server certificates
			#
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
			#
			_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
			while [ "${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}" -gt 0 ]; do
				_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=$((_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT - 1))
				_DBAAS_K8S_K2HDKC_TMP_HOST_NUM=${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}

				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Copy certificates
				#
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1} file is not existed."
				else
					# key file does not have writable permission
					rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2} file is not existed."
				else
					# key file does not have writable permission
					rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}\"."
						return 1
					fi
				fi
			done

			#
			# K2HDKC slave certificates
			#
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
			#
			_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
			while [ "${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}" -gt 0 ]; do
				_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=$((_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT - 1))
				_DBAAS_K8S_K2HDKC_TMP_HOST_NUM=${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}

				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Copy certificates
				#
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1} file is not existed."
				else
					# key file does not have writable permission
					rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2} file is not existed."
				else
					# key file does not have writable permission
					rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}\"."
						return 1
					fi
				fi
			done

			echo "  type: Opaque"
		else
			#
			# Empty CA certificate
			#
			echo "  type: Opaque"
		fi

		#
		# K2HR3 Role Tokens
		#
		# shellcheck disable=SC2039
		echo "- name: secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token"
		echo "  files:"
		echo "    - role-token-server=./${K2HR3CLI_DBAAS_K8S_SVR_TOKEN_FILENAME}"
		echo "    - role-token-slave=./${K2HR3CLI_DBAAS_K8S_SLV_TOKEN_FILENAME}"
		echo "  type: Opaque"

		#
		# Footers
		#
		echo "generatorOptions:"
		echo "  disableNameSuffixHash: true"

	} > "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}"

	prn_msg "${CGRN}Created${CDEF} : The kustomization file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Make symbolic link
	#
	rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	ln -s "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to make symbolic link to ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The symbolic file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}\") to the kustomization file for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (4) Create dbaas-k2hdkc-server.yaml
	#-----------------------------------------------------------
	_DBAAS_K8S_K2HDKC_TMP_R3API_RR_URL="https://${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}:443"

	sed	-e "s#%%CONFIGMAP_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT}#g"				\
		-e "s#%%SEC_K2HR3_TOKEN_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_K2HR3_TOKEN_MOUNTPOINT}#g"	\
		-e "s#%%SEC_CERTS_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT}#g"				\
		-e "s#%%ANTPICKAX_ETC_DIR%%#${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}#g"				\
		-e "s#%%K2HR3_API_URL%%#${_DBAAS_K8S_K2HDKC_TMP_R3API_RR_URL}#g"							\
		-e "s#%%K2HDKC_DOMAIN%%#${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}#g"									\
		-e "s#%%K2HKDC_CLUSTER_NAME%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}#g"							\
		-e "s#%%K2HKDC_SERVER_PORT%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}#g"						\
		-e "s#%%K2HKDC_SERVER_CTLPORT%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}#g"				\
		-e "s#%%K2HDKC_SERVER_COUNT%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}#g"						\
		"${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_TEMPL}"												\
		> "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The K2HDKC server yaml file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}.\") to the kustomization file for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (5) Create dbaas-k2hdkc-slave.yaml
	#-----------------------------------------------------------
	sed	-e "s#%%CONFIGMAP_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT}#g"				\
		-e "s#%%SEC_K2HR3_TOKEN_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_K2HR3_TOKEN_MOUNTPOINT}#g"	\
		-e "s#%%SEC_CERTS_MOUNTPOINT%%#${K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT}#g"				\
		-e "s#%%ANTPICKAX_ETC_DIR%%#${K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT}#g"				\
		-e "s#%%K2HR3_API_URL%%#${_DBAAS_K8S_K2HDKC_TMP_R3API_RR_URL}#g"							\
		-e "s#%%K2HDKC_DOMAIN%%#${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}#g"									\
		-e "s#%%K2HKDC_CLUSTER_NAME%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}#g"							\
		-e "s#%%K2HKDC_SLAVE_CTLPORT%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}#g"					\
		-e "s#%%K2HDKC_SLAVE_COUNT%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}#g"						\
		"${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL}"												\
		> "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}"

	if [ $? -ne 0 ]; then
		prn_err "Failed to create ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The K2HDKC slave yaml file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}.\") to the kustomization file for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (6) Create configMap / Secret
	#-----------------------------------------------------------
	"${KUBECTL_BIN}" apply -k "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		prn_err "Failed to create(apply) configMap and Secrets by kustomization.yaml."
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The configMap and Secrets from kustomization.yaml for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (7) Run K2HDKC DBaaS Cluster Servers / Slaves
	#-----------------------------------------------------------
	#
	# Run servers
	#
	"${KUBECTL_BIN}" apply -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}" >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		prn_err "Failed to create(apply) K2HDKC DBaaS Cluster Servers by ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}."
		return 1
	fi
	prn_msg "${CGRN}Created(Run)${CDEF} : The K2HDKC Servers from \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Wait a moment to start the slave
	#
	sleep 20

	#
	# Run slaves
	#
	"${KUBECTL_BIN}" apply -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}" >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		prn_err "Failed to create(apply) K2HDKC DBaaS Cluster Servers by ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}."
		return 1
	fi
	prn_msg "${CGRN}Created(Run)${CDEF} : The K2HDKC Slaves from \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (8) Save configuration
	#-----------------------------------------------------------
	save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT'		"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}"
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Server count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT})."
		return 1
	fi
	save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT'		"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}"
	if [ $? -ne 0 ]; then
		prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Slave count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT})."
		return 1
	fi
	prn_msg "${CGRN}Saved${CDEF} : The configuration(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	return 0
}

#--------------------------------------------------------------
# Print all kubernetes resource for K2HR3 system
#
# $?		: result(0/1)
# 
print_k2hdkc_k8s_resource_overview()
{
	#
	# Check K2HDKC cluster configuration
	#
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_err "The \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster does not exist or is not managed by K2HDKC DBaaS K8S."
		return 1
	fi

	pecho "-----------------------------------------------------------"
	pecho " PODs"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get pods 2>/dev/null | grep -e 'NAME'											\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " Services"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get services 2>/dev/null | grep -e 'NAME'										\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " StatefulSets"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get statefulset 2>/dev/null | grep -e 'NAME'									\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"	\
		-e "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " Secrets"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get secrets 2>/dev/null | grep -e 'NAME'		\
		-e "secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs"		\
		-e "secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token"

	pecho ""
	pecho "-----------------------------------------------------------"
	pecho " ConfigMaps"
	pecho "-----------------------------------------------------------"
	"${KUBECTL_BIN}" get configmaps 2>/dev/null | grep -e 'NAME'	\
		-e "configmap-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	pecho ""

	return 0
}

#--------------------------------------------------------------
# Scale K2HDKC DBaaS Cluster
#
# $?		: result(0/1)
# 
scale_k2hdkc_cluster()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Keep command parameter values to another variable before calling load_dbaas_k8s_k2hdkc_cluster_configuration
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ]; then
		_DBAAS_K8S_CLUSTER_TMP_SVR_CNT=0
	else
		_DBAAS_K8S_CLUSTER_TMP_SVR_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
		_DBAAS_K8S_CLUSTER_TMP_SLV_CNT=0
	else
		_DBAAS_K8S_CLUSTER_TMP_SLV_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
	fi
	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=
	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=

	#-----------------------------------------------------------
	# (1) Check / Create / Load K2HDKC cluster configuration
	#-----------------------------------------------------------
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_err "The \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster does not exist or is not managed by K2HDKC DBaaS K8S."
		return 1
	fi

	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" "0"
	if [ $? -ne 0 ]; then
		prn_err "Failed loading \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster configuration."
		return 1
	fi
	prn_dbg "(scale_k2hdkc_cluster) Succeed loading the configuration for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HKDC Cluster."

	#
	# Swap variables(current value is set to _DBAAS_K8S_CLUSTER_TMP_***_CNT, specify parameter value is set to K2HR3CLI_DBAAS_K8S_CLUSTER_***_CNT)
	#
	if [ "${_DBAAS_K8S_CLUSTER_TMP_SVR_CNT}" -eq 0 ]; then
		_DBAAS_K8S_CLUSTER_TMP_SVR_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
	else
		_DBAAS_K8S_CLUSTER_TMP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=${_DBAAS_K8S_CLUSTER_TMP_SVR_CNT}
		_DBAAS_K8S_CLUSTER_TMP_SVR_CNT=${_DBAAS_K8S_CLUSTER_TMP_CNT}
	fi
	if [ "${_DBAAS_K8S_CLUSTER_TMP_SLV_CNT}" -eq 0 ]; then
		_DBAAS_K8S_CLUSTER_TMP_SLV_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
	else
		_DBAAS_K8S_CLUSTER_TMP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=${_DBAAS_K8S_CLUSTER_TMP_SLV_CNT}
		_DBAAS_K8S_CLUSTER_TMP_SLV_CNT=${_DBAAS_K8S_CLUSTER_TMP_CNT}
	fi

	#----------------------------------------------------------
	# (2) Check certificates and create it if not existed
	#----------------------------------------------------------
	if [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" -ne "${_DBAAS_K8S_CLUSTER_TMP_SVR_CNT}" ]; then
		check_dbaas_k2hdkc_certificates "server"
		if [ $? -ne 0 ]; then
			#
			# Missing some certificate, thus create those
			#
			create_dbaas_k2hdkc_certificate_files "server" "0"
			if [ $? -ne 0 ]; then
				prn_err "Failed creating some certificates for K2HDKC DBaaS Ckuster."
				return 1
			fi
			prn_dbg "(scale_k2hdkc_cluster) Succeed creating the certificates for K2HDKC servers which were not existed."
		fi
	fi
	if [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" -ne "${_DBAAS_K8S_CLUSTER_TMP_SLV_CNT}" ]; then
		check_dbaas_k2hdkc_certificates "slave"
		if [ $? -ne 0 ]; then
			#
			# Missing some certificate, thus create those
			#
			create_dbaas_k2hdkc_certificate_files "slave" "0"
			if [ $? -ne 0 ]; then
				prn_err "Failed creating some certificates for K2HDKC DBaaS Ckuster."
				return 1
			fi
			prn_dbg "(scale_k2hdkc_cluster) Succeed creating the certificates for K2HDKC slave which were not existed."
		fi
	fi

	#----------------------------------------------------------
	# (3) Create kustomaization.yaml
	#-----------------------------------------------------------
	#
	# CA Certificates which must be under kustomizatino.yaml current directory
	#
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME} file is not existed."
		else
			cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
			if [ $? -ne 0 ]; then
				prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}\"."
				return 1
			fi
		fi
	fi
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}" ]; then
		mkdir -p "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
		if [ $? -ne 0 ]; then
			prn_err "Failed to create \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}\" directory."
			return 1
		fi
	fi
	prn_dbg "(scale_k2hdkc_cluster) Checked the CA certificate file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}\") and certificates diretcory(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}\")."

	#
	# Output kustomization.yaml
	#
	{
		sed -e "s#%%K2HKDC_CLUSTER_NAME%%#${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}#g" -e 's/^#.*$//g' -e '/^$/d' "${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOM_YAML_TEMPL}"

		#
		# Start secret certificates
		#
		echo "secretGenerator:"
		# shellcheck disable=SC2039
		echo "- name: secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs"
		echo "  files:"

		#
		# Secret for certificates
		#
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
			#
			# Specify CA certificate
			#
			echo "    - ${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}=./${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"

			#
			# K2HDKC server certificates
			#
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
			# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
			#
			_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}
			while [ "${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}" -gt 0 ]; do
				_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=$((_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT - 1))
				_DBAAS_K8S_K2HDKC_TMP_HOST_NUM=${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}

				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Remove current certificate files
				#
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Copy certificates
				#
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}\"."
						return 1
					fi
				fi
			done

			#
			# K2HDKC slave certificates
			#
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
			# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
			#
			_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}
			while [ "${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}" -gt 0 ]; do
				_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT=$((_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT - 1))
				_DBAAS_K8S_K2HDKC_TMP_HOST_NUM=${_DBAAS_K8S_K2HDKC_TMP_LOOP_CNT}

				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
				_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_1}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_CRT_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				echo "    - ${_DBAAS_K8S_K2HDKC_TMP_DST_SERVER_KEY_PATH_2}=${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Remove current certificate files
				#
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
				rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"

				#
				# Copy certificates
				#
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_1}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_CRT_FILE_2}\"."
						return 1
					fi
				fi
				if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" ]; then
					prn_warn "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2} file is not existed."
				else
					cp "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}"
					if [ $? -ne 0 ]; then
						prn_err "Failed to copy \"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_K2HDKC_TMP_SRC_SERVER_KEY_FILE_2}\"."
						return 1
					fi
				fi
			done

			echo "  type: Opaque"
		else
			#
			# Empty CA certificate
			#
			echo "  type: Opaque"
		fi

		#
		# K2HR3 Role Tokens
		#
		# shellcheck disable=SC2039
		echo "- name: secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token"
		echo "  files:"
		echo "    - role-token-server=./${K2HR3CLI_DBAAS_K8S_SVR_TOKEN_FILENAME}"
		echo "    - role-token-slave=./${K2HR3CLI_DBAAS_K8S_SLV_TOKEN_FILENAME}"
		echo "  type: Opaque"

		#
		# Footers
		#
		echo "generatorOptions:"
		echo "  disableNameSuffixHash: true"

	} > "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}"

	prn_msg "${CGRN}Created${CDEF} : The kustomization file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Make symbolic link
	#
	rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	ln -s "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
	if [ $? -ne 0 ]; then
		prn_err "Failed to make symbolic link to ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
		return 1
	fi
	prn_msg "${CGRN}Created${CDEF} : The symbolic file(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}\") to the kustomization file for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (4) Apply configMap / Secret
	#-----------------------------------------------------------
	"${KUBECTL_BIN}" apply -k "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_err "Failed to apply configMap and Secrets by kustomization.yaml."
		return 1
	fi
	prn_msg "${CGRN}Applied${CDEF} : The configMap and Secrets from kustomization.yaml for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#----------------------------------------------------------
	# (5) Scale K2HDKC DBaaS Cluster Servers / Slaves
	#-----------------------------------------------------------
	#
	# Scale servers
	#
	if [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" -ne "${_DBAAS_K8S_CLUSTER_TMP_SVR_CNT}" ]; then
		"${KUBECTL_BIN}" scale statefulsets "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" --replicas="${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" >/dev/null 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed scaling K2HDKC DBaaS Cluster Servers to ${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}."
			return 1
		fi
		prn_msg "${CGRN}Applied${CDEF} : The K2HDKC Servers statefulset(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\") to set replicas(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}\")"

		save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT' "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}"
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Server count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT})."
			return 1
		fi
		prn_msg "${CGRN}Saved${CDEF} : The configuration(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster servers."
	fi

	#
	# Scale slaves
	#
	if [ "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" -ne "${_DBAAS_K8S_CLUSTER_TMP_SLV_CNT}" ]; then
		"${KUBECTL_BIN}" scale statefulsets "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" --replicas="${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" >/dev/null 2>&1

		if [ $? -ne 0 ]; then
			prn_err "Failed scaling K2HDKC DBaaS Cluster Slaves to ${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}."
			return 1
		fi
		prn_msg "${CGRN}Applied${CDEF} : The K2HDKC Slaves statefulset(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\") to set replicas(\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}\")"

		save_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT' "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}"
		if [ $? -ne 0 ]; then
			prn_err "Failed updating the configuration for K2HDKC DBaaS Cluster Slave count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT})."
			return 1
		fi
		prn_msg "${CGRN}Saved${CDEF} : The configuration(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}\") for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster slaves."
	fi

	return 0
}

#--------------------------------------------------------------
# Delete all K2HR3 data and configuration for K2HDKC Cluster
#
# $?		: result(0/1)
# 
delete_k2hdkc_k2hr3_data()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#
	# Get and Check K2HDKC cluster configuration directory path
	#
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi

	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" "0"
	if [ $? -ne 0 ]; then
		prn_err "Failed loading \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster configuration."
		return 1
	fi
	prn_dbg "(delete_k2hdkc_k2hr3_data) Succeed loading the configuration for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HKDC Cluster."

	#
	# Check and Get Scoped Token for this kubernetes namespace
	#
	# [NOTE]
	# K2HR3CLI_SCOPED_TOKEN is cleared and recreated.
	# The CURL_CA_BUNDLE environment variable is specified if a self-signed CA certificate for the K2HR3 API exists.
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_EP}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}" ]; then
		prn_err "The EndPoint of the K2HR3 API server for this \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" is unknown."
		return 1
	fi
	K2HR3CLI_SCOPED_TOKEN=""
	K2HR3CLI_API_URI="https://${K2HR3CLI_DBAAS_K8S_R3API_EP}:${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}"
	# shellcheck disable=SC2034
	K2HR3CLI_TENANT=${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}

	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		export CURL_CA_BUNDLE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
	fi

	#
	# Check K2HR3 Unscoped token
	#
	complement_dbaas_k2hr3_unscoped_token
	if [ $? -ne 0 ] || [ -z "${K2HR3CLI_UNSCOPED_TOKEN}" ]; then
		prn_err "Use the K2HR3 system for \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" kubernetes cluster to execute this command. However, no scoped token for \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\" namespace(tenant) was created to operate the K2HR3 system."
		return 1
	fi
	prn_dbg "(delete_k2hdkc_k2hr3_data) Setup unscoped Token(\"${K2HR3CLI_UNSCOPED_TOKEN}\")"

	#
	# Check K2HR3 Scoped token
	#
	complement_scoped_token
	if [ $? -ne 0 ]; then
		prn_err "Use the K2HR3 system for \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" kubernetes cluster to execute this command. However, no scoped token for \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\" namespace(tenant) was created to operate the K2HR3 system."
		return 1
	fi
	prn_dbg "(delete_k2hdkc_k2hr3_data) Got scoped Token(\"${K2HR3CLI_SCOPED_TOKEN}\")"

	#-----------------------------------------------------------
	# (1) Delete ROLE(server/slave) to K2HR3
	#-----------------------------------------------------------
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HDKC Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Run k2hr3 for slave role
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (2) Delete ROLE(main) to K2HR3
	#-----------------------------------------------------------
	_DBAAS_K8S_TMP_K2HDKC_ROLE_POLVAL="yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:policy:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	#
	# Run k2hr3
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" role delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Role \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (3) Set POLICY to K2HR3
	#-----------------------------------------------------------
	_DBAAS_K8S_TMP_K2HDKC_POL_RESVAL="[\"yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:resource:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\",\"yrn:yahoo:::${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}:resource:${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\"]"

	#
	# Run k2hr3
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" policy delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Policy \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Policy \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (4) Delete RESOURCE(server/slave) to K2HR3
	#-----------------------------------------------------------
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/server\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#
	# Run k2hr3 for slave resource
	#
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}/slave\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."


	#-----------------------------------------------------------
	# (5) Delete RESOURCE(main) to K2HR3
	#-----------------------------------------------------------
	K2HR3CLI_API_URI="${K2HR3CLI_API_URI}"								\
	K2HR3CLI_OPT_CONFIG="${K2HR3CLI_OPT_CONFIG}"						\
	K2HR3CLI_MSGLEVEL="${K2HR3CLI_MSGLEVEL_VALUE}"						\
	K2HR3CLI_OPT_CURLDBG="${K2HR3CLI_OPT_CURLDBG}"						\
	K2HR3CLI_OPT_CURLBODY="${K2HR3CLI_OPT_CURLBODY}"					\
	K2HR3CLI_SCOPED_TOKEN="${K2HR3CLI_SCOPED_TOKEN}"					\
	K2HR3CLI_SCOPED_TOKEN_VERIFIED="${K2HR3CLI_SCOPED_TOKEN_VERIFIED}"	\
	K2HR3CLI_OPT_INTERACTIVE=0											\
	"${K2HR3CLIBIN}" resource delete "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" > /dev/null

	if [ $? -ne 0 ]; then
		prn_err "Failed removed K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for K2HDKC cluster."
		return 1
	fi
	prn_msg "${CGRN}Removed${CDEF} : The K2HR3 Resource \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC cluster."

	#-----------------------------------------------------------
	# (6) Remove directory
	#-----------------------------------------------------------
	if [ -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" ]; then
		rm -rf "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}"
		prn_msg "${CGRN}Removed${CDEF} : The K2HDKC cluster configuration firectory(\"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}\")."
	fi

	return 0
}

#--------------------------------------------------------------
# Delete K2HDKC DBaaS Cluster
#
# $?		: result(0/1)
# 
delete_k2hdkc_cluster()
{
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	if [ $? -ne 0 ]; then
		return 1
	fi

	#-----------------------------------------------------------
	# (1) Check / Create / Load K2HDKC cluster configuration
	#-----------------------------------------------------------
	set_dbaas_k8s_k2hdkc_cluster_variables "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_err "The \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster does not exist or is not managed by K2HDKC DBaaS K8S."
		return 1
	fi

	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" "0"
	if [ $? -ne 0 ]; then
		prn_err "Failed loading \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" cluster configuration."
		return 1
	fi
	prn_dbg "(delete_k2hdkc_cluster) Succeed loading the configuration for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HKDC Cluster."

	#----------------------------------------------------------
	# (2) Delete all kubernetes resources
	#-----------------------------------------------------------
	#
	# Delete K2HDKC Slave Service
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Slave Service(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC Slave Service(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	fi

	#
	# Delete K2HDKC Slave StatefulSet
	#
	"${KUBECTL_BIN}" delete statefulset "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Slave StatefulSet(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC Slave StatefulSet(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	fi

	#
	# Delete K2HDKC Slave Pods
	#
	_DBAAS_K8S_TMP_PODS_LIST=$("${KUBECTL_BIN}" get pods 2>/dev/null | grep "^${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" | awk '{print $1}')
	for _slave_pod_name in ${_DBAAS_K8S_TMP_PODS_LIST}; do
		"${KUBECTL_BIN}" delete pods "${_slave_pod_name}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Slave Pod(${_slave_pod_name})"
		else
			prn_msg "${CGRN}Removed${CDEF} : K2HDKC Slave Pod(${_slave_pod_name})"
		fi
	done

	#
	# Delete K2HDKC Server Service
	#
	"${KUBECTL_BIN}" delete services "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Server Service(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC Server Service(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	fi

	#
	# Delete K2HDKC Server StatefulSet
	#
	"${KUBECTL_BIN}" delete statefulset "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Server StatefulSet(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC Server StatefulSet(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	fi

	#
	# Delete K2HDKC Server Pods
	#
	_DBAAS_K8S_TMP_PODS_LIST=$("${KUBECTL_BIN}" get pods 2>/dev/null | grep "^${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" | awk '{print $1}')
	for _slave_pod_name in ${_DBAAS_K8S_TMP_PODS_LIST}; do
		"${KUBECTL_BIN}" delete pods "${_slave_pod_name}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC Server Pod(${_slave_pod_name})"
		else
			prn_msg "${CGRN}Removed${CDEF} : K2HDKC Server Pod(${_slave_pod_name})"
		fi
	done

	#
	# Delete Secret for K2HDKC DBaaS
	#
	"${KUBECTL_BIN}" delete secrets "secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC DBaaS Secret for certificates(secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs)"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC DBaaS Secret for certificates(secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-certs)"
	fi

	#
	# Delete Token for K2HDKC DBaaS
	#
	"${KUBECTL_BIN}" delete secrets "secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC DBaaS Secret for Token(secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token)"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC DBaaS Secret for Token(secret-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-k2hr3-token)"
	fi

	#
	# Delete configMap for K2HDKC DBaaS
	#
	"${KUBECTL_BIN}" delete configmaps "configmap-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		prn_msg "${CGRN}Failed${CDEF} : Could not delete K2HDKC DBaaS configMap(configmap-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	else
		prn_msg "${CGRN}Removed${CDEF} : K2HDKC DBaaS Secret for configMap(configmap-${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME})"
	fi

	#----------------------------------------------------------
	# (3) Delete all certificates
	#-----------------------------------------------------------
	#
	# K2HDKC server certificates
	#
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
	# certs/svrpod-<cluster name>-<num>.svrsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
	#
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-*.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-*.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-*.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-*.${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

	#
	# K2HDKC slave certificates
	#
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.crt
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.server.key
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.crt
	# certs/slvpod-<cluster name>-<num>.slvsvc-<cluster name>.<k8snamespace>.<k8sdomain>.client.key
	#
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX}"
	rm -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}-${_DBAAS_K8S_K2HDKC_TMP_HOST_NUM}.${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}"

	prn_msg "${CGRN}Removed${CDEF} : The certificates for the \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC Cluster."

	#----------------------------------------------------------
	# (4) Delete all files by removing directory
	#-----------------------------------------------------------
	if [ -n "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" ]; then
		rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE}"
		rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE}"
		rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML}"
		rm -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML}"
		# shellcheck disable=SC2115
		rm -rf "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}"
	fi
	prn_msg "${CGRN}Removed${CDEF} : The configuration and related files for the \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC Cluster."

	#----------------------------------------------------------
	# (5) All K2HR3 data and configuration for K2HDKC Cluster
	#-----------------------------------------------------------
	delete_k2hdkc_k2hr3_data
	if [ $? -ne 0 ]; then
		return 1
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
