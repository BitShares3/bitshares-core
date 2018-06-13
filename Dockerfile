FROM phusion/baseimage:0.10.1
MAINTAINER BitShares3 Project

ENV LANG=en_US.UTF-8
RUN \
    apt-get update -y && \
    apt-get install -y \
      g++ \
      autoconf \
      cmake \
      git \
      libbz2-dev \
      libreadline-dev \
      libboost-all-dev \
      libcurl4-openssl-dev \
      libssl-dev \
      libncurses-dev \
      doxygen \
      ca-certificates \
    && \
    apt-get update -y && \
    apt-get install -y fish && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /bitshares3-core
WORKDIR /bitshares3-core

# Compile
RUN \
    ( git submodule sync --recursive || \
      find `pwd`  -type f -name .git | \
	while read f; do \
	  rel="$(echo "${f#$PWD/}" | sed 's=[^/]*/=../=g')"; \
	  sed -i "s=: .*/.git/=: $rel/=" "$f"; \
	done && \
      git submodule sync --recursive ) && \
    git submodule update --init --recursive && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        . && \
    make witness_node cli_wallet && \
    make install && \
    #
    # Obtain version
    mkdir /etc/bitshares && \
    git rev-parse --short HEAD > /etc/bitshares/version && \
    cd / && \
    rm -rf /bitshares3-core

# Home directory $HOME
WORKDIR /
RUN useradd -s /bin/bash -m -d /var/lib/bitshares3 bitshares3
ENV HOME /var/lib/bitshares3
RUN chown bitshares3:bitshares3 -R /var/lib/bitshares3

# Volume
VOLUME ["/var/lib/bitshares3", "/etc/bitshares3"]

# rpc service:
EXPOSE 8090
# p2p service:
EXPOSE 2001

# default exec/config files
ADD docker/default_config.ini /etc/bitshares3/config.ini
ADD docker/bitshares3entry.sh /usr/local/bin/bitshares3entry.sh
RUN chmod a+x /usr/local/bin/bitshares3entry.sh

# default execute entry
CMD /usr/local/bin/bitshares3entry.sh
