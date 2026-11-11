#!/usr/bin/env python3
"""FR10 early-game capture driver (server 0.6.0, ROM O).

usage (from this folder):
  python fr10.py run <leg> [--from <state|tmp:name>] [--frames N] [--save tmp:name] [--shot label]
        run harness/fr10_legs/<leg>.lua (an fr10.bot program, includes fr10_steps) from a state; writes raw/FR10_<leg>.rle
        (the run-length input the bot pressed: "frames:button+button" words), prints the log rows, the step rows and the end status.
  python fr10.py replay <rle-file> [--from <state|tmp:name>] [--save tmp:name] [--shot label]
        play an rle file with play_input (frame-exact segments) from a state and print the end status (the alignment test of the
        Lua-driven discovery run against the play_input replay).
  python fr10.py status [--from <state|tmp:name>]
        load a state and print the status, the nonzero flag bytes and the live actors.

State names: a path, or `tmp:<name>` = rebuilt/states/tmp_FR10_<name>.mss (disposable discovery states). Every command opens a fresh
server session, loads ROM O, checks its SHA-1 and writes only under mesen2-results/ and rebuilt/states/. Nothing here edits the
baserom.
"""
import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import RAW, STATE_DIR, BASEROM, actor_table, open_session  # noqa: E402

O_SHA1 = "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
LEGS = os.path.join(HERE, "fr10_legs")
TITLE = os.path.join(STATE_DIR, "orig_S06_title.mss")


def state_path(name):
    if name is None:
        return TITLE
    if name.startswith("tmp:"):
        return os.path.join(STATE_DIR, f"tmp_FR10_{name[4:]}.mss")
    return name if os.path.isabs(name) else os.path.join(STATE_DIR, name)


def parse_rle(text):
    out = []
    for word in text.split():
        n, b = word.split(":", 1)
        out.append({"frames": int(n), "buttons": [] if b == "-" else b.split("+")})
    return out


def status(m):
    w = m.mem(0x0640, 0x20)

    def u16(a):
        return w[a - 0x640] | (w[a - 0x640 + 1] << 8)

    st = {
        "frame36": m.u16(0x36), "next": u16(0x642), "scene": u16(0x644), "mask": u16(0x65A), "banner": m.u8(0xB4),
        "playerFlags": m.u16(0x9AE), "displayMode": m.u16(0x9EC), "pos": (m.u16(0x1014), m.u16(0x1016)), "p09A2": (m.u16(0x9A2), m.u16(0x9A4)),
        "hp": m.u16(0xACE),
    }
    return st


def flags_nonzero(m):
    raw = m.mem(0x0A00, 180)
    return {f"{0x0A00 + i:04X}": f"{b:02X}" for i, b in enumerate(raw) if b}


def set_flags(raw):
    out = []
    for i, b in enumerate(raw):
        for bit in range(8):
            if (b >> bit) & 1:
                out.append(i * 8 + bit)
    return out


def fmt_status(st):
    return (f"scene=${st['scene']:02X} next=${st['next']:04X} mask=${st['mask']:04X} banner=${st['banner']:02X} playerFlags=${st['playerFlags']:04X} "
            f"dmf=${st['displayMode']:04X} actor=({st['pos'][0]},{st['pos'][1]}) p09A2=({st['p09A2'][0]},{st['p09A2'][1]}) hp={st['hp']} $36={st['frame36']}")


def open_o():
    m, info = open_session()
    assert info["fileSha1"] == O_SHA1, f"unexpected ROM {info['fileSha1']}"
    return m, info


def maybe_shot(m, label):
    if label:
        r = m.shot(label)
        print("screenshot:", os.path.relpath(r["path"], BASEROM))


def maybe_save(m, name, meta):
    if name:
        path = state_path(name)
        m.call("save_state_file", path=path, note="FR10 disposable discovery state", meta=meta)
        print("saved:", os.path.relpath(path, BASEROM))


def cmd_run(a):
    m, _ = open_o()
    try:
        m.call("load_state_file", path=state_path(a.from_state))
        with open(os.path.join(LEGS, a.leg + ".lua"), encoding="utf-8") as f:
            code = f.read()
        r = m.run_script_checked(code, name="fr10_" + a.leg, includes=["fr10_steps"], frames=a.frames, turbo=True, timeoutMs=900000, maxLog=300)
        for e in r["log"]["entries"]:
            t = e.get("text", "")
            if t.startswith(("Loading script", "Registered memory", "Script loaded")):
                continue
            print("LOG", t)
        res = r["result"]
        for s in res.get("steps", []):
            print("STEP", s)
        print("FINAL", res.get("final"), "| reason", res.get("reason"), "| totalFrames", res.get("totalFrames"))
        with open(os.path.join(RAW, f"FR10_{a.leg}.rle"), "w", encoding="utf-8") as f:
            f.write(res.get("rle", "") + "\n")
        for k, v in res.items():
            if k not in ("rle", "steps", "final", "reason", "totalFrames"):
                print("RESULT", k, v)
        st = status(m)
        print("STATUS", fmt_status(st))
        maybe_shot(m, a.shot)
        maybe_save(m, a.save, {"scene": st["scene"], "flags": set_flags(m.mem(0x0A00, 180)), "form": "Will", "disposable": True})
    finally:
        m.close()


def cmd_replay(a):
    m, _ = open_o()
    try:
        m.call("load_state_file", path=state_path(a.from_state))
        with open(a.rle, encoding="utf-8") as f:
            seq = parse_rle(f.read())
        # play_input is frame-exact; chunk the sequence so a single call stays small
        for i in range(0, len(seq), 200):
            m.call("play_input", sequence=seq[i:i + 200], turbo=True, thenPause=True)
        st = status(m)
        print("STATUS", fmt_status(st))
        maybe_shot(m, a.shot)
        maybe_save(m, a.save, {"scene": st["scene"], "flags": set_flags(m.mem(0x0A00, 180)), "form": "Will", "disposable": True})
    finally:
        m.close()


CHAIN = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "16b", "17", "18", "19", "20", "21", "22", "23", "24"]
CHAIN_STATES = {"4": "orig_N01_sc_first_free.mss", "20": "orig_N02_wills_house_after_feast.mss", "24": "orig_N03_castle_gate.mss"}
CHUNK = 30
SHOT_CAP = 220


def cmd_chain(a):
    """One continuous run from the title state: record_input over the play_input replay of every leg's rle, the persistent flag/scene/mask
    logger (fr10.start, loaded with load_script), a screenshot at every scene change and every dialog, the natural states at the leg ends in
    CHAIN_STATES and a signature (scene, p09A2, flag array) at every leg end."""
    m, info = open_o()
    tsv, sigs = [], []
    try:
        m.call("load_state_file", path=TITLE)
        code = "local h = fr10.start{cap = 900, sceneCap = 300, maskCap = 300}\nemu.mcp.result({ok = true})\n"
        m.call("load_script", name="fr10_chain_log", code=code, includes=["fr10_kit"])
        rec = os.path.join(RAW, "FR10_early_game.input")
        m.call("record_input", action="start", path=rec, startState=TITLE)
        seq_all, bounds = [], {}
        for leg in CHAIN:
            with open(os.path.join(RAW, f"FR10_leg{leg}.rle"), encoding="utf-8") as f:
                segs = parse_rle(f.read())
            seq_all.extend((leg, sg) for sg in segs)
            # the bot's last frame (no button) is not part of its rle: a play_input replay needs it to land on the same $36
            seq_all.append((leg, {"frames": 1, "buttons": []}))
        shots, last_scene, last_dialog_shot, frames, pending_scene = 0, m.u16(0x644), -999, 0, None
        last_leg = None
        buf = []

        def flush():
            nonlocal frames, last_scene, shots, last_dialog_shot, pending_scene
            if not buf:
                return
            m.call("play_input", sequence=list(buf), turbo=True, thenPause=True)
            frames += sum(x["frames"] for x in buf)
            buf.clear()
            sc, dmf, ban = m.u16(0x644), m.u16(0x9EC), m.u8(0xB4)
            reason = None
            if pending_scene is not None and frames - pending_scene[0] >= 60:
                reason, pending_scene = f"scene ${pending_scene[1]:02X}", None
            if sc != last_scene:
                pending_scene, last_scene = (frames, sc), sc
            if reason is None and ((dmf & 0x2000) or ban) and frames - last_dialog_shot >= 90:
                reason, last_dialog_shot = "dialog" if dmf & 0x2000 else "banner", frames
            if reason and shots < SHOT_CAP:
                shots += 1
                r = m.shot(f"FR10_chain_{shots:03d}_s{sc:02X}")
                tsv.append(f"{frames}	{sc:02X}	{reason}	{os.path.relpath(r['path'], BASEROM)}")

        used = 0
        for i, (leg, sg) in enumerate(seq_all):
            left = sg["frames"]
            while left > 0:
                take = min(left, CHUNK - used)
                buf.append({"frames": take, "buttons": sg["buttons"]})
                used += take
                left -= take
                if used >= CHUNK:
                    flush()
                    used = 0
            nxt = seq_all[i + 1][0] if i + 1 < len(seq_all) else None
            if nxt != leg:
                flush()
                used = 0
                st = status(m)
                raw = m.mem(0x0A00, 180)
                sigs.append({"leg": leg, "frames": frames, "scene": st["scene"], "p09A2": st["p09A2"], "flags": set_flags(raw)})
                print(f"LEG {leg} end frames={frames} scene=${st['scene']:02X} p09A2={st['p09A2']} mask=${st['mask']:04X}")
                if leg in CHAIN_STATES:
                    path = os.path.join(STATE_DIR, CHAIN_STATES[leg])
                    m.call("save_state_file", path=path, note=f"FR10 natural state after leg {leg} (real input from orig_S06_title.mss)",
                           meta={"scene": st["scene"], "flags": set_flags(raw), "form": "Will", "natural": True})
                    print("saved:", os.path.relpath(path, BASEROM))
        m.call("record_input", action="stop")
        rows = []
        seq = 0
        while True:
            r = m.call("get_script_log", sinceSeq=seq)
            ents = r.get("entries", [])
            if not ents:
                break
            rows.extend(e["text"] for e in ents)
            seq = r["nextSeq"]
        with open(os.path.join(RAW, "FR10_chain_log.txt"), "w", encoding="utf-8") as f:
            f.write("\n".join(rows) + "\n")
        with open(os.path.join(RAW, "FR10_chain_shots.tsv"), "w", encoding="utf-8") as f:
            f.write("frame\tscene\treason\tfile\n" + "\n".join(tsv) + "\n")
        with open(os.path.join(RAW, "FR10_chain_sigs.json"), "w", encoding="utf-8") as f:
            json.dump(sigs, f)
        print("log rows:", len(rows), "shots:", shots, "frames:", frames)
        print("FINAL", fmt_status(status(m)))
    finally:
        m.close()


def cmd_status(a):
    m, _ = open_o()
    try:
        m.call("load_state_file", path=state_path(a.from_state))
        st = status(m)
        print("STATUS", fmt_status(st))
        print("FLAGS", flags_nonzero(m))
        print("SET", [f"{n:04X}" for n in set_flags(m.mem(0x0A00, 180))])
        for ac in actor_table(m):
            print("ACTOR", f"slot=${ac['slot']:04X} entry=${ac['entry']:06X} f10=${ac['f10']:04X} f12=${ac['f12']:04X} pos=({ac['x']},{ac['y']})")
        maybe_shot(m, a.shot)
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("run")
    r.add_argument("leg")
    r.add_argument("--from", dest="from_state", default=None)
    r.add_argument("--frames", type=int, default=3000)
    r.add_argument("--save")
    r.add_argument("--shot")
    p2 = sub.add_parser("replay")
    p2.add_argument("rle")
    p2.add_argument("--from", dest="from_state", default=None)
    p2.add_argument("--save")
    p2.add_argument("--shot")
    sub.add_parser("chain")
    p3 = sub.add_parser("status")
    p3.add_argument("--from", dest="from_state", default=None)
    p3.add_argument("--shot")
    a = p.parse_args()
    {"run": cmd_run, "replay": cmd_replay, "status": cmd_status, "chain": cmd_chain}[a.cmd](a)


if __name__ == "__main__":
    main()
