# Latest image
FROM library/alpine:latest AS update

# Build stage
FROM library/node:14-alpine AS build

# Run the build script
RUN <<EOF ash -ex

  # Update packages
    apk upgrade -U --no-cache

  # Install requires
    apk add -U --no-cache python3 git bash make g++

  # Build
    git clone --recursive https://github.com/stu2005/chinachu /build/app/
    cd /build/app/
    npm install
    npm update
    npm audit fix

EOF

# Update package repositories
COPY --from=update /etc/apk/repositories /build/etc/apk/repositories


# Final image
FROM library/node:14-alpine

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 20772

# Copy build stage artifacts
COPY --chown=node:node --from=build /build/ /

# Install requires
RUN <<EOF ash -ex

  # Update
    apk upgrade -U --no-cache

  # Install
    if [ "$(uname -m)" = "x86_64" ]; then
      apk add -U --no-cache curl ffmpeg bash coreutils procps-ng ca-certificates mesa-va-gallium mesa-dri-gallium libva-intel-driver intel-media-driver
    else
      apk add -U --no-cache curl ffmpeg bash coreutils procps-ng ca-certificates mesa-va-gallium mesa-dri-gallium
    fi
    npm install pm2 -g

EOF

# Set execution user
USER node:node

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1