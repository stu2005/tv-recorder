FROM alpine:latest AS build
ARG PKG_CONFIG_PATH="/usr/lib/pkgconfig:/opt/vc/lib/pkgconfig"
ARG LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/opt/vc/lib"
ARG PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vc/bin"
RUN set -x && \
\
# Install dependencies for Build
    apk add -U --no-cache \
      git \
      autoconf \
      automake \
      pkgconf \
      libtool \
      gawk \
      mawk \
      nawk \
      make \
      gcc \
      clang \
      libjxl-dev \
      alsa-lib-dev \
      aom-dev \
      bzip2-dev \
      coreutils \
      dav1d-dev \
      fontconfig-dev \
      freetype-dev \
      fribidi-dev \
      harfbuzz-dev \
      imlib2-dev \
      ladspa-dev \
      lame-dev \
      libass-dev \
      libbluray-dev \
      libdrm-dev \
      libopenmpt-dev \
      libplacebo-dev \
      librist-dev \
      libsrt-dev \
      libssh-dev \
      libtheora-dev \
      libva-dev \
      libvdpau-dev \
      libvorbis-dev \
      libvpx-dev \
      libwebp-dev \
      libxfixes-dev \
      libxml2-dev \
      lilv-dev \
      nasm \
      openssl-dev \
      opus-dev \
      perl-dev \
      pulseaudio-dev \
      rav1e-dev \
      sdl2-dev \
      soxr-dev \
      v4l-utils-dev \
      vidstab-dev \
      vulkan-loader-dev \
      x264-dev \
      x265-dev \
      xvidcore-dev \
      zeromq-dev \
      zimg-dev \
      zlib-dev \
      raspberrypi-libs \
      bash \
      cmake \
      ninja \
      sudo \
&& \
# Build libaribb24
    git clone https://salsa.debian.org/multimedia-team/aribb24.git /aribb24 && \
    cd /aribb24 && \
    ./bootstrap && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr install && \
    make prefix=/usr install && \
    sed -i -e 's#/usr/local#/usr#g' /build/usr/lib/pkgconfig/aribb24.pc && \
    sed -i -e 's#/usr/local#/usr#g' /usr/lib/pkgconfig/aribb24.pc && \
\
# Build userland
    git clone https://github.com/stu2005/userland /userland && \
    cd /userland && \
    ./buildme && \
\
# Build ffmpeg
    cd / && \
    wget https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar -jxvf ./ffmpeg-snapshot.tar.bz2 && \
    cd ./ffmpeg/ && \
    ./configure \
      --prefix=/usr \
      --disable-librtmp \
      --disable-lzma \
      --disable-static \
      --disable-stripping \
      --disable-shared \
      --disable-debug \
      --disable-doc \
      --enable-avfilter \
      --enable-gpl \
      --enable-ladspa \
      --enable-libaom \
      --enable-libass \
      --enable-libbluray \
      --enable-libdav1d \
      --enable-libdrm \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libharfbuzz \
      --enable-libmp3lame \
      --enable-libopenmpt \
      --enable-libopus \
      --enable-libplacebo \
      --enable-libpulse \
      --enable-librav1e \
      --enable-librist \
      --enable-libsoxr \
      --enable-libsrt \
      --enable-libssh \
      --enable-libtheora \
      --enable-libv4l2 \
      --enable-libvidstab \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libwebp \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libxcb \
      --enable-libxml2 \
      --enable-libxvid \
      --enable-libzimg \
      --enable-libzmq \
      --enable-lto=auto \
      --enable-lv2 \
      --enable-openssl \
      --enable-pic \
      --enable-postproc \
      --enable-pthreads \
      --enable-shared \
      --enable-vaapi \
      --enable-vdpau \
      --enable-version3 \
      --enable-vulkan \
      --optflags=-O3 \
      --enable-libjxl \
      --enable-omx \
      --enable-omx-rpi \
      --enable-mmal \
      --enable-libaribb24 \
      --enable-nonfree && \
    make -j$(nproc)

# Final Image
FROM l3tnun/epgstation:alpine
COPY --from=build /ffmpeg/ /ffmpeg/
COPY --from=build /build/ /
RUN apk add -U --no-cache \
      aom-libs \
      lame-libs \
      libdav1d \
      libjxl \
      libtheora \
      libva \
      liborbis \
      libvpx \
      libwebp \
      libwebpmux \
      opus \
      rav1e-libs \
      x264-libs \
      x265-libs \
      xvidcore \
      alsa-lib \
      libdrm \
      libpulse \
      libxcb \
      sdl2 \
      v4l-utils-libs \
      fontconfig \
      freetype \
      frbidi \
      harfbuzz \
      libass \
      libplacebo \
      libzmq \
      libv-libs \
      vidstab \
      zimg \
      zlib \
      libbluray \
      libbz2 \
      libcrypto3 \
      libopenmpt \
      librist \
      libsrt \
      libssh \
      libssl3 \
      libxml2 \
      libzmq \
      libvdpau \
      libx11 \
      soxr \
      make && \
    cd /ffmpeg/ && \
    make install && \
    apk del --purge make && \
    rm -rf /ffmpeg/
