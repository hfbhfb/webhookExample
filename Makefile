
IMG ?= swr.cn-north-4.myhuaweicloud.com/hfbbg4/k8s-webhook-helloworld:v1
#DEBUG_LOCAL ?= https://192.168.125.37:6444/mutate # 增加validate的内容，把这个删除了
DEBUG_LOCAL ?= https://192.168.125.37:6444

# 先运行下这个
createns:
	- echo -e "\033[31m DEBUG_LOCAL 有没有修改，当前值为： ${DEBUG_LOCAL} \033[0m" 
	- kubectl create ns w1
	- kubectl create ns w2
	- kubectl create ns webhook-example

# 
runlocal: 
	- bash precheck.sh #安装依赖项
	go build
	- ./webhookExample --tlsCertFile=./pki/cert.pem --tlsKeyFile=./pki/key.pem --automatic-authentication=false --kubeconfig=~/.kube/config --log-v=5

build-bin:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/k8s-webhook-helloworld main.go


build-docker: build-bin
	DOCKER_BUILDKIT=0 docker build  -t ${IMG} .

just-install:
	- export debug_url=; cd deploy && pwd &&bash install.sh

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
just-install-debug:
	export debug_url=$(DEBUG_LOCAL); cd deploy && pwd &&bash install.sh

deploy-k8s-calllocal: build-docker
	- kubectl create ns webhook-example
	- export debug_url=$(DEBUG_LOCAL); cd deploy && pwd &&bash install.sh

debug-local: cleanns deploy-k8s-calllocal run-test
	- echo "debug-local"


