# Static Jim Tcl with SQLite 3 for Linux

## How this works

The shell script [`build.sh`](build.sh) builds a static Linux binary of [Jim Tcl](https://github.com/msteveb/jimtcl) using Docker.  You must select the target architecture by passing a command line argument to the script.  You can choose to build the latest commit (default) or any given commit, branch, or tag.  The build will include every extension enabled by the configure flag `--full` plus the SQLite 3 extension.  SQLite 3 will be built with its extensions [FTS5](https://www.sqlite.org/fts5.html) and [JSON1](https://www.sqlite.org/json1.html).

The script has been successfully tested with tags `0.78` through `0.80` for `amd64`; tag `0.77` and earlier won't work.  For `0.80` and earlier remove `redis` from the list of extensions.

## Prebuilt binaries

Prebuilt binaries are available for `amd64`, `arm32v6`, and `i386`.  See the [releases](https://github.com/dbohdan/jimsh-static/releases) on GitHub.  Checksums of the prebuilt binaries can be found [in the repository](SHA256SUMS).

## License

MIT.
