ARG arch
ARG revision
FROM ${arch}/alpine:3.20

RUN apk update
RUN apk add gcc \
            git \
            hiredis \
            hiredis-dev \
            make \
            libc-dev \
            openssl-dev \
            openssl-libs-static \
            tcl \
            zlib-dev \
            zlib-static \
            ;

RUN wget https://sqlite.org/2024/sqlite-autoconf-3460100.tar.gz
RUN tar xvf sqlite-autoconf-3460100.tar.gz

RUN cd sqlite-autoconf-3460100/ \
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
                   -DSQLITE_ENABLE_MATH_FUNCTIONS \
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
    ;

RUN git clone https://github.com/msteveb/jimtcl

RUN cd jimtcl/ \
    && git checkout ${revision} \
    && ./configure --full --ipv6 --math --ssl "--with-ext=redis sqlite3" \
    && make "LDFLAGS=-static" \
            "LDLIBS=-Wl,-Bstatic -lz -lsqlite3 -lssl -lcrypto -lhiredis" \
    ;
