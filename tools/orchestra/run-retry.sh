#!/usr/bin/env bash
# Run one brief on a list of roles, moving to the next role when a worker hangs at start.
# Copied from D:\Game3\godot-open-rts\tools\orchestra\run-retry.sh; also stops agy.exe.
#
#   tools/orchestra/run-retry.sh <brief> <role1> [role2 ...]
#
# A worker "hangs at start" when its log stays under 200 bytes for HANG_SECS (default 600).
# Then only the opencode/agy processes whose command line names this brief are stopped (by PID),
# and the next role is tried. A worker that started writing is left to finish (WORKER_TIMEOUT).
# Prints "RETRY-RESULT role=<r> exit=<code>" at the end; exit 3 when every role hung.
# Note: agy prints nothing until its turn ends, so give agy roles a large HANG_SECS or none.
set -u
brief="${1:?brief}"; shift
[ $# -gt 0 ] || { echo "run-retry: give at least one role" >&2; exit 2; }
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
name="$(basename "$brief" .md)"
hang="${HANG_SECS:-600}"

kill_brief_workers() {
	powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { (\$_.Name -eq 'opencode.exe' -or \$_.Name -eq 'agy.exe') -and \$_.CommandLine -like '*$name*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force; Write-Output \"run-retry: stopped PID \$(\$_.ProcessId)\" }"
}

for role in "$@"; do
	start=$(date +%s)
	WORKER_FALLBACK=none bash "$here/run-worker.sh" "$role" "$brief" &
	pid=$!
	sleep 15
	log=$(ls -t .orchestra/logs/*"$name"-"$role".log 2>/dev/null | head -1)
	hung=0
	while kill -0 "$pid" 2>/dev/null; do
		size=$(stat -c %s "$log" 2>/dev/null || echo 0)
		if [ "$size" -lt 200 ] && [ $(( $(date +%s) - start )) -gt "$hang" ]; then
			echo "run-retry: role=$role hung at start (log $size bytes); next role"
			kill_brief_workers
			hung=1
			break
		fi
		[ "$size" -ge 200 ] && break
		sleep 20
	done
	if [ "$hung" = 1 ]; then wait "$pid" 2>/dev/null; continue; fi
	wait "$pid"; code=$?
	echo "RETRY-RESULT role=$role exit=$code"
	exit "$code"
done
echo "RETRY-RESULT all roles hung"
exit 3
