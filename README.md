# site-watch

Checks marcusberley.com, suburbandadmode.com and cafenotes.org every 15 seconds from GitHub's servers, outside Marcus's home network. It's there to tell a real outage from the home server losing its route to Cloudflare: the server's own probe logs its timeouts in `~/.local/state/log/site-probe-fail.log`, and this repo's `log/` shows whether the sites answered the rest of the world at the same moment.

- `log/<day>.tsv`: one line per failure (time in New York, site, code, curl's error), and a `# run` line at the end of each run with its rounds and failures. A day with only `# run` lines had no failures.
- `watch.sh` does the checking; `.github/workflows/watch.yml` runs it, one run at a time, each about 5 h 40 min.
- The requests carry `X-Termwatch-Probe: 1`, as the server's probe does, so access logs can leave them out.

Public on purpose, so Actions minutes are free. It holds only the three public addresses and whether they answered.
