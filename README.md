# Building static Jim Tcl with SQLite 3 for Linux

The shell script `build.sh` builds a static Linux binary of [Jim Tcl](https://github.com/msteveb/jimtcl) using Docker.  You must select the target architecture by passing a command line argument to the script.  You can choose to build the latest commit (default) or any given commit, branch, or tag.  The build will include every extension enabled by the configure flag `--full` plus the SQLite 3 extension.

The script has been successfully tested with tags `0.72` through `0.78` for `i386`; tags `0.71` and earlier won't work.

## Prebuilt binaries

Prebuilt binaries are available for `i386` and `amd64`.  See the [releases](https://github.com/dbohdan/jimsh-static/releases) on GitHub.  Checksums of the prebuilt binaries can be found [in the repository](SHA256SUMS).

## License

MIT.
