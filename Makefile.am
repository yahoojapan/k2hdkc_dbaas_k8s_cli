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

SUBDIRS = src buildutils test

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = RELEASE_VERSION @CONFIGURECUSTOM@

# [NOTE]
# Change the default target to build.
#
.DEFAULT_GOAL = build

# [CLEAN]
# Use clean-local instead of CLEANFILES as it contains subdirectories and so on.
#
clean-local: clean-local-files

.PHONY: clean-local-files

clean-local-files:
	rm -f *.log; \
	DEFAULT_GIT_DOMAIN="@GIT_DOMAIN@" DEFAULT_K2HR3_CLI_ORG="@GIT_ORG@" buildutils/setup_k2hr3_cli_component.sh --clean

# [BUILD]
# Since it is a shell script-only project, there is nothing to build,
# but we will create a VERSION file.
#
build: setup_k2hr3_cli build_version

.PHONY: setup_k2hr3_cli build_version shellcheck

# [SETUP]
# Copy the required files from the K2HR3 CLI.
#
setup_k2hr3_cli:
	@if true; then \
		echo "*** Copy the required directories/files from the K2HR3 CLI repository."; \
		DEFAULT_GIT_DOMAIN="@GIT_DOMAIN@" DEFAULT_K2HR3_CLI_ORG="@GIT_ORG@" buildutils/setup_k2hr3_cli_component.sh --k2hr3_cli_repo k2hr3_cli; \
	fi

# [VERSION]
# Create a VERSION file in the src/libexec/database-k8s directory.
#
build_version:
	@if true; then \
		echo "*** Create VERSION file in src/libexec/database-k8s directory"; \
		RELEASE_VERSION_BASE=`cat RELEASE_VERSION`; \
		GIT_SHORT_HASH=`git rev-parse --short HEAD 2>/dev/null || echo \"Unknown\"`; \
		echo "$${RELEASE_VERSION_BASE}($${GIT_SHORT_HASH})" > src/libexec/database-k8s/VERSION 2>&1; \
		echo "   -> Succeed"; \
		echo ""; \
	fi

# [SHELLCHECK]
#
SHELLCHECK_CMD				= shellcheck
SHELLCHECK_BASE_OPT			= --shell=sh
SHELLCHECK_IGN_OPT			= --exclude=SC1117,SC1090,SC1091
SHELLCHECK_INCLUDE_IGN_OPT	= --exclude=SC1117,SC1090,SC1091,SC2034,SC2148
SHELLCHECK_FILES_SH			= `grep -ril '^\#!/bin/sh' . | grep '\.sh' | grep -v '\.sh\.' | grep -v '/\.git/' | grep -v '/rpmbuild/' | grep -v '/debian_build/' | grep -v '/autom4te.cache/' | grep -v '/m4/' | tr '\n' ' '`
SHELLCHECK_FILES_INCLUDE_SH	= `grep -Lir '^\#!/bin/sh' . | grep '\.sh' | grep -v '\.sh\.' | grep -v '/\.git/' | grep -v '/rpmbuild/' | grep -v '/debian_build/' | grep -v '/autom4te.cache/' | grep -v '/m4/' | tr '\n' ' '`

shellcheck:
	@if type shellcheck > /dev/null 2>&1; then \
		echo "*** Check all files with ShellCheck"; \
		if [ -n "$(SHELLCHECK_FILES_SH)" ]; then \
			LC_ALL=C.UTF-8 $(SHELLCHECK_CMD) $(SHELLCHECK_BASE_OPT) $(SHELLCHECK_IGN_OPT) $(SHELLCHECK_FILES_SH) || exit 1; \
		fi; \
		if [ -n "$(SHELLCHECK_FILES_INCLUDE_SH)" ]; then \
			LC_ALL=C.UTF-8 $(SHELLCHECK_CMD) $(SHELLCHECK_BASE_OPT) $(SHELLCHECK_INCLUDE_IGN_OPT) $(SHELLCHECK_FILES_INCLUDE_SH) || exit 1; \
		fi; \
		echo "   -> No error was detected."; \
		echo ""; \
	else \
		echo "ShellCheck is not installed, so skip check by it."; \
		echo ""; \
	fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
