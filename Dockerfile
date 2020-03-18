FROM debian:jessie-20200224
LABEL authors="Andrew Dunham <andrew@du.nham.ca>, Alexander Grynchuk <agrynchuk@gmail.com>"

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
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
        unzip

# Install musl-cross
RUN mkdir /build &&                                                 \
    cd /build &&                                                    \
    curl -L https://github.com/GregorR/musl-cross/archive/a8a66490dae7f23a2cf5e256f3a596d1ccfe1a03.zip -o musl-cross.zip && \
    unzip musl-cross.zip && \
    cd musl-cross-* &&                                                \
    echo 'GCC_BUILTIN_PREREQS=yes' >> config.sh &&                  \
    #sed -i -e "s/^MUSL_VERSION=.*\$/MUSL_VERSION=1.1.12/" defs.sh &&  \
    ./build.sh &&                                                   \
    cd / &&                                                         \
    apt-get clean &&                                                \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build

ENV PATH $PATH:/opt/cross/x86_64-linux-musl/bin
CMD /bin/bash
