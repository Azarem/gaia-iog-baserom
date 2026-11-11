#!/usr/bin/env python3
"""Assemble the FR40 result file sections that are tables (scenes, verdicts, lists) from raw/FR40_scene_table.json and the specs.
Writes raw/FR40_md_scenes.md, raw/FR40_md_verdicts.md, raw/FR40_md_lists.md, raw/FR40_md_obs.md (pasted into FR40_20261106.md by hand)."""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
import fr40_an as A  # noqa: E402
import fr40_report as R  # noqa: E402

RAW = fr40.RAW
T = json.load(open(os.path.join(RAW, "FR40_scene_table.json"), encoding="utf-8"))
SPEC = json.load(open(os.path.join(R.SPECS, "FR40_scene-flags.json"), encoding="utf-8"))
VERD = json.load(open(os.path.join(R.SPECS, "FR40_flag_verdicts.json"), encoding="utf-8"))


def esc(s):
    return str(s).replace("|", "/")


def flags_cell(i):
    d = i["draftFlags"]
    if not d:
        return "-"
    mf = i["minFlags"]
    sid = i["scene"]
    if sid == 6:
        return "draft 29,37,61; with flag 22 set: 61 frees, 29/37 do not"
    if mf:
        return f"draft {','.join(map(str, d))} → {','.join(map(str, mf))}"
    if i["sceneVerdict"] == "INCONCLUSIVE":
        return f"draft {','.join(map(str, d))}: no lock to skip from S01r"
    return f"draft {','.join(map(str, d))}: lock stays (CONTRADICTED)"


def entry_cell(i):
    d = i["dest"]
    return "quick" if not d else f"{d[0]},{d[1]},{d[2]},${d[3]:04X}"


def scenes_md():
    out = ["| Scene | Class | Quick warp | Entry used (x,y,facing,scroll) | Entries free/blocked | Arrival `$065A` / `$09AE` | No input | A pulses | Flags | Verdict |",
           "|---|---|---|---|---|---|---|---|---|---|"]
    for k in sorted(T, key=int):
        i = T[k]
        sid = int(k)
        ents = i["entries"]
        nb = len(i["blockedEntries"])
        ec = f"{len(ents) - nb}/{nb}" if ents else "-"
        no_in = (i["noInput"] or "-").replace("no input: ", "")
        mash = (i["mash"] or "-").replace("A pulses: ", "")
        out.append(f"| ${sid:02X} | {i['class']} | {i['aState']} | {entry_cell(i)} | {ec} | {R.hx(i['arrival']['mask0'])} / {R.hx(i['arrival']['pf0'])} | {esc(no_in)} | {esc(mash)} | "
                   f"{esc(flags_cell(i))} | {i['sceneVerdict']} |")
    return "\n".join(out)


def verdicts_md():
    out = ["| ID | Verdict (plain sentence) | Grade | Note shipped today (file:line) | Action |", "|---|---|---|---|---|"]
    for k in sorted(T, key=int):
        i = T[k]
        sid = int(k)
        if str(sid) in SPEC:
            sent = SPEC[str(sid)]["note"]
        else:
            sent = i["reason"]
        shipped = "db-us/scene-flags.json:4 \"stays nonzero\"" if sid == 10 else "-"
        if sid == 10:
            verdict = "CONTRADICTED"
            action = "scene-flags spec: replace the note (`expectOld` in specs/FR40_scene-flags.json)"
        else:
            verdict = i["sceneVerdict"]
            if str(sid) in SPEC:
                action = "scene-flags spec entry" + (" (differs from the FL32 draft)" if i["draftEntry"] != SPEC[str(sid)]["entry"] or (i["draftFlags"] and i["draftFlags"] != SPEC[str(sid)]["flags"]) else "")
            else:
                action = "not shipped; needs a story-state preset (FR50)"
        out.append(f"| SC-${sid:02X} | {esc(sent)} | {verdict} | {shipped} | {action} |")
    for v in VERD:
        out.append(f"| FLAG-{v['flag']} scenes {','.join('$%02X' % s for s in v['scope']['scenes'])} | set: {esc(v['effects']['set'])} clear: {esc(v['effects']['clear'])} | {v['verdict']} | "
                   f"registry grade now {v['expectGrade']} | flag verdict {v['queueId']} |")
    return "\n".join(out)


def lists_md():
    out = []
    # needs-spawn
    out.append("### Scenes whose quick warp lands in a wall, a pocket or a hazard (class needs-spawn-position)")
    out.append("| Scene | Quick warp | Warp x,y,facing,scroll that works |")
    out.append("|---|---|---|")
    for k in sorted(T, key=int):
        i = T[k]
        if i["class"] == "needs-spawn-position":
            d = i["dest"]
            a = A.rows[int(k)]["a"]
            why = "game over at frame %s (HP 0)" % next((t["n"] for t in a["tl"] if t["pf"] & 0x200), "?") if i["aState"] == "gameover" else i["aState"]
            out.append(f"| ${int(k):02X} | {why} | x={d[0]} y={d[1]} facing={d[2]} scroll=${d[3]:04X} (actor at x+8, y+16) |")
    # draft diffs
    out.append("")
    out.append("### FL32 draft versus observation")
    out.append("| Scene | Draft | Observed | Detail |")
    out.append("|---|---|---|---|")
    for k in sorted(T, key=int):
        i = T[k]
        obs = i["class"]
        dr = i["draftEntry"]
        ofree = obs in ("free", "needs-spawn-position")
        diff = None
        if dr == "free" and obs == "cutscene":
            bl = ", ".join(i["blockedEntries"])
            diff = f"free entries {len(i['entries']) - len(i['blockedEntries'])} of {len(i['entries'])}; locked from the warp rows {bl}"
        elif dr == "cutscene" and ofree:
            diff = "no arrival lock from the S01r story state (the draft lock depends on other story flags)" if i["draftFlags"] or int(k) == 0xE0 else "no arrival lock"
        elif dr == "locked-until-flag":
            diff = "the guard dialogue ends when A is pressed (flag 63 is set by the script); it is a cutscene, not a permanent lock"
        elif dr == "unknown":
            diff = "menu or overlay scene; see the note of the spec entry"
        elif dr == "cutscene" and obs == "cutscene" and i["draftFlags"] and i["minFlags"] != i["draftFlags"]:
            diff = f"the draft flags {i['draftFlags']} do not free the arrival; the lock ends by itself (see verdict rows)"
        if diff:
            out.append(f"| ${int(k):02X} | {dr} {i['draftFlags'] or ''} | {obs} | {esc(diff)} |")
    return "\n".join(out)


def obs_md():
    L = []
    def b(sid, var):
        r = A.rows[sid][var]
        L.append(fr40.brief(r)[:260])
    L.append(open(os.path.join(RAW, "FR40_h1_end.txt"), encoding="utf-8").read().splitlines()[0])
    for sid, var in [(10, "ctl_without63"), (10, "ctl_with63"), (10, "g_none"), (10, "g_mash"), (10, "g_draft"), (41, "g_none"), (41, "g_draft"), (85, "g_none"),
                     (85, "g_draft"), (6, "g_pre"), (6, "g_sub61"), (6, "g_sub29+37"), (44, "g_draft"), (121, "g_draft"), (145, "g3_mash"), (120, "g3_mash"),
                     (89, "g_none"), (250, "g_mash"), (231, "g_none"), (166, "hp_a"), (210, "hp_n1"), (19, "g2_none"), (14, "g2_none"), (224, "g2_f212")]:
        try:
            b(sid, var)
        except KeyError:
            pass
    return "\n".join(L[:40])


if __name__ == "__main__":
    for name, fn in (("scenes", scenes_md), ("verdicts", verdicts_md), ("lists", lists_md), ("obs", obs_md)):
        with open(os.path.join(RAW, f"FR40_md_{name}.md"), "w", encoding="utf-8") as f:
            f.write(fn())
    print("ok")
