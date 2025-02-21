# Build stage
FROM library/rust:latest AS build

# Copy startup script
COPY ./container-init.sh /build/usr/local/bin/

# Run the build script
RUN <<EOF bash -x

  # Set startup script permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apt-get update
    apt-get full-upgrade -y

  # Install requires
    apt-get install -y --no-install-recommends --no-install-suggests cmake git libclang-dev libdvbv5-dev libudev-dev pkg-config libpcsclite-dev

  # Build recisdb
    git clone --recursive https://github.com/kazuki0824/recisdb-rs /recisdb/
    cd /recisdb/
    cargo build -F dvb --release
    mkdir -p /build/usr/local/bin/
    install -m 755 target/release/recisdb /build/usr/local/bin/
    
  # Update package repositories
    mkdir -p /build/etc/apt/
    cp /etc/apt/sources.list /build/etc/apt/
    cp -r /etc/apt/sources.list.d/ /build/etc/apt/

EOF


# Final image
FROM mirakc/mirakc:debian

# Set environment variables
ENV TZ=Asia/Tokyo
ENV RUST_LOG=info

# Directories that need to be mounted to run
VOLUME /var/lib/mirakc/epg/

# Set a command to be executed at startup
CMD ["/usr/local/bin/container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy build stage artifacts
COPY --from=build /build/ /

# Install requires
RUN <<EOF bash -x

  # Update
    apt-get update
    apt-get full-upgrade -y

  # Install
    apt-get install -y --no-install-recommends --no-install-suggests libpcsclite1 pcscd libccid

  # Clean
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  # Test
    recisdb -V

EOF