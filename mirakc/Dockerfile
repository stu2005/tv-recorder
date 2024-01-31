FROM stu2005/libpcsckai:latest AS libpcsckai
FROM alpine:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/

# Install dependencies for build
RUN set -x && \
    apk add -U --no-cache git cmake ninja g++ make

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
    make && \
    make PREFIX=/build/usr/local install

WORKDIR /build/


# Final Image
FROM mirakc/mirakc:alpine
COPY --from=build /build/ /
