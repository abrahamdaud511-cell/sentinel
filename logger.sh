#!/usr/bin/env bash
# ============================================================
# SENTINEL Core — Logging Engine v2.0
# ============================================================

: "${SENTINEL_LOG:=${SENTINEL_HOME}/logs/sentinel.log}"
: "${SENTINEL_LOGS:=${SENTINEL_HOME}/logs}"
: "${LOG_LEVEL:=INFO}"
: "${LOG_MAX_SIZE:=10485760}"
: "${LOG_ROTATE_KEEP:=5}"

declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [CRIT]=4)
declare -A LOG_COLORS=(
    [DEBUG]=$'\033[2m'
    [INFO]=$'\033[0;36m'
    [WARN]=$'\033[0;33m'
    [ERROR]=$'\033[0;31m'
    [CRIT]=$'\033[1;31m'
)
RST_LOG=$'\033[0m'

_log() {
    local level="$1"; shift
    local message="$*"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]:-sentinel}:${BASH_LINENO[1]:-0}"
    
    local current_level="${LOG_LEVELS[${LOG_LEVEL:-INFO}]:-1}"
    local msg_level="${LOG_LEVELS[$level]:-1}"
    (( msg_level < current_level )) && return 0
    
    local log_line="[${ts}] [${level}] [$$] [${caller}] ${message}"
    
    mkdir -p "$SENTINEL_LOGS"
    echo "$log_line" >> "$SENTINEL_LOG" 2>/dev/null || true
    
    if [[ -t 2 ]]; then
        local color="${LOG_COLORS[$level]:-}"
        echo -e "${color}${log_line}${RST_LOG}" >&2
    fi
    
    if [[ "$level" == "CRIT" || "$level" == "ERROR" ]]; then
        echo "$log_line" >> "${SENTINEL_LOGS}/alerts.log" 2>/dev/null || true
    fi
    
    _log_rotate_if_needed
}

_log_rotate_if_needed() {
    [[ -f "$SENTINEL_LOG" ]] || return 0
    local size; size=$(stat -c%s "$SENTINEL_LOG" 2>/dev/null || stat -f%z "$SENTINEL_LOG" 2>/dev/null || echo 0)
    (( size < LOG_MAX_SIZE )) && return 0
    
    local ts; ts=$(date '+%Y%m%d_%H%M%S')
    mv "$SENTINEL_LOG" "${SENTINEL_LOG}.${ts}" 2>/dev/null || true
    
    local keep="${LOG_ROTATE_KEEP:-5}"
    ls -t "${SENTINEL_LOG}".* 2>/dev/null | tail -n +$(( keep + 1 )) | xargs rm -f 2>/dev/null || true
}

log_debug() { _log "DEBUG" "$*"; }
log_info()  { _log "INFO"  "$*"; }
log_warn()  { _log "WARN"  "$*"; }
log_error() { _log "ERROR" "$*"; }
log_crit()  { _log "CRIT"  "$*"; }

log_alert() {
    local module="${1:-unknown}"; shift
    local severity="${1:-WARN}"; shift
    local message="$*"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_line="[${ts}] [ALERT] [${module^^}] [${severity}] ${message}"
    mkdir -p "$SENTINEL_LOGS"
    echo "$alert_line" >> "${SENTINEL_LOGS}/alerts.log" 2>/dev/null || true
    _log "${severity}" "[${module^^}] ${message}"
}

log_audit() {
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${ts}] [AUDIT] $*" >> "${SENTINEL_LOGS}/audit.log" 2>/dev/null || true
}

log_perf() {
    local module="$1"; shift
    local duration="$1"; shift
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${ts}] [PERF] [${module}] duration=${duration}s $*" >> "${SENTINEL_LOGS}/perf.log" 2>/dev/null || true
}

mkdir -p "$SENTINEL_LOGS" 2>/dev/null || true