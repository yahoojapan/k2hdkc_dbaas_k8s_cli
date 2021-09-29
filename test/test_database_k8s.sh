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
TESTNAME=$(basename "$0")
# shellcheck disable=SC2034
TESTBASENAME=$(echo "${TESTNAME}" | sed 's/[.]sh$//')
TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}/../test" || exit 1; pwd)

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
# Additional options for test
#
# [NOTE]
# Overwrite special options to common options(set to $@) in util_test.sh
# A value of --config specifies a file that does not exist.
# It's a warning, but be sure not to set it, as the test will fail if
# the real file affects the variable.
#
set -- "--config" "${TESTDIR}/k2hr3.config" "--dbaas_k8s_config" "${_DBAAS_K8S_TEST_CONFIG_DIR}"

#=====================================================================
# Test for Database
#=====================================================================
TEST_EXIT_CODE=0

# [NOTE]
# The test first creates a certificate.
# This will create a configuration directory and files. Then with these
# directories and files, you can correctly test the subsequent configuration.
#
rm -rf "${_DBAAS_K8S_TEST_CONFIG_DIR}"
mkdir -p "${_DBAAS_K8S_TEST_CONFIG_DIR}"

#
# Log file for unhandled processing
#
TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG="/tmp/dbaas_k8s_unimplement.log"
rm -f "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}"

#---------------------------------------------------------------------
# (1) Normal : Certificate - Create CA
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(1) Normal : Certificate - Create CA"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert create	\
	--cert_type ca							\
	--ca_passphrase my_test_password		\
	--minikube								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (2) Normal : Certificate - Create K2HDKC
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(2) Normal : Certificate - Create K2HDKC"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert create	\
	--cert_type k2hdkc						\
	--k2hdkc_name r3dkc						\
	--k2hdkc_replicas 2						\
	--ca_passphrase my_test_password		\
	--minikube								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (3) Normal : Certificate - Create K2HR3 API
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(3) Normal : Certificate - Create K2HR3 API"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert create	\
	--cert_type k2hr3api					\
	--k2hr3api_name r3api					\
	--k2hr3api_replicas 2					\
	--nodehost_ips 192.168.10.10			\
	--ca_passphrase my_test_password		\
	--minikube								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (4) Normal : Certificate - Create K2HR3 APP
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(4) Normal : Certificate - Create K2HR3 APP"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert create	\
	--cert_type k2hr3app					\
	--k2hr3app_name r3app					\
	--k2hr3app_replicas 2					\
	--nodehost_ips 192.168.10.10			\
	--ca_passphrase my_test_password		\
	--minikube								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (5) Normal : Certificate - Create ALL
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(5) Normal : Certificate - Create ALL"
test_prn_title "${TEST_TITLE}"

#
# Remove any already created certificate
#
rm -rf "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert create	\
	--cert_type all							\
	--k2hdkc_name r3dkc						\
	--k2hr3api_name r3api					\
	--k2hr3app_name r3app					\
	--k2hdkc_replicas 2						\
	--k2hr3api_replicas 2					\
	--k2hr3app_replicas 2					\
	--nodehost_ips 192.168.10.10			\
	--ca_passphrase my_test_password		\
	--minikube								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (6) Normal : Certificate - Set CA
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(6) Normal : Certificate - Set CA"
test_prn_title "${TEST_TITLE}"

#
# Move CA certificate
#
rm -f /tmp/ca.crt
rm -f /tmp/ca.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/ca.crt"			/tmp/ca.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/private/ca.key"	/tmp/ca.key

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert set		\
	--cert_type ca							\
	/tmp/ca.crt								\
	/tmp/ca.key								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#
# Check files
#
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/ca.crt"			/tmp/ca.crt >/dev/null 2>&1 || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/private/ca.key"	/tmp/ca.key >/dev/null 2>&1 || TEST_EXIT_CODE=1

#
# Remove temporary files
#
rm -f /tmp/ca.crt
rm -f /tmp/ca.key

#---------------------------------------------------------------------
# (7) Normal : Certificate - Set K2HDKC 0
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(7) Normal : Certificate - Set K2HDKC 0"
test_prn_title "${TEST_TITLE}"

#
# Move K2HDKC 0 certificate
#
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert set								\
	--cert_type k2hdkc												\
	--k2hdkc_name r3dkc												\
	--host_number 0													\
	/tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt	\
	/tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key	\
	/tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt	\
	/tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key	\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#
# Check files
#
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key" /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key || TEST_EXIT_CODE=1

#
# Remove temporary files
#
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.server.key
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.crt
rm -f /tmp/pod-r3dkc-0.svc-r3dkc.default.svc.cluster.local.client.key

#---------------------------------------------------------------------
# (8) Normal : Certificate - Set K2HR3 API 1
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(8) Normal : Certificate - Set K2HR3 API 1"
test_prn_title "${TEST_TITLE}"

#
# Move K2HR3 API 1 certificate
#
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert set								\
	--cert_type k2hr3api											\
	--k2hdkc_name r3api												\
	--host_number 1													\
	/tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt	\
	/tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key	\
	/tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt	\
	/tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key	\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#
# Check files
#
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key" /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key || TEST_EXIT_CODE=1

#
# Remove temporary files
#
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.server.key
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.crt
rm -f /tmp/pod-r3api-1.svc-r3api.default.svc.cluster.local.client.key


#---------------------------------------------------------------------
# (9) Normal : Certificate - Set K2HR3 APP
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(9) Normal : Certificate - Set K2HR3 APP"
test_prn_title "${TEST_TITLE}"

#
# Move K2HR3 APP certificate
#
rm -f /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.key
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt" /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt
mv "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3app.svc-r3app.default.svc.cluster.local.server.key" /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.key

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert set								\
	--cert_type k2hr3app											\
	--k2hdkc_name r3app												\
	/tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt	\
	/tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.key	\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#
# Check files
#
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt" /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt || TEST_EXIT_CODE=1
cmp "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs/pod-r3app.svc-r3app.default.svc.cluster.local.server.key" /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.key || TEST_EXIT_CODE=1

#
# Remove temporary files
#
rm -f /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.crt
rm -f /tmp/pod-r3app.svc-r3app.default.svc.cluster.local.server.key

#---------------------------------------------------------------------
# (10) Normal : Certificate - Show
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(10) Normal : Certificate - Show"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s cert show	\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (11) Normal : Configiration - List
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(11) Normal : Configiration - List"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s config list "$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (12) Normal : Configiration - Show
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(12) Normal : Configiration - Show"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s config show "$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (13) Normal : K2HR3 - Create
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(13) Normal : K2HR3 - Create"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 create					\
	--k2hdkc_name r3dkc										\
	--k2hr3api_name r3api									\
	--k2hr3app_name r3app									\
	--k2hdkc_replicas 2										\
	--k2hr3api_replicas 2									\
	--k2hr3app_replicas 2									\
	--k2hr3api_nodeport_num 32043							\
	--k2hr3app_nodeport_num 32443							\
	--oidc_client_secret	DUMMY_OIDC_CLIENT_SECRET		\
	--oidc_client_id		DUMMY_OIDC_CLIENT_ID			\
	--oidc_issuer_url		https://DUMMY_OIDC_ISSUER_URL/	\
	--oidc_username_key		DUMMY_OIDC_USERNAME_KEY			\
	--oidc_cookiename		DUMMY_OIDC_COOKIENAME			\
	--oidc_cookie_expire	120								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (14) Normal : K2HR3 - Apply
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(14) Normal : K2HR3 - Apply"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 apply					\
	--k2hdkc_name r3dkc										\
	--k2hr3api_name r3api									\
	--k2hr3app_name r3app									\
	--k2hdkc_replicas 2										\
	--k2hr3api_replicas 2									\
	--k2hr3app_replicas 2									\
	--k2hr3api_nodeport_num 32043							\
	--k2hr3app_nodeport_num 32443							\
	--oidc_client_secret	DUMMY_OIDC_CLIENT_SECRET		\
	--oidc_client_id		DUMMY_OIDC_CLIENT_ID			\
	--oidc_issuer_url		https://DUMMY_OIDC_ISSUER_URL/	\
	--oidc_username_key		DUMMY_OIDC_USERNAME_KEY			\
	--oidc_cookiename		DUMMY_OIDC_COOKIENAME			\
	--oidc_cookie_expire	120								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (15) Normal : K2HR3 - Show Summary
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(15) Normal : K2HR3 - Show Summary"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 show	\
	--summary								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (16) Normal : K2HR3 - Show Configuration
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(16) Normal : K2HR3 - Show Configuration"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 show	\
	--configuration							\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (17) Normal : K2HR3 - Show kubernetes resources
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(17) Normal : K2HR3 - Show kubernetes resources"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 show	\
	--k8s_ressources						\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (18) Normal : K2HDKC - Setup
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(18) Normal : K2HDKC - Setup"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc setup				\
	--unscopedtoken DUMMY_K2HDKC_SETUP_UNSCOPEDTOKEN	\
	mycluster											\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (19) Normal : K2HDKC - Create
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(19) Normal : K2HDKC - Create"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc create				\
	--server_count 2									\
	--slave_count 2										\
	--server_port 8020									\
	--server_control_port 8021							\
	--slave_control_port 8022							\
	--nodehost_ips 192.168.10.10						\
	--ca_passphrase my_test_password					\
	mycluster											\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (20) Normal : K2HDKC - Apply
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(20) Normal : K2HDKC - Apply"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc apply				\
	--server_count 2									\
	--slave_count 2										\
	--server_port 8020									\
	--server_control_port 8021							\
	--slave_control_port 8022							\
	--nodehost_ips 192.168.10.10						\
	--ca_passphrase my_test_password					\
	mycluster											\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (21) Normal : K2HDKC - Scale
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(21) Normal : K2HDKC - Scale"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc scale				\
	--server_count 3									\
	--slave_count 3										\
	--ca_passphrase my_test_password					\
	mycluster											\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (22) Normal : K2HDKC - Show Configuration
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(22) Normal : K2HDKC - Show Configuration"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc show	\
	--configuration							\
	mycluster								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (23) Normal : K2HDKC - Show Kubernetes Resources
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(23) Normal : K2HDKC - Show Kubernetes Resources"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc show	\
	--k8s_ressources						\
	mycluster								\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (24) Normal : K2HDKC - Delete Cluster
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(24) Normal : K2HDKC - Delete Cluster"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hdkc delete				\
	--unscopedtoken DUMMY_K2HDKC_SETUP_UNSCOPEDTOKEN	\
	mycluster											\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# [NOTE]
# This result includes the full path to the repository, so delete the
# path to the repository.
#
sed -i -e 's#/.*k2hdkc-dbaas-k8s-cli-[0-9\.]*/#k2hdkc_dbaas_k8s_cli/#g' -e 's#/.*k2hdkc_dbaas_k8s_cli/#k2hdkc_dbaas_k8s_cli/#g' "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (25) Normal : K2HR3 - Delete
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(25) Normal : K2HR3 - Delete"
test_prn_title "${TEST_TITLE}"

#
# Run
#
"${K2HR3CLIBIN}" database-k8s k2hr3 delete	\
	--with_certs							\
	"$@" > "${SUB_TEST_PART_FILE}"

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#
# Check files
#
if [ -d "${_DBAAS_K8S_TEST_CONFIG_DIR}/DBAAS-default.svc.cluster.local/certs" ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# (26) Normal : Check for unhandled processing
#---------------------------------------------------------------------
#
# Title
#
TEST_TITLE="(26) Normal : Check for unhandled processing"
test_prn_title "${TEST_TITLE}"

#
# Check
#
if [ ! -f "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}" ]; then
	pecho "There is no unhandled processing." > "${SUB_TEST_PART_FILE}"
else
	pecho "Found unhandled processing:"				>  "${SUB_TEST_PART_FILE}"
	cat "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}"	>> "${SUB_TEST_PART_FILE}"
fi

#
# Check result
#
test_processing_result "$?" "${SUB_TEST_PART_FILE}" "${TEST_TITLE}"
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

#---------------------------------------------------------------------
# Check update log
#---------------------------------------------------------------------
test_update_snapshot
if [ $? -ne 0 ]; then
	TEST_EXIT_CODE=1
fi

exit ${TEST_EXIT_CODE}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
