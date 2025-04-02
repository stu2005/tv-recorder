# Build stage
FROM library/node:22.14.0-alpine3.21 AS build

# Set environment variables in a build stage
ARG DOCKER=YES
ARG NODE_ENV=production

# Copy mirakurun and libpcsckai
COPY --from=ghcr.io/stu2005/libpcsckai:latest / /
COPY --from=ghcr.io/stu2005/libpcsckai:latest / /build/
COPY --from=chinachu/mirakurun:4.0.0-beta.15 /app/ /build/app/

# Copy the startup script
COPY ./container-init-alpine-pcsckai.sh /build/usr/local/bin/container-init.sh

# Run the build script
RUN <<EOF ash -ex

  # Set startup scrtipt permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apk upgrade -qU --no-cache

  # Install requires
    apk add -qU --no-cache alpine-sdk cmake ninja-build samurai autoconf automake linux-headers pcsc-lite-dev

  # Build libaribb25
    wget -qO /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
    cd /
    unzip -qq ./libaribb25-master.zip > /dev/null
    cd /libaribb25-master/
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local -DWITH_PCSC_PACKAGE=NO -DWITH_PCSC_LIBRARY=pcsckai
    cd build
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc
    ninja -j$(nproc)
    ninja install

  # Build recpt1
    wget -qO /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip
    cd /
    unzip -qq ./recpt1.zip
    cd /recpt1-feature-px4/recpt1/
    mkdir -p /build/usr/local/bin/
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make prefix=/build/usr/local install

EOF


# Final image
FROM library/node:22.14.0-alpine3.21

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
CMD ["container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy build stage artifacts
COPY --from=build /build/ /

# Postinstall
RUN <<EOF ash -ex

  # Update
    apk upgrade -qU --no-cache

  # Install curl
    apk add -qU --no-cache curl

  # Test
    b25 || true
    recpt1 -v

EOF