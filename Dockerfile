# you can try replacing "sid" with sid.
FROM debian:sid
RUN echo 'deb-src http://httpredir.debian.org/debian sid main' >> /etc/apt/sources.list

ADD ./aflize /usr/bin/aflize

# If you'd like to specify a list of packages to be built, uncomment the
# following line by removing the # symbol at its beginning:
# ADD ./packages.list /root/

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends
RUN apt-get update && apt-get install build-essential gcc g++ wget tar gzip make -y
RUN wget 'http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz' -O- | tar zxvf - && cd afl-* && make PREFIX=/usr install

# Make sure afl-gcc will be run. This forces us to set AFL_CC and AFL_CXX or
# otherwise afl-gcc will be trying to call itself by calling gcc.
ADD ./afl-sh-profile /etc/profile.d/afl-sh-profile
ADD ./setup-afl_cc /usr/bin/setup-afl_cc
RUN setup-afl_cc

RUN mkdir ~/pkg ~/pkgs ~/logs
CMD [ "aflize" ]
