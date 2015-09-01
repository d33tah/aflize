#!/bin/bash

##############################################################################
# Prepares a directory with Debian packages compiled in a form ready for
# fuzzing with american fuzzy lop.
#
# Tested with debian:sid docker image - just run a shell session there,
# cat > ~/do.sh, copy the file and press CTR+D, then chmod +x ~/do.sh and
# call ~/do.sh. To get a date-stamped build log, run:
#
# ~/do.sh | perl -pe '$s = `date`; chomp $s; print "$s: "' | stdbuf -o 0 tee /dev/stderr >> log
#
# The built packages will be in ~/pkgs directory. List of packages is read
# from the ~/packages.list file in one-name-per-line form with no additional
# information allowed. The list of packages that failed to build are in
# ~/failed file.
#
# AUTHOR: Jacek "d33tah" Wielemborek, licensed under WTFPL.
##############################################################################

# If there's no packages.list file, assume we build all currently installed
# packages. This way we can easily get the base system ready.

[ -f ~/packages.list ] || dpkg -l | tail -n +6 | awk '{ print $2 }' > ~/packages.list

# Try to speed up package downloading by not fetching suggested and
# recommended ones. Actually, I'm not fully sure if it's a good idea
# not to download them.
echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends

# Make sure we have a deb-src repository source.
function add_src() {
        echo 'deb-src http://httpredir.debian.org/debian sid main' \
            >> /etc/apt/sources.list
        apt-get update 2>&1
}
grep deb-src /etc/apt/sources.list || add_src

apt-get -y install afl 2>&1

mkdir ~/pkg ~/pkgs

export CC="afl-gcc -fsanitize=address"
export CXX="afl-g++ -fsanitize=address"
export DEB_BUILD_OPTIONS=nocheck
export AFL_HARDEN=1

for pkg in `cat ~/packages.list`; do

        # Building some source packages results in more than one .deb file.
        # There's no point building coreutils multiple times just because we
        # need mount, libmount1 and libmount1-dev, for example.
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
