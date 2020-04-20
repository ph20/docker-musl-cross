# docker-musl-cross

This repository contains a `Dockerfile` that builds an image with the
[musl-cross][1] toolchain installed.  I will attempt to keep the version
of musl up-to-date.

This image is also an automated build on the Docker hub - you can fetch it
by running: `docker pull ph20/musl-cross`

For starting local builds run the following
`docker build -t ph20/musl-cross:$(date -u +'%Y%m%d') --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') .`

For testing docker image, try build something. For example
`docker run --rm -it -v $(pwd):/output -v $(pwd):/home/build/proj ph20/musl-cross:2020.04.18 /home/build/proj/build.sh`

[1]: https://github.com/ph20/musl-cross
BUILD_DATE argument with the proper RFC3339 standard value
