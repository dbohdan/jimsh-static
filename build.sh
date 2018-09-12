#! /bin/sh
# Only the target architectures amd64 and i386 have been tested.  The target
# architecture is checked to be one of the official architectures in order to
# guard against typosquatting and name squatting attacks on the Docker Hub.

arch="$*"
case "$arch" in
    amd64|arm32v6|arm64v8|i386|ppc64le|s390x)
        ;;
    '')
        echo 'no target architecture' > /dev/stderr
        exit 1
        ;;
    *)
        echo "unknown architecture: \"$arch\"" > /dev/stderr
        exit 1
esac
echo "target architecture is $arch"


mkdir -p inbox/
docker run \
    --rm \
    --volume "$(pwd)/inbox:/inbox" \
    "$arch/alpine:3.8" \
    sh -c \
    'cd \
     && apk update \
     && apk add gcc git make libc-dev tcl \
     && wget https://sqlite.org/2018/sqlite-autoconf-3240000.tar.gz \
     && tar xvf sqlite-autoconf-3240000.tar.gz \
     && cd sqlite-autoconf-3240000/ \
     && env CFLAGS="-DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1" ./configure \
     && make install \
     && cd \
     && git clone https://github.com/msteveb/jimtcl \
     && cd jimtcl/ \
     && ./configure --full --with-ext=sqlite3 \
     && env LDLIBS=-static make \
     && cp jimsh \
          "/inbox/jimsh-$(./jimsh --version)-$(git rev-parse HEAD \
                                               | cut -c 1-10)-$0"
    ' \
    "$arch"
