#!/bin/bash

# ./do.sh | perl -pe '$s = `date`; chomp $s; print "$s: "' | stdbuf -o 0 tee /dev/stderr >> log

[ -f ~/packages.list ] || dpkg -l | tail -n +6 | awk '{ print $2 }' > ~/packages.list

echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends

function add_src() {
        echo 'deb-src http://httpredir.debian.org/debian sid main' >> /etc/apt/sources.list
        apt-get update 2>&1
}
grep deb-src /etc/apt/sources.list || add_src

apt-get -y install afl 2>&1

mkdir ~/pkg ~/pkgs

export CC="afl-gcc -fsanitize=address"
export CXX="afl-g++ -fsanitize=address"
export DEB_BUILD_OPTIONS=nocheck

for pkg in `cat ~/packages.list`; do

        if [ -f ~/pkgs/${pkg}_* ]; then
            continue
        fi

        cd ~/pkg
        apt-get build-dep -y $pkg 2>&1
        apt-get source $pkg 2>&1
        cd *
        dpkg-buildpackage -uc -us -Jauto 2>&1 || echo $pkg >> ~/failed
        mv ~/pkg/*.deb ~/pkgs
        rm -rf ~/pkg/.* ~/pkg/*
done
