FROM chinachu/mirakurun:latest AS mirakurun
FROM rust:latest AS build
COPY --from=mirakurun /app/ /build/app/
COPY ./container-init-debian.sh /build/app/docker/container-init.sh
ARG DEBIAN_FRONTEND=noninteractive
RUN set -x && \
    apt-get update && \
    apt-get full-upgrade -y && \
\
# Install Build Dependencies
    apt-get install -y --no-install-recommends \
      curl \
      cmake \
      git \
      libclang-dev \
      libdvbv5-dev \
      libudev-dev \
      pkg-config \
      libpcsclite-dev && \
\
# Build recisdb
    git clone --recursive https://github.com/stu2005/recisdb-rs /recisdb/ && \
    cd /recisdb/ && \
    cargo build -F dvb --release && \
    mkdir -p /build/usr/local/bin/ && \
    install -m 755 target/release/recisdb /build/usr/local/bin/ && \
    mkdir -p /build/etc/apt/ && \
    cp -r /etc/apt/ /build/etc/apt/


# Final Image
FROM node:18-slim
WORKDIR /app/
ARG DEBIAN_FRONTEND=noninteractive
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
RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
      curl \
      libdvbv5-0 \
      libpcsclite1 \
      pcscd \
      libccid && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
CMD ["./docker/container-init.sh"]
EXPOSE 40772
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1