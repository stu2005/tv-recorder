FROM docker.io/library/alpine:latest AS update_baseImage
FROM docker.io/library/node:14-alpine AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Build Dependencies
    apk add -U --no-cache alpine-sdk python3 git bash && \
\
# Build Chinachu
    git config --global http.version HTTP/1.1 && \
    git clone --recursive https://github.com/stu2005/chinachu /src/chinachu && \
    mkdir -p /build/chinachu/ && \
    mv /src/chinachu/common /src/chinachu/package*json /build/chinachu/ && \
    cd /build/chinachu/ && \
    npm install && \
    npm update


# Final Image
FROM docker.io/library/node:14-alpine
ENV container=docker
COPY --from=update_baseImage / /
COPY --from=build /src/chinachu/ /app/
COPY --from=build /build/chinachu/ /app/
WORKDIR /app/
VOLUME /app/data/ /app/recorded/ /sys/fs/cgroup/
EXPOSE 20772
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache curl ffmpeg bash openrc && \
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab && \
    sed -i \
      -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
      -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
      -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
      -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
      -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
      /etc/rc.conf && \
    rm -f /etc/init.d/hwdrivers \
      /etc/init.d/hwclock \
      /etc/init.d/hwdrivers \
      /etc/init.d/modules \
      /etc/init.d/modules-load \
      /etc/init.d/modloop && \
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh && \
    ./chinachu service operator initscript > /etc/init.d/chinachu-operator && \
    ./chinachu service wui initscript > /etc/init.d/chinachu-wui && \
    rc-update add chinachu-operator && \
    rc-update add chinachu-wui
CMD ["/sbin/init"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1