# Build stage
FROM library/ubuntu:jammy AS build

# Set environment in build stage
ARG DEBIAN_FRONTEND=noninteractive

# Copy nodejs
COPY --from=library/node:14-slim /usr/local/ /usr/local/
COPY --from=library/node:14-slim /usr/local/ /build/usr/local/

# Run the build script
RUN <<EOF bash -ex

  # Update packages
    apt-get update

  # Install requires
    apt-get install -y --no-install-recommends --no-install-suggests ca-certificates python2 git make g++

  # Build
    git clone --recursive https://github.com/stu2005/chinachu /build/app/
    cd /build/app/
    npm install -s
    npm update -s
    npm audit fix -s

EOF


# Final image
FROM library/ubuntu:latest

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 20772

# Directory that need to be mounted to run
VOLUME /app/recorded/

# Copy build stage artifacts
COPY --chown=ubuntu:ubuntu --from=build /build/ /

# Install requires
RUN <<EOF bash -ex

  # Update and install
    npm install pm2 -sg
    apt-get update
    apt-get full-upgrade -y --autoremove --purge --no-install-recommends --no-install-suggests curl+ ca-certificates+ ffmpeg+
    if [[ "$(uname -m)" == "x86_64" ]]; then
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/chinachu/get_qsvencc.sh | bash
      apt-get install -y --no-install-recommends --no-install-suggests /qsvencc.deb
      qsvencc -v  
    fi

  # Test
    node -v
    pm2 -v
    ffmpeg -version
    curl --version

  # Clean
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /qsvencc.deb

EOF

# Set execution user
USER ubuntu:ubuntu

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1