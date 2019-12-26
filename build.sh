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
     && apk add gcc git make libc-dev openssl-dev tcl zlib-dev \
     && wget https://sqlite.org/2019/sqlite-autoconf-3300100.tar.gz \
     && tar xvf sqlite-autoconf-3300100.tar.gz \
     && cd sqlite-autoconf-3300100/ \
     && env CFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA \
                    -DSQLITE_ENABLE_DBSTAT_VTAB \
                    -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
                    -DSQLITE_ENABLE_FTS3 \
                    -DSQLITE_ENABLE_FTS3_PARENTHESIS \
                    -DSQLITE_ENABLE_FTS3_TOKENIZER \
                    -DSQLITE_ENABLE_FTS4 \
                    -DSQLITE_ENABLE_FTS5 \
                    -DSQLITE_ENABLE_GEOPOLY \
                    -DSQLITE_ENABLE_JSON1 \
                    -DSQLITE_ENABLE_OFFSET_SQL_FUNC \
                    -DSQLITE_ENABLE_PREUPDATE_HOOK \
                    -DSQLITE_ENABLE_RBU \
                    -DSQLITE_ENABLE_RTREE \
                    -DSQLITE_ENABLE_SESSION \
                    -DSQLITE_ENABLE_STMTVTAB \
                    -DSQLITE_ENABLE_UNLOCK_NOTIFY \
                    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
                    -DSQLITE_LIKE_DOESNT_MATCH_BLOBS \
                    -DSQLITE_OMIT_DEPRECATED \
                    -DSQLITE_SECURE_DELETE \
                    -DSQLITE_SOUNDEX \
                    -DSQLITE_USE_ALLOCA \
                    -DSQLITE_USE_URI" ./configure \
     && make install \
     && cd \
     && git clone https://github.com/msteveb/jimtcl \
     && cd jimtcl/ \
     && git checkout "$1" \
     && ./configure --full --ipv6 --math --ssl --with-ext=sqlite3 \
     && env LDLIBS=-static make \
     && make test \
     && cp jimsh \
          "/inbox/jimsh-$(./jimsh --version)-$(git rev-parse HEAD \
                                               | cut -c 1-10)-$0"
    ' \
    "$arch" \
    "$revision"
