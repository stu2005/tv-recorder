FROM library/node:18.20.8-bookworm-slim AS nodejs
FROM l3tnun/epgstation:v2.10.0-debian AS epgstation
FROM lscr.io/linuxserver/ffmpeg:7.1.1 AS ffmpeg

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=nodejs /usr/local/ /build/usr/local/
COPY --from=epgstation /app/ /build/app/
COPY --from=ffmpeg /usr/local/ /build/usr/local/


# Final image
FROM library/ubuntu:24.04

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ENV LD_LIBRARY_PATH=/usr/lib/:/usr/lib64:/usr/libexec:/usr/local/lib
ENV LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri
ARG DEBIAN_FRONTEND=noninteractive

# Directories that need to be mounted to run
VOLUME /app/data/ /app/thumbnail/ /app/recorded/

# Set a command to be executed at startup
ENTRYPOINT ["node"]
CMD ["./dist/index.js"]

# Copy downloads
COPY --from=downloads /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests \
      libxcb1+ \
      libxcb-shm0+ \
      libasound2t64+ \
      libv4l-0t64+ \
      libxml2+ \
      libglib2.0-0t64+ \
      libgomp1+ \
      libexpat1+ \
      libbrotli1+
    if [[ "$(uname -m)" == "x86_64" ]]; then
      apt-get install -qy --no-install-recommends --no-install-suggests \
        curl \
        ca-certificates
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc.sh | bash
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_vceencc.sh | bash      
      apt-get install -qy \
        --no-install-recommends --no-install-suggests \
          /qsvencc.deb \
          /vceencc.deb \
          i965-va-driver \
        --autoremove --purge \
          curl- \
          ca-certificates-
      qsvencc -v
      vceencc -v
      rm -rf /*.deb /rocm.gpg /etc/apt/sources.list.d/amdgpu.sources
    fi

  # Test
    node -v
    ffmpeg -version

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EOF