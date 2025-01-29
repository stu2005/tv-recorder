FROM ghcr.io/stu2005/libpcsckai:latest AS libpcsckai
FROM alpine:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
RUN set -x && \
    apk upgrade -U --no-cache && \
    apk add -U --no-cache \
      alpine-sdk \
      cmake \
      ninja-build && \
    mkdir -p /build/etc/apk && \
    cp /etc/apk/repositories /build/etc/apk/repositories && \
\
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./libaribb25-master.zip && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local -DWITH_PCSC_LIBRARY=pcsckai && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install && \
\
# Build recpt1
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-feature-px4/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install


# Final Image
FROM mirakc/mirakc:alpine
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache
ENV TZ=Asia/Tokyo RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
