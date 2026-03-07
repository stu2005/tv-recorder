# Build stage
FROM library/alpine:3.23.3 AS build

# Setup
RUN <<EOF ash -ex
    apk upgrade -qU --no-cache
    apk add -qU --no-cache alpine-sdk make gcc musl-dev linux-headers autoconf automake g++
    mkdir -p /build/etc/apk/
    mv /etc/apk/repositories /build/etc/apk/repositories
EOF

# Build recpt1
RUN <<EOF ash -ex
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
FROM collelog/tvchannels-scan:latest-alpine

# Set environment variable
ENV TZ=Asia/Tokyo

# Copy build stage artifacts
COPY --from=build /build/ /

# Postinstall
RUN <<EOF ash -ex

  # Update
    apk upgrade -qU --no-cache

  # Test
    recpt1 -v

EOF