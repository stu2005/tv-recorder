FROM chinachu/mirakurun:4.0.0-beta.15 AS mirakurun

# Final image
FROM library/node:22.22.0-bookworm-slim

# Set environment variables
ENV TZ=Asia/Tokyo
ENV DISABLE_PCSCD=0
ENV DISABLE_B25_TEST=1
ARG DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /app/

# Directories that need to be mounted to run
VOLUME /var/run/ /opt/ /app-config/ /app-data/

# Open port
EXPOSE 40772

# Set a command to be executed at startup
CMD ["./docker/container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Copy mirakurun
COPY --from=mirakurun /app/ /app/

# Postinstall
RUN <<EOF bash -ex

  # Update
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests curl+ ca-certificates+ jq+ libdvbv5-0+ libpcsclite1+ pcscd+ libccid+ pcsc-tools+  
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/mirakurun/build/scripts/get_recisdb.sh | bash
    apt-get install -qy --no-install-recommends --no-install-suggests /recisdb.deb --autoremove --purge jq-

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /recisdb.deb

  # Test
    curl --version
    recisdb -V

EOF