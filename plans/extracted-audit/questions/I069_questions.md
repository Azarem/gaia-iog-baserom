# I069 open questions

Mesen2 MCP was not available, so everything below is UNVERIFIED-RUNTIME. IDs are cited in the merged notes.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I069-1 | I069 | What is `spriteset_shadow_fx` (`body_table` row `$07`) for? Is it reachable through a path that does not use `SetPlayerSpriteDirect #07`? | E1/E2: the operands used in extracted/ are `$04`, `$05`, `$06`, `$08`; twelve of the 14 animations are one frame and six are the same group `17B098` for 32 ticks | Search for a writer of `$0AC8` / `animScratch2` that bypasses the COP (the transformation code writes the body index directly in some places); in Mesen2 put a write breakpoint on `$0AC8` through the Shadow form |
| OQ-I069-2 | I069 | Which actors use the other animations of `spriteset_enemies` (about 45 of the 63) and what do they show? | E2: the traced indices are in the block note; the first-operand tally over all actors mixed in non-animation operands (`#83`, `#A0`) so it was not trusted | Per actor: read the `Stage*` operand that follows `SetMetasprite ( @spriteset_enemies )`; confirm the look with the OAM viewer |
| OQ-I069-3 | I069 | What do the 13 groups of `spriteset_freedan_fx` look like, and does `$00` (4 frames, hold 2) really show the fall of the drop attack? | E1: `ClimbDropAttack` stages `#00` with a hitbox while falling; `ClimbDropLand` stages `#01` | View the poses during a vine drop attack and the Aura Barrier cast |
| OQ-I069-4 | I069 | Does any actor stage the group at `0EEEB8` (20 bytes, header + 1 sub-sprite)? It is not referenced by any frame list. Is it an orphan, or a group reached through a computed frame index? | E1: the label does not appear in extracted/; the group is printed as rows `;0B`-`;0D` of `sprite_group_0EEE5E` | Search for computed `StageSpriteFrame` operands targeting `sprite_set_0EE29E` (the set that holds `0EEE5E`); see R-I069-3 |
