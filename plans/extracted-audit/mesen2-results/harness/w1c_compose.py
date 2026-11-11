#!/usr/bin/env python3
"""Compose the W1-c result file from harness/w1c_result_template.md: pastes the verbatim kit and driver Lua, the generated tables, the scene list and the raw log lines.
usage: w1c_compose.py   (writes ../W1-c_20261107.md)
"""
import json
import os
import re

from a_common import RAW

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "W1-c_20261107.md")
DATE = "20261107"

LOG_PICKS = [
    ("boot_power", ("0A00 write", "0A80-0AA7 write", "0AEC-0AEF write"), 3),
    ("f0s_15", ("0A00 bit0 change",), 2),
    ("f0s_2C", ("0A00 bit0 change",), 1),
    ("t_flag01", ("0A00 write", "0A00 read"), 4),
    ("t_kill_c", ("0AEC-0AEF change",), 4),
    ("t_kill_d", ("0A80-0AA7 change", "0AEC-0AEF change"), 5),
    ("t_boss_reward", ("0A80-0AA7 read", "0A80-0AA7 change", "0AEC-0AEF change"), 6),
    ("t_wmclear", ("0A80-0AA7 change",), 2),
    ("t_gameover_lt100", ("0A80-0AA7 change",), 2),
]


def load(name):
    return json.load(open(os.path.join(RAW, f"W1c_{name}_{DATE}.json"), encoding="utf-8"))


def main():
    t = open(os.path.join(HERE, "w1c_result_template.md"), encoding="utf-8").read()
    kit = open(os.path.join(os.path.dirname(HERE), "kit", "lib", "w1c_kit.lua"), encoding="utf-8").read().rstrip("\n")
    t = t.replace("@@KIT@@", kit)
    for m in set(re.findall(r"@@DRIVER:([A-Za-z0-9_]+)@@", t)):
        t = t.replace(f"@@DRIVER:{m}@@", load(m)["lua"].rstrip("\n"))
    t = t.replace("@@TABLES@@", open(os.path.join(RAW, "W1c_tables.md"), encoding="utf-8").read().rstrip("\n"))
    rep = open(os.path.join(RAW, "W1c_report.md"), encoding="utf-8").read().split("\n")
    i = rep.index("## Scenes visited (frames, sum)")
    t = t.replace("@@SCENES@@", "`" + rep[i + 2].strip() + "`")
    lines = []
    for name, keys, cap in LOG_PICKS:
        got = [f"{name} | {e['text']}" for e in load(name)["log"]["entries"] if any(e["text"].startswith(k) for k in keys)]
        lines += got[:cap]
    lines = lines[:38]
    t = t.replace("@@LOGN@@", f"{len(lines)} of the run logs").replace("@@LOG@@", "\n".join(lines))
    open(OUT, "w", encoding="utf-8").write(t)
    print("wrote", OUT, t.count("\n"), "lines;", len(lines), "log lines")


if __name__ == "__main__":
    main()
