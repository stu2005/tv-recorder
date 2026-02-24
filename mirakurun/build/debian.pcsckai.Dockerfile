FROM chinachu/mirakurun:4.0.0-beta.15 AS mirakurun

# Build stage
FROM library/rust:1.93.1-bookworm AS build

# Copy libpcsckai, mirakurun and the startup script
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /build/
COPY --from=mirakurun /app/ /build/app/
COPY ./scripts/container-init-debian-pcsckai.sh /build/usr/local/bin/container-init.sh

# Run the build script
RUN <<EOF bash -ex

  # Set startup scrtipt permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apt-get update -q
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests --autoremove --purge  curl+ cmake+ git+ libclang-dev+ libdvbv5-dev+ libudev-dev+ pkg-config+ libpcsclite-dev+

  # Build recisdb
    git clone --recursive https://github.com/kazuki0824/recisdb-rs /recisdb/
    cd /recisdb/
    sed -i -e 's/pcsclite/pcsckai/g' ./b25-sys/build.rs
    sed -i -e 's/pcsclite/pcsckai/g' ./b25-sys/externals/libaribb25/CMakeLists.txt
    sed -i -e 's/pcsclite/pcsckai/g' ./b25-sys/externals/libaribb25/cmake/FindPCSC.cmake
    cargo build -F dvb --release
    mkdir -p /build/usr/local/bin/
    install -m 755 target/release/recisdb /build/usr/local/bin/

EOF


# Final image
FROM library/node:22.22.0-bookworm-slim

# Set environment variables
ENV TZ=Asia/Tokyo
ENV DISABLE_PCSCD=1
ENV DISABLE_B25_TEST=1
ARG DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /app/

# Directories that need to be mounted to run
VOLUME /var/run/ /opt/ /app-config/ /app-data/

# Open port
EXPOSE 40772

# Set a command to be executed at startup
CMD ["./docker/container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy build stage artifacts
COPY --from=build /build/ /

# Install requires
RUN <<EOF bash -ex

  # Update and install
    apt-get update
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests curl+ libdvbv5-0+

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  # Test
    curl --version
    recisdb -V

EOF