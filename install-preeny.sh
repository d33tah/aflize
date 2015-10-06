#!/bin/bash

source ~/.bashrc

set -e

apt-get update
apt-get install libini-config-dev -y

wget "https://github.com/zardus/preeny/archive/master.tar.gz" -O- | tar zxvf -
cd preeny-master/src/
make
cp *.so /lib/x86_64-linux-gnu/
