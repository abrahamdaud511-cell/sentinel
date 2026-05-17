#!/usr/bin/env bash
# ============================================================
# SENTINEL Core — Notification System v2.0
# ============================================================

: "${NOTIFY_TERMUX:=1}"
: "${NOTIFY_SOUND:=1}"
: "${ALERT_WEBHOOK:=}"
: "${ALERT_EMAIL:=}"

_has_termux_api() { command -v termux-notification &>/dev/null; }
_has_notify_send() { command -v notify-send &>/dev/null; }
_is_termux() { [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; }
_has_curl() { command -v curl &>/dev/null; }
_has_mail() { command -v mail &>/dev/null; }

notify() {
    local title="$1"
    local body="$2"
    local severity="${3:-info}"
    
    log_alert "notify" "${severity^^}" "${title}: ${body}"
    
    # Terminal bell
    if [[ "$NOTIFY_SOUND" == "1" ]]; then
        case "$severity" in
            warn)     printf '\a' ;;
            critical) printf '\a\a\a' ;;
        esac
    fi
    
    # Termux notification
    if [[ "$NOTIFY_TERMUX" == "1" ]] && _is_termux && _has_termux_api; then
        local icon="ic_dialog_alert"
        case "$severity" in
            info)     icon="ic_dialog_info" ;;
            warn)     icon="ic_dialog_alert" ;;
            critical) icon="ic_dialog_alert" ;;
        esac
        termux-notification \
            --title "🛡️ SENTINEL: ${title}" \
            --content "${body}" \
            --type "default" \
            --sound \
            --vibrate "200,100,200" \
            --id "sentinel_${RANDOM}" \
            2>/dev/null || true
        return 0
    fi
    
    # Linux desktop notification
    if _has_notify_send; then
        local urgency="normal"
        [[ "$severity" == "critical" ]] && urgency="critical"
        notify-send -u "$urgency" -i "dialog-warning" \
            "🛡️ SENTINEL: ${title}" "${body}" 2>/dev/null || true
    fi
    
    # Webhook (Discord/Slack)
    if [[ -n "$ALERT_WEBHOOK" ]] && _has_curl; then
        local color="good"
        [[ "$severity" == "warn" ]] && color="warning"
        [[ "$severity" == "critical" ]] && color="danger"
        local payload
        payload=$(cat <<JSON
{
  "attachments": [{
    "color": "${color}",
    "title": "SENTINEL Alert: ${title}",
    "text": "${body}",
    "footer": "SENTINEL | $(hostname)",
    "ts": $(date +%s)
  }]
}
JSON
)
        curl -s -X POST -H 'Content-type: application/json' \
             --data "$payload" "$ALERT_WEBHOOK" >/dev/null 2>&1 || true
    fi
    
    # Email for critical
    if [[ -n "$ALERT_EMAIL" ]] && [[ "$severity" == "critical" ]] && _has_mail; then
        echo "${body}" | mail -s "[SENTINEL CRITICAL] ${title}" "$ALERT_EMAIL" 2>/dev/null || true
    fi
    
    # Terminal output
    if [[ -t 1 ]]; then
        local prefix
        case "$severity" in
            info)     prefix=$'\033[0;36m[INFO]\033[0m' ;;
            warn)     prefix=$'\033[0;33m[WARN]\033[0m' ;;
            critical) prefix=$'\033[1;31m[CRIT]\033[0m' ;;
        esac
        echo -e "${prefix} ${title}: ${body}" >&2
    fi
}

notify_info()     { notify "$1" "$2" "info"; }
notify_warn()     { notify "$1" "$2" "warn"; }
notify_critical() { notify "$1" "$2" "critical"; }

declare -A _ALERT_CACHE=()
notify_dedup() {
    local key="$1"; shift
    local now; now=$(date +%s)
    local last="${_ALERT_CACHE[$key]:-0}"
    local cooldown="${ALERT_COOLDOWN:-300}"
    if (( now - last < cooldown )); then
        return 0
    fi
    _ALERT_CACHE[$key]=$now
    notify "$@"
}