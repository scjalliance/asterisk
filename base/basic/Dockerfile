# This debian-based docker image includes the minimal set of packages
# necessary to run asterisk, but not asterisk itself. It serves as a
# base image for both the builder and the release, and ensure that
# they include the same packages.

# Build settings
ARG DEBIAN_VERSION=9

FROM debian:${DEBIAN_VERSION}

LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="This debian-based docker image includes the minimal set of packages \
necessary to run asterisk, but not asterisk itself. It serves as a base image for both \
the builder and the release, and ensure that they include the same packages."

# TODO: Decide whether this should be here or stay only in the
#       release image. Determine whether the presence of this
#       user has any effect on the build process.
#RUN useradd --system asterisk

# Packages for minimal operation of asterisk
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            libjansson-dev \
            libxml2-dev \
            libsqlite3-dev \
            libssl-dev \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*
