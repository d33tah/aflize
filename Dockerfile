FROM debian:sid
ADD ./aflize /usr/bin/aflize

# If you'd like to specify a list of packages to be built, uncomment the
# following line by removing the # symbol at its beginning:

# ADD ./packages.list /root/

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends
RUN echo 'deb-src http://httpredir.debian.org/debian sid main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install afl

# Make sure afl-gcc will be run. This forces us to set AFL_CC and AFL_CXX or
# otherwise afl-gcc will be trying to call itself by calling gcc.
RUN rm /usr/bin/cc && cp /usr/bin/afl-gcc /usr/bin/cc
RUN rm /usr/bin/gcc && cp /usr/bin/afl-gcc /usr/bin/gcc
RUN rm /usr/bin/g++ && cp /usr/bin/afl-g++ /usr/bin/g++
RUN rm /usr/bin/x86_64-linux-gnu-gcc && cp /usr/bin/afl-gcc /usr/bin/x86_64-linux-gnu-gcc
RUN rm /usr/bin/x86_64-linux-gnu-g++ && cp /usr/bin/afl-g++ /usr/bin/x86_64-linux-gnu-g++

RUN mkdir ~/pkg ~/pkgs
CMD [ "aflsize" ]
