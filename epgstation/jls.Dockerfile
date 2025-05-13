# Build jls
FROM library/ubuntu:20.04 AS build
ARG DEBIAN_FRONTEND=noninteractive
COPY --from=ghcr.io/tobitti0/docker-avisynthplus:5.1-ubuntu2004 /usr/local/ /usr/local/
RUN <<EOF bash -ex

  # Update
    apt-get update -q
    apt-get upgrade -qy --no-install-recommends --no-install-suggests \
      curl+ \
      git+ \
      ca-certificates+ \
      build-essential+ \
      make+ \
      ninja-build+ \
      gcc+ \
      g+++ \
      cmake+ \
      libboost-all-dev+

EOF
RUN <<EOF bash -ex

  # Build jls
    git clone --recursive https://github.com/tobitti0/JoinLogoScpTrialSetLinux /JoinLogoScpTrialSetLinux
    cd /JoinLogoScpTrialSetLinux/modules/
    cd ./chapter_exe/src/
#    sed -i '/^\s*#ifndef\s\+__COMPAT__/a #include <cstdint>' compat.h
#    sed -i '/^\s*#ifndef\s\+__INPUT_H__/a #include <cstdint>' input.h
    make -j$(nproc)
    install -m 755 ./chapter_exe /JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin/
    cd ../../logoframe/src/
    make -j$(nproc)
    install -m 755 ./logoframe /JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin/
    cd ../../join_logo_scp/src/
    make -j$(nproc)
    install -m 755 ./join_logo_scp /JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin/
    cd ../../tsdivider/
    cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release
    cd ./build/
    ninja -j$(nproc)
    install -m 755 ./tsdivider /JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial/bin/
    mkdir -p /build/
    cp -r /JoinLogoScpTrialSetLinux/modules/join_logo_scp_trial /build/jls
    git clone https://github.com/tobitti0/delogo-AviSynthPlus-Linux /delogo-AviSynthPlus-Linux
    cd /delogo-AviSynthPlus-Linux/src/
    make -j$(nproc)
    mkdir -p /build/usr/local/lib/avisynth/
    install -m 755 ./libdelogo.so /build/usr/local/lib/avisynth/
    

EOF

# Get nodejs and epgstation
FROM scratch AS downloads
COPY --from=ghcr.io/tobitti0/docker-avisynthplus:5.1-ubuntu2004 /usr/local/ /build/usr/local/
COPY --from=build /build/ /build/
COPY --from=library/node:18.20.8-bookworm-slim /usr/local/ /build/usr/local/
COPY --from=library/node:18.20.8-bookworm-slim /opt/ /build/opt/
COPY --from=l3tnun/epgstation:v2.10.0-debian /app/ /build/app/


# Final image
FROM library/ubuntu:20.04

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
      ca-certificates+ \
      libboost-program-options1.71.0+ \
      libboost-filesystem1.71.0+ \
      curl+ \
      v4l-utils+
    cd /jls/
    yarn install
    yarn link
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_qsvencc_20.04.sh | bash
    curl -Ls https://raw.githubusercontent.com/stu2005/tv-recorder/refs/heads/main/epgstation/get_vceencc_20.04.sh | bash      
    apt-get install -qy \
      --no-install-recommends --no-install-suggests \
        /qsvencc.deb \
        /vceencc.deb \
      --autoremove --purge \
        curl- \
        ca-certificates-
    qsvencc -v
    vceencc -v
    node -v
    ffmpeg -version
    /jls/bin/chapter_exe || true
    /jls/bin/logoframe || true
    /jls/bin/join_logo_scp || true
    /jls/bin/tsdivider --version
    jlse --version
    apt-get clean -q
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  /*.deb /rocm.gpg /etc/apt/sources.list.d/amdgpu.sources

EOF