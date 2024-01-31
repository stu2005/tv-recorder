FROM stu2005/libpcsckai:latest AS libpcsckai
FROM alpine:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/

# Install dependencies for build
RUN set -x && \
    apk add -U --no-cache git cmake ninja g++ pcsc-lite-dev make linux-headers

# Build libaribb25
WORKDIR /libaribb25/
RUN set -x && \
    git clone https://github.com/tsukumijima/libaribb25 . && \
    cmake -GNinja -Bbuild -DWITH_PCSC_LIBRARY=pcsckai -DCMAKE_INSTALL_PREFIX=/build/usr/local && \
    cd build && \
    ninja -j$(nproc) && \
    ninja install

# Build recfsusb2n
WORKDIR /recfsusb2n/
RUN set -x && \
    git clone https://github.com/tkmsst/recfsusb2n.git . && \
    cd src && \
    rm -rf Makefile && \
    wget https://gist.githubusercontent.com/stu2005/ec575983485aa69ebfe6a58d713e8ee8/raw/c3afe8b91ba9acdda2e252e9e766da41ad8a87d8/Makefile && \
    make -j$(nproc) && \
    make PREFIX=/build/usr/local install

WORKDIR /build/


# Final Image
FROM mirakc/mirakc:alpine
COPY --from=build /build/ /
