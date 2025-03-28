# Build ffmpeg, jls
FROM library/buildpack-deps:stable-scm AS build

# Set environment variable
ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF bash -ex 

  # Install requires for build
    apt-get update -q
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/add_dmosource.sh | bash
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests \
      avisynth+-dev+ \
      ninja-build+ \
      cmake+ \
      unzip+ \
      libboost-all-dev+ \
      make+ \
      gcc+ \
      g+++

  # Clone
    mkdir -p /build/usr/local/bin/
    git clone -q --recursive https://github.com/tobitti0/JoinLogoScpTrialSetLinux /src
    cd /src/
    git submodule -q foreach git pull -q origin master

  # Build chapter_exe
    cd ./modules/chapter_exe/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mv chapter_exe ../../join_logo_scp_trial/bin/

  # Build logoframe
    cd ../../logoframe/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mv logoframe ../../join_logo_scp_trial/bin/

  # Build jls
    cd ../../join_logo_scp/src/
    make -j$(nproc)
    mv join_logo_scp ../../join_logo_scp_trial/bin/

  # Build tsdivider
    cd ../../tsdivider/
    cmake . -GNinja -DCMAKE_BUILD_TYPE=Release
    ninja -j$(nproc)
    mv ./tsdivider ../join_logo_scp_trial/bin/

  # Copy artifacts
    mv ../join_logo_scp_trial/bin/* /build/usr/local/bin/

  # Build delogo
    cd /
    curl -Lso/delogo.zip https://github.com/tobitti0/delogo-AviSynthPlus-Linux/archive/refs/heads/master.zip
    unzip -qq ./delogo.zip
    cd ./delogo-AviSynthPlus-Linux-master/src/
    sed -i -e 's#/usr/local/include/avisynth#/usr/include/avisynth#g' Makefile
    make -j$(nproc)
    mkdir -p /build/usr/lib/$(uname -m)-linux-gnu/avisynth/
    mv libdelogo.so /build/usr/lib/$(uname -m)-linux-gnu/avisynth/

EOF

# Get nodejs and jlse
FROM library/buildpack-deps:stable-scm AS jlse_node
COPY --from=library/node:18-slim /usr/local/ /usr/local/
COPY --from=library/node:18-slim /opt/ /opt/
RUN yarn global add -s https://github.com/tobitti0/join_logo_scp_trial

# Putting together the artifacts
FROM scratch AS artifacts

# jls
COPY --from=build /build/ /build/

# EPGStation
COPY --from=l3tnun/epgstation:debian /app/ /build/app/

# Yarn
COPY --from=jlse_node /opt/ /build/opt/

# Nodejs, npm, jlse
COPY --from=jlse_node /usr/local/ /build/usr/local/


# Final image
FROM library/debian:stable-slim

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

# Copy artifacts
COPY --from=artifacts /build/ /

# Postinstall
RUN <<EOF bash -ex

  # Update and install
    apt-get update -q
    apt-get install -qy --no-install-recommends --no-install-suggests curl ca-certificates
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/add_dmosource.sh | bash
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests \
      libvmaf3+ \
      libopencore-amrnb0+ \
      libopencore-amrwb0+ \
      x264+ \
      x265+ \
      opus-tools+ \
      libvorbis0a+ \
      libvorbisenc2+ \
      libvorbisfile3+ \
      libtheora-bin+ \
      vpx-tools+ \
      webp+ \
      lame+ \
      libxvidcore4+ \
      aac-enc+ \
      libopenjp2-tools+ \
      libfreetype6+ \
      libvidstab1.1+ \
      libfribidi-bin+ \
      fontconfig+ \
      libass9+ \
      libkvazaar7+ \
      aom-tools+ \
      xutils+ \
      libxau6+ \
      libxcb1+ \
      libxml2+ \
      libbluray-bin+ \
      libzmq5+ \
      srt-tools+ \
      libpng-tools+ \
      libaribb24-0+ \
      avisynth++ \
      ffmpeg+ \
      l-smash+ \
      vapoursynth-l-smash-source+ \
      libboost-program-options1.74.0+ \
      libboost-filesystem1.74.0+     
    if [[ "$(uname -m)" == "x86_64" ]]; then
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc.sh | bash
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_vceencc.sh | bash
      apt-get install -qy --no-install-recommends --no-install-suggests \
        /qsvencc.deb \
        /vceencc.deb
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
    apt-get autoremove -qy --purge deb-multimedia-keyring
    apt-get clean -q
    rm -rf \
      /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/* \
      /*.deb \
      /*.gpg \
      /etc/apt/sources.list.d/amdgpu.sources \
      /etc/apt/sources.list.d/dmo.sources \
      /etc/apt/preferences.d/dmo.pref

EOF