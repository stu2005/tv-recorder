# Get nodejs
FROM library/node:18-slim AS node

# Get epgstation
FROM l3tnun/epgstation:debian AS epgstation
COPY --from=node /usr/local/ /build/usr/local/
RUN <<EOF bash -ex

    cp -r /app /build/

EOF


# Final image
FROM linuxserver/ffmpeg:latest

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

# Copy apt settings and latest nodejs, epgstation
COPY --from=epgstation /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Create user
    groupadd --gid 1000 node
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node

  # Update
    apt-get update
    apt-get full-upgrade -y --autoremove --purge

  # Install curl
    apt-get install -y --no-install-recommends --no-install-suggests curl

  # Test
    node -v
    ffmpeg -version

  # Clean
    apt-get clean
    rm -rf /var/lib/apt/lists/*

EOF