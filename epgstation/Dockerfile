# Build ffmpeg, jls
FROM library/buildpack-deps:stable-scm AS build

# Set environment variable
ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF bash -ex 

  # Install requires for build
    sed -i -e's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources
    apt-get update -q
    apt-get build-dep -qy --no-install-recommends --no-install-suggests ffmpeg
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/add_dmosource.sh | bash
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests \
      nasm+ \
      yasm+ \
      l-smash+ \
      libx264-dev+ \
      libvpx-dev+ \
      libfdk-aac-dev+ \
      libmp3lame-dev+ \
      libopus-dev+ \
      avisynth+-dev+ \
      libffms2-dev+ \
      vapoursynth-l-smash-source+ \
      libboost-all-dev+ \
      ninja-build+ \
      cmake+ \
      unzip+

  # Build ffmpeg
    cd /
    curl -Lso/ffmpeg.tar.bz2 https://www.ffmpeg.org/releases/ffmpeg-snapshot-git.tar.bz2
    tar -xjf ./ffmpeg.tar.bz2
    cd ./ffmpeg/
    ./configure \
      --prefix=/build/usr/ \
      --toolchain=hardened \
      --libdir=/build/usr/lib/$(uname -m)-linux-gnu/ \
      --incdir=/build/usr/include/$(uname -m)-linux-gnu/ \
      --enable-gpl \
      --disable-stripping \
      --enable-gnutls \
      --enable-ladspa \
      --enable-libaom \
      --enable-libass \
      --enable-libbluray \
      --enable-libbs2b \
      --enable-libcaca \
      --enable-libcdio \
      --enable-libcodec2 \
      --enable-libdav1d \
      --enable-libflite \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libglslang \
      --enable-libgme \
      --enable-libgsm \
      --enable-libjack \
      --enable-libmp3lame \
      --enable-libmysofa \
      --enable-libopenjpeg \
      --enable-libopenmpt \
      --enable-libopus \
      --enable-libpulse \
      --enable-librabbitmq \
      --enable-librist \
      --enable-librubberband \
      --enable-libshine \
      --enable-libsnappy \
      --enable-libsoxr \
      --enable-libspeex \
      --enable-libsrt \
      --enable-libssh \
      --enable-libtheora \
      --enable-libtwolame \
      --enable-libvidstab \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libwebp \
      --enable-libx265 \
      --enable-libxml2 \
      --enable-libxvid \
      --enable-libzimg \
      --enable-libzmq \
      --enable-libzvbi \
      --enable-lv2 \
      --enable-omx \
      --enable-openal \
      --enable-opencl \
      --enable-opengl \
      --enable-sdl2 \
      --disable-sndio \
      --enable-libjxl \
      --enable-pocketsphinx \
      --enable-librsvg \
      --enable-libmfx \
      --enable-libdc1394 \
      --enable-libdrm \
      --enable-libiec61883 \
      --enable-chromaprint \
      --enable-frei0r \
      --enable-libx264 \
      --enable-libplacebo \
      --enable-librav1e \
      --enable-shared \
      --enable-version3 \
      --disable-doc \
      --disable-debug \
      --enable-pic \
      --enable-avisynth \
      --enable-libx264 \
      --enable-libfdk-aac \
      --enable-nonfree \
      --disable-ffplay
    make -j$(nproc)
    make install      

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

# FFmpeg, jls
COPY --from=build /build/ /build/

# EPGStation
COPY --from=l3tnun/epgstation:debian /app/ /build/app/

# Yarn
COPY --from=jlse_node /opt/ /build/opt/

# Nodejs, npm, jlse
COPY --from=jlse_node /usr/local/ /build/usr/local/


# Final image
FROM library/debian:testing-slim

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
    sed -i -e's/Components: main/Components: main non-free/g' /etc/apt/sources.list.d/debian.sources
    apt-get update -q
    apt-get install -qy --no-install-recommends --no-install-suggests curl ca-certificates
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/add_dmosource_testing.sh | bash
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests \
      aom-tools+ \
      libc6+ \
      libcairo2+ \
      codec2+ \
      dav1d+ \
      libglib2.0-bin+ \
      libgsm-tools+ \
      libjxl-tools+ \
      xz-utils+ \
      libmfx-gen1.2+ \
      lame+ \
      libopenjp2-tools+ \
      opus-tools+ \
      rav1e+ \
      librsvg2-bin+ \
      shineenc+ \
      snappy-tools+ \
      speex+ \
      svt-av1+ \
      libtheora0+ \
      twolame+ \
      vainfo+ \
      vorbis-tools+ \
      vpx-tools+ \
      webp+ \
      libx264-164+ \
      x265+ \
      libxvidcore4+ \
      zvbi+ \
      zlib1g+ \
      alsa-tools+ \
      libavc1394-tools+ \
      libcdio-utils+ \
      libdc1394-utils+ \
      libdrm2+ \
      libgl1+ \
      libiec61883-0+ \
      libjack-jackd2-0+ \
      openal-tools+ \
      pulseaudio-utils+ \
      libraw1394-tools+ \
      libsdl3-0+ \
      libx11-6+ \
      libxcb-shape0+ \
      libxcb-shm0+ \
      libxcb-xfixes0+ \
      libxext6+ \
      libxv1+ \
      libass9+ \
      libbs2b-bin+ \
      flite+ \
      fontconfig+ \
      libfreetype6+ \
      libfribidi-bin+ \
      libharfbuzz-bin+ \
      lilv-utils+ \
      libmfx-gen1.2+ \
      libmysofa-utils+ \
      libplacebo349+ \
      pocketsphinx+ \
      libpostproc58+ \
      librubberband2+ \
      libstdc++6+ \
      libsoxr0+ \
      libvidstab1.1+ \
      libzimg2+ \
      libzmq5+ \
      ocl-icd-libopencl1+ \
      zlib1g+ \
      libatomic1+ \
      libbluray-bin+ \
      bzip2+ \
      libchromaprint1+ \
      libdvdnav4+ \
      libgme0+ \
      gnutls-bin+ \
      openmpt123+ \
      amqp-tools+ \
      rist-tools+ \
      srt-tools+ \
      libssh-4+ \
      libxml2+ \
      vdpauinfo+ \
      ffmsindex+ \
      aac-enc+ \
      nasm+ \
      yasm+ \
      libboost-filesystem-dev+ \
      libboost-program-options-dev+ \
      l-smash+ \
      avisynth++ \
      vapoursynth-l-smash-source+ \
      libvpl-tools+ \
      caca-utils+ \

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