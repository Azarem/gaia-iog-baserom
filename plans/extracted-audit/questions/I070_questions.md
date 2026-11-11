# I070 open questions

Mesen2 MCP was not available, so everything below is UNVERIFIED-RUNTIME. IDs are cited in the merged notes.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I070-1 | I070 | How does the rebuild decide which words to substitute with `$D6` / `$D7` dictionary references (all, a fixed list, longest match)? Is the rebuilt text byte-identical to the original because the substitutions were extracted as-is or recomputed? | E1/E2: `stringTypes.json` declares both tables as dictionaries; extracted/ has no `[LU1]` / `[LU2]` tags; the rebuild gate is unchanged, so the result is byte-identical | Read the dictionary handling in `gaia-core` (string type `dictionaries` in extract and rebuild) and test with a changed word |
| OQ-I070-2 | I070 | What do the 23 groups of `spriteset_dark_friar` look like, and is the VRAM layout of `misc_fx_1CC000` ($0480 bytes at `$4400`) the one the groups assume? | E1: `DarkFriarVramDma` writes the tiles; the group tile numbers were not matched against the upload | Compare the group tile numbers with the uploaded range in a VRAM viewer during a Dark Friar cast |
| OQ-I070-3 | I070 | Are all 87 scenes with a nonzero reward tier reachable, and does every one have a last enemy (or boss range) that pays it? How are the boss ranges set (`boss_reward_range_table`)? | E1: the four readers agree on the mapping; the per-scene enemy counts and the boss ranges were not tabulated | Tabulate the scene enemy counts from the scene actor lists and the boss range operand of `boss_clear_reward_handler` |
