FROM alpine:latest

ADD bin/k8s-webhook-helloworld /webhook-example
ENTRYPOINT ["./webhook-example"]