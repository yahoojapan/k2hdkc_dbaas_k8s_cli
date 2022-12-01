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
# Use Environments and Variables
#=====================================================================
# Allowed variables are loaded from the configuration file. These variable
# is read at startup.
#
# The configuration files are as follows:
# [Checking Priority]
#	1) Command option:				--dbaas_k8s_config
#	2) Environment variable:		K2HR3CLI_DBAAS_K8S_CONFIG
#	3) User configuration file:		<USER HOME>/.antpickax/dbaas-k8s
#
# The configuration directory is determined in the following order:
# (1)options, (2)environment variables, and (3)user home directories(default).
# Make sure that (1) and (2) are processed before loading this module.
#

#
# Default path under <USER HOME>/<K2HR3 CLI configdir: .antpickax>
#
K2HR3CLI_DBAAS_K8S_DEFAULT_CONFIG_DIRNAME="dbaas-k8s"

#
# Prefix for K2HDKC DBaaS K8S domain directory
#
K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX="DBAAS-"

#
# Prefix for K2HDKC DBaaS K8S cluster
#
K2HR3CLI_DBAAS_K8S_CLUSTER_PREFIX="K2HDKC-"

#
# Keyword in templates
#
K2HR3CLI_DBAAS_K8S_KEYWORD_CURRENT_DIR="%%K2HDKC_DBAAS_K8S_LIBEXECDIR%%"

#=====================================================================
# Utility functions - Domains
#=====================================================================
#
# Check K2HDKC DBaaS K8S domain, and set default value
#
# $?		: result(0/1)
# Output	: path
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_DOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#
check_dbaas_k8s_cluster_domain()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ]; then
		if [ -n "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] && [ -n "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			K2HR3CLI_DBAAS_K8S_DOMAIN="${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		else
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k8s_domain
			if [ -z "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
				prn_err "\"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG}\" options must be specify together for kubernetes cluster domain and K2HDKC DBaaS."
				return 1
			fi
			K2HR3CLI_DBAAS_K8S_DOMAIN="${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		fi

	else
		_DBAAS_K8S_CONFIG_TMP_K8S_NAMESPACE=$(echo "${K2HR3CLI_DBAAS_K8S_DOMAIN}" | sed 's/\./ /' | awk '{print $1}')
		_DBAAS_K8S_CONFIG_TMP_K8S_DOMAIN=$(echo "${K2HR3CLI_DBAAS_K8S_DOMAIN}" | sed 's/\./ /' | awk '{print $2}')

		if [ -z "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ] && [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=${_DBAAS_K8S_CONFIG_TMP_K8S_NAMESPACE}
			K2HR3CLI_DBAAS_K8S_K8SDOMAIN=${_DBAAS_K8S_CONFIG_TMP_K8S_DOMAIN}

		elif [ -z "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" ]; then
			# [NOTE]
			# Since the condition becomes complicated, use "X"(temporary word).
			#
			if [ "X${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" != "X${_DBAAS_K8S_CONFIG_TMP_K8S_DOMAIN}" ]; then
				prn_err "The values of the \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SDOMAIN_LONG}\" options are inconsistent."
				return 1
			fi
			K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=${_DBAAS_K8S_CONFIG_TMP_K8S_NAMESPACE}

		elif [ -z "${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
			# [NOTE]
			# Since the condition becomes complicated, use "X"(temporary word).
			#
			if [ "X${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}" != "X${_DBAAS_K8S_CONFIG_TMP_K8S_NAMESPACE}" ]; then
				prn_err "The values of the \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_DOMAIN_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_K8SNAMESPACE_LONG}\" options are inconsistent."
				return 1

			fi
			K2HR3CLI_DBAAS_K8S_K8SDOMAIN=${_DBAAS_K8S_CONFIG_TMP_K8S_DOMAIN}

		else
			K2HR3CLI_DBAAS_K8S_K8SNAMESPACE=${_DBAAS_K8S_CONFIG_TMP_K8S_NAMESPACE}
			K2HR3CLI_DBAAS_K8S_K8SDOMAIN=${_DBAAS_K8S_CONFIG_TMP_K8S_DOMAIN}
		fi
	fi

	prn_dbg "(check_dbaas_k8s_cluster_domain) Using \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" as kubernets domain and namespace."

	return 0
}

#=====================================================================
# Common functions
#---------------------------------------------------------------------
# Get K2HDKC DBaaS K8S domain directory path
#
# $1		: create directory if not exist(1/0)
# $?		: result(0/1)
# Output	: path
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_DOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX
#
# shellcheck disable=SC2120
get_dbaas_k8s_cluster_directory()
{
	if [ -n "$1" ] && [ "$1" = "1" ]; then
		_DBAAS_K8S_CONFIG_CREATE_DIR=1
	else
		_DBAAS_K8S_CONFIG_CREATE_DIR=0
	fi

	if [ -z "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_DOMAIN}" != "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		prn_err "K2HDKC DBaaS K8S cluster domain parameters are inconsistent: ${K2HR3CLI_DBAAS_K8S_DOMAIN} is not as same as ${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		pecho -n ""
		return 1
	fi

	if [ ! -d "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}" ]; then
		if [ "${_DBAAS_K8S_CONFIG_CREATE_DIR}" -ne 1 ]; then
			prn_dbg "(get_dbaas_k8s_cluster_directory) K2HDKC DBaaS K8S cluster domain directory(${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}) is not existed."
			pecho -n ""
			return 1
		fi
		#
		# Create domain directory
		#
		if ! mkdir -p "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}"; then
			prn_dbg "(get_dbaas_k8s_cluster_directory) K2HDKC DBaaS K8S cluster domain directory(${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}) is not existed, and failed creating it."
			pecho -n ""
			return 1
		fi
	fi
	pecho -n "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}"
	return 0
}

#---------------------------------------------------------------------
#
# Get all K2HDKC DBaaS K8S domain names
#
# $?		: result(0/1)
# Output	: domain names spalated space
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX
#
get_dbaas_k8s_all_domains()
{
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
		prn_warn "K2HDKC DBaaS K8S configuration directory(${K2HR3CLI_DBAAS_K8S_CONFIG}) is not existed."
		pecho -n ""
		return 1
	fi

	_DBAAS_K8S_CONFIG_TMP_LIST=$(ls -d "${K2HR3CLI_DBAAS_K8S_CONFIG}"/"${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}"*/ 2>/dev/null)
	if ! _DBAAS_K8S_CONFIG_TMP_RESULT=$(echo "${_DBAAS_K8S_CONFIG_TMP_LIST}" | sed -e "s#^${K2HR3CLI_DBAAS_K8S_CONFIG}/##g" -e 's#/$##g' -e '/^$/d' 2>/dev/null); then
		prn_warn "Something error occurred in listing K2HDKC DBaaS K8S configuration directory."
		pecho -n ""
		return 0
	fi
	pecho -n "${_DBAAS_K8S_CONFIG_TMP_RESULT}"
	return 0
}

#---------------------------------------------------------------------
# Get value from configuration file
#
# $1		: file path
# $2		: key string
#
# Output	: value
# $?		: result(0/1)
#
get_dbaas_k8s_value_from_configuration()
{
	_DBAAS_K8S_CONFIG_TMP_FILEPATH=$1
	_DBAAS_K8S_CONFIG_TMP_KEYNAME=$2
	if [ ! -f "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}" ] || [ -z "${_DBAAS_K8S_CONFIG_TMP_KEYNAME}" ]; then
		prn_warn "(get_dbaas_k8s_value_from_configuration) Paramteres are wrong."
		pecho -n ""
		return 1
	fi

	if ! _DBAAS_K8S_CONFIG_TMP_VALUE=$(sed -e 's/#.*$//g' -e 's/[[:space:]]*$//g' -e 's/^[[:space:]]*//g' -e '/^$/d' "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}" | grep "^${_DBAAS_K8S_CONFIG_TMP_KEYNAME}[[:space:]]*=" | sed -e "s#^${_DBAAS_K8S_CONFIG_TMP_KEYNAME}[[:space:]]*=[[:space:]]*##g" -e 's/^\"//g' -e 's/\"$//g' | head -1); then
		_DBAAS_K8S_CONFIG_TMP_VALUE=""
	elif [ -z "${_DBAAS_K8S_CONFIG_TMP_VALUE}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=""
	fi
	pecho -n "${_DBAAS_K8S_CONFIG_TMP_VALUE}"
	return 0
}

#---------------------------------------------------------------------
# Set value to configuration file
#
# $1		: file path
# $2		: key string
# $3		: value string
#
# $?		: result(0/1)
#
save_dbaas_k8s_value_from_configuration()
{
	_DBAAS_K8S_CONFIG_TMP_FILEPATH=$1
	_DBAAS_K8S_CONFIG_TMP_KEYNAME=$2
	_DBAAS_K8S_CONFIG_TMP_VALUE=$3
	if [ ! -f "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}" ] || [ -z "${_DBAAS_K8S_CONFIG_TMP_KEYNAME}" ]; then
		prn_warn "(save_dbaas_k8s_value_from_configuration) Paramteres are wrong."
		return 1
	fi

	#
	# Make backup
	#
	cp -p "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}" "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}.$$"

	#
	# Replace
	#
	if ! sed -i -e "s#^[[:space:]]*${_DBAAS_K8S_CONFIG_TMP_KEYNAME}[[:space:]]*=.*#${_DBAAS_K8S_CONFIG_TMP_KEYNAME}=${_DBAAS_K8S_CONFIG_TMP_VALUE}#g" "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}"; then
		#
		# Restore backup file
		#
		cp -p "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}.$$" "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}"
		rm -f "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}.$$"

		prn_err "Failed to save ${_DBAAS_K8S_CONFIG_TMP_KEYNAME} key into ${_DBAAS_K8S_CONFIG_TMP_FILEPATH}."
		return 1
	fi
	rm -f "${_DBAAS_K8S_CONFIG_TMP_FILEPATH}.$$"
	prn_dbg "(save_dbaas_k8s_value_from_configuration) Saved \"${_DBAAS_K8S_CONFIG_TMP_KEYNAME}\" key into \"${_DBAAS_K8S_CONFIG_TMP_FILEPATH}\"."

	return 0
}


#=====================================================================
# Utility functions - command processing for configuration
#---------------------------------------------------------------------
# Get K2HDKC DBaaS K8S configuration path
#
# Output	: path
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_CURDIR
#	K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME
#
get_dbaas_k8s_config_path()
{
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}" ]; then
		if [ ! -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}" ]; then
			prn_err "K2HDKC DBaaS K8S configuration template file(${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}) is not existed."
			return 1
		fi

		if ! sed -e "s#${K2HR3CLI_DBAAS_K8S_KEYWORD_CURRENT_DIR}#${K2HR3CLI_DBAAS_K8S_CURDIR}#g" "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}" > "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}"; then
			prn_err "Failed to copy K2HDKC DBaaS K8S configuration template file(${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}) to local(${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME})."
			return 1
		fi
	fi
	pecho -n "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME}"
	return 0
}

#---------------------------------------------------------------------
# Get K2HDKC DBaaS K8S configuration value
#
# $1		: key string
#
# Output	: value
# $?		: result(0/1)
#
get_dbaas_k8s_config_value()
{
	if ! _DBAAS_K8S_GLOBAL_CONFIG_FILEPATH=$(get_dbaas_k8s_config_path); then
		prn_err "K2HDKC DBaaS K8S Global configuration file is not existed."
		return 0
	fi

	_DBAAS_K8S_CONFIG_TMP_KEYNAME=$1
	if [ -z "${_DBAAS_K8S_CONFIG_TMP_KEYNAME}" ]; then
		pecho -n ""
		return 1
	fi

	if ! _DBAAS_K8S_CONFIG_TMP_VALUE=$(sed -e 's/#.*$//g' -e 's/[[:space:]]*$//g' -e 's/^[[:space:]]*//g' -e '/^$/d' "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}" | grep "^${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}[[:space:]]*=" | sed -e "s#^${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}[[:space:]]*=[[:space:]]*##g" | head -1); then
		_DBAAS_K8S_CONFIG_TMP_VALUE=""
	elif [ -z "${_DBAAS_K8S_CONFIG_TMP_VALUE}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=""
	fi
	pecho -n "${_DBAAS_K8S_CONFIG_TMP_VALUE}"
	return 0
}

# Get K2HDKC DBaaS K8S configuration
#
# $?		: result(0/1)
# Output	: two type
#			  1) not JSON type
#				-------------------------------------
#				KEY=VALUE
#				...
#				-------------------------------------
#			  2) JSON type
#				-------------------------------------
#				{
#					"KEY": "VALUE",
#					...
#				}
#				-------------------------------------
#
# Using Variables
#	K2HR3CLI_OPT_JSON
#	K2HR3CLI_DBAAS_K8S_CONFIG
#
get_dbaas_k8s_config_contents()
{
	if ! _DBAAS_K8S_GLOBAL_CONFIG_FILEPATH=$(get_dbaas_k8s_config_path); then
		if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
			pecho -n "{}"
		else
			pecho -n ""
		fi
		return 0
	fi

	#
	# Load configuration file without comment etc.
	#
	_DBAAS_K8S_CONFIG_TMP_RESULT=$(sed -e 's/#.*$//g' -e 's/[[:space:]]*$//g' -e 's/^[[:space:]]*//g' -e '/^$/d' "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}" | grep '=')

	#
	# For JSON format
	#
	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		_DBAAS_K8S_CONFIG_TMP_ALL=${_DBAAS_K8S_CONFIG_TMP_RESULT}

		_DBAAS_K8S_CONFIG_TMP_RESULT="{"
		_DBAAS_K8S_CONFIG_TMP_FIRST=1
		for _one_value in ${_DBAAS_K8S_CONFIG_TMP_ALL}; do
			_one_key=$(echo "${_one_value}" | sed -e 's/=/ /' | awk '{print $1}')
			_one_value=$(echo "${_one_value}" | sed -e 's/=/ /' | awk '{print $2}')

			_DBAAS_K8S_CONFIG_TMP_ONE="\"${_one_key}\":\"${_one_value}\""

			if [ "${_DBAAS_K8S_CONFIG_TMP_FIRST}" -eq 1 ]; then
				_DBAAS_K8S_CONFIG_TMP_SEP=""
				_DBAAS_K8S_CONFIG_TMP_FIRST=0
			else
				_DBAAS_K8S_CONFIG_TMP_SEP=","
			fi

			_DBAAS_K8S_CONFIG_TMP_RESULT="${_DBAAS_K8S_CONFIG_TMP_RESULT}${_DBAAS_K8S_CONFIG_TMP_SEP}${_DBAAS_K8S_CONFIG_TMP_ONE}"
		done
		_DBAAS_K8S_CONFIG_TMP_RESULT="${_DBAAS_K8S_CONFIG_TMP_RESULT}}"
	fi

	pecho -n "${_DBAAS_K8S_CONFIG_TMP_RESULT}"
	return 0
}

#---------------------------------------------------------------------
# Get K2HDKC DBaaS K8S domains
#
# $?		: result(0/1)
# Output	: two type
#			  1) not JSON type
#				-------------------------------------
#				k8snamespace.k8sdomain
#				...
#				-------------------------------------
#			  2) JSON type
#				-------------------------------------
#				[
#					"",
#					...
#				]
#				-------------------------------------
#
# Using Variables
#	K2HR3CLI_OPT_JSON
#	K2HR3CLI_DBAAS_K8S_CONFIG
#
get_dbaas_k8s_all_domain_contents()
{
	#
	# Get all domains
	#
	if ! _DBAAS_K8S_CONFIG_TMP_RESULT=$(get_dbaas_k8s_all_domains); then
		if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
			pecho -n "[]"
		else
			pecho -n ""
		fi
		return 0
	fi

	#
	# For JSON format
	#
	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		_DBAAS_K8S_CONFIG_TMP_ALL=${_DBAAS_K8S_CONFIG_TMP_RESULT}

		_DBAAS_K8S_CONFIG_TMP_RESULT="["
		_DBAAS_K8S_CONFIG_TMP_FIRST=1
		for _one_value in ${_DBAAS_K8S_CONFIG_TMP_ALL}; do
			_DBAAS_K8S_CONFIG_TMP_ONE="\"${_one_value}\""

			if [ "${_DBAAS_K8S_CONFIG_TMP_FIRST}" -eq 1 ]; then
				_DBAAS_K8S_CONFIG_TMP_SEP=""
				_DBAAS_K8S_CONFIG_TMP_FIRST=0
			else
				_DBAAS_K8S_CONFIG_TMP_SEP=","
			fi

			_DBAAS_K8S_CONFIG_TMP_RESULT="${_DBAAS_K8S_CONFIG_TMP_RESULT}${_DBAAS_K8S_CONFIG_TMP_SEP}${_DBAAS_K8S_CONFIG_TMP_ONE}"
		done
		_DBAAS_K8S_CONFIG_TMP_RESULT="${_DBAAS_K8S_CONFIG_TMP_RESULT}]"
	fi

	pecho -n "${_DBAAS_K8S_CONFIG_TMP_RESULT}"
	return 0
}

#---------------------------------------------------------------------
# Get all K2HDKC DBaaS K8S configuration and domain names
#
# $?		: result(0/1)
# Output	: two type
#			  1) not JSON type
#				-------------------------------------
#				[K2HDKC DBaaS K8S configuration]
#				KEY=VALUE
#				...
#
#				[K2HDKC DBaaS K8S cluster domains]
#				k8snamespace.k8sdomain
#				...
#				-------------------------------------
#			  2) JSON type
#				-------------------------------------
#				{
#					"config": {
#						"KEY": "VALUE",
#						...
#					},
#					"domains": [
#						"",
#						...
#					]
#				}
#				-------------------------------------
#
# Using Variables
#	K2HR3CLI_OPT_JSON
#	K2HR3CLI_DBAAS_K8S_CONFIG
#
get_dbaas_k8s_all_configurations()
{
	_DBAAS_K8S_CONFIG_TMP_GLOBAL=$(get_dbaas_k8s_config_contents)
	_DBAAS_K8S_CONFIG_TMP_DOMAINS=$(get_dbaas_k8s_all_domain_contents)

	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		#
		# JSON
		#
		_DBAAS_K8S_CONFIG_TMP_RESULT="{\"config\":${_DBAAS_K8S_CONFIG_TMP_GLOBAL},\"domains\":${_DBAAS_K8S_CONFIG_TMP_DOMAINS}}"
		pecho "${_DBAAS_K8S_CONFIG_TMP_RESULT}"

	else
		#
		# Not JSON
		#
		pecho "[K2HDKC DBaaS K8S configuration]"
		for _one_element in ${_DBAAS_K8S_CONFIG_TMP_GLOBAL}; do
			if [ -n "${_one_element}" ]; then
				pecho "${_one_element}"
			fi
		done
		pecho "[K2HDKC DBaaS K8S cluster domains]"
		for _one_element in ${_DBAAS_K8S_CONFIG_TMP_DOMAINS}; do
			_filter_one_element=$(echo "${_one_element}" | sed -e "s#^${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}##g")
			if [ -n "${_filter_one_element}" ]; then
				pecho "${_filter_one_element}"
			fi
		done
	fi
	return 0
}

#---------------------------------------------------------------------
# Get K2HDKC DBaaS K8S cluster configuration for K2HR3
#
# $?		: result(0/1)
# Output	: two type
#			  1) not JSON type
#				-------------------------------------
#				KEY=VALUE
#				...
#				-------------------------------------
#			  2) JSON type
#				-------------------------------------
#				{
#					"KEY": "VALUE",
#					...
#				}
#				-------------------------------------
#
# Using Variables
#	K2HR3CLI_OPT_JSON
#	K2HR3CLI_DBAAS_K8S_CONFIG
#	K2HR3CLI_DBAAS_K8S_DOMAIN
#	K2HR3CLI_DBAAS_K8S_K8SNAMESPACE
#	K2HR3CLI_DBAAS_K8S_K8SDOMAIN
#
get_dbaas_k8s_cluster_k2hr3_config_contents()
{
	if [ -z "${K2HR3CLI_DBAAS_K8S_DOMAIN}" ] || [ "${K2HR3CLI_DBAAS_K8S_DOMAIN}" != "${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}" ]; then
		prn_err "K2HDKC DBaaS K8S cluster domain parameters are inconsistent: ${K2HR3CLI_DBAAS_K8S_DOMAIN} is not as same as ${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		return 1
	fi

	#
	# Load configuration file without comment etc.
	#
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
		prn_dbg "(get_dbaas_k8s_cluster_k2hr3_config_contents) K2HDKC DBaaS K8S configuration file(${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) is not existed."
		_DBAAS_K8S_CONFIG_TMP_RESULT=""
	else
		_DBAAS_K8S_CONFIG_TMP_RESULT=$(sed -e 's/#.*$//g' -e 's/[[:space:]]*$//g' -e 's/^[[:space:]]*//g' -e '/^$/d' "${K2HR3CLI_DBAAS_K8S_CONFIG}/${K2HR3CLI_DBAAS_K8S_DOMAIN_PREFIX}${K2HR3CLI_DBAAS_K8S_DOMAIN}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" | grep '=')
	fi

	#
	# Output
	#
	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		#
		# JSON
		#
		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="{\"domain\":{"
		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}\"domain\":\"${K2HR3CLI_DBAAS_K8S_DOMAIN}\","
		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}\"kubernetes namespace\":\"${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}\","
		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}\"kubernetes domain\":\"${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}\"},"

		_DBAAS_K8S_CONFIG_TMP_ALL=${_DBAAS_K8S_CONFIG_TMP_RESULT}
		_DBAAS_K8S_CONFIG_TMP_FIRST=1

		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}\"configurations\":{"
		for _one_value in ${_DBAAS_K8S_CONFIG_TMP_ALL}; do
			_one_key=$(echo "${_one_value}" | sed -e 's/=/ /' | awk '{print $1}')
			_one_value=$(echo "${_one_value}" | sed -e 's/=/ /' | awk '{print $2}')

			_DBAAS_K8S_CONFIG_TMP_ONE="\"${_one_key}\":\"${_one_value}\""

			if [ "${_DBAAS_K8S_CONFIG_TMP_FIRST}" -eq 1 ]; then
				_DBAAS_K8S_CONFIG_TMP_SEP=""
				_DBAAS_K8S_CONFIG_TMP_FIRST=0
			else
				_DBAAS_K8S_CONFIG_TMP_SEP=","
			fi

			_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}${_DBAAS_K8S_CONFIG_TMP_SEP}${_DBAAS_K8S_CONFIG_TMP_ONE}"
		done
		_DBAAS_K8S_CONFIG_TMP_JSON_RESULT="${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}}}"

		pecho "${_DBAAS_K8S_CONFIG_TMP_JSON_RESULT}"

	else
		#
		# Not JSON
		#
		pecho "[K2HDKC DBaaS Kubernetes Configuration]"
		pecho "Kubernetes Domain: ${K2HR3CLI_DBAAS_K8S_DOMAIN}"
		pecho "  Namespace:       ${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}"
		pecho "  Domain:          ${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
		pecho ""
		pecho "[Configurations]"
		if [ -z "${_DBAAS_K8S_CONFIG_TMP_RESULT}" ]; then
			pecho "  (No key and value)"
		else
			for _one_element in ${_DBAAS_K8S_CONFIG_TMP_RESULT}; do
				if [ -n "${_one_element}" ]; then
					pecho "  ${_one_element}"
				fi
			done
		fi
	fi

	return 0
}

#=====================================================================
# Utility functions - K2HR3 configurations
#---------------------------------------------------------------------
# Load K2HR3 configuration
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME
#	K2HR3CLI_DBAAS_K8S_CURDIR
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_EP
#	K2HR3CLI_DBAAS_K8S_R3APP_EP
#	K2HR3CLI_DBAAS_K8S_R3API_NPNUM
#	K2HR3CLI_DBAAS_K8S_R3APP_NPNUM
#	K2HR3CLI_DBAAS_K8S_NODE_IPS
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID
#	K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL
#	K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE
#
load_dbaas_k8s_k2hr3_configuration()
{
	#
	# Check Cluster directory
	#
	# shellcheck disable=SC2119
	if ! _DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory); then
		prn_dbg "(load_dbaas_k8s_k2hr3_configuration) Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 0
	elif [ -z "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_dbg "(load_dbaas_k8s_k2hr3_configuration) Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 0
	fi
	if [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_info "Not found the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster, thus create it."
		if ! mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}"; then
			prn_err "Could not create the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
			return 1
		fi
		prn_dbg "(load_dbaas_k8s_k2hr3_configuration) Created the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
	fi

	#
	# Check K2HR3 configuration file
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
		prn_info "Not found the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) for K2HDKC DBaaS K8S cluster, thus create it."

		if [ ! -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file is not existed."
			return 1
		fi

		#
		# Copy base configuration file
		#
		if ! cp "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}"; then
			prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file."
			return 1
		fi
		prn_dbg "(load_dbaas_k8s_k2hr3_configuration) Created the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME})."

		#
		# Copy template files for kustomization
		#
		if  [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_TEMPL}" ]	|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_TEMPL}" ]; then

			prn_err "Some template files(under ${K2HR3CLI_DBAAS_K8S_CURDIR}) are not existed, thus could not copy thoese to configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH})."
			return 1
		fi

		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_FILE}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_TEMPL}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_FILE_TEMPL}"; then
			prn_err "Failed to copy ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_FILE_TEMPL} file."
			return 1
		fi
	fi

	#
	# Load K2HR3 configuration file
	#
	# [NOTE]
	# By the time this function is called, the options have already been parsed.
	# So, only if there is an unset value, read the value and set it.
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3DKC_NAME')
		K2HR3CLI_DBAAS_K8S_R3DKC_NAME=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_NAME')
		K2HR3CLI_DBAAS_K8S_R3API_NAME=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_NAME')
		K2HR3CLI_DBAAS_K8S_R3APP_NAME=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3DKC_REPS')
		K2HR3CLI_DBAAS_K8S_R3DKC_REPS=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ]; then
			K2HR3CLI_DBAAS_K8S_R3DKC_REPS=2
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_REPS')
		K2HR3CLI_DBAAS_K8S_R3API_REPS=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
			K2HR3CLI_DBAAS_K8S_R3API_REPS=2
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_REPS')
		K2HR3CLI_DBAAS_K8S_R3APP_REPS=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
			K2HR3CLI_DBAAS_K8S_R3APP_REPS=2
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_EP}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_EP')
		K2HR3CLI_DBAAS_K8S_R3API_EP=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_EP}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_EP')
		K2HR3CLI_DBAAS_K8S_R3APP_EP=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_NPNUM')
		K2HR3CLI_DBAAS_K8S_R3API_NPNUM=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_NPNUM')
		K2HR3CLI_DBAAS_K8S_R3APP_NPNUM=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_NODE_IPS}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_NODE_IPS')
		K2HR3CLI_DBAAS_K8S_NODE_IPS=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_C')
		K2HR3CLI_DBAAS_K8S_CERT_C=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_C}" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_C="JP"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_S')
		K2HR3CLI_DBAAS_K8S_CERT_S=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_S}" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_S="Tokyo"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_O')
		K2HR3CLI_DBAAS_K8S_CERT_O=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_O}" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_O="AntPickax"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE')
		K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE}" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=5
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CA_PASS}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CA_PASS')
		K2HR3CLI_DBAAS_K8S_CA_PASS=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET')
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID')
		K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL')
		K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY')
		K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME')
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME=${_DBAAS_K8S_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE')
		K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}" ]; then
			K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE=60
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_API_URL}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_K8S_API_URL')
		K2HR3CLI_DBAAS_K8S_K8S_API_URL=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_API_URL}" ]; then
			K2HR3CLI_DBAAS_K8S_K8S_API_URL="https://kubernetes.default.svc"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_CA_CERT}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_K8S_CA_CERT')
		K2HR3CLI_DBAAS_K8S_K8S_CA_CERT=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_CA_CERT}" ]; then
			K2HR3CLI_DBAAS_K8S_K8S_CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
		fi
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN}" ]; then
		_DBAAS_K8S_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN')
		K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN=${_DBAAS_K8S_CONFIG_TMP_VALUE}
		if [ -z "${K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN}" ]; then
			K2HR3CLI_DBAAS_K8S_K8S_SA_TOKEN="/var/run/secrets/kubernetes.io/serviceaccount/token"
		fi
	fi

	prn_dbg "(load_dbaas_k8s_k2hr3_configuration) Finished loading values from configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME})."
	return 0
}

#---------------------------------------------------------------------
# Save K2HR3 configuration
#
# $1		: key string
# $2		: value string
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_CURDIR
#	K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME
#
save_dbaas_k8s_k2hr3_configuration()
{
	_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME=$1
	_DBAAS_K8S_CONFIG_TMP_SAVE_VALUE=$2
	if [ -z "${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}" ]; then
		prn_err "Save key name is empty."
		return 1
	fi

	#
	# Check Cluster directory
	#
	# shellcheck disable=SC2119
	if ! _DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory); then
		prn_err "Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 1
	elif [ -z "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_err "Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 1
	fi
	if [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_info "Not found the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster, thus create it."
		if ! mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}"; then
			prn_err "Could not create the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
			return 1
		fi
		prn_dbg "(save_dbaas_k8s_k2hr3_configuration) Created the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
	fi

	#
	# Check K2HR3 configuration file
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
		prn_info "Not found the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) for K2HDKC DBaaS K8S cluster, thus create it."

		if [ ! -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file is not existed."
			return 1
		fi

		if ! cp "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}"; then
			prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file."
			return 1
		fi
		prn_dbg "(save_dbaas_k8s_k2hr3_configuration) Created the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME})."
	fi

	#
	# Save K2HR3 configuration
	#
	if ! save_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" "${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}" "${_DBAAS_K8S_CONFIG_TMP_SAVE_VALUE}"; then
		prn_err "Could not save key(${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}) to the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) for K2HDKC DBaaS K8S cluster."
		return 1
	fi
	prn_dbg "(save_dbaas_k8s_k2hr3_configuration) Saved key(${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}) to the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) for K2HDKC DBaaS K8S cluster."

	return 0
}

#---------------------------------------------------------------------
# Print K2HR3 configurations
#
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME
#	K2HR3CLI_DBAAS_K8S_CURDIR
#	K2HR3CLI_DBAAS_K8S_R3DKC_NAME
#	K2HR3CLI_DBAAS_K8S_R3API_NAME
#	K2HR3CLI_DBAAS_K8S_R3APP_NAME
#	K2HR3CLI_DBAAS_K8S_R3DKC_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_REPS
#	K2HR3CLI_DBAAS_K8S_R3APP_REPS
#	K2HR3CLI_DBAAS_K8S_R3API_EP
#	K2HR3CLI_DBAAS_K8S_R3APP_EP
#	K2HR3CLI_DBAAS_K8S_R3API_NPNUM
#	K2HR3CLI_DBAAS_K8S_R3APP_NPNUM
#	K2HR3CLI_DBAAS_K8S_NODE_IPS
#	K2HR3CLI_DBAAS_K8S_CERT_C
#	K2HR3CLI_DBAAS_K8S_CERT_S
#	K2HR3CLI_DBAAS_K8S_CERT_O
#	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE
#	K2HR3CLI_DBAAS_K8S_CA_PASS
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET
#	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID
#	K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL
#	K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME
#	K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE
#
print_dbaas_k8s_k2hr3_configuration()
{
	#
	# Check Cluster directory
	#
	# shellcheck disable=SC2119
	if ! _DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory); then
		prn_err "Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 1
	elif [ -z "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_err "Could not get the configuration directory path of K2HDKC DBaaS K8S cluster."
		return 1
	fi
	if [ ! -d "${_DBAAS_K8S_CLUSTER_DIRPATH}" ]; then
		prn_info "Not found the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster, thus create it."
		if ! mkdir -p "${_DBAAS_K8S_CLUSTER_DIRPATH}"; then
			prn_err "Could not create the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
			return 1
		fi
		prn_dbg "(print_dbaas_k8s_k2hr3_configuration) Created the configuration directory(${_DBAAS_K8S_CLUSTER_DIRPATH}) for K2HDKC DBaaS K8S cluster."
	fi

	#
	# Check K2HR3 configuration file
	#
	if [ ! -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
		prn_info "Not found the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}) for K2HDKC DBaaS K8S cluster, thus create it."

		if [ ! -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file is not existed."
			return 1
		fi

		if ! cp "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}"; then
			prn_err "Failed to create ${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME} file."
			return 1
		fi
		prn_dbg "(print_dbaas_k8s_k2hr3_configuration) Created the configuration file(${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME})."
	fi

	#
	# Load configuration
	#
	K2HR3CLI_DBAAS_K8S_R3DKC_NAME=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3DKC_NAME')
	K2HR3CLI_DBAAS_K8S_R3API_NAME=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_NAME')
	K2HR3CLI_DBAAS_K8S_R3APP_NAME=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_NAME')
	K2HR3CLI_DBAAS_K8S_R3DKC_REPS=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3DKC_REPS')
	K2HR3CLI_DBAAS_K8S_R3API_REPS=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_REPS')
	K2HR3CLI_DBAAS_K8S_R3APP_REPS=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_REPS')
	K2HR3CLI_DBAAS_K8S_R3API_EP=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_EP')
	K2HR3CLI_DBAAS_K8S_R3APP_EP=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_EP')
	K2HR3CLI_DBAAS_K8S_R3API_NPNUM=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3API_NPNUM')
	K2HR3CLI_DBAAS_K8S_R3APP_NPNUM=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_R3APP_NPNUM')
	K2HR3CLI_DBAAS_K8S_NODE_IPS=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_NODE_IPS')
	K2HR3CLI_DBAAS_K8S_CERT_C=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_C')
	K2HR3CLI_DBAAS_K8S_CERT_S=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_S')
	K2HR3CLI_DBAAS_K8S_CERT_O=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_O')
	K2HR3CLI_DBAAS_K8S_CERT_EXPIRE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CERT_EXPIRE')
	#K2HR3CLI_DBAAS_K8S_CA_PASS=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_CA_PASS')
	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET')
	K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID')
	K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL')
	K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY')
	K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME')
	K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE=$(get_dbaas_k8s_value_from_configuration "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME}" 'K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE')

	#
	# Check empty variables
	#
	if	[ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ]	|| \
		[ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]	|| \
		[ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then

		#
		# No K2HR3 system
		#
		if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
			#
			# JSON
			#
			_DBAAS_K8S_TMP_OUTPUT_JSON="{"
			_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Directory\":\"${_DBAAS_K8S_CLUSTER_DIRPATH}\","
			_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 system\":{},"
			_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 Certificates\":{},"
			_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 Certificates\":{},"
			_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 OIDC\":{}}"
			pecho -n "${_DBAAS_K8S_TMP_OUTPUT_JSON}"

		else
			#
			# Not JSON
			#
			pecho "[Directory]"
			pecho "  Path         : ${_DBAAS_K8S_CLUSTER_DIRPATH}"
			pecho "[K2HR3 system]"
			pecho "[K2HR3 Certificates]"
			pecho "[K2HR3 OIDC]"
		fi

		return 0
	fi

	#
	# Hostnames
	#
	if [ -n "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ] && [ "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" -gt 0 ]; then
		_DBAAS_K8S_TMP_R3DKC_HOST_MAXNUM=$((K2HR3CLI_DBAAS_K8S_R3DKC_REPS - 1))
		_DBAAS_K8S_TMP_R3DKC_HOSTNAME="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-[0-${_DBAAS_K8S_TMP_R3DKC_HOST_MAXNUM}].${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
	else
		_DBAAS_K8S_TMP_R3DKC_HOSTNAME="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-[?].${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
	fi

	if [ -n "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ] && [ "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" -gt 0 ]; then
		_DBAAS_K8S_TMP_R3API_HOST_MAXNUM=$((K2HR3CLI_DBAAS_K8S_R3API_REPS - 1))
		_DBAAS_K8S_TMP_R3API_HOSTNAME="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-[0-${_DBAAS_K8S_TMP_R3API_HOST_MAXNUM}].${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
	else
		_DBAAS_K8S_TMP_R3API_HOSTNAME="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-[?].${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"
	fi

	_DBAAS_K8S_TMP_R3APP_HOSTNAME="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}-<hash value>.${K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}.${K2HR3CLI_DBAAS_K8S_K8SNAMESPACE}.${K2HR3CLI_DBAAS_K8S_K8SDOMAIN}"

	#
	# Files
	#
	if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}" ]; then
		if [ -f "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}" ]; then
			_DBAAS_K8S_TMP_CA_CERT="${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME},${K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME}/${K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME}"
		else
			_DBAAS_K8S_TMP_CA_CERT="${K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME}"
		fi
	else
		_DBAAS_K8S_TMP_CA_CERT=""
	fi

	_DBAAS_K8S_TMP_FILE_PATTERN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}-*{${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}}"
	_DBAAS_K8S_TMP_K2HDKC_FILE_LIST=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_TMP_FILE_PATTERN}" 2>/dev/null)
	_DBAAS_K8S_TMP_K2HDKC_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HDKC_FILE_LIST}" | sed -e "s#^${_DBAAS_K8S_CLUSTER_DIRPATH}/##g" -e 's#/$##g' -e '/^$/d' -e 2>/dev/null)
	_DBAAS_K8S_TMP_K2HDKC_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HDKC_CERTS}" | sed -e 's/ /,/g')

	_DBAAS_K8S_TMP_FILE_PATTERN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3API_NAME}-*{${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}}"
	_DBAAS_K8S_TMP_K2HR3_API_FILE_LIST=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_TMP_FILE_PATTERN}" 2>/dev/null)
	_DBAAS_K8S_TMP_K2HR3_API_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HR3_API_FILE_LIST}" | sed -e "s#^${_DBAAS_K8S_CLUSTER_DIRPATH}/##g" -e 's#/$##g' -e '/^$/d' -e 2>/dev/null)
	_DBAAS_K8S_TMP_K2HR3_API_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HR3_API_CERTS}" | sed -e 's/ /,/g')

	_DBAAS_K8S_TMP_FILE_PATTERN="${K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX}${K2HR3CLI_DBAAS_K8S_R3APP_NAME}*{${K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX},${K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX}}"
	_DBAAS_K8S_TMP_K2HR3_APP_FILE_LIST=$(ls -1 "${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME}/${_DBAAS_K8S_TMP_FILE_PATTERN}" 2>/dev/null)
	_DBAAS_K8S_TMP_K2HR3_APP_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HR3_APP_FILE_LIST}" | sed -e "s#^${_DBAAS_K8S_CLUSTER_DIRPATH}/##g" -e 's#/$##g' -e '/^$/d' -e 2>/dev/null)
	_DBAAS_K8S_TMP_K2HR3_APP_CERTS=$(echo "${_DBAAS_K8S_TMP_K2HR3_API_CERTS}" | sed -e 's/ /,/g')

	#
	# Output K2HR3 configuration file
	#
	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		#
		# JSON
		#
		_DBAAS_K8S_TMP_OUTPUT_JSON="{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Directory\":\"${_DBAAS_K8S_CLUSTER_DIRPATH}\","

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 system\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Base name\":\"${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Replicas\":\"${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Hostnames\":\"${_DBAAS_K8S_TMP_R3DKC_HOSTNAME}\"},"

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 API\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Base name\":\"${K2HR3CLI_DBAAS_K8S_R3API_NAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Replicas\":\"${K2HR3CLI_DBAAS_K8S_R3API_REPS}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Hostnames\":\"${_DBAAS_K8S_TMP_R3API_HOSTNAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"NodePort\":\"${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"EndPoint\":\"${K2HR3CLI_DBAAS_K8S_R3API_EP}\"},"

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 APP\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Base name\":\"${K2HR3CLI_DBAAS_K8S_R3APP_NAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Replicas\":\"${K2HR3CLI_DBAAS_K8S_R3APP_REPS}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Hostnames\":\"${_DBAAS_K8S_TMP_R3APP_HOSTNAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"NodePort\":\"${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"EndPoint\":\"${K2HR3CLI_DBAAS_K8S_R3APP_EP}\"},"

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"Node IPs\":\"${K2HR3CLI_DBAAS_K8S_NODE_IPS}\"},"

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 Certificates\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CERT COUNTRY\":\"${K2HR3CLI_DBAAS_K8S_CERT_C}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CERT STATE\":\"${K2HR3CLI_DBAAS_K8S_CERT_S}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CERT ORGANAIZAATION\":\"${K2HR3CLI_DBAAS_K8S_CERT_O}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CERT PERIOD \":\"${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE} years\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CA CERT\":\"${_DBAAS_K8S_TMP_CA_CERT}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC CERTS\":\"${_DBAAS_K8S_TMP_K2HDKC_CERTS}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 API CERTS\":\"${_DBAAS_K8S_TMP_K2HR3_API_CERTS}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 APP CERTS\":\"${_DBAAS_K8S_TMP_K2HR3_APP_CERTS}\"},"

		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HR3 OIDC\":{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CLIENT SECRET\":\"${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"CLIENT ID\":\"${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"ISSUER URL\":\"${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"USERNAME KEY\":\"${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"COOKIE NAME\":\"${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"COOKIE EXPIRE\":\"${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}\"}}"

		pecho -n "${_DBAAS_K8S_TMP_OUTPUT_JSON}"

	else
		#
		# Not JSON
		#
		pecho "[Directory]"
		pecho "  Path         : ${_DBAAS_K8S_CLUSTER_DIRPATH}"

		pecho "[K2HR3 system]"
		pecho "  K2HDKC"
		pecho "    Base name  : ${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}"
		pecho "    Replicas   : ${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}"
		pecho "    Hostnames  : ${_DBAAS_K8S_TMP_R3DKC_HOSTNAME}"

		pecho "  K2HR3 API"
		pecho "    Base name  : ${K2HR3CLI_DBAAS_K8S_R3API_NAME}"
		pecho "    Replicas   : ${K2HR3CLI_DBAAS_K8S_R3API_REPS}"
		pecho "    Hostnames  : ${_DBAAS_K8S_TMP_R3API_HOSTNAME}"
		pecho "    NodePort   : ${K2HR3CLI_DBAAS_K8S_R3API_NPNUM}"
		pecho "    EndPoint   : ${K2HR3CLI_DBAAS_K8S_R3API_EP}"

		pecho "  K2HR3 APP"
		pecho "    Base name  : ${K2HR3CLI_DBAAS_K8S_R3APP_NAME}"
		pecho "    Replicas   : ${K2HR3CLI_DBAAS_K8S_R3APP_REPS}"
		pecho "    Hostnames  : ${_DBAAS_K8S_TMP_R3APP_HOSTNAME}"
		pecho "    NodePort   : ${K2HR3CLI_DBAAS_K8S_R3APP_NPNUM}"
		pecho "    EndPoint   : ${K2HR3CLI_DBAAS_K8S_R3APP_EP}"
		pecho "  Node IPs     : ${K2HR3CLI_DBAAS_K8S_NODE_IPS}"

		pecho "[K2HR3 Certificates]"
		pecho "  CERT COUNTRY         : ${K2HR3CLI_DBAAS_K8S_CERT_C}"
		pecho "  CERT STATE           : ${K2HR3CLI_DBAAS_K8S_CERT_S}"
		pecho "  CERT ORGANAIZAATION  : ${K2HR3CLI_DBAAS_K8S_CERT_O}"
		pecho "  CERT PERIOD          : ${K2HR3CLI_DBAAS_K8S_CERT_EXPIRE} years"
		pecho "  CA CERT              : ${_DBAAS_K8S_TMP_CA_CERT}"
		pecho "  K2HDKC CERTS         : ${_DBAAS_K8S_TMP_K2HDKC_CERTS}"
		pecho "  K2HR3 API CERTS      : ${_DBAAS_K8S_TMP_K2HR3_API_CERTS}"
		pecho "  K2HR3 APP CERTS      : ${_DBAAS_K8S_TMP_K2HR3_APP_CERTS}"

		pecho "[K2HR3 OIDC]"
		pecho "  CLIENT SECRET        : ${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_SECRET}"
		pecho "  CLIENT ID            : ${K2HR3CLI_DBAAS_K8S_OIDC_CLIENT_ID}"
		pecho "  ISSUER URL           : ${K2HR3CLI_DBAAS_K8S_OIDC_ISSUER_URL}"
		pecho "  USERNAME KEY         : ${K2HR3CLI_DBAAS_K8S_OIDC_USERNAME_KEY}"
		pecho "  COOKIE NAME          : ${K2HR3CLI_DBAAS_K8S_OIDC_COOKIENAME}"
		pecho "  COOKIE EXPIRE        : ${K2HR3CLI_DBAAS_K8S_OIDC_COOKIE_EXPIRE}"
	fi

	return 0
}

#=====================================================================
# Utility functions - K2HDKC Cluster configurations
#---------------------------------------------------------------------
# Set variables for K2HDKC Cluster
#
# $1		: cluster name
# $?		: result(0/1)
#
# Output Variables
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE
#
set_dbaas_k8s_k2hdkc_cluster_variables()
{
	_DBAAS_K8S_K2HDKC_CLUSTER_NAME=$1
	if [ -z "${_DBAAS_K8S_K2HDKC_CLUSTER_NAME}" ]; then
		prn_err "K2HDKC DBaaS cluster name is not specified."
		return 1
	fi

	#
	# Setup variables without checking
	#
	# shellcheck disable=SC2119
	_DBAAS_K8S_CLUSTER_DIRPATH=$(get_dbaas_k8s_cluster_directory)
	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CLUSTER_PREFIX}${_DBAAS_K8S_K2HDKC_CLUSTER_NAME}"
	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE="${_DBAAS_K8S_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_CLUSTER_PREFIX}${_DBAAS_K8S_K2HDKC_CLUSTER_NAME}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}"

	return 0
}

#---------------------------------------------------------------------
# Load K2HDKC Cluster configuration
#
# $1		: cluster name
# $2		: 1/0 - force(create directory/file, if not exist it)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT
#
load_dbaas_k8s_k2hdkc_cluster_configuration()
{
	if [ -n "$2" ] && [ "$2" =  "1" ]; then
		_DBAAS_K8S_TMP_FORCE_FLAG=1
	else
		_DBAAS_K8S_TMP_FORCE_FLAG=0
	fi

	#
	# Setup paths
	#
	if ! set_dbaas_k8s_k2hdkc_cluster_variables "$1"; then
		return 1
	fi

	#
	# Check cluster directory and configuration file, if not existed, create those.
	#
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" ]; then
		prn_info "Not found the K2HDKC cluster configuration directory(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}), thus create it."

		if [ "${_DBAAS_K8S_TMP_FORCE_FLAG}" -ne 1 ]; then
			return 1
		fi

		if ! mkdir -p "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}"; then
			prn_err "The K2HDKC cluster ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH} is not existed, and failed creating it."
			return 1
		fi
		prn_dbg "(load_dbaas_k8s_k2hdkc_cluster_configuration) The K2HDKC cluster ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH} is not existed, and created it."
	fi

	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_info "Not found the K2HDKC cluster configuration file(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}), thus create it."

		if [ "${_DBAAS_K8S_TMP_FORCE_FLAG}" -ne 1 ]; then
			return 1
		fi

		if [ ! -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}" ]; then
			prn_err "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME} file is not existed."
			return 1
		fi

		#
		# Copy base configuration file
		#
		if ! cp "${K2HR3CLI_DBAAS_K8S_CURDIR}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"; then
			prn_err "Failed to create ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE} file."
			return 1
		fi
		prn_dbg "(load_dbaas_k8s_k2hdkc_cluster_configuration) Created the cluster configuration file(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE})."

		#
		# Copy template files for kustomization
		#
		if	[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_TEMPL}" ]	|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_TEMPL}" ]		|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_TEMPL}" ]	|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_TEMPL}" ]	|| \
			[ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_TEMPL}" ]; then

			prn_err "Some template files(under ${K2HR3CLI_DBAAS_K8S_CURDIR}) are not existed, thus could not copy thoese to configuration directory(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH})."
			return 1
		fi

		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_TEMPL}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_FILE}"; then
			prn_err "Failed to copy ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_TEMPL}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_FILE}"; then
			prn_err "Failed to copy ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_TEMPL}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE}"; then
			prn_err "Failed to copy ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_TEMPL}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE}"; then
			prn_err "Failed to copy ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE} file."
			return 1
		fi
		if ! cp "${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_TEMPL}" "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE}"; then
			prn_err "Failed to copy ${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}/${K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE} file."
			return 1
		fi
	fi

	#
	# Load K2HDKC cluster configurations
	#
	# [NOTE]
	# By the time this function is called, the options have already been parsed.
	# So, only if there is an unset value, read the value and set it.
	#
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}" ]; then
		_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT')
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT=${_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ]; then
		_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT')
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT=${_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
		_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT')
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT=${_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ]; then
		_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT')
		K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=${_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE}
	fi
	if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
		_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE=$(get_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" 'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT')
		K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=${_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_TMP_VALUE}
	fi

	prn_dbg "(load_dbaas_k8s_k2hdkc_cluster_configuration) Finished loading values from k2hdkc cluster configuration file(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE})."
	return 0
}

#---------------------------------------------------------------------
# Save K2HDKC Cluster configuration
#
# $1		: cluster name
# $2		: key string
# $3		: value string
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE
#
save_dbaas_k8s_k2hdkc_cluster_configuration()
{
	_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME=$2
	_DBAAS_K8S_CONFIG_TMP_SAVE_VALUE=$3
	if [ -z "${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}" ]; then
		prn_err "Save key name is empty."
		return 1
	fi

	#
	# Setup paths
	#
	if ! set_dbaas_k8s_k2hdkc_cluster_variables "$1"; then
		return 1
	fi

	#
	# Check cluster exist
	#
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" ]; then
		prn_err "The K2HDKC cluster $1 is not existed."
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_err "The K2HDKC cluster $1 is not initialized."
		return 1
	fi

	#
	# Save K2HDKC Cluster configuration
	#
	if ! save_dbaas_k8s_value_from_configuration "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" "${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}" "${_DBAAS_K8S_CONFIG_TMP_SAVE_VALUE}"; then
		prn_err "Could not save key(${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}) to the k2hdkc cluster configuration file(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE})."
		return 1
	fi
	prn_dbg "(save_dbaas_k8s_k2hdkc_cluster_configuration) Saved key(${_DBAAS_K8S_CONFIG_TMP_SAVE_KEYNAME}) to the k2hdkc cluster configuration file(${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE})."

	return 0
}

#---------------------------------------------------------------------
# Print K2HDKC Cluster configurations
#
# $1		: cluster name
# $2		: 1/0 - force(create directory/file, if not exist it)
# $?		: result(0/1)
#
# Using Variables
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH
#	K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT
#	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT
#
print_dbaas_k8s_k2hdkc_cluster_configuration()
{
	if [ -n "$2" ] && [ "$2" =  "1" ]; then
		_DBAAS_K8S_TMP_FORCE_FLAG=1
	else
		_DBAAS_K8S_TMP_FORCE_FLAG=0
	fi

	#
	# Setup paths
	#
	if ! set_dbaas_k8s_k2hdkc_cluster_variables "$1"; then
		return 1
	fi

	#
	# Check cluster exist
	#
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_DIRPATH}" ]; then
		prn_err "The K2HDKC cluster $1 is not existed."
		return 1
	fi
	if [ ! -f "${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}" ]; then
		prn_err "The K2HDKC cluster $1 is not initialized."
		return 1
	fi

	#
	# Load configuration
	#
	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT=$(get_dbaas_k8s_value_from_configuration	"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"	'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT')
	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT=$(get_dbaas_k8s_value_from_configuration	"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"	'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT')
	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT=$(get_dbaas_k8s_value_from_configuration	"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"	'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT')
	K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT=$(get_dbaas_k8s_value_from_configuration		"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"	'K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT')
	K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT=$(get_dbaas_k8s_value_from_configuration		"${K2HR3CLI_DBAAS_K8S_K2HDKC_CLUSTER_CONFIG_FILE}"	'K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT')

	#
	# Output K2HDKC configuration file
	#
	if [ -n "${K2HR3CLI_OPT_JSON}" ] && [ "${K2HR3CLI_OPT_JSON}" = "1" ]; then
		#
		# JSON
		#
		_DBAAS_K8S_TMP_OUTPUT_JSON="{"
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC server port\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC server contorl port\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}\","
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC slave control port\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}\""
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC server count\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}\""
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}\"K2HDKC slave count\":\"${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}\""
		_DBAAS_K8S_TMP_OUTPUT_JSON="${_DBAAS_K8S_TMP_OUTPUT_JSON}}"

		pecho -n "${_DBAAS_K8S_TMP_OUTPUT_JSON}"

	else
		#
		# Not JSON
		#
		pecho ""
		pecho "K2HDKC server port:         ${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}"
		pecho "K2HDKC server contorl port: ${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}"
		pecho "K2HDKC slave contorl port:  ${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}"
		pecho "K2HDKC server count:        ${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}"
		pecho "K2HDKC slave count:         ${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}"
		pecho ""
	fi

	return 0
}

#=====================================================================
# Main
#=====================================================================
#
# Determine the config directory
#
# [NOTE]
# K2HR3CLI_DBAAS_K8S_CONFIG has been overwritten by the configuration,
# environment variables and options of the k2hr3 main unit, and this
# function (file) is called in that state.
# And the K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME file under the
# K2HR3CLI_DBAAS_K8S_CONFIG directory is a variable that does not
# depend on other options, so when you load this file, the values in
# that file will be read. The file contains paths such as templates.
#
if [ -n "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
	#
	# Check the directory exist
	#
	if [ ! -d "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
		prn_warn "The K2HDKC DBaaS K8S configuration directory(${K2HR3CLI_DBAAS_K8S_CONFIG}) was specified, but it does not exist."
		K2HR3CLI_DBAAS_K8S_CONFIG=""
	fi
fi
if [ -z "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
	#
	# Set default directory
	#
	if ! _DBAAS_K8S_DEFAULT_USER_DIR=$(config_get_default_user_dir); then
		prn_err "The user's home directory cannot be found."
		exit 1
	fi
	K2HR3CLI_DBAAS_K8S_CONFIG="${_DBAAS_K8S_DEFAULT_USER_DIR}/${K2HR3CLI_DBAAS_K8S_DEFAULT_CONFIG_DIRNAME}"
fi

#
# Check the config directory
#
if [ ! -d "${K2HR3CLI_DBAAS_K8S_CONFIG}" ]; then
	if ! _DBAAS_K8S_CONFIG_TMP_RESULT=$(mkdir -p "${K2HR3CLI_DBAAS_K8S_CONFIG}" 2>&1); then
		prn_err "Failed the configuration directory(${K2HR3CLI_DBAAS_K8S_CONFIG}) with error: ${_DBAAS_K8S_CONFIG_TMP_RESULT}"
		exit 1
	fi
	prn_dbg "Created the configuration directory(${K2HR3CLI_DBAAS_K8S_CONFIG})."
fi

#
# Load Global configration
#
if ! _DBAAS_K8S_GLOBAL_CONFIG_FILEPATH=$(get_dbaas_k8s_config_path); then
	prn_err "K2HDKC DBaaS K8S Global configuration file is not existed."
	exit 1
elif [ -z "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}" ]; then
	prn_err "K2HDKC DBaaS K8S Global configuration file is not existed."
	exit 1
fi
if [ ! -f "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}" ]; then
	prn_err "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH} file is not existed."
	exit 1
fi
. "${_DBAAS_K8S_GLOBAL_CONFIG_FILEPATH}"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
