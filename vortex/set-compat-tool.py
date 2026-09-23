#!/usr/bin/env python3
# Selects a compatibility tool for one game in Steam's config.vdf (same as
# Properties > Compatibility > Force the use of a specific Steam Play compatibility tool).
# Steam must not be running, or it overwrites config.vdf on exit.
# Usage: set-compat-tool.py <config.vdf> <appid> <tool name>
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


def entry(appid, tool):
    return (
        f'\n\t\t\t\t\t"{appid}"\n\t\t\t\t\t{{\n'
        f'\t\t\t\t\t\t"name"\t\t"{tool}"\n'
        f'\t\t\t\t\t\t"config"\t\t""\n'
        f'\t\t\t\t\t\t"priority"\t\t"250"\n'
        f"\t\t\t\t\t}}"
    )


def main():
    path, appid, tool = sys.argv[1:4]
    with open(path, encoding="utf-8") as f:
        text = f.read()

    block = (0, len(text))
    for key in ("InstallConfigStore", "Software", "Valve", "Steam"):
        found = find_block(text, block[0] + (1 if block[0] else 0), block[1], key)
        if found is None:
            sys.exit(f"{key} not found in {path}")
        block = found

    mapping = find_block(text, block[0] + 1, block[1], "CompatToolMapping")
    if mapping is None:
        # No game has a forced tool yet, so add the whole CompatToolMapping block
        insert = '\n\t\t\t\t"CompatToolMapping"\n\t\t\t\t{' + entry(appid, tool) + "\n\t\t\t\t}"
        text = text[: block[1]].rstrip() + insert + "\n\t\t\t" + text[block[1] :]
    else:
        game = find_block(text, mapping[0] + 1, mapping[1], appid)
        if game is not None:
            # Replace the existing "<appid>" { ... } entry, key included
            key_start = text.rfind('"' + appid + '"', mapping[0], game[0])
            text = text[:key_start].rstrip() + entry(appid, tool) + text[game[1] + 1 :]
        else:
            text = text[: mapping[1]].rstrip() + entry(appid, tool) + "\n\t\t\t\t" + text[mapping[1] :]

    shutil.copy2(path, path + ".sdstr-backup")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"Set {tool} for app {appid}")


if __name__ == "__main__":
    main()
