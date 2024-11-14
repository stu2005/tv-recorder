FROM docker.io/stu2005/libpcsckai:latest AS libpcsckai
FROM docker.io/library/node:18-alpine AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
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
&& \
# Build libaribb25
    wget -O /libaribb25-master.zip https://github.com/tsukumijima/libaribb25/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./libaribb25-master.zip && \
    cd /libaribb25-master/ && \
    cmake -GNinja -Bbuild -DWITH_PCSC_LIBRARY=pcsckai -DCMAKE_INSTALL_PREFIX=/build/usr/local && \
    cd build && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb25.pc && \
    sed -i -e 's#/build/usr/local#/usr/local#g' libaribb1.pc && \
    ninja -j$(nproc) && \
    ninja install 
&& \
# Build recpt1
    wget -O /recpt1.zip https://github.com/stz2012/recpt1/archive/refs/heads/master.zip && \
    cd / && \
    unzip ./recpt1.zip && \
    cd /recpt1-master/recpt1/ && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make prefix=/build/usr/local install 
&& \
# Build Mirakurun
    wget -O /mirakurun-master.zip https://github.com/Chinachu/Mirakurun/archive/refs/heads/master.zip && \
    cd / && \
    unzip mirakurun-master.zip && \
    cd Mirakurun-master && \
    npm install --production=false && \
    npm run build && \
    npm install -g --unsafe-perm --production && \
    cd /usr/local/lib/node_modules/mirakurun/docker/ && \
    rm -rf container-init.sh && \
    wget https://gist.githubusercontent.com/stu2005/750f11ea953cf4ad33478e9830099278/raw/9f472fd7f99378a801e4f6eab3f6172f0daa6460/container-init.sh && \
    chmod +x ./container-init.sh


# Final Image
FROM docker.io/library/node:18-alpine
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
COPY --from=build /usr/local/lib/node_modules/mirakurun/ /app/
COPY --from=build /build/ /
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache curl
CMD ["./docker/container-init.sh"]
EXPOSE 40772
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
