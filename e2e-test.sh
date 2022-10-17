#!/bin/bash

export K8S_VERSION="${K8S_VERSION:-v1.23.12}"
export CLUSTER_NAME=${CLUSTER_NAME:-chart-testing}

# function wait_for_daemonset() {
#     ns="$1"
#     name="$2"

#     retries=10
#     while [[ $retries -ge 0 ]];do
#         sleep 3
#         ready=$(kubectl -n $ns get daemonset $name -o jsonpath="{.status.numberReady}")
#         required=$(kubectl -n $ns get daemonset $name -o jsonpath="{.status.desiredNumberScheduled}")
#         echo "$kind $ns/$name: rdy $ready req $required"

#         if [[ $ready -eq $required ]];then
#             echo "Succeeded"
#             break
#         fi
#         ((retries--))
#     done
# }

get_tremor_pod() {
    kubectl get pod -n $1 -l app.kubernetes.io/name=tremor -o jsonpath='{ .items[0].metadata.name }'
}

wait_for_pod() {
    pod=$(get_tremor_pod $1)
    kubectl wait pods -n $1 $pod --for condition=Ready --timeout=90s
}

collect_info() {
    pod=$(get_tremor_pod $1)

    kubectl describe pod -n $1 $pod
    kubectl logs -n $1 $pod
}

create_kind_cluster() {
    if kubectl cluster-info >/dev/null 2>&1; then
        return 0
    fi

    kind create cluster --name "$CLUSTER_NAME" --image "kindest/node:$K8S_VERSION" --wait 60s

    kubectl cluster-info || kubectl cluster-info dump
    echo

    kubectl get nodes
    echo

    echo 'Cluster ready!'
    echo
}

cleanup() {
    kind delete cluster --name "$CLUSTER_NAME"
    echo 'Done!'
}

generate_ns_name() {
    awk -F '-' '{print $5}'< /proc/sys/kernel/random/uuid
}

test_daemonset() {
    namespace=e2e-$(generate_ns_name)

    helm upgrade -i --create-namespace -n "$namespace" tremor ./charts/tremor

    wait_for_pod $namespace
    collect_info $namespace
}

test_deployment() {
    namespace=`generate_ns_name`

    helm upgrade -i --create-namespace -n "$namespace" tremor ./charts/tremor --set=kind=Deployment

    wait_for_pod $namespace
    collect_info $namespace
}

create_kind_cluster

test_daemonset
test_deployment