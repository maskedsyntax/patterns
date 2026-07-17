#!/usr/bin/env bash
# record_ads.sh — Record 15s marketing ads (one-shot story + end card hold)
# from a booted iOS Simulator or Android Emulator into ./marketing_videos/
#
# Each ad plays as a marketing video, not an app-animation demo:
#   brand open → hook/demo motion → opaque static retention card.
# The retention card holds for the rest of the 15s+ clip. No micro-loop spam.
#
# Timeline per ad (no wasted seconds):
#   1. LAUNCH      flutter run -t main_marketing --dart-define=AD_INDEX=N
#   2. READY       wait until Flutter reports the app is live
#   3. RECORD      start capture immediately (second 0 of the ad)
#   4. WINDOW      sleep DURATION (default 15s) — full story + end card
#   5. TERMINATE   stop encoder, kill app, next index
#
# Usage:
#   ./record_ads.sh
#   ONLY=3 ./record_ads.sh
#   DURATION=15 ./record_ads.sh
#   FLUTTER_MODE=profile ./record_ads.sh
#   DRY_RUN=1 ./record_ads.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

OUT_DIR="${OUT_DIR:-$ROOT/marketing_videos}"
ENTRYPOINT="lib/main_marketing.dart"
# Full recorded length (matches AdStory.duration in Dart = 15s).
DURATION="${DURATION:-15}"
DRY_RUN="${DRY_RUN:-0}"
ONLY="${ONLY:-}"
FLUTTER_MODE="${FLUTTER_MODE:-}"

# ── colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_CYAN=$'\033[36m'
else
  C_RESET=""; C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_CYAN=""
fi

log()  { printf '%s%s%s\n' "$C_CYAN" "$*" "$C_RESET"; }
ok()   { printf '%s%s%s\n' "$C_GREEN" "$*" "$C_RESET"; }
warn() { printf '%s%s%s\n' "$C_YELLOW" "$*" "$C_RESET"; }
err()  { printf '%s%s%s\n' "$C_RED" "$*" "$C_RESET" >&2; }
die()  { err "error: $*"; exit 1; }

resolve_indices() {
  if [[ -z "$ONLY" ]]; then
    echo "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24"
    return
  fi
  local raw="${ONLY//,/ }"
  local out=()
  local n
  for n in $raw; do
    [[ "$n" =~ ^[0-9]+$ ]] || die "invalid ONLY entry: $n"
    (( n >= 1 && n <= 24 )) || die "ONLY index out of range (1–24): $n"
    out+=("$n")
  done
  echo "${out[*]}"
}

INDICES=($(resolve_indices))

PLATFORM=""
TARGET_DEVICE=""
ANDROID_SERIAL=""

detect_ios() {
  command -v xcrun >/dev/null 2>&1 || return 1
  local booted
  booted="$(xcrun simctl list devices booted 2>/dev/null | grep -E 'Booted' | head -1 || true)"
  [[ -n "$booted" ]] || return 1
  local flutter_ios
  flutter_ios="$(flutter devices 2>/dev/null | grep -i 'ios' | grep -i 'simulator' | head -1 || true)"
  if [[ -n "$flutter_ios" ]]; then
    TARGET_DEVICE="$(echo "$flutter_ios" | awk -F'•' '{print $2}' | xargs)"
  else
    TARGET_DEVICE="$(echo "$booted" | grep -oE '[0-9A-Fa-f-]{25,}' | head -1 || true)"
  fi
  [[ -n "$TARGET_DEVICE" ]] || return 1
  PLATFORM="ios"
  return 0
}

detect_android() {
  command -v adb >/dev/null 2>&1 || return 1
  local serials
  serials="$(adb devices 2>/dev/null | awk '/emulator-.*device$/{print $1}' | head -1 || true)"
  if [[ -z "$serials" ]]; then
    serials="$(adb devices 2>/dev/null | awk 'NR>1 && $2=="device"{print $1}' | head -1 || true)"
  fi
  [[ -n "$serials" ]] || return 1
  ANDROID_SERIAL="$serials"
  TARGET_DEVICE="$serials"
  PLATFORM="android"
  return 0
}

detect_device() {
  if detect_ios; then
    ok "Detected iOS Simulator → $TARGET_DEVICE"
    return 0
  fi
  if detect_android; then
    ok "Detected Android device/emulator → $TARGET_DEVICE"
    return 0
  fi
  die "No booted iOS Simulator or Android emulator found."
}

override_status_bar() {
  [[ "$PLATFORM" == "ios" ]] || return 0
  log "Overriding simulator status bar (9:41 · wifi · full battery)…"
  xcrun simctl status_bar "$TARGET_DEVICE" override \
    --time "9:41" \
    --dataNetwork wifi \
    --wifiBars 3 \
    --batteryState charged \
    --batteryLevel 100 \
    2>/dev/null \
    || xcrun simctl status_bar booted override \
      --time "9:41" \
      --dataNetwork wifi \
      --wifiBars 3 \
      --batteryState charged \
      --batteryLevel 100 \
      2>/dev/null \
    || warn "status_bar override failed (continuing)"
}

clear_status_bar() {
  [[ "$PLATFORM" == "ios" ]] || return 0
  log "Clearing simulator status bar overrides…"
  xcrun simctl status_bar "$TARGET_DEVICE" clear 2>/dev/null \
    || xcrun simctl status_bar booted clear 2>/dev/null \
    || true
}

FLUTTER_PID=""
RECORD_PID=""

cleanup() {
  local code=$?
  if [[ -n "${RECORD_PID:-}" ]] && kill -0 "$RECORD_PID" 2>/dev/null; then
    kill -INT "$RECORD_PID" 2>/dev/null || true
    wait "$RECORD_PID" 2>/dev/null || true
  fi
  if [[ -n "${FLUTTER_PID:-}" ]] && kill -0 "$FLUTTER_PID" 2>/dev/null; then
    kill "$FLUTTER_PID" 2>/dev/null || true
    wait "$FLUTTER_PID" 2>/dev/null || true
  fi
  pkill -f "flutter_tools.snapshot run.*main_marketing" 2>/dev/null || true
  clear_status_bar
  exit "$code"
}
trap cleanup EXIT INT TERM

kill_flutter() {
  if [[ -n "${FLUTTER_PID:-}" ]] && kill -0 "$FLUTTER_PID" 2>/dev/null; then
    kill "$FLUTTER_PID" 2>/dev/null || true
    for _ in 1 2 3 4 5; do
      kill -0 "$FLUTTER_PID" 2>/dev/null || break
      sleep 0.4
    done
    kill -9 "$FLUTTER_PID" 2>/dev/null || true
    wait "$FLUTTER_PID" 2>/dev/null || true
  fi
  FLUTTER_PID=""
  pkill -f "flutter_tools.snapshot run.*main_marketing" 2>/dev/null || true
  if [[ "$PLATFORM" == "ios" ]]; then
    xcrun simctl terminate "$TARGET_DEVICE" com.maskedsyntax.patterns 2>/dev/null || true
    xcrun simctl terminate booted com.maskedsyntax.patterns 2>/dev/null || true
  elif [[ "$PLATFORM" == "android" ]]; then
    adb -s "$ANDROID_SERIAL" shell am force-stop com.maskedsyntax.patterns 2>/dev/null || true
  fi
}

launch_ad() {
  local index="$1"
  local mode_arg="--${FLUTTER_MODE}"
  log "① LAUNCH  AdAnimation${index}  (−d $TARGET_DEVICE · ${mode_arg} · AD_INDEX=${index})"
  flutter run \
    -t "$ENTRYPOINT" \
    --dart-define="AD_INDEX=${index}" \
    -d "$TARGET_DEVICE" \
    "$mode_arg" \
    >"$OUT_DIR/.flutter_ad_${index}.log" 2>&1 &
  FLUTTER_PID=$!
}

# Poll every 200ms so we arm the encoder as soon as the first paint is live.
wait_for_ready() {
  local index="$1"
  local log_file="$OUT_DIR/.flutter_ad_${index}.log"
  local waited_ms=0
  local max_wait_ms=180000

  log "   waiting for Flutter ready signal…"
  while (( waited_ms < max_wait_ms )); do
    if ! kill -0 "$FLUTTER_PID" 2>/dev/null; then
      err "Flutter process exited early. Last log lines:"
      tail -n 40 "$log_file" 2>/dev/null || true
      die "flutter run failed for ad $index"
    fi
    # Reliable "app is running" markers — record starts immediately after.
    # The Flutter ad itself begins with a branded hold, so capture starts from
    # the first marketing frame instead of mid-demo motion.
    if grep -qE "Flutter run key commands|To hot reload|A Dart VM Service" "$log_file" 2>/dev/null; then
      ok "   app ready after ~$((waited_ms / 1000))s — recording from t=0"
      return 0
    fi
    sleep 0.2
    waited_ms=$((waited_ms + 200))
  done
  warn "Timed out waiting for Flutter ready after $((max_wait_ms / 1000))s — continuing"
}

start_record_ios() {
  local outfile="$1"
  rm -f "$outfile"
  log "③ RECORD   simctl io $TARGET_DEVICE recordVideo --display=main (${DURATION}s)"
  xcrun simctl io "$TARGET_DEVICE" recordVideo \
    --display=main \
    --codec=h264 \
    --force \
    "$outfile" &
  RECORD_PID=$!
}

start_record_android() {
  local outfile="$1"
  local remote="/sdcard/patterns_ad_record.mp4"
  rm -f "$outfile"
  adb -s "$ANDROID_SERIAL" shell rm -f "$remote" 2>/dev/null || true
  # Android max time-limit is 180; 15s is fine.
  log "③ RECORD   adb screenrecord --time-limit=${DURATION}"
  (
    adb -s "$ANDROID_SERIAL" shell screenrecord --time-limit="$DURATION" "$remote"
    adb -s "$ANDROID_SERIAL" pull "$remote" "$outfile" >/dev/null
    adb -s "$ANDROID_SERIAL" shell rm -f "$remote" 2>/dev/null || true
  ) &
  RECORD_PID=$!
}

stop_record_ios() {
  local outfile="$1"
  if [[ -n "${RECORD_PID:-}" ]] && kill -0 "$RECORD_PID" 2>/dev/null; then
    kill -INT "$RECORD_PID" 2>/dev/null || true
    wait "$RECORD_PID" 2>/dev/null || true
  fi
  RECORD_PID=""
  sleep 0.5
  [[ -f "$outfile" ]] || die "Recording missing: $outfile"
}

stop_record_android() {
  local outfile="$1"
  if [[ -n "${RECORD_PID:-}" ]]; then
    wait "$RECORD_PID" 2>/dev/null || true
  fi
  RECORD_PID=""
  [[ -f "$outfile" ]] || die "Recording missing: $outfile"
}

# Capture the full one-shot story from second 0 (no settle waste).
record_story() {
  local index="$1"
  local target_dir="$OUT_DIR"
  local ad_duration="$DURATION"
  if (( index <= 10 )); then
    target_dir="$OUT_DIR/Batch 1"
  elif (( index <= 20 )); then
    target_dir="$OUT_DIR/Batch 2"
  else
    target_dir="$OUT_DIR/Batch 3"
    ad_duration=30
  fi
  mkdir -p "$target_dir"
  local outfile="$target_dir/ad_${index}.mp4"

  # Rotate simulator for widescreen ads (index >= 21)
  if (( index >= 21 )); then
    if [[ "$PLATFORM" == "ios" ]]; then
      # Attempt AppleScript rotation first
      log "Attempting to rotate Simulator window to landscape orientation..."
      osascript -e 'tell application "Simulator" to activate' -e 'tell application "System Events" to key code 123 using {command down}' 2>/dev/null || true
      sleep 2

      # Interactive check loop to verify landscape framebuffer dimensions
      local is_portrait=true
      while [[ "$is_portrait" == "true" ]]; do
        xcrun simctl io booted screenshot "${OUT_DIR}/.orientation_check.png" 2>/dev/null || true
        if [[ -f "${OUT_DIR}/.orientation_check.png" ]]; then
          local w h
          w=$(file "${OUT_DIR}/.orientation_check.png" | grep -oE '[0-9]+ x [0-9]+' | head -1 | cut -d' ' -f1 || echo "0")
          h=$(file "${OUT_DIR}/.orientation_check.png" | grep -oE '[0-9]+ x [0-9]+' | head -1 | cut -d' ' -f3 || echo "0")
          rm -f "${OUT_DIR}/.orientation_check.png"
          if (( w > h )); then
            is_portrait=false
          fi
        fi
        
        if [[ "$is_portrait" == "true" ]]; then
          echo -e "${C_YELLOW}${C_BOLD}⚠️  Simulator is in Portrait. Widescreen ads require Landscape.${C_RESET}"
          echo -e "   1. Focus the Simulator window on your screen."
          echo -e "   2. Press ${C_BOLD}Cmd + Left Arrow (⌘ + ←)${C_RESET} to rotate the Simulator window."
          echo -e "   Then press ${C_GREEN}[ENTER]${C_RESET} in this terminal to verify and start recording..."
          read -r _ < /dev/tty
        fi
      done
    fi
  fi

  # Arm the encoder the instant Flutter is ready — do not sleep first.
  if [[ "$PLATFORM" == "ios" ]]; then
    start_record_ios "$outfile"
  else
    start_record_android "$outfile"
  fi

  log "② WINDOW   sleep ${ad_duration}s  (from t=0: demo → end card)"
  sleep "$ad_duration"

  log "③ TERMINATE  stop recording"
  if [[ "$PLATFORM" == "ios" ]]; then
    stop_record_ios "$outfile"
  else
    stop_record_android "$outfile"
  fi

  local size
  size="$(du -h "$outfile" | awk '{print $1}')"
  ok "   saved ad_${index}.mp4 (${size}) to $target_dir"
}

main() {
  command -v flutter >/dev/null 2>&1 || die "flutter not found on PATH"
  [[ -f "$ENTRYPOINT" ]] || die "missing $ENTRYPOINT"
  [[ -d "lib/marketing_animations" ]] || die "missing lib/marketing_animations/"
  [[ "$DURATION" =~ ^[0-9]+$ ]] || die "DURATION must be a whole number of seconds"
  (( DURATION >= 15 )) || die "marketing clips must be at least 15 seconds (DURATION=$DURATION)"

  mkdir -p "$OUT_DIR"

  log "${C_BOLD}Patterns marketing recorder${C_RESET}"
  log "  ads:      ${INDICES[*]}"
  log "  duration: ${DURATION}s from t=0 (no settle delay)"
  log "  output:   $OUT_DIR"

  detect_device

  if [[ -z "$FLUTTER_MODE" ]]; then
    if [[ "$PLATFORM" == "android" ]]; then
      FLUTTER_MODE="profile"
    else
      # Flutter cannot run profile/release builds on an iOS Simulator.
      FLUTTER_MODE="debug"
    fi
  fi
  [[ "$FLUTTER_MODE" =~ ^(debug|profile|release)$ ]] \
    || die "FLUTTER_MODE must be debug, profile, or release"

  if [[ "$DRY_RUN" == "1" ]]; then
    warn "DRY_RUN=1 — plan only"
    for i in "${INDICES[@]}"; do
      echo "  ad_$i: launch (${FLUTTER_MODE}) → ready → record immediately ${DURATION}s → stop"
    done
    trap - EXIT INT TERM
    exit 0
  fi

  override_status_bar
  log "Resolving packages…"
  flutter pub get >/dev/null

  for i in "${INDICES[@]}"; do
    echo
    log "════════════════════════════════════════"
    log " Ad $i / indices: ${INDICES[*]}"
    log "════════════════════════════════════════"

    kill_flutter
    launch_ad "$i"
    wait_for_ready "$i"
    record_story "$i"
    kill_flutter
  done

  echo
  ok "Done. Recorded ${#INDICES[@]} video(s) in $OUT_DIR"
  find "$OUT_DIR" -type f -name "*.mp4" -maxdepth 2 | xargs ls -lh 2>/dev/null || true
}

main "$@"
