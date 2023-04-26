#! /bin/sh
# Only the target architectures amd64 and i386 have been tested. The target
# architecture is checked to be one of the official architectures in order to
# guard against typosquatting and name squatting attacks on the Docker Hub.

set -eu
cd "$(dirname "$0")"

archs="(amd64|arm32v6|arm64v8|i386|ppc64le|s390x)"

usage() {
    echo "usage: $(basename "$0") $archs [revision]" > /dev/stderr
}


arch="$1"
revision="${2:-HEAD}"
if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

if [ -z "$arch" ]; then
    echo 'no target architecture' > /dev/stderr
    usage
    exit 1
elif ! echo "$arch" | grep -E -q "$archs"; then
    echo "unknown architecture: \"$arch\"" > /dev/stderr
    usage
    exit 1
fi
echo "target architecture is $arch"

tag=jimsh-static:$revision-$arch
echo "building $tag"

mkdir -p inbox/

docker build \
    --build-arg arch="$arch" \
    --build-arg revision="$revision" \
    --tag "$tag" \
    . \

docker run \
    --rm \
    --tty \
    --volume "$(pwd)/inbox:/inbox" \
    "$tag" \
    sh -c \
    'cd jimtcl \
     && cp jimsh \
           "/inbox/jimsh-$(./jimsh --version)-$(git rev-parse HEAD \
                                                | cut -c 1-10)-$0"' \
    "$arch"
