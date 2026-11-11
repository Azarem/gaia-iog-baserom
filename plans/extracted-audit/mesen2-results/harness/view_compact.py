import json, sys, collections
tag = sys.argv[1]; date=sys.argv[2]
d = json.load(open(f"../raw/{tag}_merged_{date}.json"))
dec = d["decoded"]
BULK = ("CopyActorState","InitActorFromSceneData","SpawnAfter","SpawnBefore","SpawnListAppend","InitActorPool")
agg = {}
for w in d["writes"]:
    k=(w["word"], w["bit"], w["dir"], w["pc"])
    a=agg.setdefault(k, dict(n=0,nPlayer=0,sessions=collections.Counter(), scenes=set()))
    a["n"]+=w["n"]; a["nPlayer"]+=w["nPlayer"]; a["sessions"][w["session"]]+=w["n"]
    for s in w["scenes"].split(","): a["scenes"].add(s.split(":")[0])
bits = collections.defaultdict(list)
for k,a in agg.items(): bits[(k[0],k[1])].append((k,a))
sel = sys.argv[3:]
short = lambda s: "".join(c for c in s if c.isalnum())[:8]
for (word,bit),lst in sorted(bits.items()):
    if sel and f"{word}.{bit}" not in sel: continue
    print(f"== ${word} bit{bit:02d} (${1<<bit:04X})")
    bulk=collections.Counter()
    for (k,a) in sorted(lst, key=lambda t:(t[0][2], -t[1]["n"])):
        dd = dec.get(k[3], {})
        lab = dd.get('label') or '?'
        if lab.startswith(BULK):
            bulk[(k[2], lab.split('+')[0])] += a["n"]; continue
        ss = ",".join(f"{s[:6]}:{n}" for s,n in a['sessions'].most_common(4))
        print(f"  {k[2]} {k[3]} n={a['n']:5d} pl={a['nPlayer']:4d} sc={'/'.join(sorted(a['scenes']))} {lab}+{dd.get('labelOffset')} | {dd.get('instr')} | {(dd.get('site') or '').split('/')[-1]} | {ss}")
    if bulk: print("  bulk:", dict(bulk))
