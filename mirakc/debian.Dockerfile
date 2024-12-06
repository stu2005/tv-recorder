FROM rust:latest AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN set -x && \
    apt-get update && \
    apt-get full-upgrade -y && \
\
# Install dependencies for build
    apt-get install -y --no-install-recommends \ 
      cmake \
      git \
      libclang-dev \
      libdvbv5-dev \
      libudev-dev \
      pkg-config \
      libpcsclite-dev && \
\
# Build recisdb
    git clone --recursive https://github.com/kazuki0824/recisdb-rs /recisdb/ && \
    cd /recisdb/ && \
    cargo build -F dvb --release && \
    mkdir -p /build/usr/local/bin/ && \
    install -m 755 target/release/recisdb /build/usr/local/bin/ && \
    mkdir -p /build/etc/apt/ && \
    cp -r /etc/apt/ /build/etc/apt/


# Final Image
FROM mirakc/mirakc:debian
ARG DEBIAN_FRONTEND=noninteractive
COPY --from=build /build/ /
RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install --no-install-recommends -y \
      libpcsclite1 \
      pcscd \
      libccid && \    
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Tokyo RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1