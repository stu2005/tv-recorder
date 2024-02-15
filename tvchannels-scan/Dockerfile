FROM docker.io/library/alpine:latest AS update_baseImage
FROM docker.io/library/alpine:latest AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Dependencies for Build
    apk add -U --no-cache make gcc musl-dev linux-headers && \
\
# Build recfsusb2n
    wget -O /recfsusb2n.zip https://github.com/stu2005/recfsusb2n/archive/refs/heads/alpine.zip && \
    cd / && \
    unzip ./recfsusb2n.zip && \
    cd /recfsusb2n-alpine/src/ && \
    make -j$(nproc) && \
    mkdir -p /build/usr/local/bin/ && \
    make PREFIX=/build/usr/local install


# Final Image
FROM collelog/tvchannels-scan:latest-alpine
COPY --from=update_baseImage / /
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache
ENV TZ=Asia/Tokyo
