#!/usr/bin/env ash

# rename wrong filename (migration from <= 3.1.1 >= 3.0.0)
if [ -f "/app-data/services.yml" -a ! -f "$SERVICES_DB_PATH" ]; then
  cp -v "/app-data/services.yml" "$SERVICES_DB_PATH"
fi
if [ -f "/app-data/programs.yml" -a ! -f "$PROGRAMS_DB_PATH" ]; then
  cp -v "/app-data/programs.yml" "$PROGRAMS_DB_PATH"
fi

function start() {
  if [ "$DEBUG" != "true" ]; then
    pcscd
    export NODE_ENV=production
    node -r source-map-support/register lib/server.js &
  else
    npm run debug &
  fi

  wait
}

function restart() {
  echo "restarting... $(jobs -p)"
  kill $(jobs -p) > /dev/null 2>&1 || echo "already killed."
  sleep 1
  start
}
trap restart 1

start