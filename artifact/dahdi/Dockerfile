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
ARG DAHDI_VERSION=2.11.1
ARG KERNEL_VERSION=4.9.0-4
ARG KERNEL_ARCH=amd64
ARG DEBIAN_VERSION=9
#ARG RELEASE_TYPE=basic

# ---------
# Stage 1: Retrieve and build dahdi
# --------

#FROM scjalliance/asterisk:base-debian${DEBIAN_VERSION}-${RELEASE_TYPE} as builder
FROM debian:${DEBIAN_VERSION} as builder

# Install packages for retrieval
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

# Import settings
ARG KERNEL_VERSION
ARG KERNEL_ARCH

# Install packages for compilation
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            build-essential \
            linux-headers-${KERNEL_VERSION}-${KERNEL_ARCH} \
            file \
            kmod \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

# Import settings
ARG DAHDI_VERSION

# Create the source directory
WORKDIR /usr/src/dahdi

# Retrieve the source
RUN wget -qO- https://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-${DAHDI_VERSION}+${DAHDI_VERSION}.tar.gz | tar --strip-components 1 -xz

# Indicate which kernel version to build against
ENV KVERS=${KERNEL_VERSION}-${KERNEL_ARCH}

# Compile
RUN make -j"$(nproc)" all

# Create the target directory
WORKDIR /target

# Install dahdi into the target directory
WORKDIR /usr/src/dahdi
RUN make install DESTDIR=/target

# TEMPORARY: REMOVE ME
RUN ls -halR /target
#RUN du -sch /target/*
#RUN du -sch /target/usr/*
#RUN du -sch /target/usr/*/*
#RUN du -sch /target/usr/lib/asterisk/*
#RUN du -sch /target/usr/lib/asterisk/*/*

# --------
# Stage 2: Artifact
# --------

FROM scratch

# Import settings
ARG DAHDI_VERSION
ARG KERNEL_VERSION
ARG KERNEL_ARCH
ARG DEBIAN_VERSION

# Specify labels
LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="This image holds the build artifacts for dahdi ${DAHDI_VERSION}. It is not intended for direct use." \
      dahdi.version="${DAHDI_VERSION}" \
      kernel.version="${KERNEL_VERSION}" \
      kernel.arch="${KERNEL_ARCH}" \
      debian.version="${DEBIAN_VERSION}"

# Copy the output from the build stage
COPY --from=builder /target /target
