FROM ghcr.io/stu2005/libpcsckai:latest AS pcsckai
FROM node:18-alpine AS build
COPY --from=pcsckai / /
COPY --from=pcsckai / /build/
ARG DOCKER=YES NODE_ENV=production
RUN set -x && \
    apk add -U --no-cache \
      alpine-sdk \
      cmake \
      ninja-build \
      samurai \
      pcsc-lite-dev \
      autoconf \
      automake \
      linux-headers && \
\
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip -qq ./libaribb25-master.zip > /dev/null && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local -DWITH_PCSC_LIBRARY=pcsckai -DWITH_PCSC_PACKAGE=NO && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install && \
\
# Build recpt1
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip && \
    cd / && \
    unzip -qq ./recpt1.zip && \
    cd /recpt1-feature-px4/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install && \
\
# Build Mirakurun
    wget -O /mirakurun.zip https://github.com/Chinachu/Mirakurun/archive/refs/heads/master.zip && \
    cd / && \
    unzip -qq mirakurun.zip && \
    cd Mirakurun-master && \
    npm install --production=false && \
    npm run build && \
    npm install -g --unsafe-perm --production && \
    cd / && \
    mkdir -p /build/app/ && \
    mv /usr/local/lib/node_modules/mirakurun/* /build/app/
COPY ./container-init.sh /build/app/docker/container-init.sh


# Final Image
FROM node:18-alpine
WORKDIR /app/
ENV SERVER_CONFIG_PATH=/app-config/server.yml 
ENV TUNERS_CONFIG_PATH=/app-config/tuners.yml 
ENV CHANNELS_CONFIG_PATH=/app-config/channels.yml 
ENV SERVICES_DB_PATH=/app-data/services.json 
ENV PROGRAMS_DB_PATH=/app-data/programs.json 
ENV LOGO_DATA_DIR_PATH=/app-data/logo-data 
ENV PATH=/opt/bin:$PATH 
ENV DOCKER=YES 
ENV INIT_PID=$$ 
ENV MALLOC_ARENA_MAX=2 
ENV TZ=Asia/Tokyo
VOLUME /var/run/ /opt/ /app-config/ /app-data/
COPY --from=build /build/ /
RUN apk add -U --no-cache curl
CMD ["./docker/container-init.sh"]
EXPOSE 40772
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
