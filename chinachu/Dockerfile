# Get nodejs 14
FROM library/node:14-slim AS node

# Latest image
FROM library/ubuntu:jammy AS chinachu

# Set environment in build stage
ARG DEBIAN_FRONTEND=noninteractive

# Copy nodejs
COPY --from=node /usr/local/ /usr/local/
COPY --from=node /usr/local/ /build/usr/local/

# Run the build script
RUN <<EOF bash -ex

  # Update packages
    apt-get update

  # Install requires
    apt-get install -y --no-install-recommends --no-install-suggests ca-certificates python2 git make g++

  # Build
    git clone --recursive https://github.com/stu2005/chinachu /build/app/
    cd /build/app/
    npm install
    npm update
    npm audit fix

EOF


# Final image
FROM linuxserver/ffmpeg:latest

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 20772

# Directory that need to be mounted to run
VOLUME /app/recorded/

# Copy build stage artifacts
COPY --chown=node:node --from=chinachu /build/ /

# Install requires
RUN <<EOF bash -ex

  # Create user
    groupadd --gid 1000 node
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node

  # Install
    npm install pm2 -g

  # Test
    node -v
    ffmpeg -version

EOF

# Set execution user
USER node:node

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1