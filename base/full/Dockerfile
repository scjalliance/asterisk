# This debian-based docker image includes the minimal set of packages
# necessary to run asterisk, but not asterisk itself. It serves as a
# base image for both the builder and the release, and ensure that
# they include the same packages.

# Build Settings
ARG DEBIAN_VERSION=9

FROM scjalliance/asterisk:base-debian${DEBIAN_VERSION}-basic

LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="This debian-based docker image includes the minimal set of packages \
necessary to run asterisk, but not asterisk itself. It serves as a base image for both \
the builder and the release, and ensure that they include the same packages."

# Packages for full featured operation of asterisk
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            autoconf \
            binutils-dev \
            portaudio19-dev \
            unixodbc-dev \
            uuid \
            xmlstarlet \
            libxslt1-dev \
            libedit-dev \
            libgsm1-dev \
            libpopt-dev \
            libresample1-dev \
            libspandsp-dev \
            libsrtp0-dev \
            libssl-dev \
            libopus-dev \
            libogg-dev \
            libvorbis-dev \
            libspeex-dev \
            libspeexdsp-dev \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*
