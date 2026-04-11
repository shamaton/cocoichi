#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: run_app_ios_sim.sh --app-path /path/to/App.app --sim-name "iPhone 16" [--sim-udid UDID] [--background] [--booted-only]
USAGE
}

APP_PATH=""
SIM_NAME=""
SIM_UDID=""
BACKGROUND=0
BOOTED_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-path)
      APP_PATH="$2"
      shift 2
      ;;
    --sim-name)
      SIM_NAME="$2"
      shift 2
      ;;
    --sim-udid)
      SIM_UDID="$2"
      shift 2
      ;;
    --background)
      BACKGROUND=1
      shift
      ;;
    --booted-only)
      BOOTED_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
 done

if [[ -z "$APP_PATH" ]]; then
  echo "Missing --app-path" >&2
  usage
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "App not found: $APP_PATH" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINATION_ARGS=(--sim-name "$SIM_NAME")
if [[ -n "$SIM_UDID" ]]; then
  DESTINATION_ARGS+=(--sim-udid "$SIM_UDID")
fi
if [[ $BOOTED_ONLY -eq 1 ]]; then
  DESTINATION_ARGS+=(--booted-only)
fi

DESTINATION="$("$SCRIPT_DIR/resolve_sim_destination.sh" "${DESTINATION_ARGS[@]}" 2>/dev/null || true)"
if [[ -z "$DESTINATION" ]]; then
  if [[ $BOOTED_ONLY -eq 1 ]]; then
    echo "No booted iOS Simulator found; skipping app refresh."
    exit 0
  fi
  echo "No available iOS Simulator found." >&2
  exit 1
fi
SIM_UDID="${DESTINATION##*id=}"

if [[ $BOOTED_ONLY -eq 0 ]]; then
  open -a Simulator >/dev/null 2>&1 || true
  xcrun simctl boot "$SIM_UDID" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$SIM_UDID" -b
fi

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "$APP_PATH/Info.plist")

xcrun simctl install "$SIM_UDID" "$APP_PATH"
xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true

if [[ $BACKGROUND -eq 1 ]]; then
  echo "Launching on Simulator (focus may shift)."
fi

xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID"
