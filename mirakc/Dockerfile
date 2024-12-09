FROM alpine:latest AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install dependencies for build
    apk add -U --no-cache \
      make \
      gcc \
      g++ \
      cmake \
      ninja \
      pcsc-lite-dev \
      autoconf \
      automake \
      musl-dev \
      linux-headers && \
\
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./libaribb25-master.zip && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install && \
    mkdir -p /build/etc/apk && \
    cp /etc/apk/repositories /build/etc/apk/repositories && \
\
# Build recpt1
    wget -O /recpt1.zip https://github.com/stu2005/recpt1/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-master/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install


# Final Image
FROM mirakc/mirakc:alpine
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache \
      pcsc-lite \
      pcsc-lite-libs \
      ccid
ENV TZ=Asia/Tokyo RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
