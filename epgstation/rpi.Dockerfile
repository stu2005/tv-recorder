# Build userland
FROM dtcooper/raspberrypi-os:bullseye AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF bash -ex

  # Update
    apt-get update
    apt-get full-upgrade -qy --autoremove --purge \
      --no-install-recommends \
      --no-install-suggests \
        git+ \
        ca-certificates+ \
        make+ \
        cmake+ \
        sudo+ \
        build-essential+

  # Build
    git clone https://github.com/raspberrypi/userland /userland
    cd /userland
    ./buildme

EOF

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=library/node:18.20.8-bookworm-slim /usr/local/ /build/usr/local/
COPY --from=build /opt/ /build/opt/
COPY --from=l3tnun/epgstation:v2.10.0-debian /app/ /build/app/


# Final image
FROM dtcooper/raspberrypi-os:bullseye

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ENV LD_LIBRARY_PATH=/opt/vc/lib/:/usr/lib/:/usr/local/lib/
ARG DEBIAN_FRONTEND=noninteractive

# Directories that need to be mounted to run
VOLUME /app/data/ /app/thumbnail/ /app/recorded/

# Set a command to be executed at startup
ENTRYPOINT ["node"]
CMD ["./dist/index.js"]

# Copy downloads
COPY --from=downloads /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge \
      --no-install-recommends \
      --no-install-suggests \
        ffmpeg+

  # Test
    node -v
    ffmpeg -version

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EOF