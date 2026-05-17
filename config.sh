#!/usr/bin/env bash
# ============================================================
# SENTINEL Core — Configuration Manager v2.0
# ============================================================

: "${SENTINEL_HOME:=${HOME}/sentinel}"
SENTINEL_CONF="${SENTINEL_HOME}/sentinel.conf"

# ── Default Configuration ────────────────────────────────────
: "${SCAN_INTERVAL:=60}"
: "${LOG_LEVEL:=INFO}"
: "${LOG_MAX_SIZE:=10485760}"
: "${LOG_ROTATE_KEEP:=5}"
: "${ALERT_EMAIL:=}"
: "${ALERT_WEBHOOK:=}"
: "${MALWARE_SCAN_PATH:=${HOME}}"
: "${INTEGRITY_WATCH_PATH:=${SENTINEL_HOME}}"
: "${NET_ALERT_THRESHOLD:=50}"
: "${CPU_ALERT_THRESHOLD:=90}"
: "${MEM_ALERT_THRESHOLD:=90}"
: "${PROC_WATCH_INTERVAL:=15}"
: "${NET_WATCH_INTERVAL:=30}"
: "${DEEP_SCAN:=0}"
: "${WHITELIST_ENABLED:=1}"
: "${NOTIFY_TERMUX:=1}"
: "${NOTIFY_SOUND:=1}"
: "${EXCLUDE_PATHS:=/proc,/sys,/dev,/run}"
: "${SCREENSHOT_PROTECTION:=1}"
: "${SCREEN_RECORD_PROTECTION:=1}"
: "${REMOTE_CONTROL_PROTECTION:=1}"
: "${ANTI_MALWARE:=1}"
: "${ANTI_TAMPER:=1}"
: "${GAME_SECURITY:=0}"
: "${KEYBOARD_PROTECTION:=1}"
: "${AUTO_START:=0}"

# Module toggles
: "${MOD_ANTITAMPER:=1}"
: "${MOD_ROOTDETECT:=1}"
: "${MOD_MALWARE:=1}"
: "${MOD_REMOTE:=1}"
: "${MOD_SCREENGUARD:=1}"
: "${MOD_NETMON:=1}"
: "${MOD_PROCGUARD:=1}"
: "${MOD_INTEGRITY:=1}"
: "${MOD_OBFUSCATE:=1}"
: "${MOD_GAMEGUARD:=0}"
: "${MOD_KEYBOARD:=1}"

# Environment detection
detect_environment() {
    if [[ -d "/data/data/com.termux" ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
        export IS_TERMUX=1
        export IS_ROOT=0
        export PLATFORM="android-termux"
    elif [[ $EUID -eq 0 ]]; then
        export IS_TERMUX=0
        export IS_ROOT=1
        export PLATFORM="linux-root"
    else
        export IS_TERMUX=0
        export IS_ROOT=0
        export PLATFORM="linux-user"
    fi
}

config_load() {
    local conf="${1:-$SENTINEL_CONF}"
    if [[ -f "$conf" ]]; then
        while IFS='=' read -r key val; do
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]] || continue
            export "${key}=${val}"
        done < <(grep -v '^[[:space:]]*#' "$conf" | grep -v '^[[:space:]]*$')
    fi
    detect_environment
}

config_write_defaults() {
    [[ -f "$SENTINEL_CONF" ]] && return 0
    mkdir -p "$(dirname "$SENTINEL_CONF")"
    cat > "$SENTINEL_CONF" << 'CONF'
# SENTINEL Security Suite — Configuration
# Platform auto-detection enabled

# Scan intervals (seconds)
SCAN_INTERVAL=60
PROC_WATCH_INTERVAL=15
NET_WATCH_INTERVAL=30

# Logging
LOG_LEVEL=INFO
LOG_MAX_SIZE=10485760
LOG_ROTATE_KEEP=5

# Security paths
MALWARE_SCAN_PATH=${HOME}
INTEGRITY_WATCH_PATH=${SENTINEL_HOME}
EXCLUDE_PATHS=/proc,/sys,/dev,/run

# Thresholds
NET_ALERT_THRESHOLD=50
CPU_ALERT_THRESHOLD=90
MEM_ALERT_THRESHOLD=90

# Notifications
NOTIFY_TERMUX=1
NOTIFY_SOUND=1
ALERT_EMAIL=
ALERT_WEBHOOK=

# Security modules (1=enable, 0=disable)
MOD_ANTITAMPER=1
MOD_ROOTDETECT=1
MOD_MALWARE=1
MOD_REMOTE=1
MOD_SCREENGUARD=1
MOD_NETMON=1
MOD_PROCGUARD=1
MOD_INTEGRITY=1
MOD_OBFUSCATE=1
MOD_GAMEGUARD=0
MOD_KEYBOARD=1

# Protection features
SCREENSHOT_PROTECTION=1
SCREEN_RECORD_PROTECTION=1
REMOTE_CONTROL_PROTECTION=1
ANTI_MALWARE=1
ANTI_TAMPER=1
GAME_SECURITY=0
KEYBOARD_PROTECTION=1

# Advanced
DEEP_SCAN=0
WHITELIST_ENABLED=1
AUTO_START=0
CONF
}

config_validate() {
    local errors=0
    for var in SCAN_INTERVAL PROC_WATCH_INTERVAL NET_WATCH_INTERVAL \
               NET_ALERT_THRESHOLD CPU_ALERT_THRESHOLD MEM_ALERT_THRESHOLD; do
        local val="${!var:-}"
        if [[ -n "$val" ]] && ! [[ "$val" =~ ^[0-9]+$ ]]; then
            echo "[WARN] ${var} should be numeric" >&2
            (( errors++ ))
        fi
    done
    return $errors
}

# Auto-load
config_load 2>/dev/null || true