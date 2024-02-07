FROM docker.io/l3tnun/epgstation:alpine
ENV TZ="Asia/Tokyo"
VOLUME /app/data/
VOLUME /app/thumbnail/
ENTRYPOINT ["node"]
CMD ["dist/index.js"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1
RUN set -x && \
\
# Install dependencies for Build
    apk add -U --no-cache --virtual .build-deps \
      alpine-sdk \
      autoconf \
      automake \
      pkgconf \
      libtool \
      gawk \
      mawk \
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
      nasm \
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
&& \
# Build libaribb24
    wget -O /aribb24-master.tar.bz2 https://salsa.debian.org/multimedia-team/aribb24/-/archive/master/aribb24-master.tar.bz2 && \
    cd / && \
    tar -jxf ./aribb24-master.tar.bz2 && \
    cd /aribb24-master/ && \
    ./bootstrap && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/usr install && \
    sed -i -e 's#/usr/local#/usr#g' /usr/lib/pkgconfig/aribb24.pc && \
    cd / && \
    rm -rf ./aribb24* && \
\
# Build ffmpeg
    wget -O /ffmpeg-6.0.1.tar.xz https://ffmpeg.org/releases/ffmpeg-6.0.1.tar.xz && \
    tar -Jxf ./ffmpeg-6.0.1.tar.xz && \
    cd /ffmpeg-6.0.1/ && \
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
      --enable-version3 \
      --enable-libaribb24 \
      --enable-nonfree && \
    make -j$(nproc) && \
    make install && \
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
      soxr \
