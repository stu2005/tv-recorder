FROM node:14-alpine AS build
RUN set -x && \
\
# Install Build Dependencies
    apk add -U --no-cache alpine-sdk git python3 && \
\
# Build Chinachu
    git config --global http.version HTTP/1.1 && \
    git clone --recursive https://github.com/stu2005/chinachu /src/chinachu && \
    mkdir -p /build/chinachu/ && \
    mv /src/chinachu/common /src/chinachu/package*json /build/chinachu/ && \
    cd /build/chinachu/ && \
    npm install && \
    npm audit fix --force


# Final Image
FROM node:14-alpine
COPY --from=build /src/chinachu/ /app/
COPY --from=build /build/chinachu/ /app/
WORKDIR /app/
VOLUME /app/data/ /app/recorded/
EXPOSE 20772
RUN apk add -U --no-cache curl ffmpeg && \
    npm install pm2 -g
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:20772/api/status || exit 1
