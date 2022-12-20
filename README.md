K2HDKC DBaaS on Kubernetes Command Line Interface(K2HR3 CLI Plugin)
===================================================================
[![Nobuild AntPickax CI](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/workflows/Nobuild%20AntPickax%20CI/badge.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/actions)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/blob/master/COPYING)
[![GitHub forks](https://img.shields.io/github/forks/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/network)
[![GitHub stars](https://img.shields.io/github/stars/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/issues)
[![debian packages](https://img.shields.io/badge/deb-packagecloud.io-844fec.svg)](https://packagecloud.io/antpickax/stable)
[![RPM packages](https://img.shields.io/badge/rpm-packagecloud.io-844fec.svg)](https://packagecloud.io/antpickax/stable)

### **K2HDKC** **DBaaS**

![K2HDKC DBaaS](https://dbaas.k2hdkc.antpick.ax/images/top_k2hdkc_dbaas.png)

#### K2HDKC DBaaS Overview
**K2HDKC DBaaS** (DataBase as a Service of K2HDKC) is a basic system that provides [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) as a service.  
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that uses [K2HR3](https://k2hr3.antpick.ax/) and works with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/) to build a [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) Cluster for distributed KVS.  
Users can easily launch, scale, back up, and restore **K2HDKC** clusters as **K2HDKC DBaaS**.  

Detailed documentation for K2HDKC DBaaS can be found [here](https://dbaas.k2hdkc.antpick.ax/).  

#### K2HKDC DBaaS types
There are four types of **DBaaS** (Database as a Service) provided by **K2HDKC DBaaS** (Database as a Service for K2HDKC) as shown below.  
We provide two K2HDKC DBaaS types that cooperate with OpenStack and two types that cooperate with kubernetes.  

##### With Trove(Trove is Database as a Service for OpenStack)
This is DBaaS(Database as a Service) using Trove which is a product of OpenStack.  
It incorporates K2HDKC (Distributed KVS) as one of Trove’s databases to realize DBaaS(Database as a Service).

##### K2HDKC DBaaS CLI(Command Line Interface) for OpenStack
If you have an existing OpenStack environment, this K2HDKC DBaaS CLI(Command Line Interface) allows you to implement DBaaS(Database as a Service) without any changes.

##### K2HDKC DBaaS on kubernetes CLI(Command Line Interface)
If you are using kubernetes cluster or trial environment such as minikube, this K2HDKC DBaaS on kubernetes CLI(Command Line Interface) allows you to implement DBaaS(Database as a Service) without any changes.

##### K2HDKC Helm Chart
If you are using kubernetes cluster or trial environment such as minikube, you can install(build) DBaaS(Database as a Service) by using Helm(The package manager for Kubernetes) with K2HDKC Helm Chart.

### **K2HDKC DBaaS K8S CLI(Command Line Interface)** - (K2HR3 CLI Plugin)
The **K2HDKC DBaaS K8S CLI** (Command Line Interface of Database as a Service for K2HDKC) acts as a one of Plugin for the [K2HR3 CLI(Command Line Interface)](https://k2hr3.antpick.ax/).  
This **K2HDKC DBaaS K8S CLI** is included as one command `database-k8s` in the K2HR3 CLI, allowing you to build a K2HDKC cluster in [kubernetes](https://kubernetes.io/) cluster.  
And provides **one way** to build **DBaaS(Database as a Service)** on [kubernetes](https://kubernetes.io/).  

The overall **K2HDKC DBaaS on kubernetes CLI** overview diagram is shown below.  

![K2HDKC DBaaS system for kubernetes](https://dbaas.k2hdkc.antpick.ax/images/overview_k8s_cli.png)  

### Documents
[K2HDKC DBaaS Document](https://dbaas.k2hdkc.antpick.ax/index.html)  
[Github wiki page](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/wiki)

[About k2hdkc Document](https://k2hdkc.antpick.ax/index.html)  
[About chmpx Document](https://chmpx.antpick.ax/index.html)  
[About k2hr3 Document](https://k2hr3.antpick.ax/index.html)  

[About AntPickax](https://antpick.ax/)  

### Repositories
[k2hdkc dbaas](https://github.com/yahoojapan/k2hdkc_dbaas)  
[k2hdkc_dbaas_cli](https://github.com/yahoojapan/k2hdkc_dbaas_cli)  
[k2hr3](https://github.com/yahoojapan/k2hr3)  
[k2hr3_app](https://github.com/yahoojapan/k2hr3_app)  
[k2hr3_api](https://github.com/yahoojapan/k2hr3_api)  
[k2hr3_cli](https://github.com/yahoojapan/k2hr3_cli)  
[k2hr3_get_resource](https://github.com/yahoojapan/k2hr3_get_resource)  
[k2hdkc](https://github.com/yahoojapan/k2hdkc)  
[k2hdkc_dbaas_override_conf](https://github.com/yahoojapan/k2hdkc_dbaas_override_conf)  
[chmpx](https://github.com/yahoojapan/chmpx)  

### Packages
[k2hdkc(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc)  
[chmpx(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=chmpx)  
[k2hdkc-dbaas-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-cli)  
[k2hdkc-dbaas-k8s-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-k8s-cli)  
[k2hdkc-dbaas-override-conf(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-override-conf)  
[k2hr3-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hr3-cli)  
[k2hr3-app(npm packages)](https://www.npmjs.com/package/k2hr3-app)  
[k2hr3-api(npm packages)](https://www.npmjs.com/package/k2hr3-api)  
[k2hr3-get-resource(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hr3-get-resource)  

### License
This software is released under the MIT License, see the license file.

### AntPickax
K2HDKC DbaaS on kubernetes CLI is one of [AntPickax](https://antpick.ax/) products.

Copyright(C) 2021 Yahoo Japan Corporation.
