# Final image
FROM library/node:18.20.8-alpine3.21

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ENV LD_LIBRARY_PATH=/opt/vc/lib/:/usr/lib/:/usr/local/lib/

# Directories that need to be mounted to run
VOLUME /app/data/ /app/thumbnail/ /app/recorded/

# Set a command to be executed at startup
ENTRYPOINT ["node"]
CMD ["./dist/index.js"]

# Copy downloads
COPY --from=l3tnun/epgstation:v2.10.0-alpine /app/ /app/

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apk upgrade -U --no-cache
    apk add -U --no-cache \
      ffmpeg \
      raspberrypi-userland-libs

  # Test
    node -v
    ffmpeg -version

EOF