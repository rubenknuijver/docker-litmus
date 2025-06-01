FROM alpine:edge
LABEL maintainer="Ruben Knuijver <r.knuijver@primecoder.com>"

ARG VERSION=0.16
ARG REPO=https://notroj.github.io/litmus/litmus-${VERSION}.tar.gz


# Install base packages from the alpine installation
RUN apk update && \
  apk upgrade && \
  apk add --no-cache \
    ca-certificates \
    bash \
    vim \
    curl \
    wget \
    bzip2 \
    unzip \
    ncurses \
    tar \
    shadow \
    su-exec \
    git \
    libxml2 \
    openssl && \
  rm -rf /var/cache/apk/*

# Download and build litmus
# Consolidate build dependencies install, build, and cleanup into one layer
# Use --virtual for build dependencies so they can be easily removed.
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    openssl-dev \
    openssl \
    libxml2-dev \
    # expat-dev # Add if libxml2-dev is not enough, but usually it is
    # wget and tar are needed for this step, already installed above but no harm in --virtual
    wget \
    tar && \
  wget -q -O - ${REPO} | tar xzvf - -C /tmp && \
  cd /tmp/litmus-0.16 && \
  # The configure script will look for xml2-config which libxml2-dev provides
  ./configure --with-ssl && \
  make && \
  # The original ENTRYPOINT is /usr/local/bin/litmus, which is default PREFIX for make install
  # If you need it in /usr, then use PREFIX=/usr
  make install && \
  cd && \
  apk del .build-deps && \
  rm -rf /var/cache/apk/* /tmp/*

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/litmus"]
