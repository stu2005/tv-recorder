# Build stage
FROM library/node:14-alpine AS build

# Run the build script
RUN <<EOF ash -ex

  # Update packages
    apk upgrade -qU --no-cache

  # Install requires
    apk add -qU --no-cache python3 git bash make g++

  # Build
    git clone -q --recursive https://github.com/stu2005/chinachu /build/app/
    cd /build/app/
    npm install -s
    npm update -s
    npm audit fix -s

EOF

FROM scratch AS downloads

# Copy build stage artifacts
COPY --from=build /build/ /build/

# Copy nodejs
COPY --from=library/node:14-alpine /usr/local/ /build/usr/local/


# Final image
FROM library/alpine:latest

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 20772

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1

# Copy build stage artifacts
COPY --chown=node:node --from=downloads /build/ /

# Install requires
RUN <<EOF ash -ex

  # Create user
    addgroup -g 1000 node
    adduser -u 1000 -G node -s /bin/sh -D node

  # Update
    apk upgrade -qU --no-cache

  # Install
    apk add -qU --no-cache curl ffmpeg bash coreutils procps-ng ca-certificates
    npm install pm2 -sg

EOF

# Set execution user
USER node:node

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]