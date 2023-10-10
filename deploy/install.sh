#!/bin/bash

ns='webhook-example'
kubectl_ns='--namespace webhook-example'
#kube_config='--kubeconfig config'


# 清空标记
#kubectl label ns ${ns} webhook-example- ${kube_config}



sed -e "s/\${namespace}/${ns}/g" rbac.yaml > current_rbac.yaml
kubectl apply -f current_rbac.yaml  ${kubectl_ns} ${kube_config}

./webhook-create-signed-cert.sh  ${kubectl_ns} ${kube_config}


kubectl delete -f service.yaml  ${kubectl_ns} 
kubectl apply -f service.yaml  ${kubectl_ns} 

kubectl delete -f webhookExample.yaml  ${kubectl_ns} 
kubectl apply -f webhookExample.yaml  ${kubectl_ns} 

cat ./mutatingwebhook.yaml | ./webhook-patch-ca-bundle.sh > current_mutatingwebhook.yaml ${kube_config} && kubectl apply -f current_mutatingwebhook.yaml ${kubectl_ns}


# 用makefile在另外的命令空间
#kubectl label ns ${ns} webhook-example=enabled ${kube_config}

