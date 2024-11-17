FROM alpine:latest AS update
FROM node:14-alpine AS build
RUN set -x && \
    apk upgrade -U --no-cache && \
\
# Install Build Dependencies
    apk add -U --no-cache \
      python3 \
      git \
      bash && \
\
# Build Chinachu
    git clone --recursive https://github.com/stu2005/chinachu /build/app/ && \
    cd /build/app/ && \
    npm install && \
    npm update && \
    npm audit fix
COPY --from=update /etc/apk/repositories /build/etc/apk/repositories


# Final Image
FROM node:14-alpine
COPY --chown=node:node --from=build /build/ /
WORKDIR /app/
EXPOSE 20772
RUN apk upgrade -U --no-cache && \
    apk add -U --no-cache \
      curl \
      ffmpeg \
      bash \
      coreutils \
      procps-ng \
      ca-certificates && \
    npm install pm2 -g
USER node:node
ENTRYPOINT ["pm2-runtime"]
CMD ["./processes.json"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1