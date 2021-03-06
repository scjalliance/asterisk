# Build settings
ARG ASTERISK_VERSION=15.1.4
ARG DEBIAN_VERSION=9
ARG RELEASE_TYPE=basic
ARG DPMA_VERSION=3.4.3
ARG DPMA_ASTERISK_BRANCH=15.0
ARG DPMA_ARCH=x86_64

# --------
# Stage 1: Import the dpma artifact
# --------

FROM scjalliance/asterisk:artifact-dpma${DPMA_VERSION}-ast${DPMA_ASTERISK_BRANCH} as dpma

# --------
# Stage 2: Build the release image
# --------

# Start with the standard release image of the requested release type
FROM scjalliance/asterisk:${ASTERISK_VERSION}-debian${DEBIAN_VERSION}-${RELEASE_TYPE}

# Install packages for operation of dpma
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            libavahi-client3 \
            avahi-daemon \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

# Include the dpma artifacts
COPY --from=dpma /target .
COPY --from=dpma /sample /sample

# Ensure proper file ownership
RUN chown -R asterisk:asterisk /var/*/asterisk

# Import settings
ARG ASTERISK_VERSION
ARG DEBIAN_VERSION
ARG RELEASE_TYPE
ARG DPMA_VERSION
ARG DPMA_ASTERISK_BRANCH
ARG DPMA_ARCH

# Specify labels
LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="Asterisk ${ASTERISK_VERSION} running on debian ${DEBIAN_VERSION} with a ${RELEASE_TYPE} feature set. Includes dpma ${DPMA_VERSION}." \
      asterisk.version="${ASTERISK_VERSION}" \
      debian.version="${DEBIAN_VERSION}" \
      dpma.asterisk.branch="${DPMA_ASTERISK_BRANCH}" \
      dpma.version="${DPMA_VERSION}" \
      dpma.arch="${DPMA_ARCH}"

# Verify that asterisk can report its version number
RUN asterisk -V

# Map the license key storage area
VOLUME /var/lib/asterisk/licenses

# Copy sample data if we we don't have any configuration
ENV PRESTART="/bin/sh -c 'test $(ls -A /etc/asterisk | wc -l) -gt 0 || (cp -R /sample/basic-pbx/* /sample/dpma/* / && echo \"Initialized asterisk configuration with basic-pbx and dpma sample data\")'"

# Run the program
CMD ["/usr/local/bin/cmdhook", "/usr/sbin/asterisk", "-f", "-U", "asterisk", "-G", "asterisk", "-vvvg"]
