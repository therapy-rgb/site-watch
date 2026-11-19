#!/usr/bin/env bash
# Check the public sites from outside Marcus's home network: every EVERY seconds for MINUTES minutes. A site that
# doesn't answer (000) or answers 5xx is a failure line in log/<day>.tsv (local time, America/New_York, like the
# server's site-probe-fail.log), and each run ends with one "# run" line saying how many rounds it made.
set -u
export TZ=America/New_York
minutes=${MINUTES:-340}
every=${EVERY:-15}
# robots.txt, not the home page: Cloudflare counts only HTML as a page view, so a check every 15 seconds (5,760 a
# day a site) stays out of the traffic numbers (site-pulse.csv). It still proves the site answers.
sites=(https://marcusberley.com/robots.txt https://suburbandadmode.com/robots.txt https://cafenotes.org/robots.txt)
mkdir -p log
err=$(mktemp)
start=$(date '+%F %T')
stop=$((SECONDS + minutes * 60))
rounds=0 fails=0
while [ "$SECONDS" -lt "$stop" ]; do
  t0=$SECONDS
  for u in "${sites[@]}"; do
    code=$(curl -sS -o /dev/null -m 10 -A "site-watch (site monitor)" -H "X-Termwatch-Probe: 1" -w '%{http_code}' "$u" 2>"$err")
    if [ "${code:-000}" = 000 ] || [ "${code:-000}" -ge 500 ]; then
      fails=$((fails + 1))
      printf '%s\t%s\t%s\t%s\n' "$(date '+%F %T')" "$u" "${code:-000}" "$(tr '\n' ' ' <"$err")" >>"log/$(date +%F).tsv"
    fi
  done
  rounds=$((rounds + 1))
  left=$((every - (SECONDS - t0)))
  [ "$left" -gt 0 ] && sleep "$left"
done
printf '# run\t%s\tto %s\t%s rounds\t%s failures\t%s\n' "$start" "$(date '+%F %T')" "$rounds" "$fails" "${GITHUB_RUN_ID:-local}" >>"log/$(date +%F).tsv"
