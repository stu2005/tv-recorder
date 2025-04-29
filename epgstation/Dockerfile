# Build jls
FROM library/node:18.20.8-bookworm-slim AS jls
COPY --from=ghcr.io/tobitti0/docker-avisynthplus:5.1-ubuntu2004 /usr/local/ /build/usr/local/
COPY --from=ghcr.io/tobitti0/docker-avisynthplus:5.1-ubuntu2004 /usr/local/ /usr/local/
COPY --from=lscr.io/linuxserver/ffmpeg:7.1.1 /usr/local/ /build/usr/local/
COPY --from=lscr.io/linuxserver/ffmpeg:7.1.1 /etc/OpenCL/vendors/nvidia.icd /build/etc/OpenCL/vendors/
RUN <<EOF bash -ex

  # Update
    apt-get update -q
    apt-get full-upgrade -qy --no-install-recommends --no-install-suggests

  # Install
    apt-get install -qy --no-install-recommends --no-install-suggests curl git ca-certificates make ninja-build gcc g++ cmake libboost-all-dev
  
  # Build jls
    git clone --recursive https://github.com/tobitti0/JoinLogoScpTrialSetLinux /JoinLogoScpTrialSetLinux
    cd /JoinLogoScpTrialSetLinux/modules/
    cd ./chapter_exe/src/
    make -j$(nproc)
    install -m 755 ./chapter_exe /build/usr/local/bin/
    cd ../../logoframe/src/
    make -j$(nproc)
    install -m 755 ./logoframe /build/usr/local/bin/
    cd ../../join_logo_scp/src/
    make -j$(nproc)
    install -m 755 ./join_logo_scp /build/usr/local/bin/
    cd ../../tsdivider/
    cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release
    cd ./build/
    ninja -j$(nproc)
    install -m 755 ./tsdivider /build/usr/local/bin/
    git clone https://github.com/tobitti0/delogo-AviSynthPlus-Linux /delogo-AviSynthPlus-Linux
    cd /delogo-AviSynthPlus-Linux/src/
    make -j$(nproc)
    install -m 755 ./libdelogo.so /build/usr/local/lib/avisynth/

EOF

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=ghcr.io/tobitti0/docker-avisynthplus:5.1-ubuntu2004 /usr/local/ /build/usr/local/
COPY --from=lscr.io/linuxserver/ffmpeg:7.1.1 /usr/local/ /build/usr/local/
COPY --from=lscr.io/linuxserver/ffmpeg:7.1.1 /etc/OpenCL/vendors/nvidia.icd /build/etc/OpenCL/vendors/
COPY --from=jls /build/ /build/
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
    apt-get full-upgrade -qy --autoremove --purge --no-install-recommends --no-install-suggests git+ ca-certificates+
    cd /
    yarn global add git+https://github.com/tobitti0/join_logo_scp_trial.git
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

  # Clean
    apt-get autoremove --purge -qy git ca-certificates
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EOF