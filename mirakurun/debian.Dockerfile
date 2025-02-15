# Get mirakurun
FROM chinachu/mirakurun:latest AS mirakurun

# Build stage
FROM rust:latest AS build

# Apt settings in a build stage
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_OPTS="-y"
ARG APT_OPTIONS="-o APT::Install-Recommends=false -o APT::Install-Suggests=false"

# Copy mirakurun
COPY --from=mirakurun /app/ /build/app/

# Copy the startup script
COPY ./container-init-debian.sh /build/usr/local/bin/container-init.sh

# Run the build script
RUN <<EOF bash -x

  # Update packages
    apt-get update
    apt-get full-upgrade

  # Install requires
    apt-get install curl cmake git libclang-dev libdvbv5-dev libudev-dev pkg-config libpcsclite-dev

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
FROM node:18-slim

# Apt settings
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_OPTS="-y"
ARG APT_OPTIONS="-o APT::Install-Recommends=false -o APT::Install-Suggests=false"

# Set environment variables
ENV SERVER_CONFIG_PATH=/app-config/server.yml 
ENV TUNERS_CONFIG_PATH=/app-config/tuners.yml 
ENV CHANNELS_CONFIG_PATH=/app-config/channels.yml 
ENV SERVICES_DB_PATH=/app-data/services.json 
ENV PROGRAMS_DB_PATH=/app-data/programs.json 
ENV LOGO_DATA_DIR_PATH=/app-data/logo-data 
ENV PATH=/opt/bin:$PATH 
ENV DOCKER=YES 
ENV INIT_PID=$$ 
ENV MALLOC_ARENA_MAX=2 
ENV TZ=Asia/Tokyo

# Set the working directory
WORKDIR /app/

# Directories that need to be mounted to run
VOLUME /var/run/ /opt/ /app-config/ /app-data/

# Open port
EXPOSE 40772

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
    apt-get full-upgrade
  
  # Install
    apt-get install curl libdvbv5-0 libpcsclite1 pcscd libccid

  # Clean
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EOF