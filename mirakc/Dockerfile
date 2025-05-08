# Build stage
FROM library/alpine:3.21.3 AS build

# Copy the startup script
COPY ./container-init.sh /build/usr/local/bin/

# Run the build script
RUN <<EOF ash -ex

  # Set startup script permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apk upgrade -qU --no-cache

  # Install requires
    apk add -qU --no-cache alpine-sdk cmake ninja-build samurai pcsc-lite-dev autoconf automake linux-headers

  # Build libaribb25
    wget -qO /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
    cd /
    unzip -qq ./libaribb25-master.zip
    cd /libaribb25-master/
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local
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
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make prefix=/build/usr/local install

EOF


# Final image
FROM mirakc/mirakc:3.4.15-alpine

# Set environment variables
ENV TZ=Asia/Tokyo 
ENV RUST_LOG=info

# Directories that need to be mounted to run
VOLUME /var/lib/mirakc/epg/

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

  # Install
    apk add -qU --no-cache pcsc-lite-libs pcsc-lite ccid

  # Miraview
    curl -Lso/miraview.tar.gz https://github.com/maeda577/miraview/releases/download/v0.1.2/build.tar.gz
    mkdir -p /var/www/miraview
    tar -zx -C/var/www/miraview/ -f/miraview.tar.gz
    rm -rf /miraview.tar.gz
  
  # Test
    b25 || true
    recpt1 -v

EOF