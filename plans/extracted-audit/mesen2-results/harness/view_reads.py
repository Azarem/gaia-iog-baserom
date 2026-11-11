import json, sys, collections
date = sys.argv[1]
d = json.load(open(f"../raw/A2_merged_{date}.json"))
dec = d["decoded"]
fields = sys.argv[2].split(",")
pat = sys.argv[3] if len(sys.argv) > 3 else ""
agg = {}
for r in d["reads"]:
    if r["field"] not in fields: continue
    k = (r["field"], r["pc"])
    a = agg.setdefault(k, dict(n=0, nPlayer=0, scenes=set(), sess=collections.Counter()))
    a["n"] += r["n"]; a["nPlayer"] += r["nPlayer"]; a["sess"][r["session"]] += r["n"]
    for s in r["scenes"].split(","): a["scenes"].add(s.split(":")[0])
for (f, pc), a in sorted(agg.items(), key=lambda t: (t[0][0], -t[1]["n"])):
    dd = dec.get(pc, {})
    line = f"{f} {pc} n={a['n']:6d} pl={a['nPlayer']:6d} {dd.get('label')}+{dd.get('labelOffset')} | {dd.get('instr')} | next: {' ; '.join(dd.get('next', []))} | {(dd.get('site') or '').split('/')[-1]}"
    if pat and pat not in line: continue
    print(line)
