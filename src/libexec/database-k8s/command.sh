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
# Variables
#--------------------------------------------------------------
#
# k2hr3 bin
#
# shellcheck disable=SC2034
K2HR3CLIBIN="${BINDIR}/${BINNAME}"

#
# Directry Path
#
# shellcheck disable=SC2034
K2HR3CLI_DBAAS_K8S_CURDIR=${LIBEXECDIR}/${K2HR3CLI_MODE}

#
# SubCommand(2'nd option), SubMode(3'rd option)
#
# See. option.sh
#

#--------------------------------------------------------------
# Load Command / Mode / Option names for DBaaS K8S
#--------------------------------------------------------------
#
# Common const variables
#
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/constvariables.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/constvariables.sh"
fi

#
# DBaaS K8S commad / mode / option
#
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/options.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/options.sh"
fi

#
# Utility functions and common variables
#
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/functions.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/functions.sh"
fi
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/certification.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/certification.sh"
fi

#
# Utility for Kubernetes
#
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/k8sapi.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/k8sapi.sh"
fi

#
# kubectl command check
#
check_kubectl_command
if [ $? -ne 0 ]; then
	exit 1
fi

#
# Check DBaaS K8S options
#
parse_dbaas_k8s_option "$@"
if [ $? -ne 0 ]; then
	exit 1
else
	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}
fi

#
# Set configuration directory path and load functions
#
if [ -f "${K2HR3CLI_DBAAS_K8S_CURDIR}/configuration.sh" ]; then
	. "${K2HR3CLI_DBAAS_K8S_CURDIR}/configuration.sh"
fi

#
# Check and Set default domain if those are not set
#
# [NOTE]
# Need to call this function here, because it needs to load option parameteres
#
check_dbaas_k8s_cluster_domain
if [ $? -ne 0 ]; then
	exit 1
fi

#
# Load K2HR3 configuration
#
load_dbaas_k8s_k2hr3_configuration
if [ $? -ne 0 ]; then
	prn_err "Failed loading K2HR3 configuration for K2HDKC DBaaS K8S."
	exit 1
fi

#--------------------------------------------------------------
# Parse arguments
#--------------------------------------------------------------
#
# Sub Command
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
	K2HR3CLI_SUBCOMMAND=""
else
	#
	# Always using lower case
	#
	K2HR3CLI_SUBCOMMAND=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Execute type after Sub Command
#
parse_noprefix_option "$@"
if [ $? -ne 0 ]; then
	exit 1
fi
if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
	K2HR3CLI_DBAAS_K8S_EXEC=""
else
	#
	# Always using lower case
	#
	K2HR3CLI_DBAAS_K8S_EXEC=$(to_lower "${K2HR3CLI_OPTION_NOPREFIX}")
fi
# shellcheck disable=SC2086
set -- ${K2HR3CLI_OPTION_PARSER_REST}

#
# Parameters after execute type
#
if [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CONFIG}" ]; then
	#
	# Config sub command(nothind to do)
	#
	:

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CERT}" ]; then
	#
	# Cert sub command
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# Show cerfification list or certificate file
		#
		parse_noprefix_option "$@"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_NAME=""
		else
			K2HR3CLI_DBAAS_K8S_CERT_NAME=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SET}" ]; then
		#
		# Set certificate file
		#

		#
		# 1'st cert file path
		#
		parse_noprefix_option "$@"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_1=""
		else
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_1=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# 1'st cert key file path
		#
		parse_noprefix_option "$@"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_1=""
		else
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_1=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# 2'nd cert file path
		#
		parse_noprefix_option "$@"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_2=""
		else
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_2=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

		#
		# 2'nd cert key file path
		#
		parse_noprefix_option "$@"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_2=""
		else
			K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_2=${K2HR3CLI_OPTION_NOPREFIX}
		fi
		# shellcheck disable=SC2086
		set -- ${K2HR3CLI_OPTION_PARSER_REST}

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# Create certificate file(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# Delete certificate file(nothing to do)
		#
		:
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HR3}" ]; then
	#
	# K2HR3 sub command
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# Show K2HR3 information(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# Create/Apply K2HR3 system(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# Delete K2HR3 system(nothing to do)
		#
		:

	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HDKC}" ]; then
	#
	# K2HDKC sub command
	#

	#
	# All exec command needs "cluster name", so check it here
	#
	parse_noprefix_option "$@"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	if [ "X${K2HR3CLI_OPTION_NOPREFIX}" = "X" ]; then
		prn_err "\"K2HDKC Cluster name\" is not specified. \"K2HDKC Cluster name\" is required for this command."
		exit 1
	fi
	K2HR3CLI_DBAAS_K8S_CLUSTER_NAME=${K2HR3CLI_OPTION_NOPREFIX}

	# shellcheck disable=SC2086
	set -- ${K2HR3CLI_OPTION_PARSER_REST}

	#
	# Load K2HDKC Cluster configuration
	#
	load_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"

	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# Show K2HDKC Cluster information(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SETUP}" ]; then
		#
		# Show K2HDKC Cluster information(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# Create/Apply K2HDKC Cluster (nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SCALE}" ]; then
		#
		# Show K2HDKC Cluster information(nothing to do)
		#
		:

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# Delete K2HDKC Cluster (nothing to do)
		#
		:

	fi
fi

#--------------------------------------------------------------
# Processing
#--------------------------------------------------------------
#
# Set variables for hostnames and ipaddresses(for minikube)
#
set_localhost_name_ip_variables

#
# Main
#
if [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CONFIG}" ]; then
	#
	# CONFIGRATION SUB COMMAND
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_LIST}" ]; then
		#
		# LIST CONFIGRATION
		#
		get_dbaas_k8s_all_configurations
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Something error occurred."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Completed listing the configuration of K2HDKC DBaaS K8S"

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# SHOW CONFIGRATION
		#
		get_dbaas_k8s_cluster_k2hr3_config_contents
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Something error occurred."
			return 1
		fi
		if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
			prn_msg "${CGRN}Succeed${CDEF} : Print configuration."
		fi

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the execute type(${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_LIST} or ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CERT}" ]; then
	#
	# CERTIFICATE SUB COMMAND
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# SHOW CERTIFICATE
		#
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_NAME}" = "X" ]; then
			#
			# Certificate file name is not specified, then list all certificates
			#
			get_dbaas_k8s_domain_certificates
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Could not get certificates for \"${K2HR3CLI_DBAAS_K8S_DOMAIN}\" domain."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Completed listing the certificates for K2HDKC DBaaS K8S"
			fi

		else
			#
			# Certificate file name is specified, then print that certificate
			#
			print_dbaas_k8s_domain_certificate
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Something error occurred."
				exit $?
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Completed showing the certificate"
			fi
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SET}" ]; then
		#
		# SET CERTIFICATE
		#

		#
		# Check type option
		#
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
			prn_msg "${CRED}Failed${CDEF} : There is an error in the type(${K2HR3CLI_DBAAS_K8S_CERT_TYPE}) of certificate to be set."
			return 1
		fi

		#
		# Check parameters(certificate file paths)
		#
		if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_1}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_1}" ]; then
			prn_msg "${CRED}Failed${CDEF} : The first certificate or private key have not been set."
			return 1
		fi
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] || [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
			if [ -z "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_2}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_2}" ]; then
				prn_msg "${CRED}Failed${CDEF} : The second certificate or private key have not been set."
				return 1
			fi
		fi

		#
		# Set variables for interactive mode
		#
		complement_dbaas_k2hr3_k2hdkc_name
		complement_dbaas_k2hr3api_name
		complement_dbaas_k2hr3app_name

		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_HOST_NUM}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name and host number to set the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi
		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
			if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_HOST_NUM}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name and host number to set the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi
		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
			if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name to set the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi
		fi

		#
		# Set certificate files
		#
		set_dbaas_k8s_domain_certificates "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_1}" "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_1}" "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_CERT_2}" "${K2HR3CLI_DBAAS_K8S_CERT_PARAM_KEY_2}"
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed to set certificates"
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Set certificates for K2HDKC DBaaS K8S"

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# CREATE/APPLY CERTIFICATE
		#

		#
		# Check type option and other options
		#
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3_k2hdkc_name
			complement_dbaas_k2hr3api_name
			complement_dbaas_k2hr3app_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
				prn_msg "${CRED}Failed${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}\", \"${K2HR3CLI_DBAAS_K8S_R3APP_NAME}\", \"${K2HR3CLI_DBAAS_K8S_R3API_NAME}\", \"${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}\" or \"${K2HR3CLI_DBAAS_K8S_R3API_REPS}\" options are not specified."
				return 1
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ]; then
			#
			# Nothing to check
			#
			:

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3_k2hdkc_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ]; then
				prn_msg "${CRED}Failed${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}\" or \"${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}\" options are not specified."
				return 1
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3api_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ]; then
				prn_msg "${CRED}Failed${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_R3API_NAME}\" or \"${K2HR3CLI_DBAAS_K8S_R3API_REPS}\" options are not specified."
				return 1
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3app_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
				prn_msg "${CRED}Failed${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_R3APP_NAME}\" option is not specified."
				return 1
			fi

		else
			prn_msg "${CRED}Failed${CDEF} : There is an error in the type(${K2HR3CLI_DBAAS_K8S_CERT_TYPE}) of certificate to be set."
			return 1
		fi

		create_dbaas_k8s_domain_certificates
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed to create certificates"
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Created certificates"

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# DELETE CERTIFICATE
		#

		#
		# Check type option
		#
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ] && [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" != "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
			prn_msg "${CRED}Failed${CDEF} : There is an error in the type(${K2HR3CLI_DBAAS_K8S_CERT_TYPE}) of certificate to be deleted."
			return 1
		fi

		#
		# Check other opstions(some part of host name)
		#
		if [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3_k2hdkc_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name to delete the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3api_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name to delete the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_CERT_TYPE}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP}" ]; then
			#
			# Set variables for interactive mode
			#
			complement_dbaas_k2hr3app_name

			if [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
				prn_msg "${CRED}Failed${CDEF} : Need to specify the part of host name to delete the \"${K2HR3CLI_DBAAS_K8S_CERT_TYPE}\" type certificate."
				return 1
			fi
		fi

		#
		# Delete certificates
		#
		delete_dbaas_k8s_domain_certificates
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed to delete certificates"
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Deleted certificates"

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the execute type(${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SET}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY} or ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HR3}" ]; then
	#
	# K2HR3 SUB COMMAND
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# SHOW K2HR3 SYSTEM INFORMATION
		#
		_DBAAS_K8S_TMP_OPT_COUNT=0
		if [ -n "${K2HR3CLI_DBAAS_K8S_SHOW_CONFIG}" ]; then
			_DBAAS_K8S_TMP_OPT_COUNT=$((_DBAAS_K8S_TMP_OPT_COUNT + 1))
		fi
		if [ -n "${K2HR3CLI_DBAAS_K8S_SHOW_RES}" ]; then
			_DBAAS_K8S_TMP_OPT_COUNT=$((_DBAAS_K8S_TMP_OPT_COUNT + 1))
		fi
		if [ -n "${K2HR3CLI_DBAAS_K8S_SHOW_SUMMARY}" ]; then
			_DBAAS_K8S_TMP_OPT_COUNT=$((_DBAAS_K8S_TMP_OPT_COUNT + 1))
		fi
		if [ "${_DBAAS_K8S_TMP_OPT_COUNT}" -ge 2 ]; then
			prn_msg "${CRED}Error${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_SUMMARY_LONG}\" options are exclusive."
			exit 1
		elif [ "${_DBAAS_K8S_TMP_OPT_COUNT}" -le 0 ]; then
			prn_msg "${CRED}Error${CDEF} : Specify either \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG}\" or \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG}\" or \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_SUMMARY_LONG}\" option."
			exit 1
		fi

		if [ "X${K2HR3CLI_DBAAS_K8S_SHOW_CONFIG}" = "X1" ]; then
			#
			# Show configuration file and some additional information
			#
			print_dbaas_k8s_k2hr3_configuration
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Failed showing K2HDKC common configuration."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Succeed showing K2HDKC common configuration."
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_SHOW_RES}" = "X1" ]; then
			#
			# Show kubernetes resources about K2HR3 system
			#

			#
			# Check variables
			#
			complement_dbaas_k2hr3_k2hdkc_name
			complement_dbaas_k2hr3api_name
			complement_dbaas_k2hr3app_name
			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
				prn_err "The part of hostnames for K2HR3 system is not specified."
			fi

			print_k2hr3_k8s_resource_overview
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Failed showing Kubernets Resources for K2HDKC DBaaS."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Succeed showing Kubernets Resources for K2HDKC DBaaS."
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_SHOW_SUMMARY}" = "X1" ]; then
			#
			# Show summary(overview) for K2HDKC DBaaS K8S information
			#

			#
			# Check variables
			#
			complement_dbaas_k2hr3_k2hdkc_name
			complement_dbaas_k2hr3api_name
			complement_dbaas_k2hr3app_name
			if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
				prn_err "The part of hostnames for K2HR3 system is not specified."
			fi

			print_k2hr3_system_overview
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Failed showing K2HR3 system overview."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Succeed showing K2HR3 system overview."
			fi

		else
			prn_msg "${CRED}Failed${CDEF} : Something error occurred."
			exit 1
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# CREATE/APPLY K2HR3 SYSTEM
		#

		#
		# Check variables
		#
		complement_dbaas_k2hr3_k2hdkc_name
		complement_dbaas_k2hr3api_name
		complement_dbaas_k2hr3app_name
		complement_dbaas_k2hdkc_replicas
		complement_dbaas_k2hr3api_replicas
		complement_dbaas_k2hr3app_replicas

		if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_REPS}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_REPS}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_REPS}" ]; then
			prn_err "The part of hostnames for K2HR3 system and replica count are not specified."
		fi

		create_k2hr3_system
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed starting the K2HR3 system."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed starting the K2HR3 system"

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# DELETE K2HR3 SYSTEM
		#

		#
		# Check variables
		#
		complement_dbaas_k2hr3_k2hdkc_name
		complement_dbaas_k2hr3api_name
		complement_dbaas_k2hr3app_name
		if [ -z "${K2HR3CLI_DBAAS_K8S_R3DKC_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3APP_NAME}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_R3API_NAME}" ]; then
			prn_err "The part of hostnames for K2HR3 system is not specified."
		fi

		delete_k2hr3_system
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed deleting the K2HR3 system."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed deleting the K2HR3 system"

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the execute type(${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY} or ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HDKC}" ]; then
	#
	# K2HDKC SUB COMMAND
	#
	if [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}" ]; then
		#
		# SHOW K2HDKC CLUSTER INFORMATION
		#
		if [ -n "${K2HR3CLI_DBAAS_K8S_SHOW_CONFIG}" ] && [ -n "${K2HR3CLI_DBAAS_K8S_SHOW_RES}" ]; then
			prn_msg "${CRED}Error${CDEF} : The \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG}\" and \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG}\" options are exclusive."
			exit 1
		elif [ -z "${K2HR3CLI_DBAAS_K8S_SHOW_CONFIG}" ] && [ -z "${K2HR3CLI_DBAAS_K8S_SHOW_RES}" ]; then
			prn_msg "${CRED}Error${CDEF} : Specify either \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_CONFIG_LONG}\" or \"${K2HR3CLI_DBAAS_K8S_COMMAND_OPT_SHOW_RES_LONG}\" option."
			exit 1
		fi

		if [ "X${K2HR3CLI_DBAAS_K8S_SHOW_CONFIG}" = "X1" ]; then
			#
			# Show K2HDKC Cluster configuratino
			#
			print_dbaas_k8s_k2hdkc_cluster_configuration "${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}"
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Failed showing K2HDKC Cluster configuration."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Succeed showing \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC Cluster configuration."
			fi

		elif [ "X${K2HR3CLI_DBAAS_K8S_SHOW_RES}" = "X1" ]; then
			#
			# Show kubernetes resources about K2HDKC Cluster
			#
			print_k2hdkc_k8s_resource_overview
			if [ $? -ne 0 ]; then
				prn_msg "${CRED}Failed${CDEF} : Failed showing Kubernets Resources for K2HDKC Cluster."
				return 1
			fi
			if [ "X${K2HR3CLI_OPT_JSON}" != "X1" ]; then
				prn_msg "${CGRN}Succeed${CDEF} : Succeed showing Kubernets Resources for \"${K2HR3CLI_DBAAS_K8S_CLUSTER_NAME}\" K2HDKC Cluster."
			fi

		else
			prn_msg "${CRED}Failed${CDEF} : Something error occurred."
			exit 1
		fi

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SETUP}" ]; then
		#
		# SETUP K2HDKC CLUSTER(SETUP K2HR3 FOR K2HDKC CLUSTER)
		#
		complement_dbaas_k2hdkc_cluster_ports
		if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
			prn_err "The K2HDKC Cluster server/slave port number must be specified."
		fi

		setup_k2hdkc_k2hr3_data
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed initializing K2HR3 role/policy/resource for K2HDKC DBaaS K8S cluster."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed initializing K2HR3 role/policy/resource for K2HDKC DBaaS K8S cluster."

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}" ] || [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY}" ]; then
		#
		# CREATE/APPLY K2HDKC CLUSTER
		#
		complement_dbaas_k2hdkc_cluster_node_count
		if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
			prn_err "The K2HDKC Cluster server/slave count must be specified."
		fi

		complement_dbaas_k2hdkc_cluster_ports
		if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_PORT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CTLPORT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CTLPORT}" ]; then
			prn_err "The K2HDKC Cluster server/slave port number must be specified."
		fi

		create_k2hdkc_cluster
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed creating(applying) K2HDKC DBaaS K8S Cluster."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed creating(applying) K2HDKC DBaaS K8S Cluster."

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SCALE}" ]; then
		#
		# SCALE K2HDKC CLUSTER
		#
		complement_dbaas_k2hdkc_cluster_node_count
		if [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_CNT}" ] || [ -z "${K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_CNT}" ]; then
			prn_err "The K2HDKC Cluster server/slave count must be specified."
		fi

		scale_k2hdkc_cluster
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed scaling K2HDKC DBaaS K8S Cluster."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed scaling K2HDKC DBaaS K8S Cluster."

	elif [ "X${K2HR3CLI_DBAAS_K8S_EXEC}" = "X${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}" ]; then
		#
		# DELETE 
		#
		delete_k2hdkc_cluster
		if [ $? -ne 0 ]; then
			prn_msg "${CRED}Failed${CDEF} : Failed deleting K2HDKC DBaaS K8S Cluster."
			return 1
		fi
		prn_msg "${CGRN}Succeed${CDEF} : Succeed deleting K2HDKC DBaaS K8S Cluster."

	else
		prn_err "\"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_SUBCOMMAND}\" must also specify the execute type(${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SETUP}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE}, ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY} or ${K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
		exit 1
	fi

elif [ "X${K2HR3CLI_SUBCOMMAND}" = "X" ]; then
	prn_err "\"${BINNAME} ${K2HR3CLI_MODE}\" must also specify the subcommand(${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CONFIG}, ${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CERT}, ${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HR3} or ${K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HDKC}), please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
else
	prn_err "Unknown subcommand(\"${K2HR3CLI_SUBCOMMAND}\") is specified, please run \"${BINNAME} ${K2HR3CLI_MODE} ${K2HR3CLI_COMMON_OPT_HELP_LONG}(${K2HR3CLI_COMMON_OPT_HELP_SHORT})\" for confirmation."
	exit 1
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
