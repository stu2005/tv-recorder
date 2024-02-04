FROM l3tnun/epgstation:alpine
ENV TZ="Asia/Tokyo"
ARG PKG_CONFIG_PATH="/usr/lib/pkgconfig:/opt/vc/lib/pkgconfig"
ARG LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/opt/vc/lib"
ARG PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vc/bin"
EXPOSE 8888/tcp
VOLUME /app/data/
VOLUME /app/thumbnail/
RUN set -x && \
\
# Install dependencies for Build
    apk add -U --no-cache --virtual .build-deps \
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
      gnutls-dev \
      imlib2-dev \
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
      nasm
      opus-dev \
      perl-dev \
      pulseaudio-dev \
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
    make prefix=/usr install && \
    sed -i -e 's#/usr/local#/usr#g' /usr/lib/pkgconfig/aribb24.pc && \
    cd / && \
    rm -rf ./aribb24 && \
\
# Build userland
    git clone https://github.com/stu2005/userland /userland && \
    cd /userland && \
    ./buildme && \
    cd / && \
    rm -rf ./userland && \
\
# Build ffmpeg
    wget https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar -jxvf ./ffmpeg-snapshot.tar.bz2 && \
    cd ./ffmpeg/ && \
    ./configure \
      --prefix=/usr \
      --disable-librtmp \
      --disable-lzma \
      --disable-static \
      --disable-stripping \
      --disable-debug \
      --disable-doc \
      --enable-avfilter \
      --enable-gnutls \
      --enable-gpl \
      --enable-libaom \
      --enable-libass \
      --enable-libbluray \
      --enable-libdav1d \
      --enable-libdrm \
      --enable-libfontconfig \
      --enable-libfreetype \
      --enable-libfribidi \
      --enable-libmp3lame \
      --enable-libopenmpt \
      --enable-libopus \
      --enable-libplacebo \
      --enable-libpulse \
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
      --enable-lto \
      --enable-pic \
      --enable-postproc \
      --enable-pthreads \
      --enable-shared \
      --enable-vaapi \
      --enable-vdpau \
      --enable-vulkan \
      --optflags=-O3 \
      --enable-libjxl \
      --enable-omx \
      --enable-omx-rpi \
      --enable-mmal \
      --enable-version3 \
      --enable-libaribb24 \
      --enable-nonfree && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/ && \
    cd / && \
    rm -rf ./ffmpeg* && \
\
\
# Final Image
    apk del --purge .build-deps && \
    apk add -U --no-cache \
      sdl2 \
      aom-libs \
      lame-libs \
      libdav1d \
      libjxl \
      libtheora \
      libva \
      libvorbis \
      libvpx \
      libwebp \
      opus \
      x264-libs \
      x265-libs \
      xvidcore \
      zlib \
      alsa-lib \
      libdrm \
      libpulse \
      libxcb \
      v4l-utils-libs \
      fontconfig \
      freetype \
      fribidi \
      libass \
      libopenmpt \
      libplacebo \
      libzmq \
      vidstab \
      zimg \
      gnutls \
      libbluray \
      libbz2 \
      libopenmpt \
      librist \
      libsrt \
      libssh \
      libxml2 \
      libvdpau \
      libx11 \
      soxr
