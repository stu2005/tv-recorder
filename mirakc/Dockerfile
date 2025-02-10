# Build stage
FROM library/alpine:latest AS build

# Copy the startup script
COPY ./container-init.sh /build/usr/local/bin/

# Run the build script
RUN <<EOF ash -x

  # Set startup script permission
    chmod +x /build/usr/local/bin/container-init.sh

  # Update packages
    apk upgrade -U --no-cache

  # Install requires
    apk add -U --no-cache alpine-sdk cmake ninja-build samurai pcsc-lite-dev autoconf automake linux-headers

  # Update package repositories
    mkdir -p /build/etc/apk
    cp /etc/apk/repositories /build/etc/apk/repositories

  # Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
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
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip
    cd /
    unzip -qq ./recpt1.zip
    cd /recpt1-feature-px4/recpt1/
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make prefix=/build/usr/local install

EOF


# Final image
FROM mirakc/mirakc:alpine

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
RUN <<EOF ash -x
  
  # Update
    apk upgrade -U --no-cache

  # Install
    apk add -U --no-cache pcsc-lite-libs pcsc-lite ccid 

EOF