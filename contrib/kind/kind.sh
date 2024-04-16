#!/usr/bin/env bash

set -euo pipefail

default_controlplanes=1
default_workers=1
default_cluster_name="isg_kind"
default_image="kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245"
default_kubeproxy_mode="iptables"
default_ipfamily="dual"
default_pod_subnet=""
default_service_subnet=""

SED="${SED:-sed}"

# 控制平面数量
controlplanes="${1:-${CONTROLPLANES:=${default_controlplanes}}}"
# worker节点数量
workers="${2:-${WORKERS:=${default_workers}}}"
# kind集群名
cluster_name="${3:-${CLUSTER_NAME:=${default_cluster_name}}}"
# kind使用的镜像版本，会控制k8s版本
image="${4:-${IMAGE:=${default_image}}}"
kubeproxy_mode="${5:-${KUBEPROXY_MODE:=${default_kubeproxy_mode}}}"
ipfamily="${6:-${IPFAMILY:=${default_ipfamily}}}"
pod_subnet="${PODSUBNET:=${default_pod_subnet}}"
service_subnet="${SERVICESUBNET:=${default_service_subnet}}"

PROG=${0}

usage(){
    echo "Usage: ${PROG} [control-plane node count] \
    [worker node count] \
    [cluster-name] \
    [node image] \
    [kube-proxy mode] \
    [ip-family]"
}

have_kind() {
    [[ -n "$(command -v kind)" ]]
}

if ! have_kind; then
    echo "Please install kind first:"
    echo "  https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

have_kubectl() {
    [[ -n "$(command -v kubectl)" ]]
}

if ! have_kubectl; then
    echo "Please install kubectl first:"
    echo "  https://kubernetes.io/docs/tasks/tools/#kubectl"
    exit 1
fi

have_yq() {
    [[ -n "$(command -v yq)" ]]
}

if ! have_yq; then
    echo "Please install kubectl yq:"
    echo "sudo add-apt-repository ppa:rmescandon/yq"
    echo "sudo apt update"
    echo "sudo apt install yq -y"
    exit 1
fi

if [ ${#} -gt 6 ]; then
  usage
  exit 1
fi

if [[ "${controlplanes}" == "-h" || "${controlplanes}" == "--help" ]]; then
  usage
  exit 0
fi

kind_cmd="kind create cluster \
--config kind.yaml \
--name ${cluster_name}"

