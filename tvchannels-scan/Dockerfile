FROM alpine:latest AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Dependencies for Build
    apk add -U --no-cache \
      make \
      gcc \
      musl-dev \
      linux-headers \
      autoconf \
      automake \
      g++ && \
\
# Build recpt1
    wget -O /recpt1.zip https://github.com/stu2005/recpt1/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-master/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    mkdir -p /build/usr/local/bin/ && \
    make prefix=/build/usr/local install && \
    mkdir -p /build/etc/apk/ && \
    mv /etc/apk/repositories /build/etc/apk/repositories

# Final Image
FROM collelog/tvchannels-scan:latest-alpine
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache
ENV TZ=Asia/Tokyo
