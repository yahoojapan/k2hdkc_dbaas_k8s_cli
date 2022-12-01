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

#---------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------
TESTMAINBIN=$(basename "$0")
TESTMAINBASENAME=$(echo "${TESTMAINBIN}" | sed 's/[.]sh$//')

TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}/../test" || exit 1; pwd)
SRCDIR=$(cd "${TESTDIR}"/../src || exit 1; pwd)
# shellcheck disable=SC2034
LIBEXECDIR=$(cd "${SRCDIR}"/libexec || exit 1; pwd)

TEST_ALL_LOGFILE="${TESTDIR}/${TESTMAINBASENAME}.log"
TEST_EXTCODE_FILE="/tmp/.${TESTMAINBASENAME}.exitcode"
TEST_SUMMARY_FILE="${TESTDIR}/${TESTMAINBASENAME}.summary.log"

#
# Special Environment
#
# [NOTE]
# The TEST_CREATE_DUMMY_FUNCTION environment variable modifies
# the behavior of the xxx_request() function in util_request.sh
# (k2hr3_cli).
# This environment variable is set to the create_dummy_response()
# function by default when util_request.sh(k2hr3_cli) is loaded.
# After loading this util_request.sh(k2hr3_cli), override the
# TEST_CREATE_DUMMY_RESPONSE_FUNC environment variable and replace
# it with the create_dummy_dbaas_k8s_response() function in this
# file. The create_dummy_dbaas_k8s_response() function handles the
# database-k8s command only.
# Otherwise, call the original create_dummy_response() function
# and let it do the work.
# This allows for dedicated testing of plugins.
#
export TEST_CREATE_DUMMY_RESPONSE_FUNC="create_dummy_dbaas_k8s_response"

#
# Load K2HDKC DBaaS K8S dummy request file
#
export K2HR3CLI_REQUEST_FILE="${TESTDIR}/util_dbaas_k8s_request.sh"
if [ -f "${K2HR3CLI_REQUEST_FILE}" ]; then
	. "${K2HR3CLI_REQUEST_FILE}"
fi

#
# The directory for Configuration file
#
_DBAAS_K8S_TEST_CONFIG_DIR="${TESTDIR}/dbaas-k8s"
if [ ! -d "${_DBAAS_K8S_TEST_CONFIG_DIR}" ]; then
	mkdir -p "${_DBAAS_K8S_TEST_CONFIG_DIR}"
fi

#
# Sub Test files
#
# The test file is a file with the "test_" prefix and the ".sh" suffix.
#
TEST_FILES=""
for _TEST_FILE_TMP in "${TESTDIR}"/*; do
	_TEST_FILE_TMP=$(pecho -n "${_TEST_FILE_TMP}" | sed "s#^${TESTDIR}/##g")
	case ${_TEST_FILE_TMP} in
		"${TESTMAINBIN}")
			;;
		test_*.sh)
			if [ -z "${TEST_FILES}" ]; then
				TEST_FILES=${_TEST_FILE_TMP}
			else
				TEST_FILES="${TEST_FILES} ${_TEST_FILE_TMP}"
			fi
			;;
		*)
			;;
	esac
done

#
# Additional options for test
#
# [NOTE]
# Overwrite special options to common options(set to $@) in util_test.sh
# A value of --config specifies a file that does not exist.
# It's a warning, but be sure not to set it, as the test will fail if
# the real file affects the variable.
#
set -- "--config" "${TESTDIR}/k2hr3.config" "--dbaas_k8s_config" "${_DBAAS_K8S_TEST_CONFIG_DIR}"

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------
func_usage()
{
	echo ""
	echo "Usage: ${TESTMAINBIN} [option...]"
	echo "	     --update(-u)   update the test result comparison file with the current test result."
	echo "	     --help(-h)     print help."
	echo ""
}

#---------------------------------------------------------------------
# Test all
#---------------------------------------------------------------------
#
# Header
#
echo ""
echo "K2HR3 DBAAS K8S CLI TEST ($(date -R))" | tee "${TEST_ALL_LOGFILE}"
echo "" | tee -a "${TEST_ALL_LOGFILE}"

#
# Summary file
#
echo "${CREV}[Summary]${CDEF} K2HR3 DBAAS K8S CLI TEST" > "${TEST_SUMMARY_FILE}"
echo "" >> "${TEST_SUMMARY_FILE}"

#
# Test all
#
ALL_TEST_RESULT=0

for SUBTESTBIN in ${TEST_FILES}; do
	#
	# Title
	#
	SUBTEST_TITLE=$(pecho -n "${SUBTESTBIN}" | sed -e 's/^test_//g' -e 's/[.]sh$//g' | tr '[:lower:]' '[:upper:]')

	#
	# Clear exit code file
	#
	rm -f "${TEST_EXTCODE_FILE}"

	#
	# Run test
	#
	echo "${CREV}[${SUBTEST_TITLE}]${CDEF}:" | tee -a "${TEST_ALL_LOGFILE}"
	("${TESTDIR}/${SUBTESTBIN}" "${SUB_TEST_UPDATE_OPT}"; echo $? > "${TEST_EXTCODE_FILE}") | stdbuf -oL -eL sed -e 's/^/     /' | tee -a "${TEST_ALL_LOGFILE}"

	#
	# Result
	#
	if [ -f "${TEST_EXTCODE_FILE}" ]; then
		SUBTEST_RESULT=$(cat "${TEST_EXTCODE_FILE}")
		if ! compare_part_string "${SUBTEST_RESULT}" >/dev/null 2>&1; then
			echo "     ${CYEL}(error) ${TESTMAINBIN} : result code for ${SUBTEST_TITLE} is wrong(${SUBTEST_RESULT}).${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
			SUBTEST_RESULT=1
		fi
		rm -f "${TEST_EXTCODE_FILE}"
	else
		echo "     ${CYEL}(error) ${TESTMAINBIN} : result code file for ${SUBTEST_TITLE} is not existed.${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
		SUBTEST_RESULT=1
	fi

	if [ "${SUBTEST_RESULT}" -eq 0 ]; then
		echo "  => ${CGRN}Succeed${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
	else
		ALL_TEST_RESULT=1
		echo "  => ${CRED}Failure${CDEF}" | tee -a "${TEST_ALL_LOGFILE}"
	fi
	echo "" | tee -a "${TEST_ALL_LOGFILE}"

	#
	# Add Summary
	#
	if [ "${SUBTEST_RESULT}" -eq 0 ]; then
		echo "  ${CGRN}PASS${CDEF} : ${SUBTEST_TITLE}" >> "${TEST_SUMMARY_FILE}"
	else
		echo "  ${CRED}FAIL${CDEF} : ${SUBTEST_TITLE}" >> "${TEST_SUMMARY_FILE}"
	fi
done

#
# Print Summary
#
if [ -f "${TEST_SUMMARY_FILE}" ]; then
	tee -a "${TEST_ALL_LOGFILE}" < "${TEST_SUMMARY_FILE}"
	rm -f "${TEST_SUMMARY_FILE}"
fi

#
# Result(Footer)
#
echo "" | tee -a "${TEST_ALL_LOGFILE}"
if [ "${ALL_TEST_RESULT}" -eq 0 ]; then
	echo "All Test ${CGRN}PASSED${CDEF} ($(date -R))" | tee -a "${TEST_ALL_LOGFILE}"
else
	echo "All Test ${CRED}FAILED${CDEF} ($(date -R))" | tee -a "${TEST_ALL_LOGFILE}"
fi
echo ""

#
# Cleanup files
#
rm -f "${TESTDIR}/k2hr3.config"
# shellcheck disable=SC2115
rm -rf "${_DBAAS_K8S_TEST_CONFIG_DIR}"

exit "${ALL_TEST_RESULT}"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
