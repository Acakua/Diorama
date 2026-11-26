#!/usr/bin/env bash
# Run one worker on one brief. Used by the orchestrator (Claude Code).
# Adapted from D:\Game3\godot-open-rts\tools\orchestra\run-worker.sh; adds agy (Gemini).
#
#   tools/orchestra/run-worker.sh <role|provider/model> <brief.md> [project-dir] [-- extra args]
#
# - <role> is looked up in roles.conf (next to this script); anything containing "/"
#   is taken as a model id. "agy/<model>" runs the Antigravity CLI, anything else opencode.
# - opencode workers are told to read AGENTS.md; agy workers (the art director) are told
#   to read tools/orchestra/ART-DIRECTOR.md. Then the brief. Nothing else.
# - Output goes to <project-dir>/.orchestra/logs/<time>-<brief>-<role>.log
#   and a one-line result is appended to <project-dir>/.orchestra/runs.tsv
# - Exit code is the worker's exit code (124 = timed out, 3 = no report block).
#
# Env: WORKER_TIMEOUT (seconds, default 1500), WORKER_VARIANT (opencode --variant),
#      WORKER_PROMPT (replace the fixed prompt), WORKER_FALLBACK (role to use when the
#      BytePlus quota runs out; default free-<role>; "none" disables).
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

who="${1:?role or provider/model}"; brief="${2:?brief file}"; shift 2
dir="$PWD"
if [ $# -gt 0 ] && [ "$1" != "--" ]; then dir="$1"; shift; fi
[ "${1:-}" = "--" ] && shift

if [[ "$who" == */* ]]; then model="$who"; role="adhoc"
else
  role="$who"
  model="$(awk -v r="$role" '$1==r {print $2; exit}' "$here/roles.conf")"
  [ -n "$model" ] || { echo "run-worker: unknown role '$role' (see $here/roles.conf)" >&2; exit 2; }
fi

dir="$(cd "$dir" && pwd)" || exit 2
[ -f "$dir/$brief" ] || [ -f "$brief" ] || { echo "run-worker: brief not found: $brief" >&2; exit 2; }
[ -f "$dir/AGENTS.md" ] || { echo "run-worker: $dir/AGENTS.md is missing; workers need it" >&2; exit 2; }

# The BytePlus key lives in the Windows *user* environment. A shell started before
# it was set (or started by an app) does not have it, so load it explicitly.
if [[ "$model" == byteplus/* ]] && [ -z "${ARK_API_KEY:-}" ] && command -v powershell >/dev/null 2>&1; then
  ARK_API_KEY="$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('ARK_API_KEY','User')" | tr -d '\r\n')"
  export ARK_API_KEY
fi
if [[ "$model" == byteplus/* ]] && [ -z "${ARK_API_KEY:-}" ]; then
  echo "run-worker: ARK_API_KEY is not set; byteplus models will fail" >&2; exit 2
fi

name="$(basename "$brief" .md)"
mkdir -p "$dir/.orchestra/logs"
prompt="${WORKER_PROMPT:-}"
if [ -z "$prompt" ]; then
  if [[ "$model" == agy/* ]]; then
    prompt="You are the art director of this project. Read tools/orchestra/ART-DIRECTOR.md first and follow it. Then do the task in $brief exactly as written. Finish with the report block that ART-DIRECTOR.md asks for."
  else
    prompt="Read AGENTS.md first. Then do the task in $brief exactly as written. Finish with the report block that AGENTS.md asks for."
  fi
fi

run_once() {   # $1 role label, $2 model, rest: extra args
  local r="$1" m="$2"; shift 2
  log="$dir/.orchestra/logs/$(date +%Y%m%d-%H%M%S)-$name-$r.log"
  echo "run-worker: role=$r model=$m brief=$brief log=$log"
  local start; start=$(date +%s)
  if [[ "$m" == agy/* ]]; then
    # agy has no --dir: run it from the project folder. Print mode cannot prompt for
    # permission, so tools are auto-approved; the git checkpoint (RUNBOOK 5.3) is the guard.
    ( cd "$dir" && timeout "${WORKER_TIMEOUT:-1500}" agy -p "$prompt" --model "${m#agy/}" \
        --dangerously-skip-permissions --log-file "$log.agy" "$@" ) >"$log" 2>&1
  else
    local a=(run --auto -m "$m" --dir "$dir" --title "[$r] $name")
    [ -n "${WORKER_VARIANT:-}" ] && a+=(--variant "$WORKER_VARIANT")
    timeout "${WORKER_TIMEOUT:-1500}" opencode "${a[@]}" "$@" -- "$prompt" >"$log" 2>&1
  fi
  code=$?
  secs=$(( $(date +%s) - start ))
  printf '%s\t%s\t%s\t%s\texit=%s\t%ss\t%s\n' "$(date +%F\ %T)" "$r" "$m" "$brief" "$code" "$secs" "$log" >>"$dir/.orchestra/runs.tsv"
  echo "run-worker: exit=$code secs=$secs"
}

run_once "$role" "$model" "$@"

# BytePlus Coding Plan quota hit: rerun the same brief on the free team.
if [[ "$model" == byteplus/* ]] && grep -qE "exceeded the (5-hour|weekly) usage quota" "$log"; then
  fb="${WORKER_FALLBACK:-free-$role}"
  fbmodel="$(awk -v r="$fb" '$1==r {print $2; exit}' "$here/roles.conf")"
  if [ "$fb" != "none" ] && [ -n "$fbmodel" ]; then
    echo "run-worker: BytePlus quota exceeded; rerunning on $fb ($fbmodel). Partial files from the first run are still on disk."
    extra=(); skip=0
    for x in "$@"; do
      if [ $skip = 1 ]; then skip=0; continue; fi
      case "$x" in -s|--session) skip=1 ;; -c|--continue|--fork) ;; *) extra+=("$x") ;; esac
    done
    run_once "$fb" "$fbmodel" "${extra[@]}"
  else
    echo "run-worker: BytePlus quota exceeded and no fallback role '$fb' in roles.conf"
  fi
fi

# Exit 0 is not proof of work: a model can read the brief and stop.
if [ $code = 0 ] && ! grep -q "STATUS:" "$log"; then
  echo "run-worker: WARNING no report block (no 'STATUS:' line). The worker probably stopped early; check 'git status' and consider another model."
  code=3
fi

echo "----- last lines of the worker's output -----"
sed 's/\x1b\[[0-9;]*m//g' "$log" | tail -40
exit $code
