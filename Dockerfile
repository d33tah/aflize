# you can try replacing "sid" with sid.
FROM debian:sid
RUN echo 'deb-src http://httpredir.debian.org/debian sid main' >> /etc/apt/sources.list

# If you'd like to specify a list of packages to be built, uncomment the
# following line by removing the # symbol at its beginning:
# ADD ./packages.list /root/

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends
RUN apt-get update && apt-get install build-essential gcc g++ wget tar gzip make ca-certificates vim -y
RUN wget 'http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz' -O- | tar zxvf - && cd afl-* && make PREFIX=/usr install

# Make sure afl-gcc will be run. This forces us to set AFL_CC and AFL_CXX or
# otherwise afl-gcc will be trying to call itself by calling gcc.
ADD ./afl-sh-profile /etc/profile.d/afl-sh-profile
RUN ln -s /etc/profile.d/afl-sh-profile /etc/profile.d/afl-sh-profile.sh

# It looks like /etc/profile.d isn't read for some reason, but .bashrc is.
# Let's include /etc/profile.d/afl-sh-profile from there.
RUN echo '. /etc/profile.d/afl-sh-profile' >> /root/.bashrc && chmod +x /root/.bashrc

RUN chmod +x /etc/profile.d/afl-sh-profile
ADD ./setup-afl_cc /usr/bin/setup-afl_cc
RUN setup-afl_cc

ADD ./afl-fuzz-parallel /usr/bin/

ADD ./install-preeny.sh /tmp/
RUN /tmp/install-preeny.sh

RUN mkdir ~/pkg ~/pkgs ~/logs

# This isn't really necessary, but it'd be a real convenience for me.
RUN apt-get update && apt-get install apt-file -y && apt-file update

# install "exploitable" GDB script
RUN apt-get update && apt-get install gdb python -y
RUN wget -O- 'https://github.com/jfoote/exploitable/archive/master.tar.gz' | tar zxvf - && cd exploitable-master && python setup.py install

RUN mkdir ~/fuzz-results ~/pkgs-coverage
RUN apt-get install lcov -y
ADD ./testcases /root/testcases
ADD ./fuzz-pkg-with-coverage.sh /root/
ADD ./aflize /usr/bin/aflize

# Add some of the settings I find it hard to live without.
RUN echo "alias ls='ls --color=auto'" >> /root/.bashrc
RUN echo "syntax on" >> /root/.vimrc
