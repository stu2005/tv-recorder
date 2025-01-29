FROM alpine:latest AS update
FROM l3tnun/epgstation:alpine
COPY --from=update / /
RUN apk add -U --no-cache ffmpeg
ENV TZ="Asia/Tokyo"
VOLUME /app/data/ /app/thumbnail/
ENTRYPOINT ["node"]
CMD ["dist/index.js"]
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -fsSL http://localhost:8888/api/status || exit 1