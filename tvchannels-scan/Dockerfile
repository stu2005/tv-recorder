FROM alpine:latest AS build
RUN set -x && \
\
# Install Dependencies for Build
    apk add -U --no-cache make gcc musl-dev linux-headers && \
\
# Build recfsusb2n
    wget -O /recfsusb2n-master.zip https://github.com/stu2005/recfsusb2n/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./recfsusb2n-master.zip && \
    cd /recfsusb2n-master/src/ && \
    rm -rf Makefile usbdevfile.c && \
    wget https://gist.githubusercontent.com/stu2005/ec575983485aa69ebfe6a58d713e8ee8/raw/c3afe8b91ba9acdda2e252e9e766da41ad8a87d8/Makefile && \
    wget https://gist.githubusercontent.com/stu2005/041420d48d9af94dd3d8b0ec4bb5c5f1/raw/cddfc97399f4c1b19d78cdeee55d481580104a59/usbdevfile.c && \
    make -j$(nproc) && \
    mkdir -p /build/usr/local/bin/ && \
    make PREFIX=/build/usr/local install


# Final Image
FROM collelog/tvchannels-scan:latest-alpine
COPY --from=build /build/ /
ENV TZ=Asia/Tokyo
