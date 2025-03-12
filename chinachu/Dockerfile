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
FROM library/ubuntu:latest

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

  # Update and install
    npm install pm2 -g
    apt-get update
    apt-get full-upgrade -y --autoremove --purge --no-install-recommends --no-install-suggests ffmpeg+ gh+ jq+
    curl -Lo/gh.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
    curl -Lo/etc/apt/sources.list.d/ https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/chinachu/github-cli.sources
    curl -Lo/ https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/chinachu/get_qsvencc.sh
    chmod +x /get_qsvencc.sh
    /get_qsvencc.sh
    apt-get install -y --no-install-recommends --no-install-suggests /qsvencc.deb

  # Test
    node -v
    pm2 -v
    ffmpeg -version

EOF

# Set execution user
USER ubuntu:ubuntu

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1