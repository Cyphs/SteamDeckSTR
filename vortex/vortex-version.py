#!/usr/bin/env python3
# Prints the installed Vortex version (from package.json inside app.asar), or nothing
# Usage: vortex-version.py <path to resources/app.asar>
import json
import struct
import sys

try:
    with open(sys.argv[1], "rb") as f:
        # asar: 16 byte pickle header, then the JSON file index, then the file data
        header = f.read(16)
        index_size = struct.unpack("<I", header[12:16])[0]
        index = json.loads(f.read(index_size))
        entry = index["files"]["package.json"]
        f.seek(8 + struct.unpack("<I", header[4:8])[0] + int(entry["offset"]))
        print(json.loads(f.read(entry["size"]))["version"])
except (OSError, KeyError, ValueError):
    pass
