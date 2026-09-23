#!/usr/bin/env python3
# Downloads a file and shows how far along it is and about how long is left.
# The progress goes to the window (fd 3 from quiet.sh) when there is one, so the
# log file only gets the start and end lines.
# Usage: download.py <url> <file>
import os
import sys
import time
import urllib.request

url, path = sys.argv[1:3]

try:
    window = os.fdopen(os.dup(3), "w")
except OSError:
    window = sys.stderr
live = window.isatty()


def mb(size):
    return f"{size / 1_000_000:.0f} MB"


def duration(seconds):
    seconds = int(seconds)
    if seconds < 60:
        return f"{max(seconds, 1)} sec"
    return f"{seconds // 60} min {seconds % 60} sec"


print(f"Downloading {url}", flush=True)
request = urllib.request.Request(url, headers={"User-Agent": "SteamDeckSTR"})
with urllib.request.urlopen(request, timeout=60) as response, open(path + ".part", "wb") as f:
    total = int(response.headers.get("Content-Length") or 0)
    done = 0
    start = shown = time.monotonic()
    while True:
        chunk = response.read(1 << 20)
        if not chunk:
            break
        f.write(chunk)
        done += len(chunk)
        now = time.monotonic()
        if live and now - shown >= 0.5:
            shown = now
            if total:
                left = (total - done) / (done / (now - start))
                line = f"  {done * 100 // total}% of {mb(total)}, about {duration(left)} left"
            else:
                line = f"  {mb(done)} so far"
            window.write(f"\r{line:<50}")
            window.flush()

if total and done != total:
    sys.exit(f"Download incomplete: got {done} of {total} bytes")
os.replace(path + ".part", path)

line = f"  Downloaded {mb(done)} in {duration(time.monotonic() - start)}"
print(line, flush=True)
if live:
    window.write(f"\r{line:<50}\n")
    window.flush()
