FROM library/buildpack-deps:bookworm-curl
WORKDIR /app/
RUN <<EOF bash -ex

  # Update
    apt-get update
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests --autoremove --purge

  # Install
    apt-get install -qy --no-install-recommends --no-install-suggests jq
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/isdb-scanner/get_recisdb.sh | bash
    apt-get install -qy --no-install-recommends --no-install-suggests /recisdb.deb
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/isdb-scanner/get_isdbscanner.sh | bash

  # Test
    recisdb -V
    isdb-scanner --version

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /recisdb.deb

EOF

ENTRYPOINT ["isdb-scanner"]