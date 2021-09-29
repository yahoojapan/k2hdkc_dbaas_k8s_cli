K2HDKC DBaaS on Kubernetes Command Line Interface(K2HR3 CLI Plugin)
===================================================================
[![Nobuild AntPickax CI](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/workflows/Nobuild%20AntPickax%20CI/badge.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/actions)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/blob/master/COPYING)
[![GitHub forks](https://img.shields.io/github/forks/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/network)
[![GitHub stars](https://img.shields.io/github/stars/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/yahoojapan/k2hdkc_dbaas_k8s_cli.svg)](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/issues)
[![debian packages](https://img.shields.io/badge/deb-packagecloud.io-844fec.svg)](https://packagecloud.io/antpickax/stable)
[![RPM packages](https://img.shields.io/badge/rpm-packagecloud.io-844fec.svg)](https://packagecloud.io/antpickax/stable)

## **K2HDKC DBaaS K8S CLI(Command Line Interface)** - (K2HR3 CLI Plugin)
The **K2HDKC DBaaS K8S CLI** (Command Line Interface of Database as a Service for K2HDKC) acts as a one of Plugin for the [K2HR3 CLI(Command Line Interface)](https://k2hr3.antpick.ax/).  
This **K2HDKC DBaaS K8S CLI** is included as one command `database-k8s` in the K2HR3 CLI, allowing you to build a K2HDKC cluster in [kubernetes](https://kubernetes.io/) cluster.  

![K2HDKC DBaaS](https://dbaas.k2hdkc.antpick.ax/images/top_k2hdkc_dbaas.png)

## About K2HKDC DBaaS
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that uses [K2HR3](https://k2hr3.antpick.ax/) and works with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/) to build a [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) Cluster for distributed KVS.  
**K2HDKC DBaaS** (Database as a Service for K2HDKC) provides the following **two ways** to build **DBaaS(Database as a Service)** on [OpenStack](https://www.openstack.org/).  
And provides **one way** to build **DBaaS(Database as a Service)** on [kubernetes](https://kubernetes.io/).  

This repository is a tool that provides a Command Line Interface for building **K2HKDC DBaaS** cluster in [kubernetes](https://kubernetes.io/) cluster.  
For other type's source code, see the repository below.  

## About K2HKDC DBaaS on kubernetes CLI
This **K2HDKC DBaaS on kubernetes CLI** works in conjunction with [kubernetes](https://kubernetes.io/) system.  
And the [K2HR3](https://k2hr3.antpick.ax/) system is used as the back end as an RBAC(Role Base Access Control) system dedicated to K2HDKC DBaaS.  

The overall **K2HDKC DBaaS on kubernetes CLI** overview diagram is shown below.  

![K2HDKC DBaaS system for kubernetes](https://dbaas.k2hdkc.antpick.ax/images/overview_k8s_cli.png)  

### K2HR3 System Overview
**K2HR3** (**K2H**dkc based **R**esource and **R**oles and policy **R**ules) is one of extended **RBAC** (**R**ole **B**ased **A**ccess **C**ontrol) system.  
K2HR3 works as RBAC in cooperation with **OpenStack** which is one of **IaaS**(Infrastructure as a Service), and also provides useful functions for using RBAC.  

K2HR3 is a system that defines and controls **HOW**(policy Rule), **WHO**(Role), **WHAT**(Resource), as RBAC.  
Users of K2HR3 can define **Role**(WHO) groups to access freely defined **Resource**(WHAT) and control access by **policy Rule**(HOW).  
By defining the information and assets required for any system as a **Resource**(WHAT), K2HR3 system can give the opportunity to provide access control in every situation.  

K2HR3 provides **+SERVICE** feature, it **strongly supports** user system, function and information linkage.  

![K2HR3 system overview](https://k2hr3.antpick.ax/images/overview_abstract.png)  

K2HR3 is built [k2hdkc](https://github.com/yahoojapan/k2hdkc), [k2hash](https://github.com/yahoojapan/k2hash), [chmpx](https://github.com/yahoojapan/chmpx) and [k2hash transaction plugin](https://github.com/yahoojapan/k2htp_dtor) components by [AntPickax](https://antpick.ax/).  

## Documents
[K2HDKC DBaaS Document](https://dbaas.k2hdkc.antpick.ax/index.html)  
[Github wiki page](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli/wiki)

[About k2hdkc Document](https://k2hdkc.antpick.ax/index.html)  
[About chmpx Document](https://chmpx.antpick.ax/index.html)  
[About k2hr3 Document](https://k2hr3.antpick.ax/index.html)  

[About AntPickax](https://antpick.ax/)  

## Repositories
[k2hdkc dbaas](https://github.com/yahoojapan/k2hdkc_dbaas)  
[k2hdkc_dbaas_cli](https://github.com/yahoojapan/k2hdkc_dbaas_cli)  
[k2hr3](https://github.com/yahoojapan/k2hr3)  
[k2hr3_app](https://github.com/yahoojapan/k2hr3_app)  
[k2hr3_api](https://github.com/yahoojapan/k2hr3_api)  
[k2hr3_cli](https://github.com/yahoojapan/k2hr3_cli)  
[k2hdkc](https://github.com/yahoojapan/k2hdkc)  
[chmpx](https://github.com/yahoojapan/chmpx)  

## Packages
[k2hdkc(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc)  
[chmpx(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=chmpx)  
[k2hr3-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hr3-cli)  
[k2hdkc-dbaas-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-cli)  
[k2hdkc-dbaas-k8s-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-k8s-cli)  
[k2hr3-app(npm packages)](https://www.npmjs.com/package/k2hr3-app)  
[k2hr3-api(npm packages)](https://www.npmjs.com/package/k2hr3-api)  

## Docker images on [docker hub](https://hub.docker.com/)  
[k2hr3-app](https://hub.docker.com/repository/docker/antpickax/k2hr3-app)  
[k2hr3-api](https://hub.docker.com/repository/docker/antpickax/k2hr3-api)  
[k2hdkc](https://hub.docker.com/repository/docker/antpickax/k2hdkc)  
[k2htpdtor](https://hub.docker.com/repository/docker/antpickax/k2htpdtor)  
[chmpx](https://hub.docker.com/repository/docker/antpickax/chmpx)  

### License
This software is released under the MIT License, see the license file.

### AntPickax
K2HDKC DbaaS on kubernetes CLI is one of [AntPickax](https://antpick.ax/) products.

Copyright(C) 2021 Yahoo Japan Corporation.
