FROM stu2005/libpcsckai:latest AS libpcsckai
FROM alpine:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
RUN set -x && \
\
# Install dependencies for build
    apk add -U --no-cache git cmake ninja g++ pcsc-lite-dev make linux-headers && \
\
# Build libaribb25
    git clone https://github.com/tsukumijima/libaribb25 /libaribb25 && \
    cd /libaribb25/ && \
    cmake -GNinja -Bbuild -DWITH_PCSC_LIBRARY=pcsckai -DCMAKE_INSTALL_PREFIX=/build/usr/local && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install && \
\
# Build recfsusb2n
    git clone https://github.com/stu2005/recfsusb2n.git /recfsusb2n && \
    cd /recfsusb2n/src/ && \
    rm -rf Makefile usbdevfile.c && \
    wget https://gist.githubusercontent.com/stu2005/ec575983485aa69ebfe6a58d713e8ee8/raw/c3afe8b91ba9acdda2e252e9e766da41ad8a87d8/Makefile && \
    wget https://gist.githubusercontent.com/stu2005/041420d48d9af94dd3d8b0ec4bb5c5f1/raw/cddfc97399f4c1b19d78cdeee55d481580104a59/usbdevfile.c && \
    make -j$(nproc) && \
    make PREFIX=/build/usr/local install


# Final Image
FROM mirakc/mirakc:alpine
COPY --from=build /build/ /
ENV TZ=Asia/Tokyo
ENV RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
