FROM library/node:18.20.8-bookworm-slim AS nodejs
FROM l3tnun/epgstation:v2.10.0-debian AS epgstation
FROM lscr.io/linuxserver/ffmpeg:7.1.1 AS ffmpeg

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=nodejs /usr/local/ /build/usr/local/
COPY --from=epgstation /app/ /build/app/
COPY --from=ffmpeg /usr/local/ /build/usr/local/

# Final image
FROM nvidia/cuda:13.0.1-base-ubuntu24.04

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ENV LD_LIBRARY_PATH=/usr/local/lib/:/usr/lib/$LD_LIBRARY_PATH
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
      ca-certificates+ \
      libboost-program-options1.83.0+ \
      libboost-filesystem1.83.0+ \
      curl+ \
      libnvidia-compute-570+ \
      v4l-utils+
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_nvencc.sh | bash
    apt-get install -qy \
      --no-install-recommends --no-install-suggests \
        /nvencc.deb \
      --autoremove --purge \
        curl- \
        ca-certificates-
    nvencc -v
    node -v
    ffmpeg -version
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  /*.deb

EOF