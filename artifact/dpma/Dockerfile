# Build settings
ARG DPMA_VERSION=3.4.3
ARG DPMA_ASTERISK_BRANCH=15.0
ARG DPMA_ARCH=x86_64

# --------
# Stage 1: Retrieve and extract dpma
# -------

FROM debian as builder

# Install packages for retrieval
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*


# Import settings
ARG DPMA_VERSION
ARG DPMA_ASTERISK_BRANCH
ARG DPMA_ARCH

# Switch to bash for regular expression string replacement
SHELL ["/bin/bash", "-c"]

# Create the sample configuration directory
WORKDIR /sample/dpma/etc/asterisk

# Create the target modules directory
WORKDIR /target/usr/lib/asterisk/modules

# Create the target documentation directory
WORKDIR /target/usr/share/doc/asterisk/dpma

# Retrieve the dpma modules, sample configuration and documentation (modules and sample config will later be moved out of this location)
RUN wget -qO- https://downloads.digium.com/pub/telephony/res_digium_phone/asterisk-${DPMA_ASTERISK_BRANCH}/${DPMA_ARCH/_/-}/res_digium_phone-${DPMA_ASTERISK_BRANCH}_${DPMA_VERSION}-${DPMA_ARCH}.tar.gz | tar --strip-components 1 -xz;

# Move the dpma modules
RUN mv -- *.so /target/usr/lib/asterisk/modules/

# Move and rename the sample configuration files
RUN mv -- *.sample /sample/dpma/etc/asterisk
RUN for file in /sample/dpma/etc/asterisk/*.sample; do mv -- "$file" "${file%%.sample}"; done

# Create the target utilities directory
WORKDIR /target/usr/sbin/

# Retrieve the registration utilities (also rename register to astregister for less ambiguity)
RUN wget -qOasthostid https://downloads.digium.com/pub/register/${DPMA_ARCH/_/-}/asthostid
RUN wget -qOastregister https://downloads.digium.com/pub/register/${DPMA_ARCH/_/-}/register

# Make the utilities executable
RUN chmod 555 asthostid astregister

# Switch back to the basic shell
SHELL ["/bin/sh", "-c"]

# List the contents of the target and sample directories
RUN ls -halR /target
RUN ls -halR /sample

# --------
# Stage 2: Artifact
# --------

FROM scratch

# Import settings
ARG DPMA_ASTERISK_BRANCH
ARG DPMA_VERSION
ARG DPMA_ARCH 

# Specify labels
LABEL maintainer="Joshua Sjoding <joshua.sjoding@scjalliance.com>" \
      description="This image holds artifacts for dpma ${DPMA_VERSION}. It is not intended for direct use." \
      dpma.version="${DPMA_VERSION}" \
      dpma.asterisk.branch="${DPMA_ASTERISK_BRANCH}" \
      dpma.arch="${DPMA_ARCH}"

# Copy the output from the previous stage
COPY --from=builder /target /target
COPY --from=builder /sample /sample
