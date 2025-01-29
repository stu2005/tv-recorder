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
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-feature-px4/recpt1/ && \
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
