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
# Functions
#--------------------------------------------------------------
#
# Check kubectl command
#
# $?		: result(0/1)
#
check_kubectl_command()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_KUBECTL_BIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_KUBECTL_BIN}" != "1" ]; then
		if ! command -v "${KUBECTL_BIN}" >/dev/null 2>&1; then
			prn_err "${KUBECTL_BIN} command is not found, please execute again after ${KUBECTL_BIN} command can be used."
			return 1
		fi
	fi
	return 0
}

#--------------------------------------------------------------
# Check minikube command
#
# $?		: result(0/1)
#
check_minikube_command()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_MINIKUBE_BIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_MINIKUBE_BIN}" != "1" ]; then
		if ! command -v "${MINIKUBE_BIN}" >/dev/null 2>&1; then
			prn_err "${MINIKUBE_BIN} command is not found, please execute again after ${MINIKUBE_BIN} command can be used."
			return 1
		fi
	fi
	return 0
}

#--------------------------------------------------------------
# Check openssl command
#
# $?		: result(0/1)
#
check_openssl_command()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_OPENSSL_BIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_OPENSSL_BIN}" != "1" ]; then
		if ! command -v "${OPENSSL_BIN}" >/dev/null 2>&1; then
			prn_err "${OPENSSL_BIN} command is not found, please execute again after ${OPENSSL_BIN} command can be used."
			return 1
		fi
	fi
	return 0
}

#--------------------------------------------------------------
# Check socat command
#
# $?		: result(0/1)
#
check_socat_command()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_SOCAT_BIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_SKIP_CHECK_SOCAT_BIN}" != "1" ]; then
		if ! command -v "${SOCAT_BIN}" >/dev/null 2>&1; then
			prn_err "${SOCAT_BIN} command is not found, please execute again after ${SOCAT_BIN} command can be used."
			return 1
		fi
	fi
	return 0
}

#--------------------------------------------------------------
# Set localhost variables
#
# Prepare variables such as the hostname and IP address of
# the local host in consideration of the environment using
# minikube.
#
# $?		: result(0/1)
#
# Set Variables
#	K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP	(used only in this function)
#	K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME		(used only in this function)
#	K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL			(The hostname and ip address are set for minikube)
#
#	K2HR3CLI_DBAAS_K8S_R3API_EP					(if not set, set the value in this function.)
#	K2HR3CLI_DBAAS_K8S_R3APP_EP					(if not set, set the value in this function.)
#
#	K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST
#	K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST
#
set_localhost_name_ip_variables()
{
	K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP=""
	K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME=""
	K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL=""

	if [ -n "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" ] && [ "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "1" ]; then
		#
		# minikube
		#
		if ! check_minikube_command; then
			prn_err "Specified \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_MINIKUBE_LONG}\" option, but \"${MINIKUBE_BIN}\" command is not found."
			return 1
		fi

		K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP=$(${MINIKUBE_BIN} ip)
		_DBAAS_K8S_TMP_LOCAL_IPADDR=$(hostname -i)

		if [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP}" ]; then
			K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP}"
		fi
		if [ -n "${_DBAAS_K8S_TMP_LOCAL_IPADDR}" ]; then
			if [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" ]; then
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL},${_DBAAS_K8S_TMP_LOCAL_IPADDR}"
			else
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_IPADDR}"
			fi
		fi

		_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME=$(hostname)
		_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME=$(hostname -a)

		if [ -n "${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}" ] && [ -n "${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}" ]; then
			K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME=${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}

			if [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" ]; then
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL},${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME},${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}"
			else
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME},${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}"
			fi

		elif [ -n "${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}" ]; then
			K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME=${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}
			K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}"

			if [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" ]; then
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL},${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}"
			else
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_LONG_HOSTNAME}"
			fi

		elif [ -n "${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}" ]; then
			K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME=${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}
			K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}"

			if [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL}" ]; then
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL},${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}"
			else
				K2HR3CLI_DBAAS_K8S_LOCALHOST_ALL="${_DBAAS_K8S_TMP_LOCAL_SHORT_HOSTNAME}"
			fi
		fi
	fi

	#
	# Endpoint Completion
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_EP}" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" ] && [ "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "1" ]; then
			K2HR3CLI_DBAAS_K8S_R3API_EP=${K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP}
		else
			K2HR3CLI_DBAAS_K8S_R3API_EP="localhost"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_EP}" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" ] && [ "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "1" ]; then
			K2HR3CLI_DBAAS_K8S_R3APP_EP=${K2HR3CLI_DBAAS_K8S_LOCALHOST_MINIKUBE_IP}
		else
			K2HR3CLI_DBAAS_K8S_R3APP_EP="localhost"
		fi
	fi

	#
	# External host
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" ] && [ "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "1" ] && [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME}" ]; then
		K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST=${K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME}
	else
		K2HR3CLI_DBAAS_K8S_R3API_EXTERNAL_HOST=${K2HR3CLI_DBAAS_K8S_R3API_EP}
	fi
	if [ -n "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" ] && [ "${K2HR3CLI_DBAAS_K8S_MINIKUBE}" = "1" ] && [ -n "${K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME}" ]; then
		K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST=${K2HR3CLI_DBAAS_K8S_LOCALHOST_HOSTNAME}
	else
		K2HR3CLI_DBAAS_K8S_R3APP_EXTERNAL_HOST=${K2HR3CLI_DBAAS_K8S_R3APP_EP}
	fi

	return 0
}

#--------------------------------------------------------------
# Check socat program
#
# $?		: result(0/1)
#
check_socat_program()
{
	if ! check_socat_command; then
		prn_warn "The \"${SOCAT_BIN}\" program is not installed on this host. If running K2HDKC DBaaS inside a minikube, you need to proxy access to the K2HR3 API/APP. The \"${SOCAT_BIN}\" can be used to easily check the operation."

		#
		# Check OS
		#
		if [ ! -f "/etc/os-release" ]; then
			prn_err "Unknown OS type, so could not install \"${SOCAT_BIN}\", please install manually."
			return 1
		fi

		_DBAAS_K8S_TMP_OS_NAME=$(grep '^ID=' /etc/os-release | sed 's/"/ /g' | awk '{print $2}')
		if [ -z "${_DBAAS_K8S_TMP_OS_NAME}" ]; then
			prn_err "Unknown OS type, so could not install \"${SOCAT_BIN}\", please install manually."
			return 1
		elif [ "${_DBAAS_K8S_TMP_OS_NAME}" = "centos" ]; then
			sudo yum install "${SOCAT_BIN}"
		elif [ "${_DBAAS_K8S_TMP_OS_NAME}" = "ubuntu" ]; then
			sudo apt-get install "${SOCAT_BIN}"
		else
			prn_err "Unknown OS type, so could not install \"${SOCAT_BIN}\", please install manually."
			return 1
		fi

		# shellcheck disable=SC2181
		if [ $? -ne 0 ]; then
			prn_err "Failed to install \"${SOCAT_BIN}\", please install manually."
			return 1
		fi
	fi

	return 0
}

#--------------------------------------------------------------
# Complement and Set K2HDKC DBaaS K8S Domain
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#
complement_dbaas_k8s_domain()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE" "Input Kubernetes Namespace for K2HDKC DBaaS(no input: \"default\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_K8SNAMESPACE="default"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ]; then
		K2HR3CLI_DBAAS_K8S_K8SNAMESPACE="default"
	fi
	prn_dbg "(complement_dbaas_k8s_domain) Kubernetes Namespace for K2HDKC DBaaS = \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\"."

	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_K8SDOMAIN" "Input Kubernetes cluster domain for K2HDKC DBaaS(no input: \"svc.cluster.local\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_K8SDOMAIN="svc.cluster.local"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		K2HR3CLI_DBAAS_K8S_K8SDOMAIN="svc.cluster.local"
	fi
	prn_dbg "(complement_dbaas_k8s_domain) Kubernetes Namespace for K2HDKC DBaaS = \"${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}\"."

	return 0
}

#--------------------------------------------------------------
# Complement and Set K2HR3 Unscoped Token
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_UNSCOPED_TOKEN
#
complement_dbaas_k2hr3_unscoped_token()
{
	#
	# Interacvive input
	#
	completion_variable_auto "K2HR3CLI_UNSCOPED_TOKEN" "K2HR3 Unscoped Token: " 1
	_DBAAS_K8S_COMPLEMENT_RESULT=$?
	prn_dbg "(complement_dbaas_k2hr3_unscoped_token) K2HR3 Unscoped Token = \"${K2HR3CLI_UNSCOPED_TOKEN}\"."
	return "${_DBAAS_K8S_COMPLEMENT_RESULT}"
}

#--------------------------------------------------------------
# Complement and Set K2HDKC base name as the backend of K2HR3 system
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#
complement_dbaas_k2hr3_k2hdkc_name()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3DKC_NAME" "Input K2HDKC base name as the backend of K2HR3 system(no input: \"r3dkc\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3DKC_NAME="r3dkc"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ]; then
		K2HR3CLI_DBAAS_K8S_R3DKC_NAME="r3dkc"
	fi

	prn_dbg "(complement_dbaas_k2hr3_k2hdkc_name) K2HDKC base name = \"${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set K2HR3 API base name
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#
complement_dbaas_k2hr3api_name()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3API_NAME" "Input K2HR3 API base name(no input: \"r3api\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3API_NAME="r3api"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
		K2HR3CLI_DBAAS_K8S_R3API_NAME="r3api"
	fi

	prn_dbg "(complement_dbaas_k2hr3api_name) K2HR3 API base name = \"${K2HR3CLI_DBAAS_K8S_R3API_NAME}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set K2HR3 APP base name
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#
complement_dbaas_k2hr3app_name()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3APP_NAME" "Input K2HR3 APP base name(no input: \"r3app\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3APP_NAME="r3app"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
		K2HR3CLI_DBAAS_K8S_R3APP_NAME="r3app"
	fi

	prn_dbg "(complement_dbaas_k2hr3app_name) K2HR3 APP base name = \"${K2HR3CLI_DBAAS_K8S_R3APP_NAME}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set replica count for K2HR3 DKC 
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#
complement_dbaas_k2hdkc_replicas()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3DKC_REPS" "Input K2HDKC(as the backend of K2HR3 system) replica count(no input: \"2\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3DKC_REPS="2"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ]; then
		K2HR3CLI_DBAAS_K8S_R3DKC_REPS="2"
	fi

	prn_dbg "(complement_dbaas_k2hdkc_replicas) K2HDKC(as the backend of K2HR3 system) replica count = \"${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set replica count for K2HR3 API 
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#
complement_dbaas_k2hr3api_replicas()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3API_REPS" "Input K2HR3 API replica count(no input: \"2\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3API_REPS="2"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
		K2HR3CLI_DBAAS_K8S_R3API_REPS="2"
	fi

	prn_dbg "(complement_dbaas_k2hr3api_replicas) K2HR3 API replica count = \"${K2HR3CLI_DBAAS_K8S_R3API_REPS}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set replica count for K2HR3 APP 
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS
#
complement_dbaas_k2hr3app_replicas()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_R3APP_REPS" "Input K2HR3 APP replica count(no input: \"2\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_R3APP_REPS="2"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
		K2HR3CLI_DBAAS_K8S_R3APP_REPS="2"
	fi

	prn_dbg "(complement_dbaas_k2hr3app_replicas) K2HR3 APP replica count = \"${K2HR3CLI_DBAAS_K8S_R3APP_REPS}\"."
	return 0
}

#--------------------------------------------------------------
# Complement and Set the server/slave count in K2HDKC Cluster
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT
#
complement_dbaas_k2hdkc_cluster_node_count()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT" "Input K2HDKC Cluster server count(no input: \"2\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT="2"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ]; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT="2"
	else
		if ! is_positive_number "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}"; then
			prn_err "K2HDKC Cluster server count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}) must be number."
			return 1
		fi
	fi
	prn_dbg "(complement_dbaas_k2hdkc_cluster_node_count) K2HDKC Cluster server count = \"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}\"."

	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT" "Input K2HDKC Cluster slave count(no input: \"2\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT="2"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT="2"
	else
		if ! is_positive_number "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}"; then
			prn_err "K2HDKC Cluster slave count(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}) must be number."
			return 1
		fi
	fi
	prn_dbg "(complement_dbaas_k2hdkc_cluster_node_count) K2HDKC Cluster slave count = \"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}\"."

	return 0
}

#--------------------------------------------------------------
# Complement and Set the server/slave port number in K2HDKC Cluster
#
# $?	: result
#
# Access and Change Environment
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT
#
complement_dbaas_k2hdkc_cluster_ports()
{
	#
	# Interacvive input
	#
	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT" "Input K2HDKC Cluster server port number(no input: \"8020\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT="8020"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}" ]; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT="8020"
	else
		if ! is_positive_number "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}"; then
			prn_err "K2HDKC Cluster server port number(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}) must be number."
			return 1
		fi
	fi
	prn_dbg "(complement_dbaas_k2hdkc_cluster_ports) K2HDKC Cluster server port number = \"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}\"."

	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT" "Input K2HDKC Cluster server control port number(no input: \"8021\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT="8021"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ]; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT="8021"
	else
		if ! is_positive_number "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}"; then
			prn_err "K2HDKC Cluster server control port number(${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}) must be number."
			return 1
		fi
	fi
	prn_dbg "(complement_dbaas_k2hdkc_cluster_ports) K2HDKC Cluster server control port number = \"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}\"."

	if ! completion_variable_auto "K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT" "Input K2HDKC Cluster slave control port number(no input: \"8022\"): " "0"; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT="8022"
	elif [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT="8022"
	else
		if ! is_positive_number "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}"; then
			prn_err "K2HDKC Cluster slave control port number(${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}) must be number."
			return 1
		fi
	fi
	prn_dbg "(complement_dbaas_k2hdkc_cluster_ports) K2HDKC Cluster slave control port number = \"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}\"."

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
