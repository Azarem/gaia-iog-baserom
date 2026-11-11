import json, sys, collections
tag = sys.argv[1] if len(sys.argv)>1 else "A1"
d = json.load(open(f"../raw/{tag}_merged_20261030.json"))
dec = d["decoded"]
agg = collections.OrderedDict()
for w in d["writes"]:
    k=(w["word"], w["bit"], w["dir"], w["pc"])
    a=agg.setdefault(k, dict(n=0,nPlayer=0,sessions=collections.Counter(), scenes=set(), slots=set(), old=w["old"], new=w["new"]))
    a["n"]+=w["n"]; a["nPlayer"]+=w["nPlayer"]; a["sessions"][w["session"]]+=w["n"]
    for s in w["scenes"].split(","): a["scenes"].add(s.split(":")[0])
bits = collections.defaultdict(list)
for k,a in agg.items(): bits[(k[0],k[1])].append((k,a))
want = sys.argv[2:] 
for (word,bit),lst in sorted(bits.items()):
    tag_ = f"${word} bit{bit:02d} (${1<<bit:04X})"
    if want and not any(x==f"{word}.{bit}" for x in want): continue
    print("==", tag_)
    for (k,a) in sorted(lst, key=lambda t:(t[0][2], -t[1]["n"])):
        dd = dec.get(k[3], {})
        print(f"  {k[2]} {k[3]} n={a['n']:5d} player={a['nPlayer']:4d} sess={dict(a['sessions'])} scenes={sorted(a['scenes'])[:8]} | {dd.get('label')}+{dd.get('labelOffset')} | {dd.get('instr')} | {dd.get('site')}")
