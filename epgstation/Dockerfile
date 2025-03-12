# Latest image
FROM library/debian:latest AS update
COPY --from=library/node:18-slim /usr/local/ /build/usr/local/
RUN <<EOF bash -ex

    mkdir /build/etc/
    cp -r /etc/apt /build/etc/

EOF


# Final image
FROM l3tnun/epgstation:debian

# Update
COPY --from=update /build/ /

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ARG DEBIAN_FRONTEND=noninteractive

# Directories that need to be mounted to run
VOLUME /app/data/ /app/thumbnail/ /app/recorded/

# Set a command to be executed at startup
ENTRYPOINT ["node"]
CMD ["dist/index.js"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1

# Postinstall
RUN <<EOF bash -ex

  # Update
    apt-get update
    apt-get full-upgrade -y --autoremove --purge --no-install-recommends --no-install-suggests

  # Install curl
    apt-get install -y --no-install-recommends --no-install-suggests curl ffmpeg

  # Test
    node -v
    ffmpeg -version
    curl --version

  # Clean
    apt-get clean
    rm -rf /var/lib/apt/lists/*

EOF