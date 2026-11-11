from fr20_lib import *
m, info = open_o()
try:
    h = {n: ["start"] for n in range(60, 72)}
    h.update({n: ["select"] for n in range(200, 212)})
    r = visit(m, info, "FL21-02_s0B_menu_try", N03, scene=0x0B, set=[33, 35], clear=[36], settle=400, watch=False, hold=h, mash={"button": "a", "from": 1, "to": 50, "down": 2, "gap": 8}, sampleEvery=20, shot="FL21-02_s0B_menu_try")
    print([(t['n'], '%04X' % t['dmf'], '%04X' % t['mask'], t['sc']) for t in r['timeline']][:30], r['sceneEnd'])
finally:
    m.close()
