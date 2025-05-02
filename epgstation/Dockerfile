# Build jls
FROM library/ubuntu:24.04 AS build
RUN <<EOF bash -ex

  # Update
    sed -i -e's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/ubuntu.sources
    apt-get update -q
    apt-get upgrade -qy --no-install-recommends --no-install-suggests \
      curl+ \
      git+ \
      ca-certificates+ \
      build-essential+ \
      make+ \
      meson+ \
      ninja-build+ \
      gcc+ \
      g+++ \
      cmake+ \
      libboost-all-dev+ \
      libdevil-dev+ \
      libsoundtouch-dev+ \
      libavcodec-dev+ \
      libavformat-dev+ \
      libswscale-dev+ \
      libxxhash-dev+ \
      pkg-config+ \
      nasm+ \
      libaom-dev+ \
      libass-dev+ \
      libdav1d-dev+ \
      libfdk-aac-dev+ \
      libvpl-dev+ \
      libmp3lame-dev+ \
      libopenjp2-7-dev+ \
      libopus-dev+ \
      libplacebo-dev+ \
      libshaderc-dev+ \
      libv4l-dev+
      
EOF
RUN <<EOF bash -ex

    apt-get build-dep -qy --no-install-recommends --no-install-suggests \
      ffmpeg

EOF
RUN <<EOF bash -ex

  # Build AviSynth+
    git clone https://github.com/AviSynth/AviSynthPlus /avisynth+
    cd /avisynth+/
    cmake -Bbuild -GNinja
    cd ./build/
    ninja -j$(nproc)
    ninja install
    ldconfig

EOF
RUN <<EOF bash -ex

  # Build l-smash
    git clone https://github.com/l-smash/l-smash /l-smash
    cd /l-smash/
    ./configure --prefix="/usr/local" --enable-shared
    make -j$(nproc)
    make install

EOF
RUN <<EOF bash -ex

  # Build l-smash-works
    git clone https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works.git /lsmashworks
    cd /lsmashworks/AviSynth
    LDFLAGS="-Wl,-Bsymbolic" meson build
    cd build
    ninja -j$(nproc)
    ninja install

EOF
RUN <<EOF bash -ex

  # Build FFmpeg
    curl -Lso/ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 &&
    tar -jxf /ffmpeg.tar.bz2 &&
    cd /ffmpeg/
    ./configure \
      --prefix=/usr/local/ \
      --disable-debug \
      --disable-doc \
      --disable-ffplay \
      --enable-alsa \
      --enable-cuda-llvm \
      --enable-cuvid \
      --enable-ffprobe \
      --enable-gpl \
      --enable-libaom \
      --enable-libass \
      --enable-libdav1d \
      --enable-libfdk_aac \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libharfbuzz \
      --enable-libmp3lame \
      --enable-libopenjpeg \
      --enable-libopus \
      --enable-libplacebo \
      --enable-librav1e \
      --enable-librist \
      --enable-libshaderc \
      --enable-libsrt \
      --enable-libsvtav1 \
      --enable-libtheora \
      --enable-libv4l2 \
      --enable-libvidstab \
      --enable-libvorbis \
      --enable-libvpl \
      --enable-libvpx \
      --enable-libwebp \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libxml2 \
      --enable-libxvid \
      --enable-libzimg \
      --enable-libzmq \
      --enable-nonfree \
      --enable-nvdec \
      --enable-nvenc \
      --enable-opencl \
      --enable-openssl \
      --enable-stripping \
      --enable-vaapi \
      --enable-vdpau \
      --enable-version3 \
      --enable-avisynth
    make -j$(nproc)
    make install
 
EOF
RUN <<EOF bash -ex

  # Build jls
    git clone --recursive https://github.com/tobitti0/JoinLogoScpTrialSetLinux /JoinLogoScpTrialSetLinux
    cd /JoinLogoScpTrialSetLinux/modules/
    cd ./chapter_exe/src/
    sed -i '/^\s*#ifndef\s\+__COMPAT__/a #include <cstdint>' compat.h
    sed -i '/^\s*#ifndef\s\+__INPUT_H__/a #include <cstdint>' input.h
    make -j$(nproc)
    install -m 755 ./chapter_exe /usr/local/bin/
    cd ../../logoframe/src/
    make -j$(nproc)
    install -m 755 ./logoframe /usr/local/bin/
    cd ../../join_logo_scp/src/
    make -j$(nproc)
    install -m 755 ./join_logo_scp /usr/local/bin/
    cd ../../tsdivider/
    cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release
    cd ./build/
    ninja -j$(nproc)
    install -m 755 ./tsdivider /usr/local/bin/
    git clone https://github.com/tobitti0/delogo-AviSynthPlus-Linux /delogo-AviSynthPlus-Linux
    cd /delogo-AviSynthPlus-Linux/src/
    make -j$(nproc)
    install -m 755 ./libdelogo.so /usr/local/lib/avisynth/

EOF

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=build /usr/local/ /build/usr/local/
COPY --from=library/node:18.20.8-bookworm-slim /usr/local/ /build/usr/local/
COPY --from=library/node:18.20.8-bookworm-slim /opt/ /build/opt/
COPY --from=l3tnun/epgstation:v2.10.0-debian /app/ /build/app/

# Final image
FROM nvidia/cuda:12.8.1-base-ubuntu24.04

# Set the working directory
WORKDIR /app/

# Open port
EXPOSE 8888

# Set environments
ENV TZ="Asia/Tokyo"
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
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
      git+ \
      ca-certificates+ \
      libsoundtouch1+ \
      libdevil1c2+ \
      libboost-program-options1.83.0+ \
      libboost-filesystem1.83.0+ \
      libaom3+ \
      libdrm2+ \
      libva-drm2+ \
      libva-x11-2+ \
      libva2+ \
      libvdpau1+ \
      libvpl2+ \
      libx11-6+ \
      ocl-icd-libopencl1+ \
      libcairo2+ \
      libcodec2-1.2+ \
      libdav1d7+ \
      libglib2.0-0t64+ \
      libgsm1+ \
      libjxl0.7+ \
      liblzma5+ \
      libmp3lame0+ \
      libopenjp2-7+ \
      libopus0+ \
      librav1e0+ \
      librsvg2-2+ \
      libshine3+ \
      libsnappy1v5+ \
      libspeex1+ \
      libsvtav1enc1d1+ \
      libtheora0+ \
      libtwolame0+ \
      libvorbis0a+ \
      libvorbisenc2+ \
      libvpl2+ \
      libvpx9+ \
      libwebp7+ \
      libwebpmux3+ \
      libx264-164+ \
      libx265-199+ \
      libxvidcore4+ \
      libzvbi0t64+ \
      zlib1g+ \
      libasound2t64+ \
      libavc1394-0+ \
      libass9+ \
      libbluray2+ \
      libbz2-1.0+ \
      libchromaprint1+ \
      libgme0+ \
      libgnutls30t64+ \
      libopenmpt0t64+ \
      librabbitmq4+ \
      librist4+ \
      libsrt1.5-gnutls+ \
      libssh-gcrypt-4+ \
      libxml2+ \
      libzmq5+ \
      libbs2b0+ \
      libflite1+ \
      libfontconfig1+ \
      libfreetype6+ \
      libfribidi0+ \
      libharfbuzz0b+ \
      liblilv-0-0+ \
      libmysofa1+ \
      libplacebo338+ \
      libpocketsphinx3+ \
      librubberband2+ \
      libsphinxbase3t64+ \
      libstdc++6+ \
      libvidstab1.1+ \
      libzimg2+ \
      libcaca0+ \
      libcdio-cdda2t64+ \
      libcdio-paranoia2t64+ \
      libdc1394-25+ \
      libgl1+ \
      libiec61883-0+ \
      libjack-jackd2-0+ \
      libopenal1+ \
      libpulse0+ \
      libraw1394-11+ \
      libsdl2-2.0-0+ \
      libxcb-shape0+ \
      libxcb-shm0+ \
      libxcb-xfixes0+ \
      libxcb1+ \
      libxext6+ \
      libxv1+ \
      libfdk-aac2+
    cd /
    yarn global add git+https://github.com/tobitti0/join_logo_scp_trial.git
    ln -s /usr/local/bin/chapter_exe /usr/local/share/.config/yarn/global/node_modules/join_logo_scp_trial/bin/chapter_exe
    ln -s /usr/local/bin/logoframe /usr/local/share/.config/yarn/global/node_modules/join_logo_scp_trial/bin/logoframe
    ln -s /usr/local/bin/join_logo_scp /usr/local/share/.config/yarn/global/node_modules/join_logo_scp_trial/bin/join_logo_scp
    ln -s /usr/local/bin/tsdivider /usr/local/share/.config/yarn/global/node_modules/join_logo_scp_trial/bin/tsdivider
    if [[ "$(uname -m)" == "x86_64" ]]; then
      apt-get install -qy --no-install-recommends --no-install-suggests curl ca-certificates libnvidia-compute-570 v4l-utils
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc.sh | bash
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_vceencc.sh | bash      
      curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_nvencc.sh | bash
      apt-get install -qy --no-install-recommends --no-install-suggests /qsvencc.deb /vceencc.deb /nvencc.deb --autoremove --purge curl- ca-certificates-
      qsvencc -v
      vceencc -v
      nvencc -v
      rm -rf /*.deb /rocm.gpg /etc/apt/sources.list.d/amdgpu.sources
    fi

  # Test
    node -v
    ffmpeg -version
    chapter_exe || true
    logoframe || true
    join_logo_scp || true
    tsdivider --version
    jlse --version

  # Clean
    apt-get autoremove --purge -qy git ca-certificates
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EOF