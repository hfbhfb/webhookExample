
IMG ?= swr.cn-north-4.myhuaweicloud.com/hfbbg4/k8s-webhook-helloworld:v1
DEBUG_LOCAL ?= https://192.168.125.37:6444/mutate/

aaa:
	- export debug_url=$(DEBUG_LOCAL); printenv

build-bin:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/k8s-webhook-helloworld main.go


build-docker: build-bin
	DOCKER_BUILDKIT=0 docker build  -t ${IMG} .

deploy-k8s: build-docker
	- kubectl create ns webhook-example
	- export debug_url=; cd deploy && pwd &&bash install.sh

# w1 命名空间
cleanns:
	- kubectl delete ns w1
	- kubectl delete ns webhook-example 
	- kubectl create ns w1
	- kubectl create ns webhook-example 

# sleep几秒钟确保webhook运行起来了
test-all: cleanns deploy-k8s run-test
	- echo "test-all"

run-no: 
	- kubectl create ns w2
	- kubectl delete deploy my-dep -n w2
	- kubectl create deployment my-dep --image=nginx --replicas=1 -n w2

run-test: 
	- kubectl create ns w1
	- kubectl label ns w1 webhook-example=enabled
	- sleep 3
	- kubectl delete deploy my-dep -n w1
	- kubectl create deployment my-dep --image=nginx --replicas=1 -n w1

reload-test: 
	- kubectl delete deploy my-dep -n w1
	- kubectl create deployment my-dep --image=nginx --replicas=1 -n w1




#   开发调试如下配置

deploy-k8s-calllocal: build-docker
	- kubectl create ns webhook-example
	- export debug_url=$(DEBUG_LOCAL); cd deploy && pwd &&bash install.sh

debug-local: cleanns deploy-k8s-calllocal run-test
	- echo "debug-local"


