#
# K2HDKC DBaaS on Kubernetes Command Line Interface - K2HR3 CLI Plugin
#
# Copyright 2021 Yahoo Japan Corporation.
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
# Constant Variables for K2HDKC DBaaS K8S
#---------------------------------------------------------------------
#
# Programs
#
if [ -z "${KUBECTL_BIN}" ]; then
	KUBECTL_BIN="kubectl"
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_KUBECTL_BIN=0
else
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_KUBECTL_BIN=1
fi
if [ -z "${MINIKUBE_BIN}" ]; then
	MINIKUBE_BIN="minikube"
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_MINIKUBE_BIN=0
else
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_MINIKUBE_BIN=1
fi
if [ -z "${OPENSSL_BIN}" ]; then
	OPENSSL_BIN="openssl"
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_OPENSSL_BIN=0
else
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_OPENSSL_BIN=1
fi
if [ -z "${SOCAT_BIN}" ]; then
	SOCAT_BIN="socat"
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_SOCAT_BIN=0
else
	K2HR3CLI_DBAAS_K8S_SKIP_CHECK_SOCAT_BIN=1
fi

#
# Sub command
#
K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CONFIG="config"
K2HR3CLI_DBAAS_K8S_COMMAND_SUB_CERT="cert"
K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HR3="k2hr3"
K2HR3CLI_DBAAS_K8S_COMMAND_SUB_K2HDKC="k2hdkc"

#
# Execute type
#
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_LIST="list"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SHOW="show"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SET="set"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_DELETE="delete"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_CREATE="create"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_APPLY="apply"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SETUP="setup"
K2HR3CLI_DBAAS_K8S_COMMAND_EXEC_SCALE="scale"

#
# Configuration
#
K2HR3CLI_DBAAS_K8S_COMMON_CONFIG_FILENAME="dbaas-k8s.config"
K2HR3CLI_DBAAS_K8S_K2HR3_CONFIG_FILENAME="k2hr3.config"
K2HR3CLI_DBAAS_K8S_K2HDKC_CONFIG_FILENAME="k2hdkc.config"

#---------------------------------------------------------------------
# Certificates Variables
#---------------------------------------------------------------------
#
# Certificate option values
#
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_ALL="all"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_CA="ca"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3DKC="k2hdkc"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3API="k2hr3api"
K2HR3CLI_DBAAS_K8S_COMMAND_OPT_CERT_TYPE_R3APP="k2hr3app"

#
# File/Directory names under K2HDKC DBaaS K8S cluster directory
#
K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF_PATH1="/etc/pki/tls/openssl.cnf"
K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF_PATH2="/etc/ssl/openssl.cnf"
if [ -f "${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF_PATH2}" ]; then
	K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF=${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF_PATH2}
else
	K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF=${K2HR3CLI_DBAAS_K8S_MASTER_OPENSSL_CNF_PATH1}
fi
K2HR3CLI_DBAAS_K8S_OPENSSL_CNF="openssl.cnf"
K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_TMP="openssl.cnf.tmp"
K2HR3CLI_DBAAS_K8S_OPENSSL_CNF_NODE_TMP="node_openssl.cnf"

K2HR3CLI_DBAAS_K8S_CA_CERT_FILENAME="ca.crt"
K2HR3CLI_DBAAS_K8S_CA_KEY_FILENAME="ca.key"

K2HR3CLI_DBAAS_K8S_CERTS_DIRNAME="certs"
K2HR3CLI_DBAAS_K8S_NEWCERTS_DIRNAME="newcerts"
K2HR3CLI_DBAAS_K8S_OLDCERTS_DIRNAME="oldcerts"
K2HR3CLI_DBAAS_K8S_PRIVATE_DIRNAME="private"

K2HR3CLI_DBAAS_K8S_INDEX_FILENAME="index.txt"
K2HR3CLI_DBAAS_K8S_INDEX_OLD_FILENAME="index.txt.old"
K2HR3CLI_DBAAS_K8S_INDEX_ATTR_FILENAME="index.txt.attr"
K2HR3CLI_DBAAS_K8S_INDEX_ATTR_OLD_FILENAME="index.txt.attr.old"
K2HR3CLI_DBAAS_K8S_INDEX_BASE_FILENAME="index.txt"
K2HR3CLI_DBAAS_K8S_SERIAL_FILENAME="serial"
K2HR3CLI_DBAAS_K8S_SERIAL_OLD_FILENAME="serial.old"

K2HR3CLI_DBAAS_K8S_SERVER_CERT_SUFFIX=".server.crt"
K2HR3CLI_DBAAS_K8S_SERVER_CSR_SUFFIX=".server.csr"
K2HR3CLI_DBAAS_K8S_SERVER_KEY_SUFFIX=".server.key"
K2HR3CLI_DBAAS_K8S_CLIENT_CERT_SUFFIX=".client.crt"
K2HR3CLI_DBAAS_K8S_CLIENT_CSR_SUFFIX=".client.csr"
K2HR3CLI_DBAAS_K8S_CLIENT_KEY_SUFFIX=".client.key"

K2HR3CLI_DBAAS_K8S_CA_CERT_UB_SUFFIX="_CA.crt"

K2HR3CLI_DBAAS_K8S_SVR_TOKEN_FILENAME="dbaas-k2hdkc-role-token-server"
K2HR3CLI_DBAAS_K8S_SLV_TOKEN_FILENAME="dbaas-k2hdkc-role-token-slave"

#---------------------------------------------------------------------
# file names generated from templates
#---------------------------------------------------------------------
K2HR3CLI_DBAAS_K8S_K2HR3_API_NP_YAML_FILE_TEMPL="k2hr3-api-nodeport.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_NP_YAML_FILE_TEMPL="k2hr3-app-nodeport.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_API_NP_YAML_FILE="k2hr3-api-nodeport.yaml"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_NP_YAML_FILE="k2hr3-app-nodeport.yaml"

K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE_TEMPL="k2hr3-api-production.json.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE_TEMPL="k2hr3-app-production.json.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_API_PROD_JSON_FILE="k2hr3-api-production.json"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_PROD_JSON_FILE="k2hr3-app-production.json"

K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE_TEMPL="k2hr3-k2hdkc.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE_TEMPL="k2hr3-k2hr3api.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE_TEMPL="k2hr3-k2hr3app.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE_TEMPL="k2hr3-sa.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_DKC_YAML_FILE="k2hr3-k2hdkc.yaml"
K2HR3CLI_DBAAS_K8S_K2HR3_API_YAML_FILE="k2hr3-k2hr3api.yaml"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_YAML_FILE="k2hr3-k2hr3app.yaml"
K2HR3CLI_DBAAS_K8S_K2HR3_SA_YAML_FILE="k2hr3-sa.yaml"

K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML_TEMPL="k2hr3-kustomization.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML_TEMPL="dbaas-kustomization.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_KUSTOMIZATION_YAML="k2hr3-kustomization.yaml"
K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOMIZATION_YAML="dbaas-kustomization.yaml"
K2HR3CLI_DBAAS_K8S_KUSTOMIZATION_YAML="kustomization.yaml"

K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_FILE_TEMPL="k2hr3-k2hdkc.ini.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_INI_FILE_TEMPL="dbaas-k2hdkc.ini.templ"		# not used in sh code
K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_FILE="k2hr3-k2hdkc.ini"				# not used in sh code
K2HR3CLI_DBAAS_K8S_K2HDKC_INI_FILE="dbaas-k2hdkc.ini"

K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE_TEMPL="dbaas-k2hdkc-server.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE_TEMPL="dbaas-k2hdkc-slave.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_FILE="dbaas-k2hdkc-server.yaml"
K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_FILE="dbaas-k2hdkc-slave.yaml"

K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_FILE="k2hr3-k2hdkc-ini-update.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_FILE="k2hr3-api-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_FILE="k2hr3-app-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_FILE="k2hr3-app-init.sh"

K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_FILE="dbaas-k2hdkc-chmpxproc-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_FILE="dbaas-k2hdkc-serverproc-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_FILE="dbaas-k2hdkc-ini-update.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_FILE="dbaas-k2hdkc-k2hr3-registration.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_FILE="dbaas-k2hdkc-variables-setup.sh"

#---------------------------------------------------------------------
# Resource name and Part names etc
#---------------------------------------------------------------------
#
# Parts for Hostname Variables for certificates
#
# The host name has the following format:
#	"pod-<base name>.svc-<base name>.<k8s namespace>.<domain>"
#	"pod-<base name>-<number>.svc-<base name>.<k8s namespace>.<domain>"
#
#   ex.) pod-r3api-0.svc-r3api.default.svc.cluster.local.server.crt
#
K2HR3CLI_DBAAS_K8S_POD_NAME_PREFIX="pod-"
K2HR3CLI_DBAAS_K8S_SVC_NAME_PREFIX="svc-"

K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_POD_NAME_PREFIX="svrpod-"
K2HR3CLI_DBAAS_K8S_CLUSTER_SVR_SVC_NAME_PREFIX="svrsvc-"

K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_POD_NAME_PREFIX="slvpod-"
K2HR3CLI_DBAAS_K8S_CLUSTER_SLV_SVC_NAME_PREFIX="slvsvc-"

#
# NodePort for K2HR3 API/APP
#
# Since it is necessary to register the IP address of NodePort's ClusterIP
# as a SAN in the server certificate of K2HR3 API/APP, first create a
# Service for NodePort.
#
#   ex.) np-r3api, np-r3app
#
K2HR3CLI_DBAAS_K8S_K2HR3_API_NODEPORT_PREFIX="np-"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_NODEPORT_PREFIX="np-"

#
# configMap and Secret names
#
K2HR3CLI_DBAAS_K8S_SECRET_CA_NAME="secret-k2hr3-ca"
K2HR3CLI_DBAAS_K8S_SECRET_CERT_NAME="secret-k2hr3-certs"
K2HR3CLI_DBAAS_K8S_CONFIGMAP_NAME="configmap-k2hr3"

#
# Service Account
#
K2HR3CLI_DBAAS_K8S_SERVICE_ACCOUNT_PREFIX="sa-"
K2HR3CLI_DBAAS_K8S_CLUSTER_ROLEBINDING_PREFIX="crb-"
K2HR3CLI_DBAAS_K8S_CLUSTER_ROLE_PREFIX="cr-"

#
# ConfigMap and secret mount point
#
K2HR3CLI_DBAAS_K8S_CONFIGMAP_MOUNTPOINT="/configmap"
K2HR3CLI_DBAAS_K8S_SEC_CA_MOUNTPOINT="/secret-ca"
K2HR3CLI_DBAAS_K8S_SEC_CERTS_MOUNTPOINT="/secret-certs"
K2HR3CLI_DBAAS_K8S_ANTPICKAX_ETC_MOUTPOINT="/etc/antpickax"
K2HR3CLI_DBAAS_K8S_SEC_K2HR3_TOKEN_MOUNTPOINT="/secret-k2hr3-token"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
