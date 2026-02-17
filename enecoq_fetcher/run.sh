#!/usr/bin/with-contenv bashio
set -euo pipefail

EMAIL="$(bashio::config 'email')"
PASSWORD="$(bashio::config 'password')"
INTERVAL_MIN="$(bashio::config 'interval_minutes')"
JITTER_SEC="$(bashio::config 'jitter_seconds')"
OUT_DIR="$(bashio::config 'out_dir')"
LOG_LEVEL="$(bashio::config 'log_level')"

mkdir -p "$OUT_DIR"

bashio::log.info "Starting enecoQ fetcher: interval=${INTERVAL_MIN}m jitter<=${JITTER_SEC}s out_dir=${OUT_DIR}"

while true; do
  # jitter to spread load
  if [ "$JITTER_SEC" -gt 0 ]; then
    SLEEP_SEC=$(( RANDOM % (JITTER_SEC + 1) ))
    bashio::log.info "Jitter sleep ${SLEEP_SEC}s"
    sleep "$SLEEP_SEC"
  fi

  TS="$(date -Iseconds)"
  TODAY_FILE="${OUT_DIR}/enecoq_today.json"
  MONTH_FILE="${OUT_DIR}/enecoq_month.json"

  bashio::log.info "[$TS] Fetching period=today -> ${TODAY_FILE}"
  enecoq-data-fetcher \
    --email "$EMAIL" --password "$PASSWORD" \
    --period today --format json \
    --output "$TODAY_FILE" \
    --log-level "$LOG_LEVEL" || bashio::log.error "Fetch today failed"

  bashio::log.info "[$TS] Fetching period=month -> ${MONTH_FILE}"
  enecoq-data-fetcher \
    --email "$EMAIL" --password "$PASSWORD" \
    --period month --format json \
    --output "$MONTH_FILE" \
    --log-level "$LOG_LEVEL" || bashio::log.error "Fetch month failed"

  bashio::log.info "Sleeping ${INTERVAL_MIN} minutes"
  sleep "$(( INTERVAL_MIN * 60 ))"
done
