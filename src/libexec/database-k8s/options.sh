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
# Multiple read prevention
#
if [ "X${K2HR3CLI_DBAAS_OPTION_FILE_LOADED}" = "X1" ]; then
	return 0
fi
K2HR3CLI_DBAAS_OPTION_FILE_LOADED=1

#--------------------------------------------------------------
# DBaaS on Kubernetes Options
#--------------------------------------------------------------
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CONFIG_LONG="--dbaas_k8s_config"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG="--domain"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG="--k8s_namespace"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG="--k8s_domain"

#
# Options mainly for K2HR3 system and certificates
#
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_LONG="--cert_type"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_NAME_LONG="--k2hdkc_name"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NAME_LONG="--k2hr3api_name"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NAME_LONG="--k2hr3app_name"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_HOST_NUM_LONG="--host_number"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_REPS_LONG="--k2hdkc_replicas"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_REPS_LONG="--k2hr3api_replicas"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_REPS_LONG="--k2hr3app_replicas"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_EP_LONG="--k2hr3api_ep"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_EP_LONG="--k2hr3app_ep"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NPNUM_LONG="--k2hr3api_nodeport_num"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NPNUM_LONG="--k2hr3app_nodeport_num"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_NODE_IPS_LONG="--nodehost_ips"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_MINIKUBE_LONG="--minikube"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_FORCE_LONG="--force"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SUSPEND_LONG="--suspend"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_C_LONG="--cert_country"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_S_LONG="--cert_state"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_O_LONG="--cert_organization"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CA_PASS_LONG="--ca_passphrase"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_EXPIRE_LONG="--period_years"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG="--configuration"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG="--k8s_ressources"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_SUMMARY_LONG="--summary"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_RM_CERTS_LONG="--with_certs"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_SECRET_LONG="--oidc_client_secret"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_ID_LONG="--oidc_client_id"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_ISSUER_URL_LONG="--oidc_issuer_url"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_USERNAME_KEY_LONG="--oidc_username_key"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIENAME_LONG="--oidc_cookiename"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIE_EXPIRE_LONG="--oidc_cookie_expire"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_API_URL_LONG="--k8s_api_url"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_CA_CERT_LONG="--k8s_ca_cert"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_SA_TOKEN_LONG="--k8s_sa_token"

#
# Options mainly for K2HDKC clusters
#
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_PORT_LONG="--server_port"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CTLPORT_LONG="--server_control_port"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CTLPORT_LONG="--slave_control_port"

K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CNT_LONG="--server_count"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CNT_LONG="--slave_count"

#
# Parse common option
#
# $@									option strings
#
# $?									returns 1 for fatal errors
# Set global values
#	K2HR3CLI_OPTION_PARSER_REST				: the remaining option string with the help option cut off(for new $@)
#	K2HR3CLI_DBAAS_K8S_CONFIG				: --dbaas_k8s_config
#	K2HR3CLI_DBAAS_K8S_DOMAIN				: --domain
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE			: --k8s_namespace
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN			: --k8s_domain
#	K2HR3CLI_DBAAS_K8S_CERT_TYPE			: --cert_type
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME			: --k2hdkc_name
#	K2HR3CLI_DBAAS_K8S_R3API_NAME			: --k2hr3api_name
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME			: --k2hr3app_name
#	K2HR3CLI_DBAAS_K8S_HOST_NUM				: --host_number
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS			: --k2hdkc_replicas
#	K2HR3CLI_DBAAS_K8S_R3API_REPS			: --k2hr3api_replicas
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS			: --k2hr3app_replicas
#	K2HR3CLI_DBAAS_K8S_R3API_EP				: --k2hr3api_ep
#	K2HR3CLI_DBAAS_K8S_R3APP_EP				: --k2hr3app_ep
#	K2HR3CLI_DBAAS_K8S_R3API_NPNUM			: --k2hr3api_nodeport_num
#	K2HR3CLI_DBAAS_K8S_R3APP_NPNUM			: --k2hr3app_nodeport_num
#	K2HR3CLI_DBAAS_K8S_NODE_IPS				: --nodehost_ips
#	K2HR3CLI_DBAAS_K8S_MINIKUBE				: --minikube
#	K2HR3CLI_DBAAS_K8S_FORCE				: --force
#	K2HR3CLI_DBAAS_K8S_SUSPEND				: --suspend
#	K2HR3CLI_DBAAS_K8S_CERT_C				: --cert_country
#	K2HR3CLI_DBAAS_K8S_CERT_S				: --cert_state
#	K2HR3CLI_DBAAS_K8S_CERT_O				: --cert_organization
#	K2HR3CLI_DBAAS_K8S_CA_PASS				: --ca_passphrase
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE			: --period_years
#	K2HR3CLI_DBAAS_K8S_SHOW_CONFIG			: --configuration
#	K2HR3CLI_DBAAS_K8S_SHOW_RES				: --k8s_ressources
#	K2HR3CLI_DBAAS_K8S_SHOW_SUMMARY			: --summary
#	K2HR3CLI_DBAAS_K8S_RM_CERTS				: --with_certs
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET	: --oidc_client_secret
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID		: --oidc_client_id
#	K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL		: --oidc_issuer_url
#	K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY	: --oidc_username_key
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME		: --oidc_cookiename
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE	: --oidc_cookie_expire
#	K2HR3CLI_DBAAS_K8S_K8S_API_URL			: --k8s_api_url
#	K2HR3CLI_DBAAS_K8S_K8S_CA_CERT			: --k8s_ca_cert
#	K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN			: --k8s_sa_token
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT		: --server_port
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT	: --server_control_port
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT	: --slave_control_port
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT		: --server_count
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT		: --slave_count
#
parse_dbaas_k8s_option()
{
	#
	# Temporary values
	#
	_OPT_TMP_DBAAS_K8S_CONFIG=
	_OPT_TMP_DBAAS_K8S_DOMAIN=
	_OPT_TMP_DBAAS_K8S_K8SNAMESPACE=
	_OPT_TMP_DBAAS_K8S_K8SDOMAIN=
	_OPT_TMP_DBAAS_K8S_CERT_TYPE=
	_OPT_TMP_DBAAS_K8S_R3DKC_NAME=
	_OPT_TMP_DBAAS_K8S_R3APP_NAME=
	_OPT_TMP_DBAAS_K8S_R3API_NAME=
	_OPT_TMP_DBAAS_K8S_HOST_NUM=
	_OPT_TMP_DBAAS_K8S_R3DKC_REPS=
	_OPT_TMP_DBAAS_K8S_R3API_REPS=
	_OPT_TMP_DBAAS_K8S_R3APP_REPS=
	_OPT_TMP_DBAAS_K8S_R3API_EP=
	_OPT_TMP_DBAAS_K8S_R3APP_EP=
	_OPT_TMP_DBAAS_K8S_R3API_NPNUM=
	_OPT_TMP_DBAAS_K8S_R3APP_NPNUM=
	_OPT_TMP_DBAAS_K8S_NODE_IPS=
	_OPT_TMP_DBAAS_K8S_MINIKUBE=
	_OPT_TMP_DBAAS_K8S_FORCE=
	_OPT_TMP_DBAAS_K8S_SUSPEND=
	_OPT_TMP_DBAAS_K8S_CERT_C=
	_OPT_TMP_DBAAS_K8S_CERT_S=
	_OPT_TMP_DBAAS_K8S_CERT_O=
	_OPT_TMP_DBAAS_K8S_CA_PASS=
	_OPT_TMP_DBAAS_K8S_CERT_EXPIRE=
	_OPT_TMP_DBAAS_K8S_SHOW_CONFIG=
	_OPT_TMP_DBAAS_K8S_SHOW_RES=
	_OPT_TMP_DBAAS_K8S_SHOW_SUMMARY=
	_OPT_TMP_DBAAS_K8S_RM_CERTS=
	_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_SECRET=
	_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_ID=
	_OPT_TMP_DBAAS_K8S_OIDC_ISSUER_URL=
	_OPT_TMP_DBAAS_K8S_OIDC_USERNAME_KEY=
	_OPT_TMP_DBAAS_K8S_OIDC_COOKIENAME=
	_OPT_TMP_DBAAS_K8S_OIDC_COOKIE_EXPIRE=
	_OPT_TMP_DBAAS_K8S_K8S_API_URL=
	_OPT_TMP_DBAAS_K8S_K8S_CA_CERT=
	_OPT_TMP_DBAAS_K8S_K8S_SA_TOKEN=
	_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_PORT=
	_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CTLPORT=
	_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CTLPORT=
	_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CNT=
	_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CNT=

	K2HR3CLI_OPTION_PARSER_REST=""
	while [ $# -gt 0 ]; do
		_OPTION_TMP=$(to_lower "$1")

		if [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CONFIG_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CONFIG}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CONFIG_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CONFIG_LONG} option needs parameter."
				return 1
			fi
			if [ ! -d "$1" ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CONFIG_LONG} option parameter($1) directory does not exist."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CONFIG=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_DOMAIN}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_DOMAIN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_K8SNAMESPACE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_K8SNAMESPACE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_K8SDOMAIN}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_K8SDOMAIN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CERT_TYPE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

			if [ "X${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}" ] && [ "X${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ] && [ "X${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] && [ "X${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ] && [ "X${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
				prn_err "Unknown ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_LONG} option value(${_OPT_TMP_DBAAS_K8S_CERT_TYPE})."
				return 1
			fi

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_NAME_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3DKC_NAME}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_NAME_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_NAME_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3DKC_NAME=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NAME_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_NAME}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NAME_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NAME_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3APP_NAME=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NAME_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_NAME}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NAME_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NAME_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3API_NAME=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_HOST_NUM_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_HOST_NUM}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_HOST_NUM_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_HOST_NUM_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_HOST_NUM_LONG} option value must be number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_HOST_NUM=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_REPS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3DKC_REPS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_REPS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_REPS_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3DKC_REPS_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3DKC_REPS=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_REPS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_REPS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_REPS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_REPS_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_REPS_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3API_REPS=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_REPS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_REPS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_REPS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_REPS_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_REPS_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3APP_REPS=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_EP_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_EP}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_EP_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_EP_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3API_EP=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_EP_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_EP}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_EP_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_EP_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3APP_EP=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NPNUM_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_NPNUM}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NPNUM_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3API_NPNUM_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3API_NPNUM=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NPNUM_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_NPNUM}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NPNUM_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_R3APP_NPNUM_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_R3APP_NPNUM=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_NODE_IPS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_NODE_IPS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_NODE_IPS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_NODE_IPS_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_NODE_IPS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_MINIKUBE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_MINIKUBE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_MINIKUBE_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_MINIKUBE=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_FORCE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_FORCE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_FORCE_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_FORCE=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SUSPEND_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_SUSPEND}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SUSPEND_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_SUSPEND=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_C_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_C}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_C_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_C_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CERT_C=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_S_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_S}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_S_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_S_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CERT_S=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_O_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_O}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_O_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_O_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CERT_O=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CA_PASS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CA_PASS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CA_PASS_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CA_PASS_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CA_PASS=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_EXPIRE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_EXPIRE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_EXPIRE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_EXPIRE_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_EXPIRE_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CERT_EXPIRE=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_CONFIG}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_SHOW_CONFIG=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_RES}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_SHOW_RES=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_SUMMARY_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_SUMMARY}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_SUMMARY_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_SHOW_SUMMARY=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_RM_CERTS_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_RM_CERTS}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_RM_CERTS_LONG} option."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_RM_CERTS=1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_SECRET_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_SECRET}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_SECRET_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_SECRET_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_SECRET=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_ID_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_ID}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_ID_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_CLIENT_ID_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_ID=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_ISSUER_URL_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_ISSUER_URL}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_ISSUER_URL_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_ISSUER_URL_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_ISSUER_URL=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_USERNAME_KEY_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_USERNAME_KEY}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_USERNAME_KEY_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_USERNAME_KEY_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_USERNAME_KEY=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIENAME_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_COOKIENAME}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIENAME_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIENAME_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_COOKIENAME=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIE_EXPIRE_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_COOKIE_EXPIRE}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIE_EXPIRE_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_OIDC_COOKIE_EXPIRE_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_OIDC_COOKIE_EXPIRE=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_API_URL_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_API_URL}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_API_URL_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_API_URL_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_K8S_API_URL=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_CA_CERT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_CA_CERT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_CA_CERT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_CA_CERT_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_K8S_CA_CERT=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_SA_TOKEN_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_SA_TOKEN}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_SA_TOKEN_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8S_SA_TOKEN_LONG} option needs parameter."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_K8S_SA_TOKEN=$(cut_special_words "$1" | sed -e 's/%20/ /g' -e 's/%25/%/g')

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_PORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_PORT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_PORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_PORT_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_PORT_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_PORT=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CTLPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CTLPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CTLPORT_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CTLPORT_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CTLPORT=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CTLPORT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CTLPORT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CTLPORT_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CTLPORT_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CTLPORT=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CNT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CNT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CNT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CNT_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SVR_CNT_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CNT=$1

		elif [ "X${_OPTION_TMP}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CNT_LONG}" ]; then
			if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
				prn_err "already specified ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CNT_LONG} option."
				return 1
			fi
			shift
			if [ $# -le 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CNT_LONG} option needs parameter."
				return 1
			fi
			is_positive_number "$1"
			if [ $? -ne 0 ]; then
				prn_err "${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CLUSTER_SLV_CNT_LONG} option value must be positive number."
				return 1
			fi
			_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CNT=$1

		else
			if [ "X${K2HR3CLI_OPTION_PARSER_REST}" = "X" ]; then
				K2HR3CLI_OPTION_PARSER_REST="$1"
			else
				K2HR3CLI_OPTION_PARSER_REST="${K2HR3CLI_OPTION_PARSER_REST} $1"
			fi
		fi
		shift
	done

	#
	# Set override default and global value
	#
	if [ -n "${_OPT_TMP_DBAAS_K8S_CONFIG}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CONFIG=${_OPT_TMP_DBAAS_K8S_CONFIG}
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_DOMAIN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_DOMAIN=${_OPT_TMP_DBAAS_K8S_DOMAIN}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_DOMAIN=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_K8SNAMESPACE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=${_OPT_TMP_DBAAS_K8S_K8SNAMESPACE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_K8SDOMAIN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8SDOMAIN=${_OPT_TMP_DBAAS_K8S_K8SDOMAIN}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8SDOMAIN=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_TYPE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_TYPE=${_OPT_TMP_DBAAS_K8S_CERT_TYPE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_TYPE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3DKC_NAME}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3DKC_NAME=${_OPT_TMP_DBAAS_K8S_R3DKC_NAME}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3DKC_NAME=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_NAME}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_NAME=${_OPT_TMP_DBAAS_K8S_R3APP_NAME}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_NAME=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_NAME}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_NAME=${_OPT_TMP_DBAAS_K8S_R3API_NAME}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_NAME=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_HOST_NUM}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_HOST_NUM=${_OPT_TMP_DBAAS_K8S_HOST_NUM}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_HOST_NUM=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3DKC_REPS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3DKC_REPS=${_OPT_TMP_DBAAS_K8S_R3DKC_REPS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3DKC_REPS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_REPS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_REPS=${_OPT_TMP_DBAAS_K8S_R3API_REPS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_REPS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_REPS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_REPS=${_OPT_TMP_DBAAS_K8S_R3APP_REPS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_REPS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_EP}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_EP=${_OPT_TMP_DBAAS_K8S_R3API_EP}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_EP=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_EP}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_EP=${_OPT_TMP_DBAAS_K8S_R3APP_EP}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_EP=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3API_NPNUM}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_NPNUM=${_OPT_TMP_DBAAS_K8S_R3API_NPNUM}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3API_NPNUM=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_R3APP_NPNUM}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_NPNUM=${_OPT_TMP_DBAAS_K8S_R3APP_NPNUM}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_R3APP_NPNUM=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_NODE_IPS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_NODE_IPS=${_OPT_TMP_DBAAS_K8S_NODE_IPS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_NODE_IPS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_MINIKUBE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_MINIKUBE=${_OPT_TMP_DBAAS_K8S_MINIKUBE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_MINIKUBE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_FORCE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_FORCE=${_OPT_TMP_DBAAS_K8S_FORCE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_FORCE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_SUSPEND}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SUSPEND=${_OPT_TMP_DBAAS_K8S_SUSPEND}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SUSPEND=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_C}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_C=${_OPT_TMP_DBAAS_K8S_CERT_C}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_C=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_S}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_S=${_OPT_TMP_DBAAS_K8S_CERT_S}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_S=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_O}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_O=${_OPT_TMP_DBAAS_K8S_CERT_O}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_O=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CA_PASS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CA_PASS=${_OPT_TMP_DBAAS_K8S_CA_PASS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CA_PASS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CERT_EXPIRE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=${_OPT_TMP_DBAAS_K8S_CERT_EXPIRE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_CONFIG}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_CONFIG=${_OPT_TMP_DBAAS_K8S_SHOW_CONFIG}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_CONFIG=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_RES}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_RES=${_OPT_TMP_DBAAS_K8S_SHOW_RES}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_RES=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_SHOW_SUMMARY}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_SUMMARY=${_OPT_TMP_DBAAS_K8S_SHOW_SUMMARY}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_SHOW_SUMMARY=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_RM_CERTS}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_RM_CERTS=${_OPT_TMP_DBAAS_K8S_RM_CERTS}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_RM_CERTS=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_SECRET}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET=${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_SECRET}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_ID}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID=${_OPT_TMP_DBAAS_K8S_OIDC_CLIENT_ID}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_ISSUER_URL}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL=${_OPT_TMP_DBAAS_K8S_OIDC_ISSUER_URL}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_USERNAME_KEY}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY=${_OPT_TMP_DBAAS_K8S_OIDC_USERNAME_KEY}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_COOKIENAME}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME=${_OPT_TMP_DBAAS_K8S_OIDC_COOKIENAME}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_OIDC_COOKIE_EXPIRE}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE=${_OPT_TMP_DBAAS_K8S_OIDC_COOKIE_EXPIRE}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_API_URL}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_API_URL=${_OPT_TMP_DBAAS_K8S_K8S_API_URL}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_API_URL=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_CA_CERT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_CA_CERT=${_OPT_TMP_DBAAS_K8S_K8S_CA_CERT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_CA_CERT=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_K8S_SA_TOKEN}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN=${_OPT_TMP_DBAAS_K8S_K8S_SA_TOKEN}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN=""
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_PORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT=${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_PORT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT=
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT=${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CTLPORT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT=
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT=${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CTLPORT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT=
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CNT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=${_OPT_TMP_DBAAS_K8S_CLUSTER_SVR_CNT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=
	fi
	if [ -n "${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=${_OPT_TMP_DBAAS_K8S_CLUSTER_SLV_CNT}
	else
		# shellcheck disable=SC2034
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=
	fi

	#
	# Check special variable(K2HR3CLI_DBAAS_K8S_DOMAIN / K2HR3CLI_DBAAS_K8S_K8SNAMESPACE / K2HR3CLI_DBAAS_K8S_K8SDOMAIN)
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] || [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			prn_err "If specify the ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG} option, cannot specify the ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG} and ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG} options."
			return 1
		fi
		#
		# Parse domain to k8s namespace and k8s domain
		#
		K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=$(echo "${K2HR3CLI_DBAAS_K8S_DOMAIN}" | sed 's/\./ /' | awk '{print $1}')
		K2HR3CLI_DBAAS_K8S_K8SDOMAIN=$(echo "${K2HR3CLI_DBAAS_K8S_DOMAIN}" | sed 's/\./ /' | awk '{print $2}')

		if [ -z "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			prn_err "Could not parse ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG} option value to k8s namespace and domain."
			return 1
		fi

	elif [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] && [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		K2HR3CLI_DBAAS_K8S_DOMAIN="${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

	elif [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] || [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		prn_dbg "(parse_dbaas_k8s_option) ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG} and ${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG} options are not specified together."
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
