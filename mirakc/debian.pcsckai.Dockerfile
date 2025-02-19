# Get libpcsckai
FROM ghcr.io/stu2005/libpcsckai:debian AS libpcsckai

# Build stage
FROM library/rust:latest AS build

# Copy libpcsckai
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/

# Run the build script
RUN <<EOF bash -x

  # Update packages
    apt-get update
    apt-get full-upgrade -y

  # Install requires
    apt-get install -y --no-install-recommends --no-install-suggests cmake git libclang-dev libdvbv5-dev libudev-dev pkg-config

  # Build recisdb
    git clone --recursive https://github.com/stu2005/recisdb-rs /recisdb/
    cd /recisdb/
    cargo build -F dvb --release
    mkdir -p /build/usr/local/bin/
    install -m 755 target/release/recisdb /build/usr/local/bin/
    
  # Update package repositories
    mkdir -p /build/etc/apt/
    cp /etc/apt/sources.list /build/etc/apt/
    cp -r /etc/apt/sources.list.d /build/etc/apt/

EOF


# Final image
FROM mirakc/mirakc:debian

# Set environment variables
ENV TZ=Asia/Tokyo
ENV RUST_LOG=info

# Directories that need to be mounted to run
VOLUME /var/lib/mirakc/epg/

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy build stage artifacts
COPY --from=build /build/ /

# Update packages
RUN <<EOF bash -x

  # Update
    apt-get update
    apt-get full-upgrade -y

  # Clean
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EOF