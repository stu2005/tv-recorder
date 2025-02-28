# Latest image
FROM library/alpine:latest AS update


# Final image
FROM l3tnun/epgstation:alpine

# Set timezone
ENV TZ="Asia/Tokyo"

# Directories that need to be mounted to run
VOLUME /app/data/ /app/thumbnail/

# Set a command to be executed at startup
ENTRYPOINT ["node"]
CMD ["dist/index.js"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1

# Update package repositories
COPY --from=update /etc/apk/repositories /etc/apk/repositories

# Install ffmpeg
RUN <<EOF ash -ex

  # Update packages
    apk upgrade -U --no-cache
  
  # Install  
    if [ "$(uname -m)" = "x86_64" ]; then
      apk add -U --no-cache curl ffmpeg mesa-va-gallium mesa-dri-gallium libva-intel-driver intel-media-driver
    else
      apk add -U --no-cache curl ffmpeg mesa-va-gallium mesa-dri-gallium
    fi 

EOF