# Build stage
FROM library/alpine:3.21.3 AS build

# Copy libpcsckai
COPY --from=ghcr.io/stu2005/libpcsckai:latest / /
COPY --from=ghcr.io/stu2005/libpcsckai:latest / /build/

# Run the build script
RUN <<EOF ash -ex

  # Update packages
    apk upgrade -qU --no-cache

  # Install requires
    apk add -qU --no-cache alpine-sdk cmake ninja-build samurai autoconf automake linux-headers pcsc-lite-dev

  # Build libaribb25
    wget -qO /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
    cd /
    unzip -qq ./libaribb25-master.zip
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
FROM mirakc/mirakc:3.4.27-alpine

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

# Postinstall
RUN <<EOF ash -ex

  # Update
    apk upgrade -qU --no-cache

  # Miraview
    curl -Lso/miraview.tar.gz https://github.com/maeda577/miraview/releases/download/v0.1.2/build.tar.gz
    mkdir -p /var/www/miraview
    tar -zx -C/var/www/miraview/ -f/miraview.tar.gz
    rm -rf /miraview.tar.gz
  
  # Test
    b25 || true
    recpt1 -v

EOF