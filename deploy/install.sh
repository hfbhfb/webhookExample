#!/bin/bash

ns='webhook-example'
kubectl_ns='--namespace webhook-example'
#kube_config='--kubeconfig config'


# 清空标记
#kubectl label ns ${ns} webhook-example- ${kube_config}


sed -e "s/\${namespace}/${ns}/g" rbac.yaml > current_rbac.yaml
kubectl apply -f current_rbac.yaml  ${kubectl_ns} ${kube_config}


export myip=`echo $debug_url|awk -F'/' '{print $3}'|awk -F':' '{print $1}'`
echo $myip

export myip=$myip && ./webhook-create-signed-cert.sh  ${kubectl_ns} ${kube_config}


kubectl delete -f service.yaml  ${kubectl_ns} 
kubectl apply -f service.yaml  ${kubectl_ns} 

kubectl delete -f webhookExample.yaml  ${kubectl_ns} 
kubectl apply -f webhookExample.yaml  ${kubectl_ns} 


#echo "1111119999999"
kubectl delete -f current_mutatingwebhook.yaml  ${kubectl_ns} 

if [ "$debug_url" == "" ]; then
  cat ./mutatingwebhook.yaml | ./webhook-patch-ca-bundle.sh > current_mutatingwebhook.yaml ${kube_config} && kubectl apply -f current_mutatingwebhook.yaml ${kubectl_ns}
else
  debug_urlbak=$debug_url
  debug_url=$debug_url/mutate/
  export debug_url
  cat ./mutatingwebhook-debug.yaml | ./webhook-patch-ca-bundle.sh > current_mutatingwebhook.yaml ${kube_config} && kubectl apply -f current_mutatingwebhook.yaml ${kubectl_ns}
  debug_url=$debug_urlbak
fi


# 用makefile在另外的命令空间
#kubectl label ns ${ns} webhook-example=enabled ${kube_config}

if [ "$debug_url" == "" ]; then
  cat ./validatingwebhook.yaml | ./webhook-patch-ca-bundle.sh > current_validatingwebhook.yaml ${kube_config} && kubectl apply -f current_validatingwebhook.yaml ${kubectl_ns}
else
  debug_urlbak=$debug_url
  debug_url=$debug_url/validate/
  export debug_url
  cat ./validatingwebhook-debug.yaml | ./webhook-patch-ca-bundle.sh > current_validatingwebhook.yaml ${kube_config} && kubectl apply -f current_validatingwebhook.yaml ${kubectl_ns}
fi



