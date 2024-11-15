FROM mirror.gcr.io/library/alpine:latest AS build
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
    wget -O /recpt1.zip https://github.com/stz2012/recpt1/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-master/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install 

# Final Image
FROM mirror.gcr.io/library/alpine:latest AS update_baseImage
FROM docker.io/collelog/tvchannels-scan:latest-alpine
COPY --from=update_baseImage / /
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache
ENV TZ=Asia/Tokyo
