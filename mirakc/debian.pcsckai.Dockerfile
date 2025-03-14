# Build stage
FROM library/rust:latest AS build

# Set environment variable
ARG DEBIAN_FRONTEND=noninteractive

# Copy libpcsckai
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /build/

# Run the build script
RUN <<EOF bash -ex

  # Update and install packages
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests cmake+ git+ libclang-dev+ libdvbv5-dev+ libudev-dev+ pkg-config+ libpcsclite-dev+

  # Build recisdb
    git clone -q https://github.com/stu2005/recisdb-rs /recisdb/
    cd /recisdb/
    sed -i -e 's/kazuki0824/stu2005/g' .gitmodules
    git submodule init -q
    git submodule update -q
    cargo build -F dvb --release
    mkdir -p /build/usr/local/bin/
    install -m 755 target/release/recisdb /build/usr/local/bin/
    
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
RUN <<EOF bash -ex

  # Update
    apt-get update -q
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  # Test
    recisdb -V

EOF