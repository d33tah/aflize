#!/bin/sh

. /etc/profile.d/afl-sh-profile

echo 'NOTE: this script is experimental! Right now the "right" way is to use aflize'
echo
sleep 2

aflize $1
dpkg -i ~/pkgs/*.deb
apt-get -f install -y

ASAN_OPTIONS=abort_on_error=1,symbolize=0 timeout \
    15s \
    afl-fuzz \
        -i ~/testcases \
        -o ~/fuzz-results/$1 \
        $1 @@

export CC=`echo $AFL_CC`
export CXX=`echo $AFL_CXX`
cd ~/pkg
rm -rf *
apt-get source $1
cd *
export CFLAGS="-fprofile-arcs -ftest-coverage"
export CXXFLAGS="-fprofile-arcs -ftest-coverage"
export LDFLAGS="-lgcov"
dpkg-buildpackage -uc -us -Jauto
mv ~/pkg/*.deb ~/pkgs-coverage
dpkg -i ~/pkgs-coverage/*.deb

mkdir ~/fuzz-results/$1/coverage
for file in ~/fuzz-results/$1/queue/*; do
    #find ~/pkg | egrep '\.gc(da|no)$' | xargs rm
    $1 $file
    COVFILE=~/fuzz-results/$1/coverage/`basename $file`
    lcov -o $COVFILE -c -d /root/pkg -q
    lcov --summary $COVFILE
done
exit 0
