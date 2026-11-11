import json, sys, collections
sys.path.insert(0,'.')
import fr40
rows=collections.defaultdict(dict)
with open(fr40.ROWS,encoding='utf-8') as f:
    for l in f:
        r=json.loads(l)
        rows[r['scene']][r['variant']]=r
def st0(r):
    """state at the start of the movement test (60 frames after the banner): error | left | gameover | locked | dialog | still | pocket | free.
    locked = all four direction bits of $065A set, or playerFlags $0800 with no direction moving 8 px or more."""
    if r.get('error'): return 'error'
    if r.get('sceneEnd')!=r['scene']: return 'left'
    mv=r.get('move') or {}
    m0=mv.get('mask0',r.get('mask1',0)); p0=mv.get('pf0',r.get('pf1',0)); d0=mv.get('dmf0',r.get('dmf1',0))
    segs=mv.get('seg',[])
    mvd={s['dir']:abs(s['dx'])+abs(s['dy']) for s in segs if 'dx' in s}
    n=sum(1 for v in mvd.values() if v>=2); n8=sum(1 for v in mvd.values() if v>=8)
    if p0&0x0200: return 'gameover'
    if (m0&0x0F00)==0x0F00: return 'locked'
    if d0&0x2000: return 'dialog'
    if p0&0x0800 and n8==0: return 'locked'
    if n==0: return 'still'
    return 'free' if n>=2 else 'pocket'
if __name__=='__main__':
    ids=sorted(rows)
    for s in ids:
        v=rows[s]
        out=[]
        for k in sorted(v):
            r=v[k]
            if k.startswith('ctl'): continue
            out.append(f"{k}:{st0(r)}" + (f"(r{r['releaseN']})" if r.get('releaseN') else ''))
        print(f"{s:02X}", ' '.join(out))
