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
# [NOTE]
# "$0" could be a test program and a k2hr3 command.
# Reconfigure "TESTDIR" here to make sure it is the test directory.
#
TESTDIR=$(dirname "$0")
TESTDIR=$(cd "${TESTDIR}/../test" || exit 1; pwd)

#--------------------------------------------------------------
# Dummy function
#--------------------------------------------------------------
#
# Replace kubectl command for test
#
test_kubectl()
{
	_TEST_DUMMY_KUBECTL_BACKUP_ALL_PARAMS="$*"
	_DUMMY_KUBECTL_PARAM_1=$1
	_DUMMY_KUBECTL_PARAM_2=$2
	_DUMMY_KUBECTL_PARAM_3=$3
	_DUMMY_KUBECTL_PARAM_4=$4

	if [ "X${_DUMMY_KUBECTL_PARAM_1}" = "Xget" ]; then
		if [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xpods" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xpod" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get pods
				#
				pecho "NAME                       READY   STATUS    RESTARTS  AGE"
				pecho "pod-r3api-0                2/2     Running   0         1h"
				pecho "pod-r3api-1                2/2     Running   0         1h"
				pecho "pod-r3app-bcf8569f-82g6w   1/1     Running   0         1h"
				pecho "pod-r3app-bcf8569f-kxfq7   1/1     Running   0         1h"
				pecho "pod-r3dkc-0                2/2     Running   0         1h"
				pecho "pod-r3dkc-1                2/2     Running   0         1h"
				pecho "slvpod-mycluster-0         2/2     Running   0         1h"
				pecho "slvpod-mycluster-1         2/2     Running   0         1h"
				pecho "svrpod-mycluster-0         3/3     Running   0         1h"
				pecho "svrpod-mycluster-1         3/3     Running   0         1h"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservices" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservice" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get services
				#
				pecho "NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE"
				pecho "kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP             1h"
				pecho "np-r3api           NodePort    10.106.251.103   <none>        8443:32043/TCP      1h"
				pecho "np-r3app           NodePort    10.106.202.254   <none>        8443:32443/TCP      1h"
				pecho "slvsvc-mycluster   ClusterIP   None             <none>        8022/TCP            1h"
				pecho "svc-r3api          ClusterIP   None             <none>        8022/TCP            1h"
				pecho "svc-r3dkc          ClusterIP   None             <none>        8020/TCP,8021/TCP   1h"
				pecho "svrsvc-mycluster   ClusterIP   None             <none>        8020/TCP,8021/TCP   1h"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xnp-r3api" ]; then
				#
				# kubectl get services np-r3api
				#
				pecho "NAME       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE"
				pecho "np-r3api   NodePort   10.106.251.103   <none>        8443:32043/TCP   11m"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xnp-r3app" ]; then
				#
				# kubectl get services np-r3api
				#
				pecho "NAME       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE"
				pecho "np-r3app   NodePort   10.106.251.103   <none>        8443:32443/TCP   20m"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xdeployments" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xdeployment" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get deployments
				#
				pecho "NAME        READY   UP-TO-DATE   AVAILABLE   AGE"
				pecho "pod-r3app   2/2     2            2           1h"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulsets" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulset" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get statefulsets
				#
				pecho "NAME               READY   AGE"
				pecho "pod-r3api          2/2     1h"
				pecho "pod-r3dkc          2/2     1h"
				pecho "slvpod-mycluster   2/2     1h"
				pecho "svrpod-mycluster   2/2     1h"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xsecrets" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xsecret" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get secrets
				#
				pecho "NAME                           TYPE                                  DATA   AGE"
				pecho "default-token-cbm98            kubernetes.io/service-account-token   3      1h"
				pecho "sa-r3api-token-nnz8s           kubernetes.io/service-account-token   3      1h"
				pecho "secret-k2hr3-ca                Opaque                                1      1h"
				pecho "secret-k2hr3-certs             Opaque                                18     1h"
				pecho "secret-mycluster-certs         Opaque                                17     1h"
				pecho "secret-mycluster-k2hr3-token   Opaque                                2      1h"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xconfigmaps" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xconfigmap" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get configmaps
				#
				pecho "NAME                  DATA   AGE"
				pecho "configmap-k2hr3       9      1h"
				pecho "configmap-mycluster   5      1h"
				pecho "kube-root-ca.crt      1      1h"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xserviceaccounts" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xserviceaccount" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X" ]; then
				#
				# kubectl get serviceaccounts
				#
				pecho "NAME       SECRETS   AGE"
				pecho "default    1         1h"
				pecho "sa-r3api   1         1h"
				return 0
			fi
		fi

	elif [ "X${_DUMMY_KUBECTL_PARAM_1}" = "Xdescribe" ]; then
		if [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservices" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservice" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xnp-r3api" ]; then
				#
				# kubectl describe services np-r3api
				#
				pecho "Name:                     np-r3api"
				pecho "Namespace:                default"
				pecho "Labels:                   <none>"
				pecho "Annotations:              <none>"
				pecho "Selector:                 app=r3api"
				pecho "Type:                     NodePort"
				pecho "IP Family Policy:         SingleStack"
				pecho "IP Families:              IPv4"
				pecho "IP:                       10.106.251.103"
				pecho "IPs:                      10.106.251.103"
				pecho "Port:                     k2hr3-api-port  8443/TCP"
				pecho "TargetPort:               443/TCP"
				pecho "NodePort:                 k2hr3-api-port  32043/TCP"
				pecho "Endpoints:                172.17.0.7:443,172.17.0.8:443"
				pecho "Session Affinity:         None"
				pecho "External Traffic Policy:  Cluster"
				pecho "Events:                   <none>"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xnp-r3app" ]; then
				#
				# kubectl describe services np-r3app
				#
				pecho "Name:                     np-r3app"
				pecho "Namespace:                default"
				pecho "Labels:                   <none>"
				pecho "Annotations:              <none>"
				pecho "Selector:                 app=r3app"
				pecho "Type:                     NodePort"
				pecho "IP Family Policy:         SingleStack"
				pecho "IP Families:              IPv4"
				pecho "IP:                       10.106.202.254"
				pecho "IPs:                      10.106.202.254"
				pecho "Port:                     k2hr3-app-port  8443/TCP"
				pecho "TargetPort:               443/TCP"
				pecho "NodePort:                 k2hr3-app-port  32443/TCP"
				pecho "Endpoints:                172.17.0.10:443,172.17.0.9:443"
				pecho "Session Affinity:         None"
				pecho "External Traffic Policy:  Cluster"
				pecho "Events:                   <none>"
				return 0
			fi
		fi

	elif [ "X${_DUMMY_KUBECTL_PARAM_1}" = "Xapply" ]; then
		if [ "X${_DUMMY_KUBECTL_PARAM_2}" = "X-k" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local" ]; then
				#
				# kubectl apply -k <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local
				#
				pecho "succeed : kubectl apply -k <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster" ]; then
				#
				# kubectl apply -k <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster
				#
				pecho "succeed : kubectl apply -k <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "X-f" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-sa.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-sa.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-sa.yaml"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hdkc.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hdkc.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hdkc.yaml"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3api.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3api.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3api.yaml"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3app.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3app.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/k2hr3-k2hr3app.yaml"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-server.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-server.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-server.yaml"
				return 0

			elif [ "X${_DUMMY_KUBECTL_PARAM_3}" = "X${TESTDIR}/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-slave.yaml" ]; then
				#
				# kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-slave.yaml
				#
				pecho "succeed : kubectl apply -f <test directory>/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-slave.yaml"
				return 0
			fi
		fi

	elif [ "X${_DUMMY_KUBECTL_PARAM_1}" = "Xdelete" ]; then
		if [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xpods" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xpod" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete pods <resource>
				#
				pecho "succeed : kubectl delete pods ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservices" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xservice" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete services <resource>
				#
				pecho "succeed : kubectl delete services ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xdeployments" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xdeployment" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete deployments <resource>
				#
				pecho "succeed : kubectl delete deployments ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulsets" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulset" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete statefulsets <resource>
				#
				pecho "succeed : kubectl delete statefulsets ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xsecrets" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xsecret" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete secrets <resource>
				#
				pecho "succeed : kubectl delete secrets ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xconfigmaps" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xconfigmap" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete configmaps <resource>
				#
				pecho "succeed : kubectl delete configmaps ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xserviceaccounts" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xserviceaccount" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete serviceaccounts <resource>
				#
				pecho "succeed : kubectl delete serviceaccounts ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xclusterrolebindings" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xclusterrolebinding" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete clusterrolebindings <resource>
				#
				pecho "succeed : kubectl delete clusterrolebindings ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi

		elif [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xclusterroles" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xclusterrole" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" != "X" ]; then
				#
				# kubectl delete clusterroles <resource>
				#
				pecho "succeed : kubectl delete clusterroles ${_DUMMY_KUBECTL_PARAM_3}"
				return 0
			fi
		fi

	elif [ "X${_DUMMY_KUBECTL_PARAM_1}" = "Xscale" ]; then
		if [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulsets" ] || [ "X${_DUMMY_KUBECTL_PARAM_2}" = "Xstatefulset" ]; then
			if [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xsvrpod-mycluster" ] || [ "X${_DUMMY_KUBECTL_PARAM_3}" = "Xslvpod-mycluster" ]; then
				#
				# Check --replicas option value
				#
				_DUMMY_KUBECTL_REPLICAS=$(echo "${_DUMMY_KUBECTL_PARAM_4}" | sed -e 's/--replicas=//g')
				# shellcheck disable=SC2003
				expr "${_DUMMY_KUBECTL_REPLICAS}" + 1 >/dev/null 2>&1
				if [ $? -eq 0 ]; then
					#
					# kubectl scale statefulsets <cluster name> --replicas=<count>
					#
					pecho "succeed : kubectl scale statefulsets ${_DUMMY_KUBECTL_PARAM_3} --replicas=${_DUMMY_KUBECTL_REPLICAS}"
					return 0
				else
					pecho "failure : replica count value is wrong : ${_DUMMY_KUBECTL_REPLICAS}"
				fi
			fi
		fi
	fi

	echo "[Unimplement: kubectl] ${_TEST_DUMMY_KUBECTL_BACKUP_ALL_PARAMS}" >> "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}"
	return 1
}

#--------------------------------------------------------------
# Replace minikube command for test
#
test_minikube()
{
	_TEST_DUMMY_KUBECTL_BACKUP_ALL_PARAMS="$*"
	_DUMMY_MINIKUBE_PARAM_1=$1

	if [ "X${_DUMMY_MINIKUBE_PARAM_1}" = "Xip" ]; then
		pecho "192.168.1.254"
		return 0
	fi

	echo "[Unimplement: minikube] ${_TEST_DUMMY_KUBECTL_BACKUP_ALL_PARAMS}" >> "${TEST_K2HDKC_DBAAS_K8S_UNIMPLEMENT_LOG}"
	return 1
}

#--------------------------------------------------------------
# Replace socat command for test
#
test_socat()
{
	#
	# Always return success
	#
	return 0
}

#--------------------------------------------------------------
# Set symbols for dummy function
#--------------------------------------------------------------
export KUBECTL_BIN="test_kubectl"
export MINIKUBE_BIN="test_minikube"
export SOCAT_BIN="test_socat"

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
