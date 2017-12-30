# Build settings
ARG ASTERISK_VERSION=15.1.4
ARG DEBIAN_VERSION=9
ARG RELEASE_TYPE=basic
ARG DPMA_ASTERISK_VERSION
ARG DPMA_VERSION
ARG DPMA_ARCH

# --------
# Stage 1: Import the build artifact
# --------

FROM scjalliance/asterisk:artifact-ast${ASTERISK_VERSION}-debian${DEBIAN_VERSION}-${RELEASE_TYPE} as astbuild

# --------
# Stage 2: Build the release image
# --------

# Start with the base image of the requested release type
FROM scjalliance/asterisk:base-debian${DEBIAN_VERSION}-${RELEASE_TYPE}

# Add an asterisk user for the service
RUN useradd --system asterisk

# Include the build artifacts for the requested version of asterisk
COPY --from=astbuild /target .
COPY --from=astbuild /sample /sample
RUN chown -R asterisk:asterisk /var/*/asterisk
RUN chmod -R 750 /var/spool/asterisk

# Import settings
ARG ASTERISK_VERSION
ARG DPMA_VERSION
ARG DPMA_ARCH

# Specify labels
LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="Asterisk ${ASTERISK_VERSION} running on debian ${DEBIAN_VERSION} with a ${RELEASE_TYPE} feature set." \
      asterisk.version="${ASTERISK_VERSION}" \
      debian.version="${DEBIAN_VERSION}"

# Verify linkages
RUN ldd /usr/sbin/asterisk

# Verify executability
RUN asterisk -V

# Map the asterisk configuration storage area
VOLUME /etc/asterisk

# Run the program
CMD ["/usr/sbin/asterisk", "-f", "-U", "asterisk", "-G", "asterisk", "-vvvg"]
