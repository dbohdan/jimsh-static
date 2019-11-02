#! /bin/sh
# Only the target architectures amd64 and i386 have been tested.  The target
# architecture is checked to be one of the official architectures in order to
# guard against typosquatting and name squatting attacks on the Docker Hub.

archs="(amd64|arm32v6|arm64v8|i386|ppc64le|s390x)"

usage() {
    echo "usage: $(basename "$0") $archs [revision]" > /dev/stderr
}


arch="$1"
revision="${2:-HEAD}"
if ! [ -z "$3" ]; then
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


mkdir -p inbox/
docker run \
    --rm \
    --volume "$(pwd)/inbox:/inbox" \
    "$arch/alpine:3.10" \
    sh -c \
    'cd \
     && apk update \
     && apk add gcc git make libc-dev tcl zlib-dev \
     && wget https://sqlite.org/2018/sqlite-autoconf-3240000.tar.gz \
     && tar xvf sqlite-autoconf-3240000.tar.gz \
     && cd sqlite-autoconf-3240000/ \
     && env CFLAGS="-DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1" ./configure \
     && make install \
     && cd \
     && git clone https://github.com/msteveb/jimtcl \
     && cd jimtcl/ \
     && git checkout "$1" \
     && ./configure --full --with-ext=sqlite3 \
     && env LDLIBS=-static make \
     && cp jimsh \
          "/inbox/jimsh-$(./jimsh --version)-$(git rev-parse HEAD \
                                               | cut -c 1-10)-$0"
    ' \
    "$arch" \
    "$revision"
