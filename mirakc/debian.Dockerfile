# Final image
FROM mirakc/mirakc:3.4.40-debian

# Set environment variables
ENV TZ=Asia/Tokyo
ENV RUST_LOG=info
ARG DEBIAN_FRONTEND=noninteractive

# Directories that need to be mounted to run
VOLUME /var/lib/mirakc/epg/

# Set a command to be executed at startup
CMD ["container-init.sh"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1

# Install requires
RUN <<EOF bash -ex
  
  # Download startup script
    curl -Lso/usr/local/bin/container-init.sh https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/mirakc/container-init.sh
    chmod +x /usr/local/bin/container-init.sh

  # Update and install
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/mirakc/get_recisdb.sh | bash
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests
    apt-get install -qy --no-install-recommends --no-install-suggests /recisdb.deb libpcsclite1 pcscd libccid 

  # Miraview
    curl -Lso/miraview.tar.gz https://github.com/maeda577/miraview/releases/download/v0.1.2/build.tar.gz
    mkdir -p /var/www/miraview
    tar -zx -C/var/www/miraview/ -f/miraview.tar.gz

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /recisdb.deb /miraview.tar.gz

  # Test
    recisdb -V

EOF