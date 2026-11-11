-- D2 idle test (module check): S01r, no input, 60 frames; shows the Lua errors and the cheap controls.
d2.run{frames=60, nmi=33528, out='D2_idle_20261031.txt', show=30, maxEv=400}
