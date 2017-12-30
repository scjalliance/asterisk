# This image is produced by a two stage build process.
#
# The first stage is responsible for the actual compilation work and is very heavy
# as a result of the build environment. It uses the DESTDIR build argument to
# to place all of the build artifacts into the /target directory. It is derived
# from the common base layer, which ensures that both the build environment and
# release environment share a consistent package set.
#
# The second stage only includes the build artificats without the build environment
# and is very lightweight. It derives from scratch and includes a copy of the
# /target directory.
#
# The resulting image is not runnable, but the contents of its /target directory
# can be copied into a runnable environment, such as the release image.

# Build settings
ARG ASTERISK_VERSION=15.1.5
ARG DEBIAN_VERSION=9
ARG RELEASE_TYPE=basic

# --------
# Stage 1: Retrieve and compile asterisk
# --------

# Start with the base image of the requested release type
FROM scjalliance/asterisk:base-debian${DEBIAN_VERSION}-${RELEASE_TYPE} as builder

# Install packages for retrieval
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

# Install packages for compilation
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            build-essential \
            ncurses-dev \
            uuid-dev \
            libjansson-dev \
            libxml2-dev \
            libsqlite3-dev \
            libssl-dev \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

# Import settings
ARG ASTERISK_VERSION
ARG RELEASE_TYPE

# Create the source directory
WORKDIR /usr/src/asterisk

# Retrieve the source
RUN wget -qO- https://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar --strip-components 1 -xz

# Configure the build
RUN if [ "$RELEASE_TYPE" = "basic" ]; then ./configure; fi
RUN if [ "$RELEASE_TYPE" = "full" ]; then ./configure --with-resample; fi

# Prepare menuselect
RUN make menuselect/menuselect menuselect-tree menuselect.makeopts

# Exclude optimizations specific to our build environment
RUN menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts

# Include improved symbol information to assist with debugging
RUN menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts

# Include optional codecs in full builds
RUN if [ "$RELEASE_TYPE" = "full" ]; then menuselect/menuselect --enable codec_opus menuselect.makeopts; fi

# Compile
RUN make -j"$(nproc)" all

# Create the target directory
WORKDIR /target

# Install asterisk into the target directory
WORKDIR /usr/src/asterisk
RUN make DESTDIR=/target install

# Create the sample directories
WORKDIR /sample/basic-pbx/etc/asterisk
WORKDIR /sample/full/etc/asterisk
WORKDIR /sample/full/var/lib/asterisk/phoneprov

# Install samples into the sample directory
WORKDIR /usr/src/asterisk
RUN make DESTDIR=/sample/basic-pbx basic-pbx
RUN make DESTDIR=/sample/full samples

# TEMPORARY: REMOVE ME
RUN ls -halR /sample
#RUN du -sch /sample/*
#RUN du -sch /target/*
#RUN du -sch /target/usr/*
#RUN du -sch /target/usr/*/*
#RUN du -sch /target/usr/lib/asterisk/*
#RUN du -sch /target/usr/lib/asterisk/*/*

# --------
# Stage 2: Produce a slim artifact that includes the build output without the weight of the build environment
# --------

FROM scratch

# Specify labels
LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="This image holds the build artifacts for asterisk ${ASTERISK_VERSION}. It is not intended for direct use." \
      asterisk.version="${ASTERISK_VERSION}" \
      debian.version="${DEBIAN_VERSION}" \
      build.version="${BUILD_VERSION}"

# Copy the output from the build
COPY --from=builder /target /target
COPY --from=builder /sample /sample
