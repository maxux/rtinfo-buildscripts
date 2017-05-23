#!/bin/bash
set -e

mkdir -p /tmp/target/bin/
mkdir -p /tmp/archives/

apt-get update
apt-get install -y curl git libjansson-dev build-essential

# golang
curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz > /tmp/go1.8.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.8.linux-amd64.tar.gz
mkdir /gopath

export GOPATH=/gopath
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# rtinfo
pushd /opt
git clone https://github.com/maxux/librtinfo
git clone https://github.com/maxux/rtinfo

pushd librtinfo/linux
make
make install
popd

pushd rtinfo/rtinfod
make STATIC=yes
cp rtinfod /tmp/target/bin/
popd

pushd rtinfo/rtinfo-client
make STATIC=yes
cp rtinfo-client /tmp/target/bin/
popd

popd

# rtinfo-dashboard
go get -v -u github.com/jteeuwen/go-bindata/...
go get -d -v -u github.com/maxux/rtinfo-dashboard/wserver-go/...

pushd $GOPATH/src/github.com/maxux/rtinfo-dashboard/wserver-go

go generate
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' .
cp wserver-go /tmp/target/bin/rtinfo-dashboard

popd

cd /tmp/target
tar -czf /tmp/archives/rtinfo-static.tar.gz *
