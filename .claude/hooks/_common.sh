#!/usr/bin/env bash
# Shared helpers for the RSM Claude Code hook scripts.
#
# Ensures `jq` is available: the RSM Nix env already provides jq, but if a
# student runs `claude` outside that env (e.g. Git Bash on Windows) and jq is
# missing, a static binary is downloaded into .claude/bin/ on first use.
# Exports $JQ — hooks should invoke "$JQ" instead of bare `jq`.
#
# Safe to source multiple times. Silent on success. Never aborts the caller:
# if the download fails (e.g. no network), $JQ falls back to "jq" and the
# caller will surface the usual "command not found" message.

if [ -z "${JQ:-}" ]; then
  _rsm_hooks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _rsm_bin_dir="$(dirname "$_rsm_hooks_dir")/bin"

  if command -v jq >/dev/null 2>&1; then
    JQ="jq"
  else
    for _ext in "" ".exe"; do
      if [ -x "$_rsm_bin_dir/jq$_ext" ]; then
        JQ="$_rsm_bin_dir/jq$_ext"
        break
      fi
    done
    unset _ext

    if [ -z "${JQ:-}" ]; then
      mkdir -p "$_rsm_bin_dir" 2>/dev/null || true

      _jq_ver="jq-1.7.1"
      _jq_base="https://github.com/jqlang/jq/releases/download/$_jq_ver"
      _uname_s="$(uname -s 2>/dev/null || echo unknown)"
      _uname_m="$(uname -m 2>/dev/null || echo x86_64)"
      _jq_ext=""
      case "$_uname_s" in
        Linux*)
          case "$_uname_m" in
            x86_64|amd64)   _jq_asset="jq-linux-amd64" ;;
            aarch64|arm64)  _jq_asset="jq-linux-arm64" ;;
            *)              _jq_asset="jq-linux-amd64" ;;
          esac
          ;;
        Darwin*)
          case "$_uname_m" in
            arm64)   _jq_asset="jq-macos-arm64" ;;
            x86_64)  _jq_asset="jq-macos-amd64" ;;
            *)       _jq_asset="jq-macos-arm64" ;;
          esac
          ;;
        MINGW*|MSYS*|CYGWIN*|Windows*)
          _jq_asset="jq-windows-amd64.exe"
          _jq_ext=".exe"
          ;;
        *)
          _jq_asset="jq-linux-amd64"
          ;;
      esac

      _jq_url="$_jq_base/$_jq_asset"
      _jq_target="$_rsm_bin_dir/jq$_jq_ext"

      if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$_jq_target" "$_jq_url" >/dev/null 2>&1 || true
      elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$_jq_target" "$_jq_url" >/dev/null 2>&1 || true
      fi

      chmod +x "$_jq_target" 2>/dev/null || true

      if [ -s "$_jq_target" ]; then
        JQ="$_jq_target"
      else
        rm -f "$_jq_target" 2>/dev/null || true
        JQ="jq"
      fi

      unset _jq_ver _jq_base _uname_s _uname_m _jq_asset _jq_ext _jq_url _jq_target
    fi
  fi

  unset _rsm_hooks_dir _rsm_bin_dir

  export JQ
fi
