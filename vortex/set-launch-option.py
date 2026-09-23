#!/usr/bin/env python3
# Adds or removes one environment variable in a game's Steam launch options
# (Properties > General > Launch Options) for every Steam account on this device,
# keeping whatever else the user has there. Steam must not be running, or it
# overwrites localconfig.vdf on exit.
# Usage: set-launch-option.py add|remove <steam root> <appid> <NAME=value>
import glob
import os
import re
import shutil
import sys

TOKEN = re.compile(r'"((?:\\.|[^"\\])*)"|([{}])')


def find_block(text, start, end, key):
    """Return (open, close) brace positions of child block `key` directly inside text[start:end]."""
    depth = 0
    last_key = None
    for m in TOKEN.finditer(text, start, end):
        if m.group(2) == "{":
            if depth == 0 and last_key is not None and last_key.lower() == key.lower():
                level = 0
                for m2 in TOKEN.finditer(text, m.start(), end):
                    if m2.group(2) == "{":
                        level += 1
                    elif m2.group(2) == "}":
                        level -= 1
                        if level == 0:
                            return m.start(), m2.start()
            depth += 1
            last_key = None
        elif m.group(2) == "}":
            depth -= 1
            last_key = None
        elif depth == 0:
            last_key = m.group(1) if last_key is None else None
    return None


def new_options(current, action, variable):
    parts = [p for p in current.split(" ") if p and p != variable]
    options = " ".join(parts)
    if action == "remove":
        return "" if options == "%command%" else options
    if "%command%" not in options:
        # Plain arguments go after the game, so keep them after %command%
        options = ("%command% " + options).strip()
    return variable + " " + options


def update(path, action, appid, variable):
    with open(path, encoding="utf-8") as f:
        text = f.read()

    block = (-1, len(text))
    for key in ("UserLocalConfigStore", "Software", "Valve", "Steam", "apps"):
        found = find_block(text, block[0] + 1, block[1], key)
        if found is None:
            return False
        block = found

    game = find_block(text, block[0] + 1, block[1], appid)
    if game is None:
        if action == "remove":
            return False
        entry = f'\n\t\t\t\t\t"{appid}"\n\t\t\t\t\t{{\n\t\t\t\t\t\t"LaunchOptions"\t\t"{new_options("", action, variable)}"\n\t\t\t\t\t}}'
        text = text[: block[1]].rstrip() + entry + "\n\t\t\t\t" + text[block[1] :]
    else:
        body = text[game[0] : game[1]]
        m = re.search(r'("LaunchOptions"\s+")((?:\\.|[^"\\])*)"', body)
        current = m.group(2).replace('\\"', '"').replace("\\\\", "\\") if m else ""
        value = new_options(current, action, variable)
        if value == current:
            return False
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        if m:
            body = body[: m.start(2)] + escaped + body[m.end(2) :]
        else:
            body = body.rstrip() + f'\n\t\t\t\t\t\t"LaunchOptions"\t\t"{escaped}"\n\t\t\t\t\t'
        text = text[: game[0]] + body + text[game[1] :]

    shutil.copy2(path, path + ".sdstr-backup")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    return True


def main():
    action, steam_root, appid, variable = sys.argv[1:5]
    for path in glob.glob(os.path.join(steam_root, "userdata", "*", "config", "localconfig.vdf")):
        if update(path, action, appid, variable):
            print(f"{'Added' if action == 'add' else 'Removed'} {variable} for app {appid} in {path}")


if __name__ == "__main__":
    main()
