#!/usr/bin/env python3
"""R1 result writer: raw/R1_acc.json (+ the folded probes), raw/R1_ranges.json, raw/R1_legs.json -> R1_20261109.md and R1_20261109_lua.md.
Read-only on everything but the two result files. The verdicts are assigned here, per row, from the counters (rules in the text of the result file)."""
import contextlib
import io
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.abspath(os.path.join(HERE, ".."))
RAW = os.path.join(RES, "raw")

spec = importlib.util.spec_from_file_location("r1r", os.path.join(HERE, "r1_report.py"))
M = importlib.util.module_from_spec(spec)
_argv = sys.argv
sys.argv = ["x"]
with contextlib.redirect_stdout(io.StringIO()):
    spec.loader.exec_module(M)
sys.argv = _argv

ROWS, A, LEGS = M.R, M.A, M.LEGS
BYID = {}
for r in ROWS:
    BYID.setdefault(r["id"], []).append(r)
CDLS = json.load(open(os.path.join(RAW, "R1_cdl_stats.json")))

CAMLEGS_EARLY = None
VR, VS, CO, IN = "VERIFIED-RUNTIME", "VERIFIED-STATIC", "CONTRADICTED", "INCONCLUSIVE"
out = []          # verdict rows: (id, label, offset, exec, starts, read, cdl, verdict, note)


def acc(r):
    return A[r["req"]]


def row_of(id_, name, start=None):
    for r in BYID[id_]:
        if r["name"] == name and (start is None or r["start"] == start):
            return r
    raise KeyError((id_, name))


def cdl(a):
    f = a["cdlFlags"]
    s = "".join(c for b, c in ((1, "C"), (2, "D"), (4, "J"), (8, "S")) if f & b) or "-"
    return f"{s} ({a.get('cdlCodeBytes', 0)}c/{a.get('cdlDataBytes', 0)}d)"


CAMLEGS_EARLY = len(A[[x for x in BYID["I049-7"] if "control" in x["name"]][0]["req"]]["legs"])


def add_row(id_, r, verdict, note, label=None):
    a = acc(r)
    off = f"{r['start']}..{r['end']}"
    out.append((id_, label or r["name"], off, a["exec"], a["execFirstByte"], a["read"], cdl(a), verdict, note))


def add_text(id_, label, off, ex, st, rd, cd, verdict, note):
    out.append((id_, label, off, ex, st, rd, cd, verdict, note))


# ------------------------------------------------------------------------------------------------------ never-referenced code (UNREF method group)
STATIC_NOTE = {
    "I034-3": "no label reference; 24-bit hits for K / K+3 (6) lie in gfx / spritemap / music data (`R1_static.txt`); the 6 same-bank 16-bit hits for K lie in an unmapped stretch of bank 08 with random-looking bytes and no stride-2 neighbours",
    "I038-4": "no label reference; 0 pointer hits (24-bit and 16-bit)",
    "I045-4": "no label reference besides notes; 24-bit hits 0; one 16-bit hit (730705) inside `gfx_pyramid_sprites`",
    "I048-4": "no label reference; 24-bit hit for K+3 inside `bgm_blessing_of_nature` data; 16-bit hits inside `gfx_pyramid_sprites` / `spm_solidarm`",
    "I049-1": "no label reference; one 24-bit hit for K inside `set_euro` (tileset data); no table pointer",
    "I057-2": "no label reference besides the block note; 24-bit hit for `DiaryJoypadFilter_noref` inside `gfx_tunnel_enemies`; 16-bit hit for `DiaryIncCounter_noref` K+3 inside `spm_mine_sprites`",
    "I057-5": "no label reference; 0 pointer hits",
}
for id_ in ("I034-3", "I038-4", "I045-4", "I048-4", "I049-1"):
    for r in BYID[id_]:
        a = acc(r)
        assert a["exec"] == 0 and a["read"] == 0, (r["name"], a["exec"], a["read"])
        add_row(id_, r, VR, "never executed, never read in the coverage (exec 0, read 0, CDL none); static: S-" + id_)
add_text("I034-3", "idle_sprite_display: touching it gives 5 gems (GiveItemToPlayer `$85`, `NullActorScriptStub` replaces it)", "589055..589077", 0, 0, 0, "-", IN,
         "the actor is never spawned, so the touch path was not exercised; needs a debug spawn (not part of R1)")

for r in BYID["I049-7"]:
    if "control" in r["name"]:
        add_row("I049-7", r, VR, "control: the controller was executed in %d recorded runs (legs and probes; the exec figure is a byte sum, not a rate)" % CAMLEGS_EARLY)
    else:
        a = acc(r)
        assert a["exec"] == 0
        add_row("I049-7", r, VR, "never executed while `camera_scroll_controller` ran (control row below); static: S-I049-7")

for r in BYID["I050-5"]:
    a = acc(r)
    if "words 0-7" in r["name"]:
        add_row("I050-5", r, VR, "read by `camera_drift` (`LDA camera_drift_offsets,Y`): the first 8 words are the live table")
    else:
        assert a["read"] == 0 and a["exec"] == 0
        add_row("I050-5", r, VR, "words 8-15 never read in the coverage (CDL none); static: S-I050-5")

for r in BYID["I057-2"]:
    a = acc(r)
    if "control" in r["name"]:
        add_row("I057-2", r, VR, "control: diary menu executed (`x_diary_seeded`, `menu_diary`)")
    else:
        assert a["exec"] == 0 and a["read"] == 0, r["name"]
        add_row("I057-2", r, VR, "never executed in the diary sessions (title to diary, two saved slots, cursor, A, Y, cancel) or elsewhere; static: S-I057-2")

for r in BYID["I057-5"]:
    a = acc(r)
    if "control" in r["name"]:
        add_row("I057-5", r, VR, "control: the title comet actor ran (boot, natural)")
    else:
        assert a["exec"] == 0 and a["read"] == 0
        add_row("I057-5", r, VR, "never executed over the title (cold boot 9,000 frames, `natural`); static: S-I057-5. Palette bundle `$2D` pointer reads: see the I060-5 rows")

for r in BYID["I023-5"]:
    a = acc(r)
    if "control" in r["name"]:
        add_row("I023-5", r, VR, "control: `TileQueryGate` (same file) executed")
    else:
        assert a["exec"] == 0
        add_row("I023-5", r, VR, "never executed in any leg (CDL none); static: S-I023-5")

# ------------------------------------------------------------------------------------------------------ I039-4
for r in BYID["I039-4"]:
    if r["name"] == "NorthProbeRedirect":
        add_row("I039-4", r, VR, "executed (153 entries in the sweeps). Data-flow probe (`R1_probe_north_probe.json`, 5 entries, scene `$01`): at the entry and at `loc_02D208` (ROM 184840) the `$00` word, SP, D, DBR and the M/X bits are equal in 5 of 5; between them only X (+`$10`, `MapCellDown`), A and the carry change, and `MapCellLeft` reloads both from `$00` (`tile_collision.asm`, tag 189280) so the pair is dead")
    else:
        add_row("I039-4", r, VR, "control: the dispatcher jump to `NorthProbeRedirect` target executed")

# ------------------------------------------------------------------------------------------------------ I072-3
I72 = {r["name"]: r for r in BYID["I072-3"]}
for nm in ("consolestring_01E82B", "consolestring_01E834", "consolestring_01E83D", "consolestring_01E846", "consolestring_01E851", "consolestring_01E85C"):
    r = I72[nm]
    a = acc(r)
    assert a["read"] == 0
    extra = ""
    if nm == "consolestring_01E851":
        extra = "; its K+3 16-bit hit (102294) lies in a `scene_warps` rectangle record (coordinates, not a pointer field)"
    add_row("I072-3", r, VR, "never read (read 0, CDL none) in coverage; static: S-I072-3" + extra)
for nm in ("thinker_spawn_0CE8E6", "thinker_spawn_0CE9EA", "thinker_spawn_0CEA45"):
    r = I72[nm]
    add_row("I072-3", r, VR, "never parsed as a list: over all 228 scene ids (`R1_probe_thinker_full.json`) only the first byte is read, as the high byte of a 16-bit load that overruns the previous list's `$FF` (pc `$83:D802/D812/D840/D846`); " + ("the other bytes were read once in scene `$AA` by a block move (Observation 1); " if nm != "thinker_spawn_0CE8E6" else "") + "no table word points at the list start (table scan, 256 entries)")
for nm in ("consolestring_01E641 (Shadow placeholder)", "consolestring_01E64B (Shadow placeholder)", "consolestring_01E6C0 (Shadow placeholder)", "consolestring_01E6CA (Shadow placeholder)"):
    r = I72[nm]
    add_row("I072-3", r, VR, "read when the Status tab of form 2 lists its slots (`status_f2`: `$0AD4` = 2, `$0AA2` = `$7777` written in the loaded `orig_S09_inventory` state): reached through the ability name / description tables, not dead")
for nm in ("consolestring_01E655 (Shadow placeholder)", "consolestring_01E6D4 (Shadow placeholder)"):
    r = I72[nm]
    add_row("I072-3", r, IN, "the range is a superset: it also covers the pointer-table words that follow the string (Observation 5); the read count cannot be assigned to the string bytes alone, the string needs its own narrow range")
for nm in ("consolestring_01E7B9 ('Dark 1', ability description)", "consolestring_01E7BE ('Dark 1', ability description)", "consolestring_01E7C3 ('Dark 1', ability description)"):
    r = I72[nm]
    add_row("I072-3", r, VR, "read in the form-2 Status probe (descriptions of slots `$09`-`$0B`)")
r = I72["consolestring_01E7C8 ('Dark 1', ability description)"]
add_row("I072-3", r, VR, "never read: it is `ability_description_table[0C]`; the Status tab builds the index as form x 4 + slot + 1 with slots 0-2 only, so the largest index it reads is `$0B` (`ability_description_table[0C]` pointer row: read 0 in every probe)")
for nm in ("consolestring_01E614 (control: Spin Dash name / description)", "consolestring_01E6F6 (control: Spin Dash name / description)", "consolestring_01E73C (control: Spin Dash name / description)"):
    r = I72[nm]
    add_row("I072-3", r, VR, "control: Will Status tab read it (`status_f0`)")

# ------------------------------------------------------------------------------------------------------ I042-1
for r in BYID["I042-1"]:
    a = acc(r)
    if r["name"] == "SpawnItemSparkleEffect":
        add_row("I042-1", r, IN, "natural reach not seen: exec 0 over all legs incl. drop probes (low HP, 6 combat scenes). The 82 reads are one byte (56579): the high byte of the 16-bit opcode fetch `LDA [$0A]` of `CopDispatch` for the COP at 56578 in the preceding script (`R1_probe_sparkle_reader.json`, pc `$80:847B` = `cop_dispatch` tag 33915, A = 56576 / 56578), not an access to the actor. Entry with a poked item id: VERIFIED-RUNTIME in G2 (`G2_20261109.md` row OQ-I042-1)")
    elif r["name"] == "AppendSparkleOamEntries":
        add_row("I042-1", r, IN, "not executed in R1 coverage; executed in G2 with the poked heal id")
    elif "heal branch" in r["name"]:
        add_row("I042-1", r, IN, "heal branch not reached by a natural drop in R1 (exec 0; probe `final.healDropBodies` 0 in the drop scenes). The 10 reads (leg `sweep_will_600_14`) are not attributed to a reader; the COP did not run")
    else:
        add_row("I042-1", r, VR, "control: `GiveItemToPlayer` executed (chests, gems)")

# ------------------------------------------------------------------------------------------------------ I065-4
for r in BYID["I065-4"]:
    a = acc(r)
    if "control" in r["name"]:
        add_row("I065-4", r, VR, "control: mode 0 entry executed")
    else:
        assert a["exec"] == 0
        add_row("I065-4", r, VR, "never executed over 228 scene loads x 3 forms, title, diary, world map, credits, game over (every scene record runs this interpreter); static: S-I065-4")

# ------------------------------------------------------------------------------------------------------ I068-5
for r in BYID["I068-5"]:
    a = acc(r)
    if r["name"] in ("ForcedWalkWest", "ForcedWalkEast"):
        add_row("I068-5", r, VR, "never executed (the 1 read of `ForcedWalkWest` is its first byte, the same pattern as 56579, not traced); static: S-I068-5")
    elif r["name"] == "StartForcedWalk":
        add_row("I068-5", r, VR, "control: 5 forced walks executed (north / south: `natural`, `warp_chain`)")
    elif "bit 5 branch" in r["name"]:
        add_row("I068-5", r, VR, "control: the bit-5 test (`BNE`) ran 5 times and was not taken (3-byte row = `BNE` + first byte of the next instruction)")
    else:
        add_row("I068-5", r, VR, "control: executed")

# ------------------------------------------------------------------------------------------------------ I063-1 shared words
SW = {}
for r in BYID["I063-1"]:
    m_ = re.match(r"shared_word_table\[(\w+)\] pointer", r["name"])
    if m_:
        SW[m_.group(1)] = acc(r)["read"]
used = sorted(k for k, v in SW.items() if v)
never = sorted(k for k, v in SW.items() if not v)
for k in ("00", "03", "0D"):
    r = row_of("I063-1", f"shared_word_table[{k}] pointer")
    add_row("I063-1", r, VR, "never selected: `ConsoleCmd_InsertSharedWord` executed (control row below) with other indices only; static: S-I063-1")
add_text("I063-1", "other indices read (context)", "125711..125740", 0, 0, sum(SW[k] for k in used), "D", VR,
         "selected: " + ", ".join("$" + k for k in used) + " (inventory menu, Status tab, title / credits strings)")
add_text("I063-1", "other indices never selected (context, not asked)", "125711..125740", 0, 0, 0, "-", IN,
         "never selected in coverage: " + ", ".join("$" + k for k in never if k not in ("00", "03", "0D")) + " (these have vanilla `[LU:n]` tags, so they are shown by strings the coverage did not display)")
r = row_of("I063-1", "ConsoleCmd_InsertSharedWord")
add_row("I063-1", r, VR, "control: executed (`menu_inventory`, Status tab probes, credits)", label="ConsoleCmd_InsertSharedWord (control)")


# ------------------------------------------------------------------------------------------------------ index tables
def table_idx(id_, prefix):
    d = {}
    for r in BYID[id_]:
        m_ = re.match(prefix + r"\[(\w+)\] (ptr|list@\d+)", r["name"])
        if m_:
            e = d.setdefault(m_.group(1).upper(), {})
            e[m_.group(2)[:4]] = (acc(r)["read"], r["start"])
    return d


def rng(s):
    a, b = s.split("-")
    return [f"{i:02X}" for i in range(int(a, 16), int(b, 16) + 1)]


def idx_rows(id_, prefix, setname, asked, ctx_note, base=None):
    d = table_idx(id_, prefix)
    asked_all = []
    for a_ in asked:
        asked_all += rng(a_) if "-" in a_ else [a_]
    asked_all = [i for i in asked_all if i in d]
    rd = [i for i in asked_all if d[i].get("ptr", (0,))[0]]
    nv = [i for i in asked_all if not d[i].get("ptr", (0,))[0]]
    first = d[min(d)]["ptr"][1]
    last = max(v["ptr"][1] for v in d.values())
    off = f"{first}..{last + 1}"
    if rd:
        add_text(id_, f"{setname}: asked indices selected", off, 0, 0, sum(d[i]["ptr"][0] for i in rd), "D", VR,
                 "pointer read (anim selected) in coverage: " + " ".join("$" + i for i in rd) + " (" + ctx_note + ")")
    if nv:
        add_text(id_, f"{setname}: asked indices never selected", off, 0, 0, 0, "-", IN,
                 "pointer and frame list never read (CDL none) in coverage: " + " ".join("$" + i for i in nv) + ". A stager that takes the index from RAM is not excluded by the operand grep, and R3 is not available: zero is not proof")
    others_rd = [i for i in sorted(d) if i not in asked_all and d[i]["ptr"][0]]
    others_nv = [i for i in sorted(d) if i not in asked_all and not d[i]["ptr"][0]]
    if others_rd or others_nv:
      add_text(id_, f"{setname}: other indices (context)", off, 0, 0, sum(d[i]["ptr"][0] for i in others_rd), "D", IN if others_nv else VR,
             f"selected {len(others_rd)} of {len(others_rd) + len(others_nv)}; never selected: " + (" ".join("$" + i for i in others_nv) or "none"))


idx_rows("I067-4", "spriteset_transform_poses", "spriteset_transform_poses (body row 5)", ["04", "0C", "11"], "the seven `Transform_*` routines were entered by the forced-entry session `f_transform_forced` (FORCED: pointer written into the player actor, as the statue dialogues do), plus `x_p18_gaia_rich`")
add_text("I067-4", "spriteset_transform_poses `$0A` (staged by a script per the question) never selected", "1032212..1032213", 0, 0, 0, "-", IN,
         "the question lists `$0A` as staged by a `Transform_*` script, yet no pointer read of `$0A` in `f_transform_forced`: that routine or its precondition is not reproduced by the forced entry (new question)")
idx_rows("I068-2", "spriteset_npc_props", "spriteset_npc_props (npc props)", ["03", "09"], "any scene")
add_text("I068-2", "spriteset_npc_props `$0A` (not asked) never selected", "973332..973333", 0, 0, 0, "-", IN, "same: never selected in coverage")
idx_rows("I064-4", "spriteset_will", "spriteset_will (Will)", ["04-07", "10-13", "14-17"], "`$10`-`$13` are selected by the Gold Ship / chest / Dark Space scripts (`f_goldship`, `chest_1D`, `natural`); `$04`-`$07` and `$14`-`$17` never")
idx_rows("I063-2", "spriteset_freedan", "spriteset_freedan (Freedan)", ["04-07", "14-17", "1C-29", "3E-41", "4A-4B"], "ramps / ladders / vines, Freedan replays `*_f1` and sweep forms")
idx_rows("I066-5", "spriteset_shadow", "spriteset_shadow (Shadow)", ["19-1C", "1D-25", "2E-31", "34-35"], "Shadow replays `*_f2` and the sweeps; `$19`-`$1C` come from the Shadow-only scenes (`$E7`, `$E8`)")
idx_rows("I072-6", "spriteset_will_abilities", "spriteset_will_abilities (was `spriteset_will_alt`)", ["08-0B", "1E", "21", "23-26"], "Psycho Dash, Slider, Spin Dash from `f_will_dash`, `f_will_slider`; the credits")
add_text("I072-6", "body row serving `$03` (open since OQ-I061-1)", "(not measured)", 0, 0, 0, "-", IN, "R1 counts ROM reads of the animation tables, not the body-table row; the row of `$0AC8` was not logged in R1")
d = table_idx("I069-1", "spriteset_shadow_fx")
add_text("I069-1", "spriteset_shadow_fx (body row 7): all 14 animations never selected", "%d..%d" % (min(v["ptr"][1] for v in d.values()), max(v["ptr"][1] for v in d.values()) + 1), 0, 0, 0, "-", IN,
         "0 pointer reads in every leg, including the forced `Transform_*` routines (all three forms) and `f_shadow_aura`; the operands used in `extracted/` are `$04`, `$05`, `$06`, `$08`; a writer of `$0AC8` that bypasses the COP was not searched (R3), so not proof")
idx_rows("I069-2", "spriteset_pickups_effects", "spriteset_pickups_effects (was `spriteset_enemies`)", [f"{i:02X}" for i in range(0x3F)], "enemies, pickups, effects selected in the sweeps and sessions")
add_text("I069-2", "what the other animations show / which actors use them", "(not measured)", 0, 0, 0, "-", IN, "R1 shows which indices are selected, not which actor selects them; per-actor selection needs the `Stage*` operand per actor (static)")

# palette bundles
PB = {}
for r in BYID["I060-5"]:
    m_ = re.match(r"palette_bundles\[(\w+)\] pointer", r["name"])
    PB[m_.group(1)] = acc(r)["read"]
pbr = sorted(k for k, v in PB.items() if v)
pbn = sorted(k for k, v in PB.items() if not v)
add_text("I060-5", "palette bundles started (pointer read)", "1474560..1474815", 0, 0, sum(PB.values()), "D", VR,
         f"{len(pbr)} of 128 bundle pointers read: " + " ".join("$" + k for k in pbr))
add_text("I060-5", "palette bundles never started in coverage", "1474560..1474815", 0, 0, 0, "-", IN,
         f"{len(pbn)} of 128: " + " ".join("$" + k for k in pbn) + ". Not proof: R3 / a static list of every `animScratch+2` operand was not done; `$2D` is the `TitlePaletteStep_noref` bundle (I057-5)")

# move chains
MC = {}
for r in BYID["I062-4"]:
    m_ = re.match(r"move_chain_table\[(\w+)\] pointer", r["name"])
    MC[m_.group(1)] = acc(r)["read"]
mcr = sorted(k for k, v in MC.items() if v)
mcn = sorted(k for k, v in MC.items() if not v)
for k in ("21", "3D", "4C", "4D", "4E"):
    r = row_of("I062-4", f"move_chain_table[{k}] pointer")
    a = acc(r)
    if a["read"]:
        add_row("I062-4", r, VR, "chain selected in coverage (pointer read %d); the user is not identified by R1" % a["read"])
    else:
        add_row("I062-4", r, IN, "never selected in coverage; a user could be a movement operand built from RAM (not excluded)")
add_text("I062-4", "other chains selected (context)", "110726..110895", 0, 0, sum(v for k, v in MC.items() if k not in ("21", "3D", "4C", "4D", "4E")), "D", VR, f"{len([k for k in mcr if k not in ('21','3D','4C','4D','4E')])} of the remaining 80 chains read")
add_text("I062-4", "chains never selected in coverage (context)", "110726..110895", 0, 0, 0, "-", IN, ("never read: " + " ".join("$" + k for k in mcn if k not in ("21", "3D", "4C", "4D", "4E"))) + ". Not proof (the operands of the COP movement ops were not collected)")

# B001-1 / I056-7
r = BYID["B001-1"][0]
add_row("B001-1", r, IN, "`spm_darkspace_sprites` is a compressed file (Quintet LZ): the ROM counters see only the compressed bytes (13,149 reads: the decompression loads in `x_g2_s6d_will` and `x_diary_seeded`, CDL data 567 bytes); animation #04-#09 selection is not visible in ROM counters; needs the animation index `$28` of the actor under scene `$10` or reads of the decompressed copy in WRAM", label="spm_darkspace_sprites (compressed)")
r2 = dict(r)
add_text("I056-7", "spm_darkspace_sprites effects #04-#09 / scene `$10`", "1910209..1910775", 0, 0, acc(r)["read"], cdl(acc(r)), IN, "same row as B001-1: compressed, so the question is not answered by ROM counters")

# --------------------------------------------------------------------------------------------------------------- write result file
legs = LEGS
nlegs = len(legs)
frames = sum(l.get("frames", 0) or 0 for l in legs)
nmi = sum(l.get("nmi", 0) or 0 for l in legs)
kinds = {}
for l in legs:
    k = {"scene sweep": "scene sweeps", "session": "sessions", "cold boot (fro": "cold boot", "recorded input": "recorded input"}.get(l.get("kind", "")[:14], l.get("kind"))
    e = kinds.setdefault(k, [0, 0, 0])
    e[0] += 1
    e[1] += l.get("frames", 0) or 0
    e[2] += l.get("nmi", 0) or 0
lowl = min((l for l in legs if l.get("frames")), key=lambda l: l["nmi"] / l["frames"])
LOW = (lowl["frames"], lowl["nmi"])
assert lowl["leg"] == "x_s10_will", lowl["leg"]
CAMLEGS = len(acc(row_of("I049-7", "camera_scroll_controller (control)"))["legs"])
cnt = {VR: 0, VS: 0, CO: 0, IN: 0}
for o in out:
    cnt[o[7]] += 1
ids_in_order = []
for o in out:
    if o[0] not in ids_in_order:
        ids_in_order.append(o[0])

L = []
w = L.append
w("# R1 Execution coverage (ROM O): UNREF group, tables and spriteset rows")
w("")
w("ROM: O")
w("File: `rebuilt/Illusion of Gaia.smc` (original retail ROM, HiROM, header title \"ILLUSION OF GAIA USA\"; no build mode applies to O)")
w("SHA-1: 38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3   size: 2,097,152   CRC-32: 1c3848c0 (the values of the run log `raw/R1_run_1.log` and of E4)")
w("`artifacts/crc.json`: `mode` = `plain`, `sha1` = `0cfcb55863052af92041107ecc28226d9f89f8aa` (file time 2026-10-31 10:51). That file describes the R build `rebuilt/Illusion of Gaia - Rebuilt.smc`, not O; it is recorded because the plan asks for it and is not used for any O number.")
w("Server: Mesen2 MCP 0.6.0 or later (`get_server_status`, `get_access_summary` with `rangesPath`, `get_cdl_statistics`, `save_cdl`, `load_cdl`); flags `--mcp-lib-dir=...\\kit\\lib`, `--mcp-results-dir=...\\raw`.")
w("")
w("## State")
w("")
w("No new savestate was written. Every leg loads a state of `rebuilt/states/` (`orig_*`, all with a sidecar SHA-1 equal to the loaded ROM; `romCheck: match`) and runs the H1 validity test first (load, 120 frames, `cpu.k` in `$80-$BF`, `cpu.sp` in `$0100-$01FF`, `sceneCurrent` as expected): H1 passed on %d loads (`raw/R1_legs.json`, field `h1`). The boot leg starts from power (`fromReset: power`, no state). States used: `orig_S01r_south-cape-ready` (all sweeps, the W1-f ability sessions), the `orig_P00..P18` progress states (boss approach), `orig_N01..N03`, `orig_S07_diary`, `orig_S09_inventory`, `orig_S10..S12` combat rooms (Will / Freedan / Shadow), `orig_S12b`, `orig_S13`, `orig_S14*` slope scenes, `orig_G2_*`, `orig_G3_*`, `orig_C1_*` chests, `orig_M2_diary_seeded`, `orig_E4_credits`, `orig_S16`. No state became stale." % sum(1 for l in legs if l.get("h1") and l["h1"].get("ok")))
w("")
w("## Static prelude")
w("")
w("`harness/r1_static.py` -> `raw/R1_static.txt`: for each unreferenced label (key K, CPU address `$bb:aaaa`) a byte search of ROM O for the 24-bit little-endian pointer to K and to K+3 (the actor-def entry after its 3-byte header), the same-bank 16-bit pointer, and `rg -w <label> extracted baserom db-us/files.json db-us/overrides.json`. This is the R3 method on ROM O; the R3 result file is not present yet, so every R3 reference below is to my own `R1_static.txt`. `harness/r1_hits.py` classified every hit by `blocks.json` / `files.json` containment:")
w("")
w("- all 24-bit hits (22 of 24 offsets) lie inside graphics, tilemap, tileset, spritemap, music or `scene_warps` records (random byte coincidence with the 3-byte pattern); 258011 is the known `COP SpawnListAppend ( @SpawnItemSparkleEffect ...)` operand; 399067 (`33 FA 9A 03 DD C0`, bank `C0`) lies outside every `blocks.json` / `files.json` entry and its bytes look like compressed data, so it is unclassified, not a pointer table;")
w("- the 6 same-bank 16-bit hits for `idle_sprite_display` (531097..556692) lie in the unmapped stretch 518439..557056 of bank 08; the bytes around them (`21 10 0D FF FC 1D`, `FE 7A F2 34 35 21 00 20 FF FC 7A`, ...) have no stride-2 table structure;")
w("- `rg` found no code reference by name for any UNREF label other than notes and the label definition itself.")
w("- `scene_warps` ROM parse (`python`, read-only): 200 lists, 543 scene warps, 200 forced-walk warps, forced-walk byte 6 high nibble `$8` x100 and `$4` x100.")
w("- `scene_thinkers` table scan (256 words at 845285): no word equals the start of `0CE8E6`, `0CE9EA` or `0CEA45`; the nearest entries are `0CE8EF`, `0CE8F4`, `0CE8F9`, `0CE906`, `0CE9FB`, `0CEA08`, `0CEA52`, `0CEA5B`.")
w("")
w("## Script")
w("")
w("Run by `harness/r1_run.py` (resumable, one process per batch; `run_script` of 400,000 frames can wedge the Cursor-registered server, so each batch is its own Python process that drives the server through `harness/mcp_client.py`). Legs: `boot` (cold boot, 9,000 frames, no input), `natural` (recorded `FR10_early_game.input`: title to the castle gate), `sessions` (the 42 W1-a/b sessions: seeded bots, direction patterns, quick warps, slope scenes, chests, menus, warp chains, credits), `extra` (16 sessions: combat rooms and boss approaches with the rich bot, game over, credits, seeded diary, inventory), `ability` (the 8 W1-f sessions: Psycho Dash / Slider / Spin Dash, Dark Friar, Aura Barrier, Shadow Aura item, Gold Ship cutscenes, Dark Space statues, forced `Transform_*`), `forms` (34 sessions: the slope, chest, warp, boss-approach and mine sessions replayed as Freedan and Shadow with `$0AD4` = 1 / 2, `$0AA2` = `$0077`), and the three scene sweeps (`e2.sweep`: write `$0642`, dismiss the banner, `post` NMI frames with a direction pattern and B / A presses, HP refilled). After every leg: `get_access_summary {type:\"prgRom\", rangesPath: raw/R1_ranges_req.json, cdl:true}` over 1,099 named ranges (decimal keys of `db-us/names/bankNN.json`), summed into `raw/R1_acc.json`; the `exec` figure is the sum over the bytes of the range (not a rate), `execFirstByte` counts starts. `save_cdl` -> `raw/R1_cdl_union.cdl` after each leg (`load_cdl merge:true` on resume); `get_cdl_statistics` -> `raw/R1_cdl_stats.json`. The Lua of every leg is verbatim in `R1_20261109_lua.md` (the sweep template, the session wrapper `acen.run{...}`, the probes).")
w("")
w("Targeted probes (their counters are folded into the totals, each is a separate run of the same ROM): `thinker_overrun`, `thinker_full` (all 228 scenes, post 40), `thinker_sweep` (scenes `$4D-$59`, post 600), `north_probe`, `sparkle_read`, `sparkle_reader`, `drop_lowhp_*` / `drop_roll_*` (low HP and forced-roll drop scenes), `status_f0/f1/f2` (inventory Status tab per form). Files `raw/R1_probe_<name>.json` hold result and Lua.")
w("")
w("## Positive control")
w("")
w("`NmiHandler` (ROM 33528) is range `CTRL`; its `execFirstByte` is the number of NMIs. Total over all legs: %d NMI entries for %d recorded frames (the sweep legs record frames = measured NMI count). Every one of the %d legs has a nonzero NMI count and all but the cold boot (no state) have an `H1` record; the lowest NMI-to-frame ratio is `x_s10_will` (%d NMI entries in %d recorded frames; the cause was not examined and that leg carries no absence claim of its own). `camera_scroll_controller` is the second control (I049-7): its range was executed in %d legs." % (nmi, frames, nlegs, LOW[1], LOW[0], CAMLEGS))
w("")
w("| Kind | Legs | Frames | NMI entries |")
w("|------|------|--------|-------------|")
for k, (n, f, m_) in kinds.items():
    w(f"| {k} | {n} | {f:,} | {m_:,} |")
w(f"| **total** | {nlegs} | {frames:,} | {nmi:,} |")
w("")
w("## Coverage")
w("")
w(f"- **Frames:** {frames:,} frames in {nlegs} legs (about {frames / 60 / 3600:.1f} hours of game time) plus the 20 probe runs.")
w("- **Scenes:** the three sweeps loaded each of the 228 scene ids of `artifacts/scenes.json` (the ids `00 09 14 48 4A 57 76 77 80 81 84 9E 9F AA AB AF C1 C2 CA CB EB EC ED EE EF F1 F8 F9` have no entry there and were not warped to; scene `$AA` appeared as `sceneCurrent` about 700 frames into the `$4D-$59` chunk of the Will sweep, so something in a scene warped there in-game): Will 600 frames per scene (10 s, 138,709 frames), Freedan and Shadow 150 frames per scene (2.5 s, 38,702 frames each); no scene timed out. Scenes `$FE` (world map) and `$FF` (inventory) were swept without the banner step.")
w("- **Forms and buttons:** Will, Freedan and Shadow. Directions (8-way pattern), physical B (attack, held 160-190 frames in the ability sessions), A (interact; banner), Y (item), X, L / R (Spin Dash, Aura Barrier). Abilities: Psycho Dash, Psycho Slider, Spin Dash (`f_will_dash`, `f_will_slider`), Dark Friar and Aura Barrier (`f_freedan_aura`), the Aura item as Shadow (`f_shadow_aura`). Earthquaker, Psycho Slider from a slope and the Freedan / Shadow vine and ladder staging were not reached.")
w("- **Menus and screens:** cold boot and title (9,000 frames), the diary menu (`menu_diary`, `x_diary_seeded` with two saved slots), the inventory overlay and its four tabs (`menu_inventory`, `x_s09_inventory_rich`, `status_f0/f1/f2` through the Status tab for all three forms), the world map (`$FE`), credits (`x_credits` 5,200 frames, `warp_credits`), game over (`x_gameover`).")
w("- **Story coverage:** the recorded early game (title to the castle gate), the 19 progress states `P00-P18` (new game to Dark Gaia) with the seeded bots (1,200-1,500 frames each), Castoth and mine melee bots; no dungeon was played through by input, the later bosses run from their approach states.")
w(f"- **CDL (union, `get_cdl_statistics`):** code {CDLS['codeBytes']:,} bytes, data {CDLS['dataBytes']:,} bytes, of {CDLS['totalBytes']:,} (HiROM PRG): {100 * CDLS['codeBytes'] / CDLS['totalBytes']:.1f} % flagged as code. The CDL flag \"data\" is also set by block-move reads (Observation 1), so it is not evidence of a table read.")
w("- **Not covered (limits of the absence claims):** natural enemy drops of the heal item, Earthquaker, vines and ladders for Freedan and Shadow, the second-slot and diary save screens beyond two seeded slots, event-flag-dependent scenes beyond the states of the progress list, and anything that needs more than 600 frames in a scene.")
w("")
w("## Observations")
w("")
w("1. **Block moves read bytes that no routine parses.** In scene `$AA` a block move running from the WRAM mirror (`$82:0406`) reads 846315..846330 and 846406..846417 in sequence (X and Y +1, A -1 per byte). These are the all-bytes reads that first made `thinker_spawn_0CE9EA` and `0CEA45` look \"touched\" (17 and 13 bytes). The record loop of `SpawnSceneThinkers` reads only the first byte of each (the high byte of a 16-bit load across the previous list's `$FF`, pc `$83:D802/D812/D840/D846`). A read counter over a data range therefore needs the reader's pc before it counts as use.")
w("2. **A 16-bit opcode fetch reads one byte past a script.** The 82 reads of ROM 56579 (first byte of `SpawnItemSparkleEffect`) are `LDA [$0A]` in `CopDispatch` (`cop_dispatch` tag 33913, pc `$80:847B`) fetching the COP signature at 56578 (the last COP of `SpawnDamageNumberEffect`) as a word. The same pattern is the likeliest source of the single read of `ForcedWalkWest` (60483); that one was not traced by a callback.")
w("3. **`NorthProbeRedirect` pair is dead (5 of 5 entries).** At the entry and at `loc_02D208` the `$00` word, SP, D and DBR are equal; X (+`$10`) and A and the carry differ after the pair but `MapCellLeft` reloads X and A from `$00`. The shipped part note still says \"Everything here is UNVERIFIED-RUNTIME\" (see Notes spec).")
w("4. **Ability name / description tables.** Status tab, form 0 reads `ability_name_table[01-03]`, form 1 `[05-07]`, form 2 `[09-0B]` and the matching description pointers: the index is form x 4 + slot + 1 with slots 0-2 (`[00]`, `[04]`, `[08]` of the name, menu and description tables and `ability_description_table[0C]` are never read; the 4 reads of the \"`ability_name_table[0C]`\" row are the string bytes of `BLACK4K`, Observation 5). The Shadow placeholder strings `DEFENCERK`, `DARKCOREK`, `BLACK4K` and 'Dark 1' are read in the form-2 probe, so they are reachable through the tab when the Shadow ability bits of `$0AA2` are set (`$7777` written in the probe; whether the game ever sets bits 8-10 was not checked).")
w("5. **Range definition caveat.** The `ability_name_table[0C]` row is the first 2 bytes of the string `BLACK4K` and the rows `consolestring_01E655` and `consolestring_01E6D4` extend over the pointer tables that follow the string; their read counts mix string and table bytes (verdict INCONCLUSIVE for those two rows).")
SEL = {k: sum(1 for v in table_idx(i, k).values() if v["ptr"][0]) for i, k in (("I064-4", "spriteset_will"), ("I063-2", "spriteset_freedan"), ("I066-5", "spriteset_shadow"), ("I072-6", "spriteset_will_abilities"), ("I069-2", "spriteset_pickups_effects"), ("I067-4", "spriteset_transform_poses"))}
w("6. **Coverage depth.** Animation pointers selected: Will %d of 72, Freedan %d of 76, Shadow %d of 76, `spriteset_will_abilities` %d of 39, `spriteset_pickups_effects` %d of 63, `spriteset_transform_poses` %d of 19. The Will table's `$04`-`$07` and `$14`-`$17` were never selected by any of the 133 legs or the 20 probes; the unread Freedan and Shadow ranges `$1D`-`$29` and `$3E`-`$4B` need states (vine, ladder, ledge, flight) that the replays did not reach." % (SEL["spriteset_will"], SEL["spriteset_freedan"], SEL["spriteset_shadow"], SEL["spriteset_will_abilities"], SEL["spriteset_pickups_effects"], SEL["spriteset_transform_poses"]))
w("")
w("## Verdicts")
w("")
w(f"Rule used: a zero count is VERIFIED-RUNTIME (negative) only when (a) the control rows of the same range family ran in the same legs, (b) the coverage statement above lists what was driven, and (c) my own pointer scan (`R1_static.txt`, the R3 method on ROM O) found no reference; otherwise a zero count is INCONCLUSIVE. Index tables (sprite animations, palette bundles, move chains): a pointer read proves the index is selected (VERIFIED-RUNTIME); a zero never proves absence because a stager can take the index from RAM (INCONCLUSIVE). Full per-range counters (1,099 ranges, exec / starts / read / write / CDL / top legs): `raw/R1_table.md`.")
w("")
w(f"**Totals (rows below): VERIFIED-RUNTIME {cnt[VR]}, VERIFIED-STATIC {cnt[VS]}, CONTRADICTED {cnt[CO]}, INCONCLUSIVE {cnt[IN]}.**")
w("")
STAT = {
 "S-I034-3": STATIC_NOTE["I034-3"], "S-I038-4": STATIC_NOTE["I038-4"], "S-I045-4": STATIC_NOTE["I045-4"], "S-I048-4": STATIC_NOTE["I048-4"], "S-I049-1": STATIC_NOTE["I049-1"],
 "S-I057-2": STATIC_NOTE["I057-2"], "S-I057-5": STATIC_NOTE["I057-5"],
 "S-I049-7": "no branch or jump operand names `CameraDeadBoundsX/Y`; the stubs are `LDA cameraBoundsX/Y, BRA` after an unconditional branch (`extracted/actors/camera_scroll_controller.asm:22`); the only pattern hits lie in `map_pyramid_dangerslide_a` data (24-bit) and a bank-00 data stretch (16-bit)",
 "S-I050-5": "the index is masked to 3 bits (`AND #$0007`, `ASL`; `extracted/functions/camera_drift.asm:22`); the only pointers to the table are the base address `$00:D068` inside that code (16-bit hits at 53255 / 53301, `R1_static.txt`)",
 "S-I023-5": "no `COP [DrawMetatileStream]` / `[DrawMetatileStreamDelay]` site in `extracted/` (only the `cop_dispatch` table words), no `COP [OrExtraFlags]` operand with bit `$0004` set (every site in `extracted/`), no `ORA #$0004` or `LDA #$0004` + `STA $extendedFlags` (multi-line `rg`, 2026-11-09)",
 "S-I065-4": "whole-file operand counts of the question (bitmap modes 255 / 62 / 2 / 0; tilemap flags `$01` and `$02` only)",
 "S-I068-5": "ROM parse of `scene_warps`: 200 lists, 543 scene warps, 200 forced-walk warps, byte 6 high nibble `$8` x100 (north) and `$4` x100 (south), bits 4/5 never set; `scrollStepTableBase` is written only inside `forced_walk.asm` (`rg`)",
 "S-I063-1": "no `[LU:0]`, `[LU:3]` or `[LU:D]` tag in any string of `extracted/` (the three `rg` hits are the comments `No vanilla [LU:n] tag` of `extracted/tables/shared_word_table.asm:51, 60, 83`)",
 "S-I072-3": "no label reference besides notes (`rg`); the few 24-bit hits (`01E82B` at 197380; `01E834`+3 at 1233177 and 1376061) lie in graphics / tilemap data and the `01E851`+3 hit at 102294 in a `scene_warps` rectangle record: byte coincidences, no pointer table",
}
w("Static notes referenced by the rows (R1_static.txt, `rg`, ROM parses):")
w("")
for k, v in STAT.items():
    w(f"- **{k}**: {v}.")
w("")
w("| Id | Label | Offset (decimal) | Exec (byte sum) | Exec starts | Read | CDL flags | Verdict | Evidence |")
w("|----|-------|------------------|-----------------|-------------|------|-----------|---------|----------|")
order = ["OQ-I072-3", "OQ-I023-5", "OQ-I034-3", "OQ-I038-4", "OQ-I039-4", "OQ-I045-4", "OQ-I048-4", "OQ-I049-1", "OQ-I049-7", "OQ-I050-5", "OQ-I057-2", "OQ-I057-5", "OQ-I067-4", "OQ-I068-2",
         "B001-1", "I056-7", "I042-1", "I060-5", "I062-4", "I063-1", "I063-2", "I064-4", "I065-4", "I066-5", "I068-5", "I069-1", "I069-2", "I072-6"]
alias = {"I072-3": "OQ-I072-3", "I023-5": "OQ-I023-5", "I034-3": "OQ-I034-3", "I038-4": "OQ-I038-4", "I039-4": "OQ-I039-4", "I045-4": "OQ-I045-4", "I048-4": "OQ-I048-4", "I049-1": "OQ-I049-1",
         "I049-7": "OQ-I049-7", "I050-5": "OQ-I050-5", "I057-2": "OQ-I057-2", "I057-5": "OQ-I057-5", "I067-4": "OQ-I067-4", "I068-2": "OQ-I068-2", "I042-1": "OQ-I042-1", "I060-5": "OQ-I060-5",
         "I062-4": "OQ-I062-4", "I063-1": "OQ-I063-1", "I063-2": "OQ-I063-2", "I064-4": "OQ-I064-4", "I065-4": "OQ-I065-4", "I066-5": "OQ-I066-5", "I068-5": "OQ-I068-5", "I069-1": "OQ-I069-1",
         "I069-2": "OQ-I069-2", "I072-6": "OQ-I072-6", "B001-1": "OQ-B001-1", "I056-7": "OQ-I056-7"}
order = ["OQ-I072-3", "OQ-I023-5", "OQ-I034-3", "OQ-I038-4", "OQ-I039-4", "OQ-I045-4", "OQ-I048-4", "OQ-I049-1", "OQ-I049-7", "OQ-I050-5", "OQ-I057-2", "OQ-I057-5", "OQ-I067-4", "OQ-I068-2",
         "OQ-B001-1", "OQ-I056-7", "OQ-I042-1", "OQ-I060-5", "OQ-I062-4", "OQ-I063-1", "OQ-I063-2", "OQ-I064-4", "OQ-I065-4", "OQ-I066-5", "OQ-I068-5", "OQ-I069-1", "OQ-I069-2", "OQ-I072-6"]
by_oq = {}
for o in out:
    by_oq.setdefault(alias[o[0]], []).append(o)
for q in order:
    for o in by_oq.get(q, []):
        w("| %s | %s | %s | %s | %s | %s | %s | **%s** | %s |" % (q, o[1].replace("|", "/"), o[2], f"{o[3]:,}", o[4], f"{o[5]:,}", o[6], o[7], o[8].replace("|", "/")))
w("")
w("## Tool issues")
w("")
w("- T-80 (new, in `tool-issues.md`): a `run_script` without `e2.sweep` after an `e2.sweep` `run_script` in the same server session ends with `done` and no result (2 of 2); workaround: sweep legs and probes in separate server sessions.")
w("- T-81 (new, in `tool-issues.md`): `get_access_summary` with two ranges that share the same `start` returns both rows with the length of the later range (`{start:846314,length:17}` plus `{start:846314,length:1}` gave two rows of length 1). The R1 ranges file has unique starts per request, so no R1 number is affected (checked: the 1,099 range starts of `raw/R1_ranges.json` are all distinct).")
w("- Documentation / harness notes (not tool issues): `emu.addMemoryCallback` reports 24-bit CPU addresses (T-78); the CDL \"data\" flag is set by block-move reads, so a data-flagged row is not a table-read proof.")
w("")
w("## Notes spec")
w("")
w("One shipped part note is stale: `extracted/system/player/player_move_ns.asm:36` (\"Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code.\"): the dead-pair claim of lines 34 and 389-391 is now runtime-checked. Draft `specs/R1_notes.json` (block note edit); checked with `npm run merge -- plans/extracted-audit/mesen2-results/specs/R1_notes.json --dry-run` (1 block note would change, `notes/blockNotes/bank02.json`). No names spec: no name or label is wrong.")
w("")
w("No other shipped sentence is contradicted: `camera_scroll_controller.asm:22` (never branched to), `camera_drift.asm:22` (only 8 words used), `cop_handlers_metatile.asm:3` and `:9` (no script site; nothing sets `extendedFlags` bit 2), `SpawnItemSparkleEffect.asm:5` (`$86` reachable through `DropBodyHeal5`), `scene_thinkers.asm:16` (three unreferenced lists), `forced_walk` / `scene_warps` (no east or west walk) and `sFA_diary_menu.asm:38` (nine `_noref` routines) agree with the counters.")
w("")
w("## New questions")
w("")
w("- Which routine runs the block move at `$82:0406` in scene `$AA` (frame about 700 of the Will sweep), and what span does it copy (the reads seen are 846315..846330 and 846406..846417)?")
w("- Which `Transform_*` routine, with which precondition, stages animation `$0A` of `spriteset_transform_poses` (the forced entry of the seven routines never selected it)?")
w("- Does any natural flow set the Shadow ability bits (8-10) of `$0AA2`, so that the Shadow placeholder strings appear in the Status tab?")
w("- Which actor of the Freedan and Shadow vine, ladder and ledge states selects the animations `$1D`-`$29` and `$3E`-`$4B` of their tables (the replays on the slope scenes did not reach them)?")
w("- What is the compressed data `spm_darkspace_sprites` animation `#04-#09` use in scene `$10`: the animation index `$28` of the actor in that scene needs a breakpoint, not a ROM counter.")
w("- Is the single read of `ForcedWalkWest` (ROM 60483) also the `CopDispatch` word fetch of the preceding script's last COP? (needs a read callback on 60483 in a forced-walk scene)")
w("")
open(os.path.join(RES, "R1_20261109.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")

# --------------------------------------------------------------------------------------------------------------- lua file
LU = []
x = LU.append
x("# R1 Lua scripts and legs (verbatim)")
x("")
x("Companion of `R1_20261109.md`. The wrapper of every session leg is `acen.run{...}` (kit `a_census.lua`, the positive control is the `$36` write count `control36Writes` in its result) built by `harness/r1_run.py lean_lua`; the sweep Lua is the template `SWEEP_LUA`; the probes are in `harness/r1_probe*.py` and in `raw/R1_probe_<name>.json` (field `lua`).")
x("")
x("## Scene sweep template (`harness/r1_run.py`, `SWEEP_LUA`, filled with form, post and the 12 / 40 scene ids of the chunk)")
x("")
x("```lua")
sw = [l for l in open(os.path.join(HERE, "r1_run.py"), encoding="utf-8").read().split('SWEEP_LUA = r"""')[1].split('"""')[0].split("\n")]
x("\n".join(sw))
x("```")
x("")
x("## Session legs")
x("")
seen = set()
for l in legs:
    if l.get("lua") and l["leg"] not in seen:
        seen.add(l["leg"])
        x(f"### {l['leg']} (state `{l.get('state')}`, {l.get('frames')} frames, NMI {l.get('nmi')})")
        x("")
        x("```lua")
        x(l["lua"])
        x("```")
        x("")
x("## Probes")
x("")
import glob
for f in sorted(glob.glob(os.path.join(RAW, "R1_probe_*.json"))):
    d = json.load(open(f, encoding="utf-8"))
    if d.get("lua"):
        x(f"### {d.get('name', os.path.basename(f))} (`raw/{os.path.basename(f)}`, state `{d.get('state')}`)")
        x("")
        x("```lua")
        x(d["lua"])
        x("```")
        x("")
x("## Legs table")
x("")
x("| Leg | Kind | State | Frames | NMI | H1 |")
x("|-----|------|-------|--------|-----|----|")
for l in legs:
    x(f"| {l['leg']} | {str(l.get('kind', ''))[:40]} | {l.get('state')} | {l.get('frames')} | {l.get('nmi')} | {'ok' if (l.get('h1') or {}).get('ok') else '-'} |")
open(os.path.join(RES, "R1_20261109_lua.md"), "w", encoding="utf-8").write("\n".join(LU) + "\n")
print("rows", len(out), cnt)
