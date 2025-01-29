FROM stu2005/libpcsckai:latest AS pcsckai
FROM alpine:latest AS update
FROM node:18-alpine AS build
COPY --from=pcsckai / /
COPY --from=pcsckai / /build/
COPY --from=update /etc/apk/repositories /etc/apk/repositories
ARG DOCKER=YES NODE_ENV=production
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Build Dependencies
    apk add -U --no-cache \
      gcc \
      g++ \
      cmake \
      ninja \
      pcsc-lite-dev \
      make \
      linux-headers \
      autoconf \
      automake && \
\
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./libaribb25-master.zip && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/build/usr/local -DWITH_PCSC_LIBRARY=pcsckai && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install && \
\
# Build recpt1
    wget -O /recpt1.zip https://github.com/hendecarows/recpt1/archive/refs/heads/feature-px4.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-feature-px4/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install && \
\
# Build Mirakurun
    wget -O /mirakurun.zip https://github.com/Chinachu/Mirakurun/archive/refs/heads/master.zip && \
    cd / && \
    unzip mirakurun.zip && \
    cd Mirakurun-master && \
    npm install --production=false && \
    npm run build && \
    npm install -g --unsafe-perm --production && \
    cd / && \
    mkdir -p /build/app/ && \
    mv /usr/local/lib/node_modules/mirakurun/* /build/app/ && \
    mkdir -p /build/etc/apk/ && \
    cp /etc/apk/repositories /build/etc/apk/repositories
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
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache curl
CMD ["./docker/container-init.sh"]
EXPOSE 40772
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
