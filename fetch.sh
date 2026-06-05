#!/usr/bin/env bash
set -e

BASE_URL="https://api.hpc.tools/v2/public/fts"
ENDPOINT="${ENDPOINT:-flow}"
DATE=$(date -u +%Y-%m-%d)

# Build query string from inputs
PARAMS=""
[ -n "$YEAR" ]      && PARAMS="${PARAMS}&year=${YEAR}"
[ -n "$COUNTRY" ]   && PARAMS="${PARAMS}&locationISOCode=${COUNTRY}"
[ -n "$ORG" ]       && PARAMS="${PARAMS}&organizationAbbrev=${ORG}"
[ -n "$EMERGENCY" ] && PARAMS="${PARAMS}&emergencyId=${EMERGENCY}"
[ -n "$PLAN" ]      && PARAMS="${PARAMS}&planId=${PLAN}"
PARAMS="${PARAMS#&}"  # strip leading &

# Build a human-readable folder name from the params used
SLUG="${ENDPOINT}"
[ -n "$YEAR" ]      && SLUG="${SLUG}_${YEAR}"
[ -n "$COUNTRY" ]   && SLUG="${SLUG}_${COUNTRY}"
[ -n "$ORG" ]       && SLUG="${SLUG}_${ORG}"
[ -n "$EMERGENCY" ] && SLUG="${SLUG}_emergency${EMERGENCY}"
[ -n "$PLAN" ]      && SLUG="${SLUG}_plan${PLAN}"
SLUG=$(echo "$SLUG" | tr '[:upper:]' '[:lower:]')

# Output path: data/{slug}/{date}.{format}
OUT_DIR="data/${SLUG}"
mkdir -p "$OUT_DIR"
OUT_FILE="${OUT_DIR}/${DATE}.${FORMAT}"

# Build full URL
QUERY_URL="${BASE_URL}/${ENDPOINT}"
[ -n "$PARAMS" ] && QUERY_URL="${QUERY_URL}?${PARAMS}"

echo "Fetching: ${QUERY_URL}"
echo "Saving to: ${OUT_FILE}"

#-u "${FTS_CLIENT_ID}:${FTS_PASSWORD}" \
HTTP_STATUS=$(curl -s -w "%{http_code}" \
  -H "Accept: application/${FORMAT}" \
  -o "${OUT_FILE}" \
  "${QUERY_URL}")

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "Error: API returned HTTP ${HTTP_STATUS}"
  cat "${OUT_FILE}"
  exit 1
fi

echo "Success — $(wc -c < "${OUT_FILE}") bytes written"

# Keep a latest.{format} symlink/copy so consumers can always find current data
cp "${OUT_FILE}" "${OUT_DIR}/latest.${FORMAT}"

# Regenerate the index
bash scripts/build-index.sh
