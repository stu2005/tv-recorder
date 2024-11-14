FROM docker.io/stu2005/libpcsckai:latest AS libpcsckai
FROM docker.io/library/alpine:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install dependencies for build
    apk add -U --no-cache \ 
      gcc \
      g++ \
      cmake \
      ninja \
      pcsc-lite-dev && \
\
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./libaribb25-master.zip && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DWITH_PCSC_LIBRARY=pcsckai -DCMAKE_INSTALL_PREFIX=/build/usr/local && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install


# Final Image
FROM docker.io/mirakc/mirakc:alpine
COPY --from=build /build/ /
COPY --from=update_baseImage / /
RUN apk upgrade -U --no-cache
ENV TZ=Asia/Tokyo RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
