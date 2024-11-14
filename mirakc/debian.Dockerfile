FROM docker.io/stu2005/libpcsckai:debian AS libpcsckai
FROM docker.io/library/rust:latest AS build
ARG DEBIAN_FRONTEND=noninteractive
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
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
      pkg-config && \
\
# Build recisdb
    git clone --recursive https://github.com/stu2005/recisdb-rs /recisdb/ && \
    cd /recisdb/ && \
    cargo build -F dvb --release && \
    mkdir -p /build/usr/local/bin/ && \
    install -m 755 target/release/recisdb /build/usr/local/bin/


# Final Image
FROM docker.io/mirakc/mirakc:debian
ARG DEBIAN_FRONTEND=noninteractive
COPY --from=build /build/ /
RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Tokyo RUST_LOG=info
VOLUME /var/lib/mirakc/epg/
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1