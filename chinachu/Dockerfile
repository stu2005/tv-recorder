FROM docker.io/library/node:14-alpine AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Build Dependencies
    apk add -U --no-cache alpine-sdk python3 git bash && \
\
# Build Chinachu
    git config --global http.version HTTP/1.1 && \
    git clone --recursive https://github.com/stu2005/chinachu /src && \
    mkdir -p /build/ && \
    mv /src/common /src/package*json /build/ && \
    cd /build/ && \
    npm install && \
    npm update && \
    npm audit fix


# Final Image
FROM docker.io/library/alpine:latest AS update_baseImage
FROM docker.io/library/node:14-alpine
COPY --from=update_baseImage /etc/apk/repositories /etc/apk/repositories
COPY --chown=node:node --from=build /src/ /app/
COPY --chown=node:node --from=build /build/ /app/
WORKDIR /app/
VOLUME /app/data/ /app/recorded/
EXPOSE 20772
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache curl ffmpeg bash coreutils procps-ng ca-certificates && \
    npm install pm2 -g && \
    chown -R node:node *
USER node:node
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1