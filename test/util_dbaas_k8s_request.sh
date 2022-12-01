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
# [NOTE]
# This file is loaded from the test script or from the k2hr3 process.
# So create the exact path to the test directory here.
#
_INIT_TESTDIR=$(dirname "$0")
_LOCAL_TESTDIR=$(cd "${_INIT_TESTDIR}/../test" || exit 1; pwd)

#
# Set own file path to K2HR3CLI_REQUEST_FILE if it is empty
#
if [ -z "${K2HR3CLI_REQUEST_FILE}" ]; then
	export K2HR3CLI_REQUEST_FILE="${_LOCAL_TESTDIR}/util_dbaas_k8s_request.sh"
fi

#
# Load K2HR3 Test dummy response file
#
UTIL_REQUESTFILE="util_request.sh"
if [ -f "${_LOCAL_TESTDIR}/${UTIL_REQUESTFILE}" ]; then
	. "${_LOCAL_TESTDIR}/${UTIL_REQUESTFILE}"
fi

#
# Load utility file for test
#
UTIL_TESTFILE="util_test.sh"
if [ -f "${_LOCAL_TESTDIR}/${UTIL_TESTFILE}" ]; then
	. "${_LOCAL_TESTDIR}/${UTIL_TESTFILE}"
fi

#
# Response Header File
#
K2HR3CLI_REQUEST_RESHEADER_FILE="/tmp/.${BINNAME}_$$_curl.header"

#
# Test for common values
#
_TEST_K2HR3_USER="test"
_TEST_K2HR3_PASS="password"
_TEST_K2HR3_TENANT="test1"
_TEST_K2HDKC_CLUSTER_NAME="testcluster"

#
# Log file for unhandled processing
#
TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG="/tmp/dbaas_k8s_unimplement.log"

#--------------------------------------------------------------
# Load K2HDKC DBaaS K8S dummy request sub file
#--------------------------------------------------------------
export K2HR3CLI_REQUEST_SUB_FILE="${_LOCAL_TESTDIR}/util_dbaas_k8s_sub_request.sh"
if [ -f "${K2HR3CLI_REQUEST_SUB_FILE}" ]; then
	. "${K2HR3CLI_REQUEST_SUB_FILE}"
fi

#--------------------------------------------------------------
# Utility functions
#--------------------------------------------------------------
#
# Search Headers
#
# $1		: target header name
# $2...		: headers
# $?		: result
# Output
#	header value
#
util_search_header()
{
	_UTIL_SEARCH_HEADER_KEYWORD=$(to_upper "$1")
	shift

	if [ -z "${_UTIL_SEARCH_HEADER_KEYWORD}" ]; then
		pecho -n ""
		return 1
	fi

	while [ $# -gt 0 ]; do
		_UTIL_ONE_HEADER_PAIR=$(to_upper "$1")
		if pecho -n "${_UTIL_ONE_HEADER_PAIR}" | grep -q "^${_UTIL_SEARCH_HEADER_KEYWORD}"; then
			_UTIL_ONE_HEADER_VALUE=$(pecho -n "$1" | sed -e 's/:/ /g' | awk '{print $2}')
			pecho -n "${_UTIL_ONE_HEADER_VALUE}"
			return 0
		fi
		shift
	done

	return 1
}

#
# Search User Token Header
#
# $1...		: headers
# $?		: result
# Output
#	token value
#
util_search_usertoken()
{
	if ! _UTIL_SEARCH_TOKEN=$(util_search_header "x-auth-token" "$@"); then
		prn_dbg "Not found \"x-auth-token\" header"
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 1-2)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ] || [ "${_UTIL_SEARCH_TOKEN_TMP}" != "U=" ]; then
		prn_err "\"x-auth-token\" header value does not start \"U=\"(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	_UTIL_SEARCH_TOKEN_TMP=$(pecho -n "${_UTIL_SEARCH_TOKEN}" | cut -c 3-)
	if [ -z "${_UTIL_SEARCH_TOKEN_TMP}" ]; then
		prn_err "\"x-auth-token\" header value is empty(x-auth-token: ${_UTIL_SEARCH_TOKEN})."
		return 1
	fi
	pecho -n "${_UTIL_SEARCH_TOKEN_TMP}"
	return 0
}

#
# Create Dummy K2HDKC DBaaS K8S Response(proxying)
#
create_dummy_dbaas_k8s_response()
{
	#
	# Call own test response function
	#
	create_dummy_dbaas_k8s_response_sub "$@"
	if [ $? -eq 3 ]; then
		#
		# Cases that I did not handle myself, Call k2hr3_cli test response function.
		#
		prn_dbg "(create_dummy_dbaas_k8s_response) Delegate requests that are not handled by K2HDKC DBaaS K8S to create_dummy_response."
		create_dummy_response "$@"
	fi
	return $?
}

#--------------------------------------------------------------
# K2HDKC DBaaS K8S Response for All test
#--------------------------------------------------------------
#
# Create Dummy K2HDKC DBaaS K8S Response Sub
#
# $1		: Method(GET/PUT/POST/HEAD/DELETE)
# $2		: URL path and parameters in request
# $3		: body data(string) for post
# $4		: body data(file path) for post
# $5		: need content type header (* this value is not used)
# $6...		: other headers (do not include spaces in each header)
#
# $?		: result
#				0	success(request completed successfully, need to check K2HR3CLI_REQUEST_EXIT_CODE for the processing result)
#				1	failure(if the curl request fails)
#				2	fatal error
#				3	not handling
#
# Set global values
#	K2HR3CLI_REQUEST_EXIT_CODE		: http response code
#	K2HR3CLI_REQUEST_RESULT_FILE	: request result content file
#
create_dummy_dbaas_k8s_response_sub()
{
	if [ $# -lt 2 ]; then
		prn_err "Missing options for calling request."
		return 2
	fi
	_TEST_DUMMY_K2HR3API_BACKUP_ALL_PARAMS="$*"

	#
	# Check Parameters
	#
	_DUMMY_METHOD="$1"
	if [ -z "${_DUMMY_METHOD}" ] || { [ "${_DUMMY_METHOD}" != "GET" ] && [ "${_DUMMY_METHOD}" != "HEAD" ] && [ "${_DUMMY_METHOD}" != "PUT" ] && [ "${_DUMMY_METHOD}" != "POST" ] && [ "${_DUMMY_METHOD}" != "DELETE" ]; }; then
		prn_err "Unknown Method($1) options for calling requet."
		return 2
	fi

	_DUMMY_URL_FULL="$2"
	_DUMMY_URL_PATH=$(echo "${_DUMMY_URL_FULL}" | sed -e 's/?.*$//g' -e 's/&.*$//g')

	if pecho -n "${_DUMMY_URL_FULL}" | grep -q '[?|&]'; then
		_DUMMY_URL_ARGS=$(pecho -n "${_DUMMY_URL_FULL}" | sed -e 's/^.*?//g')
	else
		_DUMMY_URL_ARGS=""
	fi
	prn_dbg "(create_dummy_dbaas_k8s_response_sub) all url(${_DUMMY_METHOD}: ${_DUMMY_URL_FULL}) => url(${_DUMMY_METHOD}: ${_DUMMY_URL_PATH}) + args(${_DUMMY_URL_ARGS})"

	_DUMMY_BODY_STRING="$3"
	_DUMMY_BODY_FILE="$4"
	_DUMMY_CONTENT_TYPE="$5"
	if [ $# -le 5 ]; then
		shift $#
	else
		shift 5
	fi

	#------------------------------------------------------
	# Parse request
	#------------------------------------------------------
	if pecho -n "${_DUMMY_URL_PATH}" | grep -v "^/v1/role/token/" | grep -v "/v1/user/tokens" | grep -q "^/v1/role/"; then
		#------------------------------------------------------
		# K2HR3 Role API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
			#
			# Get Role Token(/v1/role/token/...)
			#
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/role/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			_DUMMY_URL_PATH_SECOND_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $2}')

			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first or seond path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				prn_dbg "Url seond path is ${_DUMMY_URL_PATH_SECOND_PART}"
			fi

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=204
			_UTIL_RESPONSE_CONTENT=""
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"
			return 0
		fi

	elif pecho -n "${_DUMMY_URL_PATH}" | grep -v "^/v1/role/token/" | grep -v "/v1/user/tokens" | grep -q "^/v1/role"; then
		#------------------------------------------------------
		# K2HR3 Role API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
			#
			# Create Role(/v1/role)
			#

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			#
			# Url arguments
			#
			_UTIL_TMP_ROLENAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_POLICIES=$(util_search_urlarg "policies" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")
			if [ -z "${_UTIL_TMP_ROLENAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found role name."
				return 1
			fi
			if [ -z "${_UTIL_TMP_POLICIES}" ]; then
				prn_dbg "Not found policies(optional)."
			fi
			if [ -z "${_UTIL_TMP_ALIAS}" ]; then
				prn_dbg "Not found alias(optional)."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/v1/role/token/"; then
		#------------------------------------------------------
		# K2HR3 Role Token API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "GET" ]; then
			#
			# Get Role Token(/v1/role/token/...)
			#
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/role/token/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			_DUMMY_URL_PATH_SECOND_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $2}')

			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ] || [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first or seond path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			#
			# expire URL argument
			#
			_UTIL_TMP_EXPIRE=$(util_search_urlarg "expire" "${_DUMMY_URL_ARGS}")
			prn_dbg "(create_dummy_response) all url args(${_DUMMY_URL_ARGS}) => expire(${_UTIL_TMP_EXPIRE})"
			if ! is_positive_number "${_UTIL_TMP_EXPIRE}" >/dev/null 2>&1; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "\"expire\" URL argument value is wrong.(${_DUMMY_URL_ARGS})."
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=200
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null,\"token\":\"TEST_TOKEN_ROLE_${_DUMMY_URL_PATH_FIRST_PART}_EXPIRE_${_UTIL_TMP_EXPIRE}\",\"registerpath\":\"TEST_REGISTERPATH_ROLE_${_DUMMY_URL_PATH_FIRST_PART}_EXPIRE_${_UTIL_TMP_EXPIRE}\"}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/user/tokens" ]; then
		#------------------------------------------------------
		# K2HR3 User Token API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "HEAD" ]; then
			#
			# HEAD Token(/v1/user/tokens)
			#
			if [ -n "${_DUMMY_URL_ARGS}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "There is an unnecessary URL arguments.(${_DUMMY_URL_ARGS})."
				return 1
			fi
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=204
			_UTIL_RESPONSE_CONTENT=''
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
			#
			# POST Token(/v1/user/tokens)
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				_UTIL_TMP_TOKENVAL=""
			fi

			if [ -z "${_DUMMY_BODY_STRING}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "There is no body to create scoped token."
				return 1
			fi

			_UTIL_TMP_TENANT=$(echo "${_DUMMY_BODY_STRING}" | sed -e 's/^{"auth":{"tenantName":"//g' -e 's/"}}$//g')
			if [ -z "${_UTIL_TMP_TENANT}" ] || [ "${_UTIL_TMP_TENANT}" != "default" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "The tenant name must be \"default\"."
				return 1
			fi

			#
			# Create Scoped Token from credential
			#
			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":\"succeed\",\"scoped\":true,\"token\":\"TEST_TOKEN_SCOPED_FOR_TENANT_${_UTIL_TMP_TENANT}\"}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/v1/resource/"; then
		#------------------------------------------------------
		# K2HR3 Policy API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/resource/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')
			_DUMMY_URL_PATH_SECOND_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $2}')

			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first or seond path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi
			if [ -z "${_DUMMY_URL_PATH_SECOND_PART}" ]; then
				prn_dbg "Url seond path is ${_DUMMY_URL_PATH_SECOND_PART}"
			fi

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=204
			_UTIL_RESPONSE_CONTENT=""
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/resource" ]; then
		#------------------------------------------------------
		# K2HR3 Resource API
		#------------------------------------------------------
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "POST" ]; then
			#
			# POST: Url arguments
			#
			if [ -n "${_DUMMY_BODY_FILE}" ] && [ -n "${_DUMMY_BODY_STRING}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Both post body file and data are specified."
				return 1
			elif [ -z "${_DUMMY_BODY_FILE}" ] && [ -z "${_DUMMY_BODY_STRING}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Both post body file and data is not specified."
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0

		elif [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
			#
			# PUT: Url arguments
			#
			_UTIL_TMP_RESOURCENAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_TYPE=$(util_search_urlarg "type" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_DATA=$(util_search_urlarg "data" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_KEYS=$(util_search_urlarg "keys" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")

			if [ -z "${_UTIL_TMP_RESOURCENAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found role name."
				return 1
			fi

			_UTIL_TMP_TYPE=$(to_upper "${_UTIL_TMP_TYPE}")
			if [ -z "${_UTIL_TMP_TYPE}" ]; then
				prn_dbg "\"type\" url argument is empty(not update data)."
			elif [ "${_UTIL_TMP_TYPE}" = "NULL" ]; then
				prn_dbg "\"type\" url argument is null(not update data)."
			elif [ "${_UTIL_TMP_TYPE}" = "STRING" ]; then
				prn_dbg "\"type\" url argument is string."
			elif [ "${_UTIL_TMP_TYPE}" = "OBJECT" ]; then
				prn_dbg "\"type\" url argument is object."
			fi

			_UTIL_TMP_KEYS=$(to_upper "${_UTIL_TMP_DATA}")
			if [ -z "${_UTIL_TMP_DATA}" ]; then
				prn_dbg "\"data\" url argument is empty(not update date)."
			elif [ "${_UTIL_TMP_DATA}" = "NULL" ]; then
				prn_dbg "\"data\" url argument is null(not update data)."
			fi

			_UTIL_TMP_KEYS=$(to_upper "${_UTIL_TMP_KEYS}")
			if [ -z "${_UTIL_TMP_KEYS}" ]; then
				prn_dbg "\"keys\" url argument is empty(not update kesy)."
			elif [ "${_UTIL_TMP_KEYS}" = "NULL" ]; then
				prn_dbg "\"keys\" url argument is null(not update keys)."
			fi

			if [ -z "${_UTIL_TMP_ALIAS}" ]; then
				prn_dbg "Not found alias(optional)."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif [ -n "${_DUMMY_URL_PATH}" ] && [ "${_DUMMY_URL_PATH}" = "/v1/policy" ]; then
		#------------------------------------------------------
		# K2HR3 Policy API
		#------------------------------------------------------
		if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
			K2HR3CLI_REQUEST_EXIT_CODE=400
			return 1
		fi

		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "PUT" ]; then
			#
			# Url arguments
			#
			_UTIL_TMP_POLICYNAME=$(util_search_urlarg "name" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_EFFECT=$(util_search_urlarg "effect" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ACTION=$(util_search_urlarg "action" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_RESOURCE=$(util_search_urlarg "resource" "${_DUMMY_URL_ARGS}")
			_UTIL_TMP_ALIAS=$(util_search_urlarg "alias" "${_DUMMY_URL_ARGS}")

			if [ -z "${_UTIL_TMP_POLICYNAME}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Not found policy name."
				return 1
			fi

			_UTIL_TMP_EFFECT=$(to_upper "${_UTIL_TMP_EFFECT}")
			if [ -n "${_UTIL_TMP_EFFECT}" ] && [ "${_UTIL_TMP_EFFECT}" = "ALLOW" ]; then
				prn_dbg "\"effect\" url argument is allow."
			elif [ -n "${_UTIL_TMP_EFFECT}" ] && [ "${_UTIL_TMP_EFFECT}" = "DENY" ]; then
				prn_dbg "\"type\" url argument is deny."
			else
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "\"effect\" URL argument has unknown value or empty(${_UTIL_TMP_EFFECT})."
				return 1
			fi

			if [ -n "${_UTIL_TMP_ACTION}" ]; then
				prn_dbg "\"action\" URL argument is \"${_UTIL_TMP_ACTION}\"."
			else
				prn_dbg "\"action\" URL argument is empty."
			fi

			if [ -n "${_UTIL_TMP_RESOURCE}" ]; then
				prn_dbg "\"resource\" URL argument is \"${_UTIL_TMP_RESOURCE}\"."
			else
				prn_dbg "\"resource\" URL argument is empty."
			fi

			if [ -n "${_UTIL_TMP_ALIAS}" ]; then
				prn_dbg "\"alias\" URL argument is \"${_UTIL_TMP_ALIAS}\"."
			else
				prn_dbg "\"alias\" URL argument is empty."
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=201
			_UTIL_RESPONSE_CONTENT="{\"result\":true,\"message\":null}"
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi

	elif pecho -n "${_DUMMY_URL_PATH}" | grep -q "^/v1/policy/"; then
		#------------------------------------------------------
		# K2HR3 Policy API
		#------------------------------------------------------
		if [ -n "${_DUMMY_METHOD}" ] && [ "${_DUMMY_METHOD}" = "DELETE" ]; then
			_DUMMY_URL_PATH_AFTER_PART=$(pecho -n "${_DUMMY_URL_PATH}" | sed -e 's#/v1/policy/##g')
			_DUMMY_URL_PATH_FIRST_PART=$(pecho -n "${_DUMMY_URL_PATH_AFTER_PART}" | sed -e 's#/# #g' | awk '{print $1}')

			if [ -z "${_DUMMY_URL_PATH_FIRST_PART}" ]; then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				prn_err "Url first or seond path is empty(${_DUMMY_URL_PATH})."
				return 1
			fi

			#
			# Scoped token
			#
			if ! _UTIL_TMP_TOKENVAL=$(util_search_usertoken "$@"); then
				K2HR3CLI_REQUEST_EXIT_CODE=400
				return 1
			fi

			K2HR3CLI_REQUEST_EXIT_CODE=204
			_UTIL_RESPONSE_CONTENT=""
			pecho "${_UTIL_RESPONSE_CONTENT}" > "${K2HR3CLI_REQUEST_RESULT_FILE}"

			return 0
		fi
	fi

	echo "[Unimplement: K2HR3 API] ${_TEST_DUMMY_K2HR3API_BACKUP_ALL_PARAMS}" >> "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}"
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
