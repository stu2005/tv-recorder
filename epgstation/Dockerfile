# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=library/node:18-slim /usr/local/ /build/usr/local/
COPY --from=l3tnun/epgstation:debian /app/ /build/app/


# Final image
FROM library/ubuntu:latest

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

# Copy downloads
COPY --from=downloads /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests curl+ ca-certificates+ ffmpeg+ 
    if [[ "$(uname -m)" == "x86_64" ]]; then
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc.sh | bash
      apt-get install -qy --no-install-recommends --no-install-suggests /qsvencc.deb
      qsvencc -v
    fi

  # Test
    node -v
    ffmpeg -version
    qsvencc -v
    curl --version

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /qsvencc.deb /vceencc.deb /rocm.gpg /etc/apt/sources.list.d/amdgpu.sources

EOF