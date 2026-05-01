#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf "%s\n" \
    "Usage: scripts/record-demo.sh [store-to-complete]" \
    "" \
    "Environment:" \
    "  SIM_NAME       Simulator name or auto (default: auto)" \
    "  AGENT_NAME     Build isolation label (default: DEMO)" \
    "  VIDEO_DIR      Output directory (default: build/videos)"
}

SCENARIO="${1:-store-to-complete}"
SIM_NAME="${SIM_NAME:-auto}"
AGENT_NAME="${AGENT_NAME:-DEMO}"
VIDEO_DIR="${VIDEO_DIR:-build/videos}"
PROJECT="CocoichiPoC.xcodeproj"
SCHEME="CocoichiPoC"
DERIVED_DATA="build/DerivedData/${AGENT_NAME}-demo-recording"

case "$SCENARIO" in
  store-to-complete)
    TEST_ID="CocoichiPoCUITests/DemoRecordingUITests/testStoreSelectToComplete"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown scenario: $SCENARIO" >&2
    usage
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p "$VIDEO_DIR"

DESTINATION="$("$SCRIPT_DIR/resolve_sim_destination.sh" --sim-name "$SIM_NAME")"
SIM_UDID="${DESTINATION##*id=}"
STAMP="$(date +%Y%m%d-%H%M%S)"
RAW_VIDEO="$VIDEO_DIR/${SCENARIO}-${STAMP}-raw.mp4"
SOCIAL_VIDEO="$VIDEO_DIR/${SCENARIO}-${STAMP}-9x16.mp4"
RESULT_BUNDLE="$VIDEO_DIR/${SCENARIO}-${STAMP}.xcresult"
RECORD_PID=""

stop_recording() {
  if [[ -n "$RECORD_PID" ]] && kill -0 "$RECORD_PID" >/dev/null 2>&1; then
    kill -INT "$RECORD_PID" >/dev/null 2>&1 || true
    wait "$RECORD_PID" >/dev/null 2>&1 || true
  fi
}

trap stop_recording EXIT

open -a Simulator >/dev/null 2>&1 || true
xcrun simctl boot "$SIM_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIM_UDID" -b

echo "Building UI test bundle for $DESTINATION"
xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  SDKROOT=iphonesimulator

echo "Recording $RAW_VIDEO"
xcrun simctl io "$SIM_UDID" recordVideo --codec=h264 --force "$RAW_VIDEO" &
RECORD_PID="$!"
sleep 1

set +e
xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:"$TEST_ID" \
  -resultBundlePath "$RESULT_BUNDLE"
TEST_STATUS=$?
set -e

sleep 1
stop_recording
trap - EXIT

if command -v ffmpeg >/dev/null 2>&1; then
  echo "Rendering social video $SOCIAL_VIDEO"
  ffmpeg -y -i "$RAW_VIDEO" \
    -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
    -r 30 -c:v libx264 -pix_fmt yuv420p -movflags +faststart \
    "$SOCIAL_VIDEO"
else
  echo "ffmpeg not found; keeping raw video only: $RAW_VIDEO"
fi

if [[ "$TEST_STATUS" -ne 0 ]]; then
  echo "Scenario failed. Raw recording: $RAW_VIDEO" >&2
  exit "$TEST_STATUS"
fi

echo "Done:"
echo "  raw:    $RAW_VIDEO"
if [[ -f "$SOCIAL_VIDEO" ]]; then
  echo "  social: $SOCIAL_VIDEO"
fi
