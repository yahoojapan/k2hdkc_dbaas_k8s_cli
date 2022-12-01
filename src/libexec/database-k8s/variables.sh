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

#--------------------------------------------------------------
# DBaaS K8S Valiables
#--------------------------------------------------------------
# The following values are used in the K2HDKC DBAAS K8S CLI.
#
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_DOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#

#--------------------------------------------------------------
# DBaaS Variables for Configration
#--------------------------------------------------------------
#
# Description
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="${K2HR3CLI_PLUGIN_CONFIG_VAR_DESC} config_var_desciption_dbaas_k8s"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_DESC="config_var_desciption_dbaas_k8s"
fi

#
# Names
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="${K2HR3CLI_PLUGIN_CONFIG_VAR_NAME} config_var_name_dbaas_k8s"
else
	K2HR3CLI_PLUGIN_CONFIG_VAR_NAME="config_var_name_dbaas_k8s"
fi

#
# Check DBaaS Variables
#
if [ -n "${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR}" ]; then
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="${K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR} config_check_var_name_dbaas_k8s"
else
	K2HR3CLI_PLUGIN_CONFIG_CHECK_VAR="config_check_var_name_dbaas_k8s"
fi

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
#
# Return variable description for this Example Plugin
#
# $?	: result
#
# [NOTE]
#           +---+----+----+----+----+----+----+----+----+----+----+----+----|
#           ^   ^
#           |   +--- Start for Description
#           +------- Start for Variables Title
#
config_var_desciption_dbaas_k8s()
{
	prn_msg "K2HR3CLI_DBAAS_K8S_CONFIG"
	prn_msg "   Specify the configuration directory path that has files such"
	prn_msg "   as templates used by DBaaS K8S."
	prn_msg ""
	prn_msg "K2HR3CLI_DBAAS_K8S_DOMAIN"
	prn_msg "   Set the domain name to build the K2HDKC DBaaS cluster."
	prn_msg "   The domain name must consist of the domain name and namespace"
	prn_msg "   of the kubernetes cluster."
	prn_msg "     \"domain name\" = \"k8s namespace\" . \"k8s cluester domain name\""
	prn_msg "   The \"K2HR3CLI_DBAAS_K8S_K8SNAMESPACE\" and"
	prn_msg "   \"K2HR3CLI_DBAAS_K8S_K8SDOMAIN\" values are updated if"
	prn_msg "   updates this variable."
	prn_msg ""
	prn_msg "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE"
	prn_msg "    Specifies a part of the domain name to build the K2HDKC DBaaS"
	prn_msg "    cluster. This option specifies the domain name for the"
	prn_msg "    kubernetes cluster. The value of this and the value of the"
	prn_msg "    \"K2HR3CLI_DBAAS_K8S_K8SDOMAIN\" combine to form the"
	prn_msg "    domain name."
	prn_msg "    The \"K2HR3CLI_DBAAS_K8S_DOMAIN\" value is updated if"
	prn_msg "    updates this variables."
	prn_msg ""
	prn_msg "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
	prn_msg "    Specifies a part of the domain name to build the K2HDKC DBaaS"
	prn_msg "    cluster. This option specifies the domain name for the"
	prn_msg "    kubernetes cluster. The value of this and the value of the"
	prn_msg "    \"K2HR3CLI_DBAAS_K8S_K8SNAMESPACE\" combine to form the"
	prn_msg "    domain name."
	prn_msg "    The \"K2HR3CLI_DBAAS_K8S_DOMAIN\" value is updated if"
	prn_msg "    updates this variables."
	prn_msg ""
}

#
# Return variable name
#
# $1		: variable name(if empty, it means all)
# $?		: result
# Output	: variable names(with separator is space)
#
config_var_name_dbaas_k8s()
{
	if [ -z "$1" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_CONFIG: \"${K2HR3CLI_DBAAS_K8S_CONFIG}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_CONFIG: (empty)"
		fi
		if [ -n "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_DOMAIN: \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_DOMAIN: (empty)"
		fi
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE: \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE: (empty)"
		fi
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SDOMAIN: \"${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SDOMAIN: (empty)"
		fi

	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_CONFIG" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_CONFIG: \"${K2HR3CLI_DBAAS_K8S_CONFIG}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_CONFIG: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_DOMAIN" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_DOMAIN: \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_DOMAIN: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE: \"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE: (empty)"
		fi
		return 0

	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_K8SDOMAIN" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SDOMAIN: \"${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}\""
		else
			prn_msg "K2HR3CLI_DBAAS_K8S_K8SDOMAIN: (empty)"
		fi
		return 0

	fi
	return 1
}

#
# Check variable name
#
# $1		: variable name
# $?		: result
#
config_check_var_name_dbaas_k8s()
{
	if [ -z "$1" ]; then
		return 1
	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_CONFIG" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_DOMAIN" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_K8SNAMESPACE" ]; then
		return 0
	elif [ "$1" = "K2HR3CLI_DBAAS_K8S_K8SDOMAIN" ]; then
		return 0
	fi
	return 1
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
