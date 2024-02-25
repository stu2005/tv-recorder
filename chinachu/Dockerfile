FROM docker.io/library/node:14-alpine AS build
FROM docker.io/alpine:latest AS update_baseImage
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
COPY --from=update_baseImage / /
COPY --from=build /src/chinachu/ /app/
COPY --from=build /build/chinachu/ /app/
WORKDIR /app/
VOLUME /app/data/ /app/recorded/ /sys/fs/cgroup/
EXPOSE 20772
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache curl ffmpeg bash && \
    npm install pm2 -g && \
    ln -s /var/run/chinachu-wui-0.pid /var/run/chinachu-wui.pid && \
    ln -s /var/run/chinachu-operator-1.pid /var/run/chinachu-operator.pid
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1