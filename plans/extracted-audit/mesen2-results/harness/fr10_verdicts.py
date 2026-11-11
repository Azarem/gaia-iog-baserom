#!/usr/bin/env python3
"""FR10 verdict builder (read-only inputs, writes specs/FR10_flag_verdicts.json and raw/FR10_timeline.md).

Inputs: raw/FR10_timeline.json (fr10_timeline.py), raw/FR10_verify.json (fr10_verify.py), the registry fragments of plans/flags/results/registry.
One row per distinct (scene, flag): the registry record whose evidence offsets contain the offset of the setter COP that the run executed
(`setter` of the timeline row) is the record that the runtime run confirms; a flag change without such a record is `no record`.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
RES = os.path.dirname(HERE)
RAW = os.path.join(RES, "raw")

QUEUE_FOR = {  # queue items of other steps that this run also answers on the setter side (evidence only)
    (0x10, 8): ["FL20-01", "FL31-03", "FL30-05", "FL30-07"], (0x16, 2): ["FL20-02", "FL30-08"], (0x1C, 6): ["FL20-03", "FL30-09"], (0x3F, 10): ["FL32-40"],
}


def main():
    tl = json.load(open(os.path.join(RAW, "FR10_timeline.json"), encoding="utf-8"))
    rows = [r for r in tl["rows"] if r["flag"] != 255]
    groups = {}
    for r in rows:
        groups.setdefault((r["scene"], r["flag"]), []).append(r)
    out = []
    md = ["| frame | scene | flag | set/clear | player p09A2 | setter ROM offset (COP) | setter file:line | actor entry offset | registry record (fragment: name, grade) |", "|---:|---|---|---|---|---:|---|---:|---|"]
    for r in rows:
        st = r["setter"]
        offs = {o for x in r["registry"] for o in x["offsets"]}
        rec = [x for x in r["registry"] if st and st["offset"] in x["offsets"]] or r["registry"][:1]
        names = "; ".join(f"{x['fragment']}: {x['name'] or '(row)'}, {x['grade'] or '-'}" for x in rec) or "no record"
        md.append(f"| {r['frame']} | ${r['scene']:02X} | ${r['flag']:02X} | {r['op']} | ({r['player'][0]},{r['player'][1]}) | {st['offset'] if st else '-'} | "
                  f"{st['src'] if st else '-'} | {r['entryOffset']} | {names} |")
    for (scene, flag), grp in sorted(groups.items()):
        sets = [g for g in grp if g["op"] == "set"]
        clears = [g for g in grp if g["op"] == "clear"]
        first = grp[0]
        st = first["setter"]
        offs = {o for g in grp for x in g["registry"] for o in x["offsets"]}
        matched = [x for g in grp for x in g["registry"] if g["setter"] and g["setter"]["offset"] in x["offsets"]]
        rec = matched[0] if matched else (first["registry"][0] if first["registry"] else None)
        grades = [x["grade"] for x in (matched or first["registry"]) if x["grade"]]
        old = grades[0] if grades else None
        set_txt = clear_txt = None
        if sets:
            g = sets[0]
            set_txt = (f"set {len(sets)} time(s) in scene ${scene:02X}, first at frame {g['frame']} with the player at ({g['player'][0]},{g['player'][1]}), by the COP at ROM offset "
                       f"{g['setter']['offset'] if g['setter'] else '?'} ({g['setter']['src'] if g['setter'] else 'unresolved'})")
        if clears:
            g = clears[0]
            clear_txt = (f"cleared {len(clears)} time(s), first at frame {g['frame']} with the player at ({g['player'][0]},{g['player'][1]}), by the COP at ROM offset "
                         f"{g['setter']['offset'] if g['setter'] else '?'} ({g['setter']['src'] if g['setter'] else 'unresolved'})")
        verdict, grade = ("VERIFIED-RUNTIME", "VERIFIED-RUNTIME") if rec and matched else ("INCONCLUSIVE", old)
        out.append({"flag": flag, "scope": {"scenes": [scene]}, "queueId": ",".join(QUEUE_FOR.get((flag, scene), [])) or None,
                    "record": f"{rec['fragment']}: {rec['name']}" if rec else None, "verdict": verdict, "grade": grade,
                    "effects": {"set": set_txt, "clear": clear_txt}, "expectGrade": old,
                    "evidence": "FR10_20261104.md Timeline, rows of $%02X in scene $%02X (raw/FR10_chain_log.txt, raw/FR10_timeline.json); the registry record's evidence lists the setter offset" % (flag, scene)})
    # the queue items of this step
    verify = json.load(open(os.path.join(RAW, "FR10_verify.json"), encoding="utf-8"))
    n03 = verify["states"]["N03"]
    queue_rows = [
        {"flag": None, "scope": None, "queueId": "FL32-46", "verdict": "CONTRADICTED", "grade": "CONTRADICTED",
         "effects": {"set": "New Game through the title Start button (FC -> FA diary menu -> 08 church) sets no flag of the M01 list: $F4 stays clear until the first $10 (school lesson).", "clear": None},
         "expectGrade": "INFERRED",
         "evidence": "FR10_20261104.md Observations, rows FL32-46: the continuous run from orig_S06_title.mss (flags first change at frame 2919, $10, scene 08); control run: 3200 idle frames set $F4 at frame 3481 (store 45265 by the COP at 772466) and queue scene 8C"},
        {"flag": None, "scope": None, "queueId": "FL32-46", "verdict": "VERIFIED-RUNTIME", "grade": "VERIFIED-RUNTIME",
         "effects": {"set": "The 2516-tick idle path of the title sets $F4 (offset 772466) and queues scene 8C (prologue).", "clear": None}, "expectGrade": "INFERRED",
         "evidence": "FR10_20261104.md Observations (idle control run, raw/FR10_idle_control.txt)"},
        {"flag": None, "scope": None, "queueId": "FL32-47", "verdict": "VERIFIED-RUNTIME", "grade": "VERIFIED-RUNTIME",
         "effects": {"set": "M02 flags $10 $11 $12 $13 $14 $15 $16 $17 are all set after the school lesson, the three house narrations, the cave intro and Kara's news (natural state orig_N02 holds them).", "clear": None},
         "expectGrade": "INFERRED", "evidence": "FR10_20261104.md Timeline rows $10-$17; states-index orig_N02_wills_house_after_feast.mss"},
        {"flag": 0x20, "scope": {"scenes": [2]}, "queueId": "FL32-47", "verdict": "INCONCLUSIVE", "grade": "INFERRED",
         "effects": {"set": None, "clear": None}, "expectGrade": "INFERRED",
         "evidence": "FR10_20261104.md: $20 sc_cave_friends_idle (optional, marked * in the FL32 table) was not set on the natural route through the cave (no write to byte $0A04 bit 0 in the log)"},
        {"flag": None, "scope": None, "queueId": "FL32-48", "verdict": "VERIFIED-RUNTIME", "grade": "VERIFIED-RUNTIME",
         "effects": {"set": "M03 flags $3D $1B $3E $1C $1D $35 are set in this order by the evening, dinner and morning scenes of scene 06, and key item $09 sits in inventory slot 0 afterwards.", "clear": None},
         "expectGrade": "INFERRED", "evidence": "FR10_20261104.md Timeline rows scene 06; natural states N02 (before $35) and N03 (inventory slot 0 = $%s)" % n03["inventory0AB4"][:2]},
        {"flag": None, "scope": None, "queueId": "FL32-49", "verdict": "VERIFIED-RUNTIME", "grade": "VERIFIED-RUNTIME",
         "effects": {"set": "$3F is set by ec0A_left_guard at the castle gate (scene 0A) after the letter scene; the player is free afterwards at (504,704).", "clear": None},
         "expectGrade": "INFERRED", "evidence": "FR10_20261104.md Timeline row frame 20619 and states-index orig_N03_castle_gate.mss"},
        {"flag": None, "scope": None, "queueId": "FL32-50", "verdict": "INCONCLUSIVE", "grade": "INFERRED", "effects": {"set": None, "clear": None}, "expectGrade": "INFERRED",
         "evidence": "FR10_20261104.md: the route stops at the castle gate; the throne room, prison and aqueduct are not reached"},
        {"flag": None, "scope": None, "queueId": "FL41-01", "verdict": "INCONCLUSIVE", "grade": "INFERRED", "effects": {"set": None, "clear": None}, "expectGrade": "INFERRED",
         "evidence": "FR10_20261104.md Coverage: 0 of the 261 unreferenced bits (and no D3 bit of $019E-$01FF) changed in 20,079 frames over scenes FC FA 08 01 03 04 02 06 FE 0A; control fired (119 $36 writes and 119 NMI executions per 120 frames). One early-game route is not the whole game"},
    ]
    out = queue_rows + out
    with open(os.path.join(RES, "specs", "FR10_flag_verdicts.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1)
    with open(os.path.join(RAW, "FR10_timeline.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(md) + "\n")
    print(len(out), "verdict rows;", len(md) - 2, "timeline rows")


if __name__ == "__main__":
    main()
