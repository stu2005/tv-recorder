FROM ghcr.io/stu2005/libpcsckai:debian AS libpcsckai
FROM mirror.gcr.io/chinachu/mirakurun:latest AS mirakurun
FROM public.ecr.aws/docker/library/rust:latest AS build
COPY --from=libpcsckai / /
COPY --from=libpcsckai / /build/
COPY --from=mirakurun /app/ /build/app/
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
    cd /build/app/docker/ && \
    rm -rf container-init.sh && \
    curl -OL https://gist.githubusercontent.com/stu2005/750f11ea953cf4ad33478e9830099278/raw/9f472fd7f99378a801e4f6eab3f6172f0daa6460/container-init.sh && \
    chmod +x ./container-init.sh && \
    mkdir -p /build/etc/apt/ && \
    cp -r /etc/apt/ /build/etc/apt/


# Final Image
FROM public.ecr.aws/docker/library/node:18-slim
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
RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
CMD ["./docker/container-init.sh"]
EXPOSE 40772
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:40772/api/status || exit 1
