# Build jls
FROM library/node:18-slim AS build
COPY --from=l3tnun/epgstation:debian /app/ /build/app/

# Set environment variable
ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF bash -ex 

  # Install requires for build
    apt-get update -q
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests --autoremove --purge build-essential+ zip+ unzip+ libboost-all-dev+ gcc+ g+++ make+ git+ curl+ ca-certificates+ ninja-build+ cmake+
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/add_dmosource.sh | bash
    apt-get install -qy --no-install-recommends --no-install-suggests avisynth+-dev

  # Build
    mkdir -p /build/usr/local/bin/
    git clone -q --recursive https://github.com/tobitti0/JoinLogoScpTrialSetLinux /src
    cd /src/
    git submodule -q foreach git pull -q origin master
    cd ./modules/chapter_exe/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mv chapter_exe ../../join_logo_scp_trial/bin/
    cd ../../logoframe/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mv logoframe ../../join_logo_scp_trial/bin/
    cd ../../join_logo_scp/src/
    make -j$(nproc)
    mv join_logo_scp ../../join_logo_scp_trial/bin/
    cd ../../tsdivider/
    cmake . -GNinja -DCMAKE_BUILD_TYPE=Release
    ninja -j$(nproc)
    mv ./tsdivider ../join_logo_scp_trial/bin/
    mv ../join_logo_scp_trial/bin/* /usr/local/bin/
    cd /
    curl -Lo/delogo.zip https://github.com/tobitti0/delogo-AviSynthPlus-Linux/archive/refs/heads/master.zip
    unzip -qq delogo.zip
    cd /delogo-AviSynthPlus-Linux-master/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mkdir -p /usr/local/lib/avisynth/
    mv libdelogo.so /usr/local/lib/avisynth/
    yarn global add -s https://github.com/tobitti0/join_logo_scp_trial

EOF

FROM scratch AS downloads
COPY --from=build /build/ /build/
COPY --from=build /usr/local/ /build/usr/local/
COPY --from=build /opt/ /build/opt/

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
CMD ["./dist/index.js"]

# Check if container is running
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1

# Copy downloads
COPY --from=downloads /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apt-get update -q
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests libboost-filesystem1.74-dev+ libboost-program-options1.74-dev+ curl+ ca-certificates+ ffmpeg+ 
    if [[ "$(uname -m)" == "x86_64" ]]; then
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc.sh | bash
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_vceencc.sh | bash
      apt-get install -qy --no-install-recommends --no-install-suggests /qsvencc.deb /vceencc.deb
      qsvencc -v
      vceencc -v
    fi

  # Test
    node -v
    ffmpeg -version
    curl --version
    chapter_exe || true
    jlse --version
    logoframe || true
    tsdivider --version

  # Clean
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /qsvencc.deb /vceencc.deb /rocm.gpg /etc/apt/sources.list.d/amdgpu.sources /etc/apt/preferences.d/jammy.pref

EOF