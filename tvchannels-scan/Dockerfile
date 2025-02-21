# Build stage
FROM alpine:latest AS build

# Run the build script
RUN <<EOF ash -x

  # Update packages
    apk upgrade -U --no-cache

  # Install requires
    apk add -U --no-cache alpine-sdk make gcc musl-dev linux-headers autoconf automake g++

  # Build recpt1
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip
    cd /
    unzip -qq ./recpt1.zip
    cd /recpt1-feature-px4/recpt1/
    ./autogen.sh
    ./configure
    make -j$(nproc)
    mkdir -p /build/usr/local/bin/
    make prefix=/build/usr/local install

  # Update package repositories
    mkdir -p /build/etc/apk/
    mv /etc/apk/repositories /build/etc/apk/repositories

EOF


# Final image
FROM collelog/tvchannels-scan:latest-alpine

# Set environment variable
ENV TZ=Asia/Tokyo

# Copy build stage artifacts
COPY --from=build /build/ /

# Postinstall
RUN <<EOF ash -x

  # Update
    apk upgrade -U --no-cache

  # Test
    recpt1 -v

EOF