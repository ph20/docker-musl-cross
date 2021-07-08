# vim:set ft=dockerfile:
FROM debian:buster-20210621 as buster-latest

# make Apt non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# prevent debconf: delaying package configuration, since apt-utils is not installed
#RUN echo 'Dpkg::Options::="--force-confold";' >> /etc/apt/apt.conf.d/90confold
RUN apt-get update
RUN apt-get install apt-utils --no-install-recommends -yy
RUN apt-get upgrade  -yy
RUN apt-get install sudo --no-install-recommends -yy

RUN useradd --uid=10000 --user-group --create-home build && \
	echo 'build ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-build && \
	echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep
RUN mkdir /build && chown build:build /build


FROM buster-latest as buster-devel
# Install build tools
RUN apt-get install --no-install-recommends  -yy \
        automake            \
        bison               \
        build-essential     \
        curl                \
        file                \
        flex                \
        git                 \
        libtool             \
        pkg-config          \
        python              \
        texinfo             \
        vim                 \
        wget                \
        unzip               \
        locales             \
        ca-certificates

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM buster-devel as buster-devel-prebuild
RUN mkdir /opt/cross && chown build:build /opt/cross
USER build
ADD --chown=build:build https://github.com/GregorR/musl-cross/archive/a8a66490dae7f23a2cf5e256f3a596d1ccfe1a03.zip /build/musl-cross.zip
RUN cd /build/ && unzip -q musl-cross.zip && rm -f musl-cross.zip && mv musl-cross-* musl-cross
ADD --chown=build:build https://www.musl-libc.org/releases/musl-1.1.24.tar.gz /build/musl-cross/tarballs/
ADD --chown=build:build https://ftp.barfooze.de/pub/sabotage/tarballs/linux-headers-4.19.88.tar.xz /build/musl-cross/tarballs/
ADD --chown=build:build https://ftpmirror.gnu.org/gnu/binutils/binutils-2.27.tar.bz2 /build/musl-cross/tarballs/
ADD --chown=build:build https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=3d5db9ebe860 /build/musl-cross/tarballs/config.sub;hb=3d5db9ebe860
ADD --chown=build:build https://ftpmirror.gnu.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2 /build/musl-cross/tarballs/
ADD --chown=build:build https://ftpmirror.gnu.org/gnu/gmp/gmp-6.1.0.tar.bz2 /build/musl-cross/tarballs/
ADD --chown=build:build http://ftpmirror.gnu.org/gnu/mpfr/mpfr-3.1.4.tar.bz2 /build/musl-cross/tarballs/
ADD --chown=build:build https://ftpmirror.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz /build/musl-cross/tarballs/
WORKDIR /build

FROM buster-devel-prebuild as buster-devel-build
# Install musl-cross
RUN cd /build &&                                                    \
    cd /build/musl-cross &&                                                \
    echo 'GCC_BUILTIN_PREREQS=yes' >> config.sh &&                  \
    #sed -i -e "s/^MUSL_VERSION=.*\$/MUSL_VERSION=1.1.24-ea952/" defs.sh &&  \
    ./build.sh

FROM buster-devel
LABEL authors="Andrew Dunham <andrew@du.nham.ca>, Alexander Grynchuk <agrynchuk@gmail.com>"
LABEL maintainer="Alexander Grynchuk <agrynchuk@gmail.com>"

COPY --from=buster-devel-build /opt/cross/ /opt/cross/
ARG BUILD_DATE=undefined
ENV BUILD_DATE=$BUILD_DATE
# App Container Build Specification
# https://github.com/appc/spec
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="ph20/musl-cross"
LABEL org.label-schema.description="Container with a musl-cross toolchain installed"
LABEL org.label-schema.url="http://musl.codu.org/"
LABEL org.label-schema.vcs-url="https://github.com/ph20/docker-musl-cross"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/output ph20/musl-cross:latest"
ENV PATH $PATH:/opt/cross/x86_64-linux-musl/bin
USER build
WORKDIR /build
# usermod -u 2005 foo
# groupmod -g 3000 foo
CMD /bin/bash
