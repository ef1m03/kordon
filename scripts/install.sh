#!/bin/sh
# Kordon installer for macOS and Linux.
#
#   curl -fL --connect-timeout 10 --max-time 30 --retry 2 https://raw.githubusercontent.com/ef1m03/kordon/main/scripts/install.sh | sh
#   curl -fL --connect-timeout 10 --max-time 30 --retry 2 https://raw.githubusercontent.com/ef1m03/kordon/main/scripts/install.sh | sh -s uninstall
#
set -eu

REPO="ef1m03/kordon"
BASE="https://github.com/$REPO/releases/latest/download"
ACTION="${1:-install}"

say() { printf '\033[1m%s\033[0m\n' "$*"; }

download() {
  say "Скачиваю $1…"
  for attempt in 1 2 3; do
    say "Попытка $attempt из 3"
    if curl -q --fail --location --progress-bar --show-error --connect-timeout 10 \
      --max-time "$3" --speed-limit 1 --speed-time 20 -o "$2" "$BASE/$1"; then
      return 0
    fi
    rm -f "$2"
    if [ "$attempt" -lt 3 ]; then sleep "$attempt"; fi
  done
  printf '%s\n' "Не удалось скачать $1. Проверьте соединение с GitHub и повторите команду установки." >&2
  return 1
}

# verify FILE NAME: compares FILE with the NAME line of the release's SHA256SUMS.txt,
# so a file damaged or swapped on the way is never installed.
verify() {
  download SHA256SUMS.txt "$1.sums" 20
  say "Проверяю контрольную сумму…"
  want="$(awk -v name="$2" '$2 == name { print $1 }' "$1.sums")"
  if command -v sha256sum >/dev/null 2>&1; then got="$(sha256sum "$1" | cut -d' ' -f1)"
  else got="$(shasum -a 256 "$1" | cut -d' ' -f1)"; fi
  if [ -z "$want" ] || [ "$want" != "$got" ]; then
    echo "Контрольная сумма $2 не совпала - файл повреждён или подменён, ничего не установлено." >&2
    exit 1
  fi
}

stop_running() {
  # Quitting through the menu would un-freeze apps; on update Kordon does it at its next start.
  pkill -x kordon 2>/dev/null || true
  sleep 1
}

mac() {
  dest="/Applications"
  [ -w "$dest" ] || dest="$HOME/Applications"
  if [ "$ACTION" = "uninstall" ]; then
    stop_running
    rm -rf "$dest/Kordon.app" "$HOME/Applications/Kordon.app"
    rm -f "$HOME/Library/LaunchAgents/dev.efimov.kordon.plist"
    say "Kordon удалён. Настройки остались в ~/Library/Application Support/Kordon - удалите папку, если не нужны."
    return
  fi
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  download Kordon-macos.zip "$tmp/Kordon.zip" 90
  verify "$tmp/Kordon.zip" Kordon-macos.zip
  stop_running
  mkdir -p "$dest"
  rm -rf "$dest/Kordon.app"
  ditto -x -k "$tmp/Kordon.zip" "$dest"
  open "$dest/Kordon.app"
  say "Готово: Kordon в $dest и уже в строке меню (зелёная точка рядом с часами)."
}

linux() {
  bin="$HOME/.local/bin"
  if [ "$ACTION" = "uninstall" ]; then
    stop_running
    rm -f "$bin/kordon" "$HOME/.config/autostart/kordon.desktop"
    say "Kordon удалён. Настройки остались в ~/.config/kordon."
    return
  fi
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) echo "Неподдерживаемая архитектура: $(uname -m)" >&2; exit 1 ;;
  esac
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  download "kordon-linux-$arch.tar.gz" "$tmp/kordon.tar.gz" 90
  verify "$tmp/kordon.tar.gz" "kordon-linux-$arch.tar.gz"
  stop_running
  mkdir -p "$bin"
  tar -xzf "$tmp/kordon.tar.gz" -C "$bin" kordon
  chmod +x "$bin/kordon"
  "$bin/kordon" autostart on
  nohup "$bin/kordon" >/dev/null 2>&1 &
  say "Готово: $bin/kordon запущен и стартует при входе."
}

case "$(uname -s)" in
  Darwin) mac ;;
  Linux) linux ;;
  *) echo "Для Windows (PowerShell): irm https://raw.githubusercontent.com/$REPO/main/scripts/install.ps1 | iex" >&2; exit 1 ;;
esac
