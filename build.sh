ASTERISK_BRANCH=$1
ASTERISK_VERSION=$2
DEBIAN_VERSION="9"
DAHDI_VERSION="2.11.1"
DPMA_VERSION="3.4.3"

if [ -z "$ASTERISK_BRANCH" ] || [ -z "$ASTERISK_VERSION" ]; then
	echo "usage: $0 asterisk_branch asterisk_version"
	echo "example: $0 15 15.1.5"
	exit
fi

DPMA_ASTERISK_BRANCH="${ASTERISK_VERSION%%.*}.0"

docker pull debian
docker pull debian:${DEBIAN_VERSION}

set -o xtrace

docker build -t scjalliance/asterisk:artifact-dahdi${DAHDI_VERSION}-debian${DEBIAN_VERSION} \
	--build-arg DAHDI_VERSION=${DAHDI_VERSION} \
	--build-arg DEBIAN_VERSION=${DEBIAN_VERSION} \
	artifact/dahdi

docker build -t scjalliance/asterisk:artifact-dpma${DPMA_VERSION}-ast${DPMA_ASTERISK_BRANCH} \
	--build-arg DPMA_VERSION=${DPMA_VERSION} \
	--build-arg DPMA_ASTERISK_BRANCH=${DPMA_ASTERISK_BRANCH} \
	artifact/dpma

for RELEASE_TYPE in basic full; do
	#echo "Building $RELEASE_TYPE asterisk docker image chain for asterisk branch $ASTERISK_BRANCH with asterisk version $ASTERISK_VERSION..."

	docker build -t scjalliance/asterisk:base-debian${DEBIAN_VERSION}-${RELEASE_TYPE} \
		--build-arg DEBIAN_VERSION=${DEBIAN_VERSION} \
                base/${RELEASE_TYPE}

	docker build -t scjalliance/asterisk:artifact-ast${ASTERISK_VERSION}-debian${DEBIAN_VERSION}-${RELEASE_TYPE} \
		--build-arg ASTERISK_VERSION=${ASTERISK_VERSION} \
		--build-arg DEBIAN_VERSION=${DEBIAN_VERSION} \
		--build-arg RELEASE_TYPE=${RELEASE_TYPE} \
		artifact/asterisk

	docker build \
		-t scjalliance/asterisk:${ASTERISK_VERSION}-debian${DEBIAN_VERSION}-${RELEASE_TYPE} \
		-t scjalliance/asterisk:${ASTERISK_BRANCH}-debian${DEBIAN_VERSION}-${RELEASE_TYPE} \
		--build-arg DEBIAN_VERSION=${DEBIAN_VERSION} \
		--build-arg ASTERISK_VERSION=${ASTERISK_VERSION} \
		--build-arg RELEASE_TYPE=${RELEASE_TYPE} \
		release/standard

	docker build \
		-t scjalliance/asterisk:${ASTERISK_VERSION}-debian${DEBIAN_VERSION}-${RELEASE_TYPE}-dpma \
		-t scjalliance/asterisk:${ASTERISK_BRANCH}-debian${DEBIAN_VERSION}-${RELEASE_TYPE}-dpma \
		--build-arg DEBIAN_VERSION=${DEBIAN_VERSION} \
		--build-arg ASTERISK_VERSION=${ASTERISK_VERSION} \
		--build-arg RELEASE_TYPE=${RELEASE_TYPE} \
		--build-arg DPMA_VERSION=${DPMA_VERSION} \
		--build-arg DPMA_ASTERISK_BRANCH=${DPMA_ASTERISK_BRANCH} \
		release/dpma
done
