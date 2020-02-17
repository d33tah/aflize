#!/bin/bash

source ~/.bashrc
source /etc/profile.d/afl-sh-profile

set -e

apt-get update
apt-get install libini-config-dev libseccomp-dev -y

wget "https://github.com/zardus/preeny/archive/master.tar.gz" -O- | tar zxvf -
cd preeny-master/src/
make
cp *.so /lib/x86_64-linux-gnu/
