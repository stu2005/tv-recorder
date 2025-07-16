# Build stage
FROM library/node:14.21.3-alpine3.17 AS build

# Run the build script
RUN <<EOF ash -ex

  # Update packages
    apk upgrade -qU --no-cache

  # Install requires
    apk add -qU --no-cache python3 git bash make g++

  # Build
    git clone -q --recursive https://github.com/chinachu/chinachu /build/app
    cd /build/app/
    rm -rf processes.json
    wget -q https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/chinachu/processes.json
    wget -qPapi https://raw.githubusercontent.com/mzyy94/Chinachu-IPTV-API-addon/refs/heads/master/api/resource-iptv.json
    wget -qPapi https://raw.githubusercontent.com/mzyy94/Chinachu-IPTV-API-addon/refs/heads/master/api/script-iptv.vm.js
    mkdir log run data
    npm install -s
    npm update -s
    npm audit fix -s

EOF

FROM scratch AS downloads

# Copy build stage artifacts
COPY --from=build /build/ /build/

# Copy nodejs
COPY --from=build /usr/local/ /build/usr/local/


# Final image
FROM library/alpine:3.22.1

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 20772

# Copy build stage artifacts
COPY --from=downloads /build/ /

# Install requires
RUN <<EOF ash -ex

  # Create user
    addgroup -g 1000 node
    adduser -u 1000 -G node -s /bin/sh -D node
    chown -R node:node ./

  # Update
    apk upgrade -qU --no-cache

  # Install
    apk add -qU --no-cache ffmpeg bash coreutils procps-ng ca-certificates
    npm install pm2 -sg

EOF

# Set execution user
USER node:node

# Set a command to be executed at startup
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]