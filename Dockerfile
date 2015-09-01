FROM debian:sid
ADD ./do.sh /root/
RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/no-suggests
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/no-recommends
RUN echo 'deb-src http://httpredir.debian.org/debian sid main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install afl
RUN mkdir ~/pkg ~/pkgs
CMD [ "/root/do.sh" ]
