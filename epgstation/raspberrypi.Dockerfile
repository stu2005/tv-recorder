FROM alpine:latest AS update
FROM l3tnun/epgstation:alpine AS epgstation
COPY --from=update /etc/apk/repositories /etc/apk/repositories
RUN set -x && \
    mkdir -p /build/etc/apk/ && \
    cp /etc/apk/repositories /build/etc/apk/repositories && \
    mv /app/ /build/app/
FROM node:18-alpine
COPY --from=epgstation /build/ /
WORKDIR /app/
EXPOSE 8888
ENV TZ="Asia/Tokyo" LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/opt/vc/lib"
ARG PKG_CONFIG_PATH="/usr/lib/pkgconfig:/opt/vc/lib/pkgconfig" PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vc/bin"
VOLUME /app/data/ /app/thumbnail/
ENTRYPOINT ["node"]
CMD ["dist/index.js"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1
RUN apk upgrade -U --no-cache && \
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
      x264-dev \
      x265-dev \
      xvidcore-dev \
      zeromq-dev \
      zimg-dev \
      zlib-dev \
      raspberrypi-userland-dev && \
\
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
    wget -O /ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar -jxf ./ffmpeg-snapshot.tar.bz2 && \
    cd /ffmpeg/ && \
    ./configure \
      --prefix=/usr \
      --disable-librtmp \
      --disable-lzma \
      --disable-static \
      --disable-stripping \
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
    cd / && \
    rm -rf ./ffmpeg* && \
\
\
# Final Image
    apk del --purge .build-deps && \
    apk add -U --no-cache \
      curl \
      aom-libs \
      lame-libs \
      libdav1d \
      libjxl \
      libtheora \
      libva \
      libvorbis \
      libvpx \
      libwebp \
      libwebpmux \
      opus \
      rav1e-libs \
      x264-libs \
      x265-libs \
      xvidcore \
      zlib \
      alsa-lib \
      libdrm \
      libpulse \
      libxcb \
      sdl2 \
      v4l-utils-libs \
      fontconfig \
      freetype \
      fribidi \
      harfbuzz \
      libass \
      libplacebo \
      libva \
      libzmq \
      lilv-libs \
      vidstab \
      zimg \
      libbluray \
      libbz2 \
      libcrypto3 \
      libopenmpt \
      librist \
      libssh \
      libssl3 \
      libxml2 \
      libzmq \
      libvdpau \
      libx11 \
      soxr \
      raspberrypi-userland-libs
