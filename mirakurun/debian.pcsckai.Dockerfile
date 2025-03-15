# Build stage
FROM rust:latest AS build

# Copy libpcsckai, mirakurun and the startup script
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /
COPY --from=ghcr.io/stu2005/libpcsckai:debian / /build/
COPY --from=chinachu/mirakurun:latest /app/ /build/app/
COPY ./container-init-debian-pcsckai.sh /build/usr/local/bin/container-init.sh

# Run the build script
RUN <<EOF bash -ex

  # Set startup scrtipt permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apt-get update -q
    apt-get full-upgrade -qy

  # Install requires
    apt-get install -qy --no-install-recommends --no-install-suggests curl cmake git libclang-dev libdvbv5-dev libudev-dev pkg-config libpcsclite-dev

  # Build recisdb
    git clone -q https://github.com/kazuki0824/recisdb-rs /recisdb/
    cd /recisdb/
    sed -i -e 's/tsukumijima/stu2005/g' .gitmodules
    git submodule init
    git submodule update
    cargo build -F dvb --release
    mkdir -p /build/usr/local/bin/
    install -m 755 target/release/recisdb /build/usr/local/bin/

EOF


# Final image
FROM node:18-slim

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
ARG DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /app/

# Directories that need to be mounted to run
VOLUME /var/run/ /opt/ /app-config/ /app-data/

# Open port
EXPOSE 40772

# Set a command to be executed at startup
CMD ["container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy build stage artifacts
COPY --from=build /build/ /

# Install requires
RUN <<EOF bash -ex

  # Update and install
    apt-get update
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests curl+ libdvbv5-0+ libpcsclite1+

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  # Test
    curl --version
    recisdb -V

EOF