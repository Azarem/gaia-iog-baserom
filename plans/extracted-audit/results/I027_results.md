# I027 results

Files: `actors/player/attack_ability_system.asm` (Bank 02), `thinkers/oneshot_palette_flash_40.asm` (Bank 00), `thinkers/oneshot_palette_flash_1F.asm` (Bank 00).
Spec: [edits/I027.json](../edits/I027.json). New proposals: [renames/I027_renames.md](../renames/I027_renames.md). New questions: [questions/I027_questions.md](../questions/I027_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/player/attack_ability_system.asm (Bank 02)

Evidence: E1 (the whole file, read end to end; `db-us/transforms.json` rules for the block; palette bundles `#0B/#0C/#2A/#2B/#2C/#4A/#4B/#5B` decoded from the ROM table at file offset `$168000` with the `LoadPaletteBundle` model), E2 (`vblank_joypad` and `cop_handlers_input` for `joypadRaw` / `joypadCurrent` / `joypadHeld` and the `BranchIfPressed` selector bit; `actor_execution`, `actor_pool` and `cop_handlers_sprite` for the `$10` / `$12` bits, `SpawnAfter*` ordering and `AnimOneFrame`; `cop_handlers_force_move` and `movement_delta_table` for the movement operands; `ability_anim_tables`, `ApplyOrbitalOffsetFromRef`, `cop_handlers_palette`; spawn sites that pass the ability levels), E3 (`docs/wram-memory-map.md` playerFlags table).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Part notes were good, comments were sparse in exactly the places that needed explaining (button masks, movement operands, flag bits, palette bundles) | FIXED (block note rewritten with SECTIONS and CONVENTIONS, 3 part notes updated and 5 added, 61 comments: 5 new, 56 updated) |
| Q2 | M | A reader could not tell what the movement numbers, the `$0081` mask or the `climbStateData` writes mean | FIXED |
| Q3 | **F** | (a) **Attack mask**: the note said `$8001`; the code tests `$0081` (the vanilla mask differs and is rewritten by `transforms.json`). Bit 0 only selects `joypadRaw` (the physical level, which still reports a button consumed through `joypadHeld`); `$0080` is the logical attack bit, physical A in this ROM. (b) **Cancel mask**: "Y/A/L/R ($40B0)" is the vanilla value; the transformed code tests `$0030` (L/R) in `joypadCurrent`. (c) **Movement operands are indices into `movement_delta_table`, not distances**: `$36` is a delta chain (8 x 0, 4,4,7,7,9,9,12,12, 0,0, 8 x -8) that moves the afterimage sprites out and back (net 0); the old "~54-pixel dash" read it as decimal pixels. The `+1/+2/+3` loop operands are constant per-frame speeds (indices 1/3/5). (d) **`$10` bit meanings**: bit 14 (`$4000`) is the off-screen flag kept by `SortActorsByDepth`, not a wall hit; bit 7 (`$0080`) is the hit/iframe marker, which is what ends the Spin Dash charge loop (old note: "wall collision"); bit 13 (`$2000`) is hidden/script-only, which is why `SpawnAfterMarked` orbitals are invisible to the depth sort. `$12` bits `$2000` / `$4000` negate Y / X of staged chains (one chain serves both north/south and east/west). (e) **`LoadAbilityAnimTable*` do not load animations**: each 6-byte record is `{ word, pointer to the ability level word, one damage byte per level }` and the loader stores the damage byte for the current level to `climbStateData` (`$09E0` Will, `$09E2` Freedan), the bonus that combat adds; values by level decoded (Psycho Dash 5/10, Slider 5/8, Spin Dash 4/7, Dark Friar 5/8/12, Aura Barrier 5/9, Earthquaker 0/7). (f) **Ability bitmask `$0AA2`** bits are the event flags `$0510 + form x 4 + slot`, the flags the inventory Status tab tests. (g) **`CheckAttackChargeable`** is not a hitstun/death/combo gate: carry is clear only while `playerFlags $8000` is clear and the body animation index is 0-3 or `$10`-`$13`. (h) **Dark Friar**: `DarkFriarBounceLoop` does not bounce; it keeps the trail travelling until it leaves the screen, and at upgrade level 2 holding attack runs `DarkFriarDisableCollide`, which **falls through** into `DarkFriarOnHit` (detonation on demand, callback removed first). Fragment starting angles are `$40/$80/$C0` (256 units per turn). (i) **Trail followers**: the position source is `$04` (the previous actor-list entry, the actor the follower was inserted after), not a stored parent id; A (spawned last) lags 3 frames, B (spawned first, follows A) about 6. (j) **Aura Barrier orbit**: diameter `$40` is scaled by sine/cosine (max `$7F`) keeping the high byte, so the radius is about 32 px, not 64. (k) **Spin Dash charge**: level `$26` starts at `$0F`; `SpinDashChargeTick` needs a fresh L (odd level) or R (even level) press each time, because it consumes the shoulder bits; four presses (`$0F` to `$0B`) end the phase. (l) **`$16` at the two DMA waits** is the actor's Y position word, not a DMA status; the `$0020` split is unexplained (OQ-I027-1). (m) **Palette FX** decoded: Will `#2A` x2 (62 ticks per pass) then `#2B` forever (14), Freedan `#4B` x2 (50) then `#2C` forever (16), Aura `#5B` forever (8 colors at CGRAM `$A1`-`$A8`, 16 ticks); cleanup uses the single-frame restore bundles `#0B`/`#0C`; Dark Friar also spawns a thinker for `#4A` (white flash fading to Freedan's colors in 36 ticks). (n) **Combat lock** (`playerFlags $0008`): the companion's `Die` at entry is the combat-lock exit, not a player-death check | FIXED (block note, part notes, comments) |
| Q4 | M | The `$0081` / `$0030` masks, the `$0B1A`-style level-word reads and the `climbStateData` writes carried no explanation; mnemonics themselves are correct | FIXED (comments) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `DarkFriarTrailSouthInit` is only reached from the **north** cast (it sets the negate-Y bit and falls into the south body); `DarkFriarBounceLoop` and the Psycho/Spin Dash names are accurate enough | PROPOSED (R-I027-1) |
| Q7 | M | E1 + E2 for flags, masks, movement chains, bundles and damage tables; fragment launch directions, the Psycho Dash travel distance and the reader of actor bit `$0200` are static conclusions or unresolved | DEFERRED-EVIDENCE (OQ-I027-1 to OQ-I027-5) |

### File 2: thinkers/oneshot_palette_flash_40.asm (Bank 00)

Evidence: E1 (`PaletteStart #40`, `PaletteStep`, `KillThinker`; bundle `#40` decoded from the ROM), E2 (`cop_handlers_palette` handler model; spawn sites `angel_village/angel_tunnel_rooms/av74_kara` and `seaside_palace/palace_fountain/sp5D_fountain` with their CGADSUB writes; `NMI` uploads the backdrop triplet from `$7F0C00`), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 2 comments) |
| Q2 | M | The note called it a single-step flash tied to specific visuals; nothing said what the bundle contains | FIXED |
| Q3 | **F** | The thinker does not flash in one step: bundle `#40` is 16 three-byte frames (1 extra tick, 32 ticks in all) that drive the **backdrop COLDATA triplet** (`$7F0C00`) from 31 down to 0 in steps of 2 (last step 3), a fast white-to-black fade. It only shows when color math is on (Kara's room `CGADSUB $21`, the fountain scene `$03`). Spawned twice per scene with a 60-frame wait | FIXED |
| Q4 | NA | Bundle ID is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "palette flash" names a palette write; the bundle fades the fixed color | PROPOSED (R-I027-2) |
| Q7 | M | E1 + E2; the visual result in both scenes is a static reading | DEFERRED-EVIDENCE (OQ-I027-6) |

### File 3: thinkers/oneshot_palette_flash_1F.asm (Bank 00)

Evidence: E1 (`PaletteStart #1F`, `PaletteStep`, `KillThinker`; bundle `#1F` decoded), E2 (`cop_handlers_palette`; spawn site `itory/moon_tribe_camp/it1A_moon_tribe`, `code_09D137`, right after it sets event flag `$2A`), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 2 comments) |
| Q2 | M | The note tied it to "lunar visuals" without saying what it does | FIXED |
| Q3 | **F** | Not a backdrop flash: bundle `#1F` is a single strip of 8 frames of 16 colors written to CGRAM `$F0` (palette 15), 7 extra ticks per frame (64 ticks): a grey ramp (R = G = B) from almost black to light grey. The final frame stays in the staging buffer. Spawned once, from the Moon Tribe camp actor | FIXED |
| Q4 | NA | Bundle ID is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | **F** | The name says "flash" and groups it with the backdrop fades, but it is a palette-15 grey fade-in | PROPOSED (R-I027-2) |
| Q7 | M | E1 + E2; what palette 15 recolors in Itory is not traced | DEFERRED-EVIDENCE (OQ-I027-6) |

### Shared gate (I027)

`npm run merge -- edits/I027.json --dry-run` first reported seven warnings (one comment containing the `$8000` literal that a `transforms.json` rule could rewrite, six comments over 160 characters); the texts were reworded or moved into the new part notes `WillAttackPaletteFX` / `FreedanAttackPaletteFX`, the dry run is clean, the merge applied: 3 block notes (attack_ability_system, 1F, 40) plus 5 part notes added and 3 updated, 65 comment entries (9 new, 56 updated). A second dry run (after `npm run extract:lt`) reports 0 files to change. The first generator draft also carried the notes for `1B` and `1C`; those belong to I028 and were moved to `edits/I028.json` before the merge. `npm run extract:lt` OK and the notes render in `extracted/`. `npm run rebuild` (after I027 and I028 together): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204.

Other files: the header text of `tables/ability_anim_tables.asm` still calls the records animation tables (it belongs to another iteration; the correct description is in the `attack_ability_system` block note and OQ-I027-5).

Suggested commit message: `audit(I027): correct attack_ability_system button masks, movement/flag semantics, ability damage tables and palette FX; rewrite palette flash 40/1F thinker notes`

Please commit when you're ready.
