#!/bin/bash

# Prepares a directory with Debian packages compiled in a form ready for
# fuzzing with american fuzzy lop. See README.md for more details.
#
# AUTHOR: Jacek "d33tah" Wielemborek, licensed under WTFPL.

# If there's no packages.list file, assume we build all currently installed
# packages. This way we can easily get the base system ready.

[ -f ~/packages.list ] || dpkg -l | tail -n +6 | awk '{ print $2 }' > ~/packages.list

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
