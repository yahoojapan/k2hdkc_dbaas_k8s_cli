#!/bin/sh
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

# [NOTE]
# This script copies the required files and directories from the
# k2hr3_cli repository.
# Since the K2HR3 CLI PLUGIN has only the plugin elements, it
# requires the k2hr3_cli component under the current directory
# for testing and debugging.
# This script allows you to deploy the minimum required components.
#

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
PRGNAME=$(basename "$0")
MYSCRIPTDIR=$(dirname "$0")
SRCTOP=$(cd "${MYSCRIPTDIR}/.." || exit 1; pwd)

#
# Git directory/file
#
GIT_DIR="${SRCTOP}/.git"
GIT_CONFIG_FILE="${GIT_DIR}/config"

#
# k2hr3_cli default
#
SPECIFIED_K2HR3_CLI_PATH_ENV=1
if [ -z "${DEFAULT_GIT_DOMAIN}" ]; then
	DEFAULT_GIT_DOMAIN="github.com"
	SPECIFIED_K2HR3_CLI_PATH_ENV=0
fi
if [ -z "${DEFAULT_K2HR3_CLI_ORG}" ]; then
	DEFAULT_K2HR3_CLI_ORG="yahoojapan"
	SPECIFIED_K2HR3_CLI_PATH_ENV=0
fi
if [ -z "${K2HR3_CLI_REPO_NAME}" ]; then
	K2HR3_CLI_REPO_NAME="k2hr3_cli"
fi

#
# expand directory
#
EXPAND_TOP_DIR="/tmp/.k2hdkc_dbaas_cli_tmp"

#--------------------------------------------------------------
# Functions
#--------------------------------------------------------------
func_usage()
{
	echo ""
	echo "Usage:  $1 [--clean(-c)] [--force_archive(-f)] [--k2hr3_cli_repo <repo name>] [--help(-h)]"
	echo "	--clean(-c)                     Cleanup directories and files"
	echo "	--force_archive(-f)             Forcibly use the archive(default: not use archive)"
	echo "	--k2hr3_cli_repo <repo name>    Specify k2hr3_cli repository name(default: k2hr3_cli)"
	echo "	--help(-h)                      Display help."
	echo ""
}

#--------------------------------------------------------------
# Options
#--------------------------------------------------------------
#
# Check options
#
IS_CLEANUP=0
USE_ARCHIVE=0
_TMP_K2HR3_CLI_REPO_NAME=""
while [ $# -ne 0 ]; do
	if [ -z "$1" ]; then
		break;

	elif echo "$1" | grep -q -i -e "^-h$" -e "^--help$"; then
		func_usage "${PRGNAME}"
		exit 0

	elif echo "$1" | grep -q -i -e "^-c$" -e "^--clean$"; then
		if [ "${IS_CLEANUP}" -eq 1 ]; then
			echo "[ERROR] ${PRGNAME} - Already specified \"$1\" option." 1>&2
			exit 1
		fi
		IS_CLEANUP=1

	elif echo "$1" | grep -q -i -e "^-f$" -e "^--force_archive$"; then
		if [ "${USE_ARCHIVE}" -eq 1 ]; then
			echo "[ERROR] ${PRGNAME} - Already specified \"$1\" option." 1>&2
			exit 1
		fi
		USE_ARCHIVE=1

		#
		# Force
		#
		if [ "${SPECIFIED_K2HR3_CLI_PATH_ENV}" -eq 1 ]; then
			SPECIFIED_K2HR3_CLI_PATH_ENV=0
		fi

	elif echo "$1" | grep -q -i "^--k2hr3_cli_repo$"; then
		if [ -n "${_TMP_K2HR3_CLI_REPO_NAME}" ]; then
			echo "[ERROR] ${PRGNAME} - Already specified \"$1\" option." 1>&2
			exit 1
		fi
		shift
		if [ $# -le 0 ]; then
			echo "[ERROR] ${PRGNAME} - \"$1\" option needs parameter." 1>&2
			exit 1
		fi
		_TMP_K2HR3_CLI_REPO_NAME="$1"

	else
		echo "[ERROR] ${PRGNAME} - Unknown option \"$1\"" 1>&2
		echo "0" | tr -d '\n'
		exit 1
	fi
	shift
done
if [ -n "${_TMP_K2HR3_CLI_REPO_NAME}" ]; then
	K2HR3_CLI_REPO_NAME="${_TMP_K2HR3_CLI_REPO_NAME}"
fi

#==============================================================
# Main processing
#==============================================================
#
# Cleanup
#

# [NOTE]
# Changed not to delete the VERSION file, as it is always overwritten.
# Revert to delete if necessary.
#
# [TODO] 
# Directories may still be added.
#
#rm -f "${SRCTOP}/src/libexec/database/VERSION"
rm -f "${SRCTOP}/src/k2hr3"
rm -rf "${SRCTOP}/src/libexec/common"
rm -rf "${SRCTOP}/src/libexec/config"
rm -rf "${SRCTOP}/src/libexec/token"
rm -rf "${SRCTOP}/src/libexec/resource"
rm -rf "${SRCTOP}/src/libexec/policy"
rm -rf "${SRCTOP}/src/libexec/role"
rm -rf "${SRCTOP}/src/libexec/userdata"
rm -f "${SRCTOP}/test/util_test.sh"
rm -f "${SRCTOP}/test/util_request.sh"
if [ "${IS_CLEANUP}" -eq 1 ]; then
	exit 0
fi

#--------------------------------------------------------------
# Check k2hr3_cli source code
#--------------------------------------------------------------
#
# Check .git/config file
#
USE_GIT_CONFIG=0
if [ -d "${GIT_DIR}" ]; then
	if [ -f "${GIT_CONFIG_FILE}" ]; then
		USE_GIT_CONFIG=1
	fi
fi

#
# Check options and git domain / organaization
#
if [ "${USE_GIT_CONFIG}" -eq 1 ]; then
	#
	# Check git information
	#
	echo "[INFO] ${PRGNAME} - Check .git/config for git domain and organaiztion" 1>&2

	GIT_URL_THIS_REPO=$(grep -i '^[[:space:]]*url[[:space:]]*=[[:space:]]*' .git/config | head -1 | sed -e 's/^[[:space:]]*url[[:space:]]*=[[:space:]]*//gi' | tr -d '\n')

	if [ -n "${GIT_URL_THIS_REPO}" ]; then
		#
		# Get git domain and organaization
		#
		GIT_DOMAIN_NAME=$(echo "${GIT_URL_THIS_REPO}" | sed -e 's/^git@//g' -e 's#^http[s]*://##g' -e 's/:/ /g' -e 's#/# #g' | awk '{print $1}' | tr -d '\n')
		GIT_ORG_NAME=$(echo "${GIT_URL_THIS_REPO}" | sed -e 's/^git@//g' -e 's#^http[s]*://##g' -e 's/:/ /g' -e 's#/# #g' | awk '{print $2}' | tr -d '\n')

		if [ -z "${GIT_DOMAIN_NAME}" ] || [ -z "${GIT_ORG_NAME}" ]; then
			echo "[WARNING] ${PRGNAME} - Unknown git dmain and organaization in .git/config" 1>&2
			USE_ARCHIVE=1
			GIT_DOMAIN_NAME="${DEFAULT_GIT_DOMAIN}"
			GIT_ORG_NAME="${DEFAULT_K2HR3_CLI_ORG}"
		fi
	else
		echo "[WARNING] ${PRGNAME} - Unknown git url in .git/config" 1>&2
		USE_ARCHIVE=1
		GIT_DOMAIN_NAME="${DEFAULT_GIT_DOMAIN}"
		GIT_ORG_NAME="${DEFAULT_K2HR3_CLI_ORG}"
	fi
else
	echo "[INFO] ${PRGNAME} - .git/config is not existed." 1>&2
	USE_ARCHIVE=1
	GIT_DOMAIN_NAME="${DEFAULT_GIT_DOMAIN}"
	GIT_ORG_NAME="${DEFAULT_K2HR3_CLI_ORG}"
fi

#
# Check environments
#
if [ "${USE_ARCHIVE}" -eq 1 ] && [ "${SPECIFIED_K2HR3_CLI_PATH_ENV}" -eq 1 ] && [ -n "${DEFAULT_GIT_DOMAIN}" ] && [ -n "${DEFAULT_K2HR3_CLI_ORG}" ]; then
	echo "[INFO] ${PRGNAME} - Since the k2hr3_cli repository path is specified in the environment, use it to clone instead of downloading the archive." 1>&2
	USE_ARCHIVE=0
	GIT_DOMAIN_NAME="${DEFAULT_GIT_DOMAIN}"
	GIT_ORG_NAME="${DEFAULT_K2HR3_CLI_ORG}"
fi

#
# Check local archive file
#
# [NOTE]
# Archive files have the highest priority and will ignore all options if the file exists.
#
CHECK_START_TOP_DIR="${SRCTOP}"
USE_LOCAL_ARCHIVE_FILE=0

while [ "${USE_LOCAL_ARCHIVE_FILE}" -eq 0 ]; do
	LOCAL_ARCHIVE_FILE="${CHECK_START_TOP_DIR}/${K2HR3_CLI_REPO_NAME}.tgz"
	if [ -f "${LOCAL_ARCHIVE_FILE}" ]; then
		USE_LOCAL_ARCHIVE_FILE=1
	else
		CHECK_START_TOP_DIR=$(dirname "${CHECK_START_TOP_DIR}")
		if [ -z "${CHECK_START_TOP_DIR}" ] || [ "${CHECK_START_TOP_DIR}" = "/" ]; then
			#
			# Not found
			#
			LOCAL_ARCHIVE_FILE=""
			break
		fi
	fi
done

#--------------------------------------------------------------
# Get k2hr3_cli source code
#--------------------------------------------------------------
mkdir -p "${EXPAND_TOP_DIR}"

K2HR3_CLI_EXPAND_DIR=""

if [ "${USE_LOCAL_ARCHIVE_FILE}" -eq 1 ]; then
	#
	# Expand local archive file
	#
	CURRENT_DIR=$(pwd)
	cd "${EXPAND_TOP_DIR}" || exit 1

	if tar xvfz "${LOCAL_ARCHIVE_FILE}" >/dev/null; then
		if [ -d "${K2HR3_CLI_REPO_NAME}" ]; then
			K2HR3_CLI_EXPAND_DIR="${EXPAND_TOP_DIR}/${K2HR3_CLI_REPO_NAME}"
		else
			echo "[ERROR] ${PRGNAME} - Not found ${EXPAND_TOP_DIR}/${K2HR3_CLI_REPO_NAME}" 1>&2
		fi
	else
		echo "[ERROR] ${PRGNAME} - Failed to expand ${EXPAND_TOP_DIR}/${K2HR3_CLI_ZIP_NAME} from ${LOCAL_ARCHIVE_FILE}" 1>&2
	fi
	cd "${CURRENT_DIR}" || exit 1

elif [ "${USE_ARCHIVE}" -ne 1 ]; then
	#
	# Git clone k2hr3_cli
	#
	echo "[INFO] ${PRGNAME} - Try git clone all ${K2HR3_CLI_REPO_NAME}" 1>&2

	K2HR3_CLI_GIT_URI="https://${GIT_DOMAIN_NAME}/${GIT_ORG_NAME}/${K2HR3_CLI_REPO_NAME}.git"

	CURRENT_DIR=$(pwd)
	cd "${EXPAND_TOP_DIR}" || exit 1

	if git clone "${K2HR3_CLI_GIT_URI}"; then
		if [ -d "${K2HR3_CLI_REPO_NAME}" ]; then
			K2HR3_CLI_EXPAND_DIR="${EXPAND_TOP_DIR}/${K2HR3_CLI_REPO_NAME}"
		else
			echo "[ERROR] ${PRGNAME} - Not found ${K2HR3_CLI_REPO_NAME} directory." 1>&2
		fi
	else
		echo "[ERROR] ${PRGNAME} - Failed to clone ${K2HR3_CLI_REPO_NAME}" 1>&2
	fi
else
	#
	# Download k2hr3_cli archive
	#
	echo "[INFO] ${PRGNAME} - Try Download ${K2HR3_CLI_REPO_NAME} archive" 1>&2

	K2HR3_CLI_ZIP_NAME="master.zip"
	K2HR3_CLI_ZIP_URI="https://${GIT_DOMAIN_NAME}/${GIT_ORG_NAME}/${K2HR3_CLI_REPO_NAME}/archive/${K2HR3_CLI_ZIP_NAME}"

	if curl -s -L "${K2HR3_CLI_ZIP_URI}" --output "${EXPAND_TOP_DIR}/${K2HR3_CLI_ZIP_NAME}"; then
		if [ -f "${EXPAND_TOP_DIR}/${K2HR3_CLI_ZIP_NAME}" ]; then
			CURRENT_DIR=$(pwd)
			cd "${EXPAND_TOP_DIR}" || exit 1

			if unzip "${K2HR3_CLI_ZIP_NAME}" >/dev/null; then
				if [ -d "${K2HR3_CLI_REPO_NAME}-master" ]; then
					mv "${K2HR3_CLI_REPO_NAME}-master" "${K2HR3_CLI_REPO_NAME}"
					K2HR3_CLI_EXPAND_DIR="${EXPAND_TOP_DIR}/${K2HR3_CLI_REPO_NAME}"
				else
					echo "[ERROR] ${PRGNAME} - Not found ${EXPAND_TOP_DIR}/${K2HR3_CLI_REPO_NAME}-master" 1>&2
				fi
			else
				echo "[ERROR] ${PRGNAME} - Failed to unzip ${EXPAND_TOP_DIR}/${K2HR3_CLI_ZIP_NAME}" 1>&2
			fi
			cd "${CURRENT_DIR}" || exit 1
		else
			echo "[ERROR] ${PRGNAME} - Not found download file(${EXPAND_TOP_DIR}/${K2HR3_CLI_ZIP_NAME})" 1>&2
		fi
	else
		echo "[ERROR] ${PRGNAME} - Failed to download ${K2HR3_CLI_REPO_NAME} archive" 1>&2
	fi
fi

#
# Check download
#
if [ -z "${K2HR3_CLI_EXPAND_DIR}" ]; then
	rm -rf "${EXPAND_TOP_DIR}"
	exit 1
fi
if [ ! -d "${K2HR3_CLI_EXPAND_DIR}" ]; then
	rm -rf "${EXPAND_TOP_DIR}"
	exit 1
fi

#
# Copy(mv) files/directories
#
echo "[INFO] ${PRGNAME} - Copy ${K2HR3_CLI_REPO_NAME} files/directories" 1>&2

#
# [TODO] ... Directories may still be added.
#
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/k2hr3"				"${SRCTOP}/src"			|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/common"		"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/config"		"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/token"		"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/resource"	"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/policy"		"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/role"		"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/src/libexec/userdata"	"${SRCTOP}/src/libexec"	|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/test/util_request.sh"	"${SRCTOP}/test"		|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)
cp -r "${K2HR3_CLI_EXPAND_DIR}/test/util_test.sh"		"${SRCTOP}/test"		|| (rm -rf "${EXPAND_TOP_DIR}";  exit 1)

rm -rf "${EXPAND_TOP_DIR}"

echo "[INFO] ${PRGNAME} - Finish" 1>&2

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
