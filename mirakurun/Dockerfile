# Build stage
FROM node:18-alpine AS build

# Set environment variables in a build stage
ARG DOCKER=YES
ARG NODE_ENV=production

# Copy the startup script
COPY ./container-init-alpine.sh /build/usr/local/bin/container-init.sh

# Run the build script
RUN <<EOF ash -x

  # Set startup scrtipt permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apk upgrade -U --no-cache

  # Install requires
    apk add -U --no-cache alpine-sdk cmake ninja-build samurai pcsc-lite-dev autoconf automake linux-headers

  # Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
    cd /
    unzip -qq ./libaribb25-master.zip > /dev/null
    cd /libaribb25-master/
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local
    cd build
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc
    ninja -j$(nproc)
    ninja install

  # Build recpt1
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip
    cd /
    unzip -qq ./recpt1.zip
    cd /recpt1-feature-px4/recpt1/
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make prefix=/build/usr/local install

  # Build mirakurun
    wget -O /mirakurun.zip https://github.com/Chinachu/Mirakurun/archive/refs/heads/master.zip
    cd /
    unzip -qq mirakurun.zip
    cd Mirakurun-master
    npm install --production=false
    npm run build
    npm install -g --unsafe-perm --production
    cd /
    mkdir -p /build/app/
    mv /usr/local/lib/node_modules/mirakurun/* /build/app/

EOF


# Final image
FROM node:18-alpine

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

# Postinstall
RUN <<EOF ash -x
  
  # Update
    apk upgrade -U --no-cache

  # Install
    apk add -U --no-cache curl pcsc-lite-libs pcsc-lite ccid

  # Test
    b25 || true
    recpt1 -v

EOF
