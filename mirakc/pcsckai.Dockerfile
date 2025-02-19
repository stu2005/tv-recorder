# Get libpcsckai
FROM ghcr.io/stu2005/libpcsckai:latest AS libpcsckai

# Build stage
FROM library/alpine:latest AS build

# Copy libpcsckai
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/

# Run the build script
RUN <<EOF ash -x

  # Update packages
    apk upgrade -U --no-cache

  # Install requires
    apk add -U --no-cache alpine-sdk cmake ninja-build samurai autoconf automake linux-headers

  # Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip
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
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip
    cd /
    unzip -qq ./recpt1.zip
    cd /recpt1-feature-px4/recpt1/
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make prefix=/build/usr/local install

  # Update package repositories
    mkdir -p /build/etc/apk
    cp /etc/apk/repositories /build/etc/apk/repositories

EOF


# Final image
FROM mirakc/mirakc:alpine

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
RUN apk upgrade -U --no-cache