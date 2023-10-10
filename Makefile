
IMG ?= swr.cn-north-4.myhuaweicloud.com/hfbbg4/k8s-webhook-helloworld:v1


build-bin:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/k8s-webhook-helloworld main.go


build-docker: build-bin
	DOCKER_BUILDKIT=0 docker build  -t ${IMG} .

deploy-k8s: build-docker
	- kubectl create ns webhook-example
	-cd deploy && pwd &&bash install.sh

# w1 命名空间
clean:
	- kubectl delete ns w1
	- kubectl delete ns webhook-example 

# sleep几秒钟确保webhook运行起来了
test-all: clean deploy-k8s
	- kubectl create ns w1
	- kubectl label ns w1 webhook-example=enabled
	- sleep 3
	- kubectl create deployment my-dep --image=nginx --replicas=1 -n w1
#kubectl create deployment k8s-webhook-helloworld --image=${IMG} --replicas=1 --dry-run -oyaml



