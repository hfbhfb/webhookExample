

# set -e

yum install -y jq
yum install -y make


# golang编译器安装
go version
if [ "$?" -eq 0 ]; then
echo "already exist go"
else
GOZIP=go1.18.1.linux-amd64.tar.gz
wget https://dl.google.com/go/$GOZIP
GOINSTALLDIR=$HOME/gov18
GOROOT=$GOINSTALLDIR/go
GOPATH=$GOINSTALLDIR/gopath
mkdir -p $GOROOT $GOPATH
GOPROXY=https://goproxy.cn,direct
PATH=$GOROOT/bin:$GOPATH/bin:$PATH
export GOINSTALLDIR GOROOT GOPATH GOZIP GOPROXY PATH
rm -rf $GOROOT && mkdir -p $GOINSTALLDIR && tar -C $GOINSTALLDIR -xzf $GOZIP
# 测试
which go
go version
#rm $GOZIP
mkdir -p $GOPATH/src $GOPATH/bin && chmod -R 744 $GOPATH

# 环境变量注入
echo "export GOROOT=$GOINSTALLDIR/go" >> $HOME/.bashrc 
echo "export GOPATH=$GOINSTALLDIR/gopath" >> $HOME/.bashrc 
echo "export PATH=\$GOROOT/bin:$\GOPATH/bin:\$PATH" >> $HOME/.bashrc 
echo "export GOPROXY=https://goproxy.cn,direct" >> $HOME/.bashrc 


fi



# 
# ./webhookExample --tlsCertFile=./pki/cert.pem --tlsKeyFile=./pki/key.pem --automatic-authentication=false --kubeconfig=~/.kube/config --log-v=5


