# Bank $08 — Native Village, Angkor Wat, Dao, Pyramid & Dark Space

> ROM bank $08 (`$088000`–`$08FFFF`, 32,768 bytes) contains **NPC actor
> definitions, puzzle scripts, global system actors, and a boss encounter**
> spanning the late-game chapter of Illusion of Gaia — from the Native Village
> and Angkor Wat temple complex through the desert town of Dao, the Egyptian
> Pyramid dungeon, the Gaia/Dark Space system, and the Jeweler Gem mansion
> endgame reveal. This is one of the most narratively dense banks in the ROM,
> covering Will's journey through the North-western Hemisphere.
>
> The bank holds **119 mapped pieces** across 6 parent groups: NPC actor-defs,
> puzzle mechanics, DialogString blocks, Code helpers, and two globally-spawned
> system actors (Jeweler Gem, Dark Space portal). Coverage is **97.7%** mapped.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$088000`–`$08FFFF` (557,056–589,823) |
| Total bank size | 32,768 bytes |
| Mapped | 32,024 bytes (97.7%) |
| Unmapped gaps | ~744 bytes scattered |
| Parent groups | 6 (`native_village`, `angkor_wat`, `dao`, `pyramid`, `system`/`actors`, `mansion`) |
| Total pieces | 119 |
| Block types | ~80 × `actor-def`, ~25 × `Code`, ~7 × `DialogString`, ~4 × `Binary`/`Byte`/table |
| Scene groups | 31 distinct scenes |

---

## 2. Memory Map

### 2.1 Native Village — Village Exterior (scene `native_village`, nvAC)

The main Native Village overworld. Will and party arrive after the Angkor Wat arc;
the village is starving and a multi-phase sacrificial feast sequence unfolds. Contains
party NPCs (Kara, Erik, Hamlet), villagers with emotional dialogue-choice interactions,
and environmental props. The entire area is heavily flag-gated through a linear
progression: `#AC` → `#AD` → `#AE` → `#AF` → `#B0` → `#B2`.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$088000` | `$088057` | 87 | `nvAC_bones` | actor-def | **Skeleton prop** — body `#00`, metasprite `@table_0EDA00` frame `#02`. `SolidHighHere`. On interact: *"They're not weathered yet... Only recently bleached white."* No flags set or checked |
| `$088057` | `$0881A5` | 334 | `nvAC_kara` | actor-def | **Kara (party)** — body `#0C`. Primary narrative driver for the entire Native Village arc. **Flags checked:** `#B6`→Die, `#CF`→Die, `#B2`→post-Hamlet idle, `#AF`→morning/bonfire sequence, `#B0`→Die path, `#AD`→Die, `#AC`→skeleton dialogue state; local `#01`–`#05` for sub-phases. **Flags set:** `#AC` (intro done), `#01` (temp scene), `#AD` (skeleton-house seen), `#AF` (after sleep). **Flags cleared:** `#02`, `#03` (Hamlet grief one-shots). **Intro cutscene** (`#AC` unset): joypad masked `$CFF0`, multi-step sprite walk (XY `#10,#08` → X `#10` → Y `#0F,#06`) with music `#1B`. **Interact `#AD` unset:** empty village, skeletons, go into houses? **Morning** (`#AF`, `#01` unset): villager-spawn cutscene. **Post-`#B2` interact:** learned "Ramapoe" = Hello. **Spawns:** 3 villager walkers (`code_088A60`/`88A90`/`88AAF`) for bonfire approach; bone-pile actor `nv_actor_0881A5`. **Scene change:** `QueueMapChange (#AC, $0080, $00F0, #03, $2200)` back to main village after sleep |
| `$0881A5` | `$0881BE` | 25 | `nv_actor_0881A5` | Code | **Bone-pile helper** — spawned by Kara & Erik. Metasprite `@table_0EE000`, frame `#30` (initial) or `#07` (bone pile). `ExitIfFlagByte (#05, #01)` — skips if Hamlet sacrifice spawn done. Entry `code_0881AE` applies `AddPosition (#00, #F6)` (Y−10) for bone remnant positioning |
| `$0881BE` | `$088546` | 904 | `code_0881BE` | Code | **Kara extended behavior** — large code block handling Kara's multi-phase cutscene animations (pre-`#AC` sprite movement choreography, morning bonfire villager-spawn orchestration, post-Hamlet `#B2` grief dialogue dispatch with `#02`/`#03` one-shot checks, and interact handler routing between `code_0881D0`/`0881D8`/`0881DD`) |
| `$088546` | `$088659` | 275 | `nvAC_erik` | actor-def | **Erik (party)** — body `#04`. **Flags checked:** `#B6`→Die, `#CF`→Die, `#B2`→gorgon-era idle at `(#12,#0B)`, `#AF`→morning at `(#0A,#10)`, `#AD`→Die, `#AC`→idle at `(#0B,#11)`, `#05`→skip bone spawn. **Pre-`#AC`:** sprite walk XY `(#08,#08)` → X `(#08)` → Y `(#07,#04)`. **Interact** (`code_0885D7`): Erik on the small tribe, starvation, how they cope. **Spawns:** if `#AF` set and `#05` unset: `SpawnAfterFlags @nv_actor_0881A5.code_0881AE, #$1002`. **Collision:** `SolidHighHere`; `ClearLowHere` during pre-`#AD` wander |
| `$088659` | `$0887C6` | 365 | `nvAC_hamlet` | actor-def | **Hamlet the pig** — body `#14`. **Flags checked:** `#B3`→Die, `#CF`→Die, `#B2`→memorial NPC at `(#08,#13)` frame `#AD`, `#AF`→bonfire sacrifice, `#AD`→Die, `#AC`→pre-scene wander, local `#01`–`#05` in sacrifice flow. **Flags set:** `#02` (sad approach), `#03` (fire-jump), `#04` (ghost phase), `#B2` (sacrifice complete), `#05` (Lola voice done). **Sacrifice sequence** (`#AF` path): walks to fire X `(#18,#0A,#12)` Y `(#17,#02,#12)`, sad approach, fire jump loop (frames `#AB`/`#AC`), ghost rises (frame `#2A` ascending/descending). **Spawns:** `SpawnAfterFlags @code_088755, #$1002` (flying ghost pig); `SpawnBeforeFlags @code_0887BA, #$2000` (Lola voice actor — sets `#05`, delivers Mystic Statues / Tower of Babel prophecy). **Sounds:** `#2121`, `#0F0F`; `StartMusic (#11)`. **Post-`#B2` interact:** sniff sniff, aroma of roasting Hamlet |
| `$0887C6` | `$08885C` | 150 | `dialogstring_0887C6` | DialogString | **Kara arc dialogue** — strings for Kara's post-`#AC` cutscene phases (hungry children, skeleton observations) |
| `$08885C` | `$088A60` | 516 | `dialogstring_08885C` | DialogString | **Hamlet/sacrifice dialogue** — extended strings for the sacrifice sequence: Erik "eat or not?", Kara sobbing, Hamlet's spirit speaking through fire |
| `$088A60` | `$088AC7` | 103 | `code_088A60` | Code | **Villager walker scripts** — three embedded routines (`code_088A60`/`88A90`/`88AAF`) spawned by Kara during the morning bonfire cutscene. Each walks a fixed path toward the bonfire area, sets local flag `#01`, then dies |
| `$088C51` | `$088C6D` | 28 | `nvAC_bonfire` | actor-def | **Bonfire obstacle** — body `#31`. `StageSprAndHitbox (#31)`, `SolidHighHere`, `AnimOnce` loop. **Active only while `#AF` is clear** (pre-morning). `BranchIfFlagByte (#AF, #00)` → dies when feast begins |
| `$088C6D` | `$088D6B` | 254 | `nvAC_hand_man1` | actor-def | **Starving villager (hand offer)** — body `#1D`, frame `#1D`. Active only while `#AF` is clear (dies when set). **Flags checked:** `#AF`→Die, `#03`→post-gather position, `#04`→skip final reposition. **Movement:** loop pattern X21→Y1E→X20→Y1F until `#03`. Settle: snap to X20 Y1E, `SolidHighHere`. **Interact** (`code_088CC6`, shared with hand_man2): `DialogueOptions (#02, #01)` — *"The man timidly held out his hand... Take his hand? Yes/No"*. Yes → *"We don't understand each other's language, but I think we agree..."*. No → *"The man looks lonely..."* |
| `$088CC4` | `$088CC6` | 2 | `nvAC_staring_man2_destroy` | Code | **Destroy shim** — inline 2-byte routine (names.json alias: `nvAC_hand_man1_destroy`) |
| `$088D6B` | `$088E86` | 283 | `nvAC_dumpling_man1` | actor-def | **Villager (food offer)** — body `#1C`. Same lifecycle as hand_man (`#AF`→Die, `#03`/`#04` positioning). Walk loop X20→Y1F→X21→Y1E. **Interact** (`code_088DC4`, shared): `DialogueOptions (#02, #01)` — *"The man holds out some food... Eat some? Yes/No"*. Yes → insect dumplings, hearts filled. No → *"The man looked sad..."* |
| `$088E86` | `$088F88` | 258 | `nvAC_staring_man1` | actor-def | **Villager (staring)** — body `#1D`. Same lifecycle. **Interact** (`code_088EC2`, shared): `DialogueOptions (#02, #01)` — *"The man looks deeply into Will's eyes. Stare back? Yes/No"*. Yes → looks into your heart, seed sprouted. No → lonely |
| `$088F88` | `$08908A` | 258 | `nvAC_map_kid` | actor-def | **Native child (map)** — body `#24`, frame `#24`. Same lifecycle. **Flags set:** `#B1` (show map accepted). **Interact:** `DialogueOptions (#02, #01)` — *"The boy points to the northeast... Show him the map? Yes/No"*. Yes → draws temple on map, sets `#B1`. No → lonely |
| `$08908A` | `$089200` | 374 | `nvAC_beckon_kid` | actor-def | **Native child (beckon)** — body `#24`. **Flags checked:** `#AF`→Die, `#B2`→post-Hamlet follow mode, `#03`/`#04`/`#06`. **Flags set:** `#06` (follow accepted). **Interact:** `DialogueOptions` — *"He tugs on Will's sleeve... Go with him? Yes/No"*. Yes → beckons. **Post-`#B2` + `#06` unset:** `ClearLowHere`, `MoveToward (#29, #01)` to waypoints `($0148,$0120)` then `($0188,$0140)`. Reaches skeleton → interact with tears: relative? friend? |
| `$089200` | `$089248` | 72 | `nvAC_dumpling_man2` | actor-def | **Dumpling man variant** — body `#1A`. Secondary instance, same interact handler `code_088DC4`. Walk approach, `ClearLowHere` during movement, `SolidHighHere` when settled |
| `$089248` | `$08925C` | 20 | `nvAC_hand_man2` | actor-def | **Hand man variant** — body `#1A`. Secondary instance, same interact handler `code_088CC6`. `SolidHighHere` |
| `$08925C` | `$0892A2` | 70 | `nvAC_staring_man2` | actor-def | **Staring man variant** — body `#1A`. Secondary instance, same interact handler `code_088EC2`. Walk approach then `SolidHighHere` |

**Subtotal:** 19 pieces, 4,378 bytes (native_village scene)

### 2.2 Native Village — Vacant Hut (scene `vacant_hut`, nvAD)

The hut where the party rests before the feast. All three party members
have simplified behavior, gated on `#AD` (must have seen skeleton prompt)
and removed after `#B2` (Hamlet sacrifice complete).

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$088AC7` | `$088B9F` | 216 | `nvAD_kara` | actor-def | **Kara in hut** — body `#0B`, frame `#0A`. **Flags checked:** `#B2`→Die, `#AE`→resting idle, `#AD` (must be set). **Flags set:** `#AE` (hut intro seen), `#B0` (ready to leave). **Entry:** locks joypad, Kara/Erik abandoned-village dialogue, walk Y `(#0F,#05,#12)`. **Interact** (`code_088B1A`): *"Let's rest today."* → `QueueMapChange (#AC, $00B0, $00A0, #00, $2200)` back to main village. **Post-`#AE`:** `SetTilePos (#07,#08)`, `SolidHighHere` |
| `$088B9F` | `$088C0E` | 111 | `nvAD_erik` | actor-def | **Erik in hut** — body `#03`. **Flags:** `#B2`→Die, `#AE`→idle, `#AD` (must be set). Until `#AE`: walk Y `(#07,#04,#12)`. Resting: tile `(#07,#0A)`, `SolidHighHere`. **Interact:** *"I'm exhausted. I feel like sleeping for days."* |
| `$088C0E` | `$088C51` | 67 | `nvAD_hamlet` | actor-def | **Hamlet in hut** — body `#13`, frame `#12`. **Flags:** `#B2`→Die, `#AE`→resting, `#AD` (must be set). Until `#AE`: walk Y `(#17,#0C,#12)`. Resting: tile `(#08,#08)`, `SolidHighHere`. **Interact:** *"Oink oink."* |

**Subtotal:** 3 pieces, 394 bytes

### 2.3 Native Village — Gorgon Hut (scene `gorgon_hut`, nvAE)

The hut containing three stone girls petrified by the Gorgon Flower.
All party actors here require flags `#BF`, `#C0`, `#C1` to **all** be
set (all three girls transformed) before their cutscene activates.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$0892A2` | `$089366` | 196 | `nvAE_stone_girl1` | actor-def | **Stone girl 1** — body `#36`. 30-cycle animation loop alternating stone frame `#36` ↔ human frame `#32`. **Flags checked:** `#BF` (transformed). **Statue interact** (`code_0892DA`): *"The statue of a girl stands silently."* **Transformed interact** (`code_0892DF`): *"You don't understand..."* `SolidHighHere` |
| `$089366` | `$089471` | 267 | `nvAE_stone_girl2` | actor-def | **Stone girl 2** — body `#36`, same flicker loop. **Flags checked:** `#C0` (transformed), `#E6` (jewel already given). **Flags set:** `#E6` after jewel. **When transformed + `#E6` clear:** `GiveItem (#01)` — **Red Jewel** via `hidden_red_jewel` handler. Repeat: *"You don't understand..."* `SolidHighHere` |
| `$089471` | `$08951E` | 173 | `nvAE_stone_girl3` | actor-def | **Stone girl 3** — body `#36`, same flicker. **Flags checked:** `#C1` (transformed). No item reward. Transformed: *"You don't understand..."* `SolidHighHere` |
| `$08951E` | `$089730` | 530 | `nvAE_kara` | actor-def | **Kara (gorgon hut)** — body `#0B`. **Flags checked:** `#B6`→Die, `#CF`→post-intro idle; requires `#BF`, `#C0`, `#C1` all set (`ExitIfFlagByte` if any clear). **Flags set:** `#CF` (intro complete). **Intro:** sign language with villagers, animals returned. **Interact** (`#CF` set): `DialogueOptions (#02, #02)` — *"Travel to the labor trader's village? Yes / Wait a while."* Wait → make preparations. Yes → sets `$0D60=#0000`, `$0D62=#0001`, `$0D64=#0004` (companion slots), `StageWorldMapMove (#$0124, #$01A4, #00, #1D)`, `QueueMapChange (#C4, $0078, $00A0, #00, $1100)` — **Dao**. Walk Y `(#0F,#03,#02)`. Post-`#CF`: tile `(#07,#0A)`, `SolidHighHere` |
| `$089730` | `$0897CB` | 155 | `nvAE_erik` | actor-def | **Erik (gorgon hut)** — body `#03`. **Flags:** `#B6`→Die, `#CF`→idle; requires `#BF`/`#C0`/`#C1` all set. Until `#CF`: wait `#59`, walk Y `(#07,#03,#02)`. Post-`#CF`: tile `(#08,#0A)`, `SolidHighHere`. **Interact:** labor traders knew there was no food, led children away — terrible story |

**Subtotal:** 5 pieces, 1,321 bytes

---

### 2.4 Angkor Wat — Entrance & Outer Areas (scenes `angkor_entrance` awB0, `angkor_outer_east` awB2, `angkor_outer_north` awB3, `snake_pit` awB4)

Trigger actors for the Angkor Wat temple exploration. Includes the intro
narration, stair/ladder triggers, and the snake pit room controller.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$0897CB` | `$0897E0` | 21 | `awB4_actor_0897CB` | actor-def | **Snake pit visual init** — body `#28`. One-shot: `SetMetasprite (@table_14C12C)`, `SetAnimScratch (@misc_fx_1CD380)`, `ResetSpriteInit (#00, $2020)`, `LoadSpriteAnimGlobal`. Sets up sprite FX tables for the snake pit room, then returns. Not an NPC |
| `$0897E0` | `$08985E` | 126 | `awB0_intro` | actor-def | **Angkor intro narration** — body `#30` (trigger). **Flags checked:** `#BE`→skip (spirit guide done), `#B3`→skip (intro already played). **Flags set:** `#B3`. One-shot narration with joypad lock `$CFF0`, wait `#1D` frames: *"Through the jungle, three days journey from the native village, there is a huge temple."* Then dies |
| `$08985E` | `$0898C8` | 106 | `awBD_actor_08985E` | actor-def | **Cross-map spawn reposition** — body `#20` (invisible trigger). Scans position table `spawn_trigger_0898A8` (5 entries covering scenes `$BB`/`$BD`) against `sceneCurrent`, `playerXPos`, `playerYPos`. On match: locks joypad `$CFF0`, sets player `$0800`, `AddPosition (#00, #80)` (drops 128px), plays 8-frame ladder descent animation, sound `#2C`, restores idle. Then dies |
| `$0898C8` | `$0898DA` | 18 | `awB2_actor_0898C8` | actor-def | **Outer-east stair trigger** — body `#23`. `ExitIfFlagWord (#$016B, #01)` — dies if stair already used. Otherwise stores `$0E=#$000A` and `JumpScript (@stair_climb.code_00D16D)` for shared east stair handler |
| `$0898DA` | `$08992A` | 80 | `awB3_actor_0898DA` | actor-def | **Outer-north ladder trigger** — body `#30`. **Flags checked:** word `$016E`→skip if set. **Flags set:** word `$016E` (north ladder used). Waits for player in tile bounds `(#6A,#0C)`–`(#6F,#0D)`. On enter: `LoopInit (#14)` (20-frame lock), `PlaySoundBoth (#$0F0F)`, `StageBgChange (#6E)` + `ApplyBgChange` (opens passage), redirects player to `ClimbVineEntry` (engine label — **ladder climbing** behavior), sets `playerFlags` `$0800` |
| `$08992A` | `$0899AF` | 133 | `awB4_actor_08992A` | actor-def | **Snake pit room controller** — body `#30`. **Flags checked:** `#B5`→skip first-visit FX. **Flags set:** `#B5` (first visit). **Entry:** at player position `($0578,$0010)` — clears/sets player `$0010` bits, redirects to `loc_02C63B` (ladder climbing loop with 3-sprite cycle), sets `$0800`. **First visit only:** color math `TM=#15, CGADSUB=#A1, COLDATA=#FF`, `WaitByte (#B3)`, `SpawnThinker (@oneshot_palette_flash_1C)`. **Ambient:** `SetEntryContinue` loop, `BranchIfButton (#$0F01)` — any D-pad in tile region `(#3D,#0C)`–`(#43,#1B)` or `(#43,#06)`–`(#5D,#1B)` facing north → `PlaySoundCh2 (#08)` |

**Subtotal:** 6 pieces, 484 bytes

### 2.5 Angkor Wat — Inner Areas & Shrine (scenes `angkor_inner_gate` awB7, `angkor_shrine_crystal` awBC, `angkor_pinnacle` awBF, `angkor_inner_courtyard` awBA, `angkor_outer_courtyard` awB6)

The deep temple interior: gate mechanisms, the blinding crystal shrine,
the spirit guide prophecy, explorer remains with journal entries, and the
Black Crystal Glasses pickup.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$0899AF` | `$089A1C` | 109 | `awB7_actor_0899AF` | actor-def | **Inner gate controller** — body `#00`, sprite `#03`. No flags. `AddPosition (#08, #00)`, `SetEntryContinue` loop. **South approach** `(#03,#10)`–`(#07,#18)`: sets player `$0010` bit `$0010`, places `SolidHighAbs (#05,#0F)` + `(#06,#0F)`, spawns shimmer child (`code_0899FB` — toggles `$000E` bit `$0200` every 2 frames), slides gate sprite `StageSpriteMoveX (#85, #01)` (133px right), frames `#07`→`#08`. **North side** `(#08,#12)`–`(#0A,#14)`: clears player `$0010` bit `$0010` |
| `$089A1C` | `$089AA3` | 135 | `awBC_blinding_light` | actor-def | **Shrine blinding hazard** — body `#30`. **Flags checked:** `#B7`→skip first dialog. **Flags set:** `#B7` (first entry). **First entry:** joypad lock, *"Setting one foot inside, the floating crystal started to glow!"* **Loop:** `WaitByte (#13)`, `SpawnThinker (@oneshot_palette_flash_18)`, wait `#B3` frames. **Exit condition:** `BranchIfEquipped (#1C)` — **Black Crystal Glasses** must be **equipped** (not just owned). When equipped: `SpawnThinker (@oneshot_palette_flash_19)`, wait, return. Hazard is visual/palette only |
| `$089AA3` | `$089F2C` | 1,161 | `awBF_spirit_guide` | actor-def | **Spirit guide (pinnacle)** — body `#10`, metasprite `@table_0EDA00` (skeleton). **Flags checked:** `#BE`→Die (arc complete), `#BD`→run reward. **Flags set:** `#BD` (vision started), `#BE` (arc complete). **First interact** (`SetOnInteract → code_089B6D`): Spirit waited thousands of years, asks Will to close eyes. `QueueMapChange (#C0, $0000, $0000, #00, $4400)` — vision scene. **Reward cutscene** (`#BD` set): grey new world description, Gorgon Flower given. `GiveItem (#1D)` — **Gorgon Flower**. Payment: `BranchIfNoItem (#01)` → takes Red Jewel (`RemoveItem #01`, increments `jewelsCollected`); else `BranchIfNoItem (#06)` → takes Herb (`RemoveItem #06`). Fanfare `MusicAndText (#17)`: *"You have the Gorgon Flower!"* **Collision:** `SolidHighHere` + `SolidHighOffset (#01, #00)`. Post-vision: `ClearLowAbs (#0F,#0A)` + `(#10,#0A)` |
| `$089F2C` | `$089F7C` | 80 | `awBC_actor_089F2C` | actor-def | **Floating shrine crystal** — body `#0B`, sprite `#31`. Bounces within camera bounds: `$24`/`$26` = X/Y velocity (init `$FFFF`), reverses at boundaries. `SpawnAfterFlags (@sp5D_fountain.code_069502, #$2800)` — reuses seaside palace fountain sparkle. `SetEntryContinue` perpetual loop. No interaction |
| `$089F7C` | `$089FFC` | 128 | `awBA_glasses` | actor-def | **Black Crystal Glasses pickup** — body `#10`, metasprite `@table_0EE000`, sparkle loop (frame `#02`, `AnimOnce`, `WaitByte (#3B)`). **Flags checked:** `#BA`→Die (already collected). **Flags set:** `#BA`. **Interact:** *"There's something shiny on the ground."* `GiveItem (#1C)` — **Black Crystal Glasses**. Fanfare `MusicAndText (#17)`: *"You've found the Black Crystal Glasses!"* Full inventory → `InventoryFullMessage`. `$displayModeFlags` bit `$0080` during pickup |
| `$089FFC` | `$08A25E` | 610 | `awB6_bones` | actor-def | **Explorer remains (outer)** — body `#10`, sprite `#2C`. `SolidHighHere`, `SetOnInteract`. *"The bones of a lost explorer... There's some kind of journal..."* `DialogueOptions (#02, #02)` — **Read / Quit**. Read: Friezer's personal journal — jungle crossing, native village famine, discovery of Angkor Wat, immortality rumor, demons, decision to return |
| `$08A25E` | `$08A4AB` | 589 | `awBA_bones` | actor-def | **Explorer remains (inner)** — body `#10`, sprite `#2C`. `SolidHighHere`. Same `DialogueOptions (#02, #02)` — **Read / Quit**. **Friezer's Research Record:** spirit temple, 2F Main Hall bright room blocks path, must wear Black Crystal Glasses, something shiny dropped near hall. **Critical gameplay hint** for the glasses pickup and blinding room |

**Subtotal:** 7 pieces, 2,812 bytes

---

### 2.6 Dao — Hotel & Dorm (scenes `dao_hotel` daC4, `dao_dorm` daC8)

Party member NPCs during the Dao town stay. Neil rejoins here
and arranges transport to the Tower of Babel after the Pyramid arc.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08A4AB` | `$08A567` | 188 | `daC4_kara` | actor-def | **Kara at hotel** — body `#1A`. **Flags checked:** `#D2`→Die, `#D0`→normal setup, `#BB`→Die (if `#D0` not set), `#B6`. **Flags set:** `#B6` (Dao arrival narration). **First visit** (`#B6` clear): joypad lock `$CFF0`, wait `#1D`: *"A town shining in the desert. We went to Dao."* **Interact:** *"This place is supposed to be famous for labor merchants. It doesn't look like it."* `SolidHighHere` |
| `$08A567` | `$08A5AE` | 71 | `daC4_erik` | actor-def | **Erik at hotel** — body `#0A`. **Flags:** `#D2`→Die. Static idle, `SolidHighHere`. **Interact:** *"I can't go outside in a sandstorm like this."* |
| `$08A5AE` | `$08A7F6` | 584 | `daC8_neil` | actor-def | **Neil reunion (dorm)** — body `#12`. **Flags checked:** `#D2`→Die, `#B4`, `#D0`. **Flags set:** `#B4` (reunion played). **Intro** (`#B4` clear): joypad lock, walk Y `(#16,#01)`, Neil on pepper imports replacing labor trade, pyramid/Mystic Statue hints. **Default interact:** *"I came to Dao to replace the labor trade with pepper imports."* **When `#D0`=1:** farewell — flies Will to Tower of Babel: `StageWorldMapMove (#$0094, #$0114, #00, #21)`, `QueueMapChange (#DC, $0000, $0000, #00, $1100)` — map **DC** (Over Babel flyover). Sets `$0D60=#$000B`, `$gfxCacheIdxB=#$0404`. `SolidHighHere` |

**Subtotal:** 3 pieces, 843 bytes

### 2.7 Dao — Town Exterior (scene `dao`, daC3)

The main desert town area. Diverse NPCs related to the labor trade,
carpet weaving, and pyramid exploration. Most are static interactable
NPCs with `SolidHighHere`.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08A7F6` | `$08A85F` | 105 | `daC3_man1` | actor-def | **Townsman** — body `#02`. `NpcRandomWanderAI` (`$currentHp=#02` seed, 8-way random walk via `SwitchCase` on RNG). **Interact:** *"This is Dao, the desert village. Children don't come to places like this very often."* |
| `$08A85F` | `$08A89B` | 60 | `daC3_sandy` | actor-def | **Sandy NPC** — body `#02`. Static, `SolidHighHere`. **Interact:** *"I got sand in my eyes. It started to sting..."* |
| `$08A89B` | `$08A8FB` | 96 | `daC3_merchant` | actor-def | **Carpet merchant** — body `#05`. **Dialogue:** *"I have fine goods for sale today. You've never seen carpets this nice."* **Movement:** `SolidHighHere` at spawn → `WaitByte (#EF)` → `ClearLowHere` → `StageSpriteLoopMoveX (#08, #40, #12)` walks off-screen → `Die` |
| `$08AADF` | `$08AB23` | 68 | `daC3_moving_kruk` | actor-def | **Moving kruk bird** — body `#1A`. `$12` bit `$0200`. `SolidHighHere` → `WaitByte (#EF)` → `ClearLowHere` → `SpawnAfterFlags (@code_08AB03, #$1001)` trailing companion → `StageSpriteLoopMoveXY (#1B, #40, #53, #54)` → `Die`. Companion: `StageSpriteLoopMoveX (#1C, #40, #53)` → `Die`. **Interact:** *"Kiaaa...kiaaa..."* |
| `$08AB23` | `$08AB88` | 101 | `daC3_freedom_man` | actor-def | **Freedom NPC** — body `#05`. Static, `SolidHighHere`. **Interact:** *"A freedom movement has started recently. The president of Rolek started the labor trade freedom movement."* |
| `$08AB88` | `$08ABF7` | 111 | `daC3_carpet_man` | actor-def | **Carpet NPC** — body `#04`. Static, `SolidHighHere`. **Interact:** Dao famous for spices and carpets; Edward Castle carpets took 40 years to weave here |
| `$08ABF7` | `$08AC23` | 44 | `daC3_kruk1` | actor-def | **Kruk bird 1** — body `#1A`. `$12` bit `$0200`. Static idle (`SetEntryContinue` + `AnimOnce`), `SolidHighHere`. **Interact:** *"Kiaaa...Kiaaa..."* |
| `$08AC23` | `$08AC4F` | 44 | `daC3_kruk2` | actor-def | **Kruk bird 2** — body `#1A`. Identical to kruk1 |
| `$08AC4F` | `$08ACC5` | 118 | `daC3_prisoner` | actor-def | **Prisoner** — body `#0A`. Paces via `BranchOnPlayerX (#$0008)`: west → `BranchIfSolidOffset(#FE,#00)` checks wall, walks east; east → checks offset `(#03,#00)`, walks west; near player → idle frame `#0A`. **Interact:** *"I guess he didn't understand what I said. His eyes were expressive..."* |
| `$08ACC5` | `$08AD8F` | 202 | `daC3_jackal_girl` | actor-def | **Silent girl** — body `#14`. Static, `SolidHighHere`. **Interact:** *"The girl silently offers one sheet of paper."* `WriteApuIo0 (#7F)` (sting SFX) → *"There was a picture of a jackal! A shiver ran down my spine. It was a warning from the Jackal, who had been stalking us...."* `WriteApuIo0 (#01)` (reset APU) |
| `$08AD8F` | `$08AE49` | 186 | `daC3_training_man` | actor-def | **Snake Panic trainee** — body `#1F`. `$12` bit `$0200`. `SolidHighHere`. **Spawns** 5 practice pots via `SpawnAfterRelFlags (@code_08ADF3)` at X offsets `$FFE0/$FFF0/$0000/$0010/$0020`, Y `$0020` — child loops frames `#20`→`#24`→`#20`→`#25`. **Interact:** *"Have you ever played Snake Panic? I'm still in training for it."* |
| `$08B152` | `$08B2ED` | 411 | `daC3_luggage_man` | actor-def | **Hotel clerk** — body `#1F`. `$12` bit `$0200`, `SolidHighHere`. **Flags checked:** `#B8`→post-delivery. **Flags set:** `#B8` (delivery done). **When `#B8`=1:** *"This is a hotel for travelling merchants."* **When `#B8`=0:** *"Would you happen to be Will? Yes / No"*. No → *"Hmmm. I hope he arrives soon."* Yes → counts empty inventory slots (needs ≥2): `GiveItem (#25)` **Lola's Letter** + `GiveItem (#26)` **Father's Journal**, sets `#B8`, fanfare `MusicAndText (#17)`. Full inventory → *"Somehow, your inventory is full..."* |
| `$08B2ED` | `$08B334` | 71 | `daC3_slaver` | actor-def | **Town slaver** — body `#1D`. `$12` bit `$0200`, `SolidHighHere`. **Interact:** *"Hey, hey. This isn't a show!! Get out of here!"* |
| `$08B334` | `$08B3A2` | 110 | `daC3_treasure_man` | actor-def | **Treasure NPC** — body `#1D`. `$12` bit `$0200`, `SolidHighHere`. **Interact:** Pyramid nearby; many explorers, none found treasure yet |

**Subtotal:** 14 pieces, 1,727 bytes

### 2.8 Dao — Special Rooms (scenes `indecision_room` daC9, `desert_explorers` daC7, `panic_room` daC6, `sweatshop` daC5)

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08A8FB` | `$08A98E` | 147 | `daC9_businessman` | actor-def | **Businessman** — body `#02`. `NpcRandomWanderAI` (`$currentHp=#02`). **Interact:** *"You've come all the way to this town to buy labor... I can't make up my mind. You can't put a price on people..."* |
| `$08A98E` | `$08A9DD` | 79 | `daC7_explorer1` | actor-def | **Explorer 1** — body `#05`. Static, `SolidHighHere`. **Interact:** *"The Pyramid is made of huge stones. Strange that it doesn't sink into the desert...."* |
| `$08A9DD` | `$08AA9B` | 190 | `daC7_explorer2` | actor-def | **Explorer 2** — body `#02`. Static, `SolidHighHere`. **Interact:** Legend — *"Only those who've transcended the body may enter."* Living cannot enter — it's a tomb |
| `$08AA9B` | `$08AADF` | 68 | `daC7_explorer3` | actor-def | **Explorer 3** — body `#04`. Static, `SolidHighHere`. **Interact:** *"We're explorers. I hear there's a treasure inside the Pyramid..."* |
| `$08AE49` | `$08B152` | 777 | `daC6_snake_panic` | actor-def | **Snake Panic minigame** — body `#1F`. **Flags:** local `#01`–`#04` for game state; global `#E7` (high-score reward given). **Prompt:** `DialogueOptions` — *"Play the game with the snakes? Yes / No"*. No → *"Too bad."* Yes → spawns 3 snake enemies via `SpawnAfterRelFlags (@code_08B0D4, #$0300)`, game controller `SpawnAfterFlags (@code_08AFB4, #$2000)`. **Snakes:** `$12` bits `$0031` (enemy type), `$currentHp=#$00FF`, `SetHitCallback` → on hit: `SetFlagByte(#02)`, BCD score++ in `$0AAC`, SFX `#0D`, `SetFlagByte(#04)` for respawn. **Timer:** `$24` counts to `#$0E10` (3600 frames ≈ 60s). **Score check:** `CMP #$0051` (81 BCD). **≥81 + `#E7` clear:** *"Wow [score] snakes. Very good! For your prize, I'll give you two Red Jewels."* `jewelsCollected += 2`, `SetFlagByte(#E7)`. **<81:** *"You've hit [score] snakes. Try again!"* Player `$playerFlags`: `TRB #$0008` on start, `TSB #$0008` on end |
| `$08B3A2` | `$08B464` | 194 | `daC5_slaver` | actor-def | **Sweatshop overseer** — body `#1D`. `$12` bit `$0200`, `SolidHighHere`. **Interact:** Dark monologue (`[TPL:E]`) about women weaving carpets for ~40 years since childhood — *"Some are born to misfortune."* |
| `$08B464` | `$08B577` | 275 | `daC5_weaver` | actor-def | **Carpet weaver** — body `#26`, init flags `#18`. Loom animation via `JSL func_06B9F2` (derives `$24` variant from `$0E` nibble). `$12` bit `$0200`, `SolidHighHere`. **Interact:** `SwitchCase ($24, 4)` — all branches identical: *"She didn't understand. She just kept working."* |

**Subtotal:** 7 pieces, 1,730 bytes

---

### 2.9 Pyramid — Main Hall & Entrance (scene `pyramid_main`, pyCC)

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08B668` | `$08B6A2` | 58 | `pyCC_actor_08B668` | actor-def | **Dark Space spawner** — body `#23`. Tests `$0100+low($0E)` flag via `JSL TestFlag_0100`. When set: `SpawnAfterFlags (@dark_space.code_08D6B5, #$2B00)`, child `$000E←#$2000`, child `$0024←#$0003` (or `#$0001` if `$0E=#$0072`). Parent dies immediately |
| `$08B6A2` | `$08B6F4` | 82 | `pyCC_entrance_portal` | actor-def | **Entrance portal** — body `#1C`. `$12` bit `$0200`. `SetOnInteract`. **Dialogue:** *"The door to the Pyramid appears in the light... Quit / Jump in"*. **Jump in:** spawns warp VFX `@py_actor_08B6F4` at `#$1800`, sets `$gfxCacheIdxA/B=#$0303`, player `$0010` bit `$2000`, `QueueMapChange (#CC, $01F8, $0130, #03, $4400)` — pyramid interior |
| `$08B70D` | `$08B74D` | 64 | `dialogstring_08B70D` | DialogString | **Portal dialogue** — strings for the entrance portal interaction and cancel text |
| `$08CD6C` | `$08CE12` | 166 | `pyCC_portal` | actor-def | **Mummy Queen portal** — body `#1C`. `$12` bit `$0200`. **Flags checked:** `#FC`→Die (arc complete), `#D1` required (puzzle solved). `AddPosition (#08, #0C)`. **Dialogue:** *"The mummified queen of the Pyramid appears. Quit / Jump in"*. **Jump in:** spawns `@py_actor_08B6F4`, `$gfxCacheIdxA/B=#$0303`, `QueueMapChange (#DD, $00F8, $01B0, #00, $2200)` — Mummy Queen lair. Portal hidden until `#D1` set, removed after `#FC` |

**Subtotal:** 4 pieces, 370 bytes

### 2.10 Pyramid — Puzzle Room / Jackal Scene (scene `puzzle_room`, pyCD)

The central puzzle room containing the Jackal boss encounter, Kara's
narrative climax, flame statue traps, the explorer gate NPC, and the
hieroglyph stone arrangement puzzle. This is the most complex subsection.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08B74D` | `$08B7E8` | 155 | `pyCD_flame_statue` | actor-def | **Flame statues (×2 in file)** — **Left:** body `#1C`, `SolidHighHere`, `AddPosition (#F8, #00)`. `ExitIfFlagByte (#01, #01)`. After `WaitByte (#1D)`: `PlaySoundBoth (#$1919)`, spawns `CameraDriftLoopSimple`, after `WaitByte (#3B)`: spawns 5 dart projectiles (`LoopInit #05` → `@code_08B804`), `SetFlagByte (#03)`. **Right (`pyCD_flame_statue2`):** body `#9C`, `AddPosition (#08, #00)`. `ExitIfFlagByte (#01, #01)`. `WaitByte (#59)` (longer delay), spawns darts with inverted offset `$0026=#$FFF8`. Left sets `#03`, right does not |
| `$08B7E8` | `$08B81E` | 54 | `code_08B7E8` | Code | **Dart projectile code** — spawned by flame statues. Sound `#$0505`, bouncing vertical trajectory. `code_08B804` = dart spawner with RNG offset, `$0026,Y` = Y offset direction |
| `$08B81E` | `$08BD30` | 1,298 | `pyCD_jackal` | actor-def | **Jackal boss/cutscene** — body `#0B`. **Flags set:** `#0E` (scene busy), `#0F` (stealth active, cleared on completion), `#02` (player positioned), `#04` (dart phase), `#05` (mid-death), `#06` + `#BB` (Jackal defeated). **Flags checked:** `#C2`–`#C7` all `ExitIfFlagByte` (dies if any hieroglyph taken already), `#BB`→post-defeat idle at tile `(9,11)`. **Stealth:** *"Walk to the left without a sound!!"* Waits for player in `(5–9, 9–11)`. Wrong input: *"It says to walk to the left!!"* Position reached: *"There, that's good. Don't move!!"* **Confrontation:** Jackal reveals bio-tech/comet lore, King Edward manipulation; Kara denies. **Flute whisper:** *"A voice whispers in Will's head... Will... Play the Flute...."* Based on `$characterForm`: form≠0,≠1 → `sE6_gaia.func_08F3B1` (Earthquaker); form=1 → `sE6_gaia.func_08F37D` (Aura Barrier). **Death:** dart burst (`LoopInit #0C`), Jackal cry, `FadeThenStartMusic (#11)`. **Collision:** stealth barriers at `(06–09,0C)`, `(09,09–0A)`, swapped to `(05,09–0A)` after player positioned. **Post-`#BB`:** idle corpse frame `#02`, `SolidHighHere` |
| `$08BD30` | `$08C1FD` | 1,229 | `pyCD_kara` | actor-def | **Kara (pyramid)** — body `#03`. **Flags checked:** `#D0`→Die, `#C2`–`#C7` all `ExitIfFlagByte`, `#BB`→post-Jackal path, `#02`/`#04`/`#05`/`#06` for sync, `#FC`→skip flute re-trigger. **Flags set:** `#D0` (pyramid arc complete). **Pre-`#BB`:** walks in during Jackal scene, sprite movement loops synced with Jackal flags. *"Will... Why must everyone hate each other...?"* **Post-`#BB`:** tile `(8,11)`, frame `#05`, `SolidHighHere`. Flute/Dr. Jones: *"Will. You've done well... Bring the five Mystic Statues to the Tower..."* Will: *"Father?!"* Kara: Neil built another airplane, let's go back to Dao. `$gfxCacheIdxB=#$0404`, `QueueMapChange (#C8, $0070, $00A0, #00, $1100)` — **Dao dorm**. **Interact (post):** *"The melody you played became the Jackal's dirge."* |
| `$08C1FD` | `$08C2DA` | 221 | `pyCD_explorer` | actor-def | **Explorer gate NPC** — body `#1F`. **Flags checked:** `#C2`–`#C7` any set → die path. **Items checked:** `BranchIfNoItem` on `#1E`–`#23` (Hieroglyph Stones 1–6) — stays solid blocking passage until all owned OR flags set. **Dialogue:** *"There are traps scattered around... a booby trap that responds to sound... don't make any noise..."* When conditions met: `ClearLowHere` + `Die` (opens passage). `$12` bit `$0200`, `SolidHighHere` |
| `$08CB94` | `$08CB9A` | 6 | `byte_08CB94` | Byte | **Puzzle data** — 6-byte metatile index array mapping slot indices → metatile IDs `#84, #85, #86, #8C, #8D, #8E` for hieroglyph display |
| `$08CB9A` | `$08CD6C` | 466 | `pyCD_puzzle` | actor-def | **Hieroglyph arrangement puzzle** — body `#30`. **Flags checked:** `#D1`→Die (already solved). **Flags set:** `#D1` (correct arrangement). Reads 6 slot assignments from `$0B28`–`$0B32` (step 2). **Correct solution:** each `$0B28+2n` must equal `n` (values 0–5 in order). **Success:** `PlaySoundBoth (#$0F0F)`, joypad lock `$CFF0`: *"There was a sound from over the entrance!"* Sets `#D1` (enables Mummy Queen portal). **Failure:** `PlaySoundCh1 (#12)`, lock `$EFF0`: *"Nothing happened... Maybe they're arranged wrong."* Returns all stones via `GiveItemToPlayer`, slots cleared to `$FFFF`, redraws empty metatile `#87` at tiles `(5–10, 6)` |

**Subtotal:** 7 pieces, 3,429 bytes

### 2.11 Pyramid — Dungeon Rooms (scenes `pyramid_vader_a` pyD6, `pyramid_vader_b` pyD7, `pyramid_dangerslide_b` pyD9, `pyramid_trickle_a` pyD4, `heiroglyph_room` pyDA, `mummy_queen_lair` pyDD)

Hazard and puzzle actors across the pyramid's dungeon rooms.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08B592` | `$08B668` | 214 | `pyD0_actor_08B592` | actor-def | **Ladder climb trigger** — body `#30`. **Flags checked:** word `$0170` or `$0171` (per-variant via `$26`). **Flags set:** word `$0170` or `$0171` after BG change. Requires player **climbing** (body `$95`/`$8E`, state `$001C` in `$0028`) and `BranchIfPlayerNear (#01)`. Phase 1 (`$24=0`): draws metatiles `#E8`/`#E9` via `DrawMetatileHere`. Phase 2: `PlaySoundCh1 (#15)`, `SwitchCase($26)` → `StageBgChange (#70)` or `(#71)` + `ApplyBgChange`. Redirects player to `ClimbVineEntry` (engine label — **ladder climbing** state): sets player `$0010` bits. Dies via flag word if already used |
| `$08B6F4` | `$08B70D` | 25 | `py_actor_08B6F4` | actor-def | **Portal warp VFX** — body `#09`. Copies parent position, `SetMetasprite (@table_0EE000)`, `StageSpriteFrame (#1C)`, `AnimOnce`, dies. Shared by both pyramid portals |
| `$08C2DA` | `$08C3FD` | 291 | `pyD6_actor_08C2DA` | actor-def | **Toggle gate A** — body `#0F`, `$12` bits `$0031` (hittable). Stats: `enemy_stats_table+118`, `$currentHp=#$7FFF` (invulnerable switch). **Flags:** local `#0F` (re-entry guard, set/cleared during toggle). Initializes shared counter on actor `$1060`: `$0026←#$FE00`. **Hit callback:** toggles barrier solids between rows `(34–39, 2B–2C)` ↔ `(34–39, 4B–4C)`, increments `$0026` on `$1060`. Counter reaching 0 → clears barriers, sound `#$1515`, resets. `SolidHighHere` |
| `$08C3FD` | `$08C4EA` | 237 | `pyD6_actor_08C3FD` | actor-def | **Toggle gate B** — mirror of gate A. Starts barriers at `(4B–4C)`, on hit moves to `(2B–2C)`, **decrements** `$0026`. Counter reaching `$FE00` → clears, resets. Paired with gate A — both must align to open path |
| `$08C4EA` | `$08C5CA` | 224 | `pyD7_actor_08C4EA` | actor-def | **Sliding sand trap** — body `#1D`, 2 variants in file. Moves `AddPosition (#00, #FE)` (up 2px/frame). `$24` toggles direction at player `($378, $4A0)`. Near player (`#01` radius): frame `#1E` (attack), sound `#$2C2C`. Hit callback adjusts `$1060.$0026` ±1 (linked to gate puzzle counter). Second variant `pyD7_actor_08C57F`: `$24←#$FFFF` (starts reversed). Calls `JSL func_09BB17` for sand-scroll visual (`#$0F` pattern fill) |
| `$08C5CA` | `$08C6EA` | 288 | `pyD9_actor_08C4EA` | actor-def | **Falling rock spawner** — body `#30`. Loop: `WaitByte (#3B)`, increments `$1060.$0026` to `#$0060`, then decrements to 0. At 0: `PlaySoundCh1 (#15)`, spawns `CameraDriftPatterned`. 9-entry zone table (`zone_trigger_08C6BC`) covering scenes D9 (5 zones) and DB (4 zones) with X/Y bounds. When player in zone: spawns `@code_08C697` — rock at player-adjacent Y, `StageSprAndHitbox (#00)`, 1-frame hazard, dies |
| `$08C6EA` | `$08C77F` | 149 | `pyD4_actor_08C6EA` | actor-def | **Water trickle puzzle** — body `#30`. Per-instance flag via `$0E + #$0080` (`TestFlagRaw`/`SetFlagRaw`). **Activation requires ALL:** player body `$97` (Shadow attack), `$0028=#$0001` (attack held), `$characterForm=#$0001` (**Shadow**), `BranchIfPlayerNear (#0C)`. On success: `SetFlagRaw`, water-flow anim `StageSpriteLoopMoveY (#1B, #02, #0F)`, sounds `#$1515`. **Already solved:** `ClearAllHere`, collision priority toggled. `SetMetasprite (@table_0EE000)`, `StageSprAndHitbox (#1B)` |
| `$08C77F` | `$08C84C` | 205 | `pyDA_lithograph1` | actor-def | **Hieroglyph Stone 1** — body `#30`. `$cameraBoundsY=#$0100`. **Flags checked:** `#C2`→already taken. **Flags set:** `#C2`. `$12` bit `$0200`, `AddPosition (#00, #02)`. **Interact:** *"There's a lithograph on this wall... a hieroglyph... Let's try to remove it."* `GiveItem (#1E)` — **Hieroglyph Stone**. Fanfare `MusicAndText (#17)`: *"You've got the Hieroglyph Stone!"* Full inventory → `InventoryFullMessage`. If `#C2` already set: `StageBgChange (#94)` + `ApplyBgChange` (empty wall) + Die |
| `$08C84C` | `$08C8F4` | 168 | `pyDA_lithograph2` | actor-def | **Hieroglyph Stone 2** — flag `#C3`, item `#1F`, BG change `#95`. Same pattern as lithograph1, reuses its dialogue strings |
| `$08C8F4` | `$08C99C` | 168 | `pyDA_lithograph3` | actor-def | **Hieroglyph Stone 3** — flag `#C4`, item `#20`, BG change `#96` |
| `$08C99C` | `$08CA44` | 168 | `pyDA_lithograph4` | actor-def | **Hieroglyph Stone 4** — flag `#C5`, item `#21`, BG change `#97` |
| `$08CA44` | `$08CAEC` | 168 | `pyDA_lithograph5` | actor-def | **Hieroglyph Stone 5** — flag `#C6`, item `#22`, BG change `#98` |
| `$08CAEC` | `$08CB94` | 168 | `pyDA_lithograph6` | actor-def | **Hieroglyph Stone 6** — flag `#C7`, item `#23`, BG change `#99` |
| `$08CE12` | `$08CEA0` | 142 | `pyDD_mystic_statue` | actor-def | **Fifth Mystic Statue** — body `#30`. Runs only if `$0AEC=0` (boss defeated, not yet rewarded). Joypad lock `$FFF0`, `WaitByte (#3B)`: *"Defeating the spirit of the Pyramid, he obtained a Mystic Statue!!"* Sets `$0AAC=#$0004` (Dark Space mode), `$0B12=#$00CD` (pyramid hint key), `$0B08/$0B0A=#$0007`, `$0B0C/$0B0E=#$0009`, `$0B10=#$0000`, `$characterForm=0` (Will). `QueueMapChange (#FD, $0000, $0000, #00, $1100)` — Dark Space for Gaia reward |

**Subtotal:** 14 pieces, 2,615 bytes

---

### 2.12 Global Actors — Jeweler Gem, Dark Space & Utility (movable, scene varies)

Two globally-spawned system actors that appear across multiple areas,
plus two small utility actors.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08B577` | `$08B592` | 27 | `actor_08B577` | actor-def | **Camera vertical nudge** — body `#20` (utility). Each frame: copies `$cameraTargetX` → `$cameraDeltaX`. If `$0036` bit `$0200` set → `$cameraDeltaY++`; else `$cameraDeltaY--`. `SetEntryContinue` loop. Used during pyramid scroll sequences |
| `$08CEA0` | `$08D69B` | 2,043 | `jeweler_gem` | actor-def | **Jeweler Gem NPC** — body `#02`. **Flags checked:** `#E8`→Die (post–Solid Arm). **Flags set:** `#E9`–`#EE` (tiers 1–6 claimed), no flag for tier 7. `SolidHighHere`, `SetOnInteract`. **Intro:** *"I am the Jeweler Gem. I control the Seven Seas."* Shows count `[BCD:2,AB0]`. **Menu** `DialogueOptions (#03, #01)`: small talk / deposit / show rewards. **Deposit:** scans all 16 `$inventorySlots` for item `#01` (Red Jewel), removes each, BCD-adds to `$jewelsCollected` (`$0AB0`). **Reward tiers (cascade on interact):** |
|  |  |  |  |  | **≥3** (`#E9`): `GiveItem (#06)` — Herb |
|  |  |  |  |  | **≥5** (`#EA`): `$playerDef` (`$0ADC`) +1 |
|  |  |  |  |  | **≥8** (`#EB`): `$playerMaxHp` (`$0ACA`) +1, `$damageFlashTimer=1` |
|  |  |  |  |  | **≥12** (`#EC`): `$playerStr` (`$0ADE`) +1 |
|  |  |  |  |  | **≥20** (`#ED`): `$0B16=1` (Psycho Dash power level) |
|  |  |  |  |  | **≥30** (`#EE`): `$0B1C=2` (Dark Friar upgrade — collision + redirect) |
|  |  |  |  |  | **≥50** (no flag): `$gfxCacheIdxA=#$0202`, `$gfxCacheIdxB=#$0404`, `QueueMapChange (#E9, $0330, $03D0, #80, $4400)` — **mansion** |
| `$08D69B` | `$08D7A8` | 269 | `dark_space` | actor-def | **Dark Space portal** — body `#0B`, sprite `#24`. Two variants: `dark_space` (`$0E=#$3000`) and `dark_space2` (`$0E=#$2000`). `SetMetasprite (@table_0EE000)`, `StageSprAndHitbox (#24)`, `SolidHighHere`, `OrActorFlags (#$0200)`. **Proximity anim:** `BranchIfPlayerNear (#05)` — idle while far; when near: activation frames `#1F`→`#21`; on departure: reverse `#21`→`#1F`. **Spawns** child `@code_08D713` at `#$2300` for activation polling. **Activation** (`code_08D730`): checks `BranchIfPlayerInRelTiles (#FF, #00, #01, #01)` + `BranchIfButton (#$0801)`. On confirm: joypad mask `$CFF0`, locks player `$0010` bit `$2000`, `PlaySoundBoth (#$0C0C)`, frame `#1C`, teleports player to portal XY−(8,16), stores variant in `$0AAC`, sets `$gfxCacheIdxB=#$0101`, `$gfxCacheIdxA=#$0200`, `$layerPriorityFlag` bit `$0200` |
| `$08FCFF` | `$08FD16` | 23 | `actor_08FCFF` | actor-def | **Decorative sprite stub** — body `#00`, init flags `#20`. Sets `$chatPtr=#$0085`, `SetMetasprite`, frame `#06`, `AnimOnce`, returns. Minimal one-shot visual prop |

**Subtotal:** 4 pieces, 2,362 bytes

### 2.13 Dark Space / Gaia System (scene `dark_space`, sE6)

The complete Gaia hub system — save, heal, transform, scene-specific
hints, ability unlocks, and exit portal. This is the largest single
logical block in bank $08, spanning over 8 KB. It powers every Dark
Space room in the game.

**Hub state machine** on entry: `$0AAC` (portal variant 0–3) stored in `$0AB2`, then `SwitchCase`:

| State | Handler | Purpose |
|-------|---------|---------|
| 0 | `code_08D856` | Default hub — minimal BG, only Gaia pedestal active |
| 1 | `code_08D87C` | Form-aware hub (Will/Freedan/Shadow BG layouts) |
| 2 | `code_08D9CC` | Ability-unlock shrine room |
| 3 | `code_08DA7D` | Sets `$0AAC=1`, jumps to state 1 |

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08D7A8` | `$08D7EA` | 66 | `sE6_gaia` | actor-def | **Gaia actor entry** — body `#23`. Spawns ambient particles (`@code_08F687` at `#$2800`, RNG-drift particles), decorative actors (`@e_actor_09A090`/`@code_09A096`). `SwitchCase($0AB2)` dispatches to hub state |
| `$08D7EA` | `$08DB9A` | 944 | `func_08D7EA` | Code | **Exit portal & save/heal** — tiles `(5–13, 13–15)` = exit portal: sound `#0C0C`, frame `#1C`, restores overworld from `$0B12`/`$0B08`/`$0B0C`/`$0B10`. `$0AAC=0`, `$gfxCacheIdxB=#$0101`, `$gfxCacheIdxA=#$0002`. **Gaia pedestal** tiles `(7–8, 9–9)`: **Flags set:** `#DC` (first visit intro). First visit: *"I am Gaia..."* Dark Power + travel journal tutorial. **Heal loop:** if `$playerHp < $playerMaxHp`: *"It looks like you're hurt. Close your eyes."* `$damageFlashTimer=#$0028` (40f), loops until HP full. **Hint dispatch:** `$0B12` (source scene) → `binary_08DE72` lookup (34 entries) → `SwitchCase` → scene-specific hint. **Save:** `DialogueOptions (#02, #02)` — *"Record what's happened so far?"* Record: `JSL SaveGameState_Scene`, sound `#29`. Don't record: exit |
| `$08DB9A` | `$08DD0B` | 369 | `loc_08DB9A` | Code | **Transform dispatch** — tile-region routing for Will↔Freedan↔Shadow transforms based on `$characterForm` and player position. Left statue `(3–10, 5–11)`: Will→Freedan or reverse. Right statue `(11–10, 13–11)`: Freedan→Shadow or reverse |
| `$08DD0B` | `$08DE72` | 359 | `dialogstring_08DD0B` | DialogString | **Gaia intro dialogue** — *"I am Gaia..."* opening conversation and tutorial strings |
| `$08DE72` | `$08DE96` | 36 | `binary_08DE72` | Binary | **Hint scene index table** — 34 source-scene IDs mapped to hint handler indices |
| `$08DE96` | `$08E9D4` | 2,878 | `dialogstring_08DE96` | DialogString | **Gaia hint dialogue (main)** — massive dialogue table with scene-specific hints for every dungeon. Key hints: `#0B` jewel/radar, `#15` Psycho Dash, `#1E` boss weak point, `#42` Dark Friar, `#62` Psycho Slider, `#85` Spin Dash, `#A7` Aura Barrier, `#B8` Earthquaker, `#CC` Shadow/Aura |
| `$08E9D4` | `$08EB2F` | 347 | `func_08E9D4` | Code | **Ability unlock logic** — reads `binary_08EB5A` table (source scene → ability bitmask). Skips if already unlocked (`mask & $abilityBitmask ≠ 0`). Player must stand in tiles `(3–10, 5–11)`. ORs mask into `$abilityBitmask`, plays unlock cinematic + tutorial text from `table_08EBD3` |
| `$08EB2F` | `$08EB5A` | 43 | `sub_08EB2F` | Code | **Ability form check** — validates high nibble of ability mask for character form requirement before animation |
| `$08EB5A` | `$08EB68` | 14 | `binary_08EB5A` | Binary | **Ability unlock table** — 6 entries mapping source scenes to ability bitmasks: |
|  |  |  |  |  | Scene `#15` (Itory) → bit `$01` Psycho Dash |
|  |  |  |  |  | Scene `#62` (Mu West) → bit `$02` Psycho Slider |
|  |  |  |  |  | Scene `#86` (Wall Blind Pit) → bit `$04` Spin Dash |
|  |  |  |  |  | Scene `#42` (Mine Elevator) → bit `$10` Dark Friar |
|  |  |  |  |  | Scene `#A7` (Kress Maze) → bit `$20` Aura Barrier |
|  |  |  |  |  | Scene `#B8` (Angkor Inner East) → bits `$40` Earthquaker |
| `$08EB68` | `$08EB8F` | 39 | `dialogstring_08EB68` | DialogString | **Supplementary dialogue** — short additional hint/ability strings |
| `$08EB8F` | `$08EBD3` | 68 | `table_08EB8F` | &DialogString | **Hint pointer table A** — pointer array indexing into hint dialogue |
| `$08EBD3` | `$08EF32` | 863 | `table_08EBD3` | &DialogString | **Ability tutorial table** — pointer array mapping ability indices to tutorial/description strings |
| `$08EF32` | `$08F235` | 771 | `func_08EF32` | Code | **Transform system** — handles Will↔Freedan↔Shadow character swap: sprite reloading, ability state, `$characterForm` update, `ShadowShimmerInit` spawn for Shadow. **First Freedan** (`#F7` clear): inner-voice cutscene, `SetFlagByte (#F7)`. **First Shadow** (`#DD` clear): Shadow intro cutscene, `SetFlagByte (#DD)`. Repeat transforms: `DialogueOptions (#02, #02)` Yes/No. **Shadow requires:** `#B4` clear (Shadow-era flag). All transforms set `$playerFlags |= #$0800` during cutscene |
| `$08F235` | `$08F26E` | 57 | `func_08F235` | Code | **Ability: Psycho Dash** — grants Will's Psycho Dash, bit `$01` |
| `$08F26E` | `$08F2A3` | 53 | `func_08F26E` | Code | **Ability: Psycho Slider** — grants Will's Psycho Slider, bit `$02` |
| `$08F2A3` | `$08F2DF` | 60 | `func_08F2A3` | Code | **Ability: Spin Dash** — grants Will's Spin Dash, bit `$04` |
| `$08F2DF` | `$08F37D` | 158 | `func_08F2DF` | Code | **Return to Will** — form-dependent reverse animation, restores `$characterForm=0` |
| `$08F37D` | `$08F3B1` | 52 | `func_08F37D` | Code | **Ability: Aura Barrier** — grants Freedan's Aura Barrier, bit `$20`. Also called from Jackal scene when `$characterForm=1` |
| `$08F3B1` | `$08F3EA` | 57 | `func_08F3B1` | Code | **Ability: Earthquaker** — grants Freedan's Earthquaker, bits `$40`. Also called from Jackal scene when `$characterForm≠0,≠1` |
| `$08F3EA` | `$08F5F9` | 527 | `func_08F3EA` | Code | **Shadow transform & Aura item** — handles Shadow transformation (`$characterForm=2`), spawns `ShadowShimmerInit`. Also handles Aura item `#24` grant: `GiveItem (#24)` with inventory-full check, `MusicAndText (#17)`. State 2 BG: extra layers `#8E`/`#8F` |
| `$08F5F9` | `$08F63C` | 67 | `func_08F5F9` | Code | **Exit portal config A** — configures south-portal exit coordinates/warp destination |
| `$08F63C` | `$08F67F` | 67 | `func_08F63C` | Code | **Exit portal config B** — alternate exit for certain Dark Space rooms |
| `$08F67F` | `$08F6D3` | 84 | `actor_08F67F` | actor-def | **Exit portal actor** — south-facing portal, warps back to overworld at stored coords |
| `$08F6D3` | `$08F709` | 54 | `sub_08F6D3` | Code | **Portal cleanup** — clears `$playerFlags` bit `$0800`, restores idle state after Dark Space exit |

**Subtotal:** 24 pieces, 8,033 bytes

---

### 2.14 Mansion — Solid Arm Boss & Intro (scenes `solid_arm_lair` sEA, `mansion` sE9)

The Jeweler Gem's endgame reveal: mansion awakening and the Solid Arm
boss fight. Flag `#E8` links these to `jeweler_gem` — setting it here
causes the Gem NPC to die globally.

| Address | End | Size | Name | Type | Description |
|---------|-----|------|------|------|-------------|
| `$08F709` | `$08FC6A` | 1,377 | `sEA_solid_arm` | actor-def | **Solid Arm boss** — body `#00`. **Flags set:** `#E8` (intro played — also kills `jeweler_gem` globally). `$cameraBoundsY=#$0100`. **Intro** (`#E8` clear): `WaitByte (#13)`, sound `#0E`, `StageBgChange (#9C)`, joypad mask `$EFF0`, music `#1B`. Long reveal: Jeweler Gem = Solid Arm, Red Jewel scheme, Blazer, forced labor. **Boss AI** (loops on `$playerYPos` and `BranchOnPlayerX`): **Upper zone** (`Y < #$0070`): shard rain (3 spawns `@code_08F8B4/8E6/900` at Y−24), double diagonal shards, double horizontal shards, shuffle left/right. **Lower zone** (`Y ≥ #$0070`): move toward player, **slam left** (stats `enemy_stats_table+180`, frames `#09`→`#0A`, sound `#02`), **slam right** (frames `#0B`→`#0C`). **Projectiles:** `OrActorFlags (#$0010)`, `CollPrioritySetMax`, priority `#30`, looping paths, `$26`=damage timer (6/8/10f). Homing `code_08F977` uses `CopySiblingFollowState` with `$chatPtr=#$8013`, `$loopCounter=3`, tracks `$playerActor`. **Defeat** (`$0AEC==0`, companion `code_08F9F2`): *"I was defeated again… hurry to the Tower of Babel…"* PPU: `$TM=#$15`, `$CGADSUB=#$21`. `QueueMapChange (#E3, $0280, $01A0, #80, $2310)` — **Babel upper floors** |
| `$08FC6A` | `$08FCFF` | 149 | `sE9_mansion_intro` | actor-def | **Mansion awakening** — body `#30`. **Flags checked:** `#29`→skip intro. **Flags set:** `#29` (first visit). **First visit:** `$CGADSUB=#$21`, joypad mask `$EFF0`, `WaitByte (#1D)`: *"When I awoke, I was standing in the entrance to a strange mansion."* **Persistent:** applies `$CGADSUB=#$21` while player outside exit zone. **Exit zone** `(#32,#3E)`–`(#34,#3F)`: `$gfxCacheIdxA=#$0202`, `$gfxCacheIdxB=#$0404`, `QueueMapChange (#E3, $0280, $01A0, #80, $2310)` — same Babel destination as Solid Arm defeat |

**Subtotal:** 2 pieces, 1,526 bytes

---

## 3. Group Summary by Parent

| Parent Group | Scenes | Pieces | Bytes | % of Bank | Address Range |
|--------------|--------|--------|-------|-----------|---------------|
| `native_village` | 3 | 27 | 6,093 | 18.6% | `$088000`–`$0897CB` |
| `angkor_wat` | 7 | 13 | 3,296 | 10.1% | `$0897CB`–`$08A4AB` |
| `dao` | 7 | 24 | 4,300 | 13.1% | `$08A4AB`–`$08B577` |
| `pyramid` | 8 | 25 | 6,414 | 19.6% | `$08B577`–`$08CEA0` |
| `actors` (global) | — | 4 | 2,362 | 7.2% | `$08CEA0`–`$08D7A8` + `$08FCFF` |
| `system` (dark_space) | 1 | 24 | 8,033 | 24.5% | `$08D7A8`–`$08F709` |
| `mansion` | 2 | 2 | 1,526 | 4.7% | `$08F709`–`$08FD16` |
| *(unmapped)* | — | — | ~744 | 2.3% | scattered gaps |

---

## 4. Scene Cross-Reference

| Scene ID | Scene Name | Pieces | Primary Purpose |
|----------|------------|--------|-----------------|
| nvAC | `native_village` | 19 | Party NPCs, villagers, sacrifice sequence |
| nvAD | `vacant_hut` | 3 | Party rest hut |
| nvAE | `gorgon_hut` | 5 | Stone girls, Kara departure trigger |
| awB0 | `angkor_entrance` | 1 | Jungle intro narration |
| awB2 | `angkor_outer_east` | 1 | Stair trigger |
| awB3 | `angkor_outer_north` | 1 | Ladder climb trigger |
| awB4 | `snake_pit` | 2 | Snake pit room controller + visual init |
| awB6 | `angkor_outer_courtyard` | 1 | Explorer remains (Friezer's journal) |
| awB7 | `angkor_inner_gate` | 1 | Gate controller |
| awBA | `angkor_inner_courtyard` | 2 | Explorer remains + glasses pickup |
| awBC | `angkor_shrine_crystal` | 2 | Blinding light hazard + floating crystal |
| awBD | *(cross-map trigger)* | 1 | Spawn position / ladder descent |
| awBF | `angkor_pinnacle` | 1 | Spirit guide prophecy |
| daC3 | `dao` | 14 | Town NPCs, animals, labor trade |
| daC4 | `dao_hotel` | 2 | Kara & Erik at hotel |
| daC5 | `sweatshop` | 2 | Overseer + weaver |
| daC6 | `panic_room` | 1 | Snake Panic minigame |
| daC7 | `desert_explorers` | 3 | Pyramid exploration camp |
| daC8 | `dao_dorm` | 1 | Neil reunion |
| daC9 | `indecision_room` | 1 | Businessman moral dilemma |
| pyCC | `pyramid_main` | 4 | Entrance portal, dark space, mummy queen portal |
| pyCD | `puzzle_room` | 7 | Jackal boss, Kara, flame traps, hieroglyph puzzle |
| pyD0 | *(ladder climb)* | 1 | Ladder trigger |
| pyD4 | `pyramid_trickle_a` | 1 | Water puzzle (Shadow-only) |
| pyD6 | `pyramid_vader_a` | 2 | Toggle gate pair |
| pyD7 | `pyramid_vader_b` | 1 | Sliding sand trap |
| pyD9 | `pyramid_dangerslide_b` | 1 | Falling rock spawner |
| pyDA | `heiroglyph_room` | 6 | Hieroglyph stone pickups (×6) |
| pyDD | `mummy_queen_lair` | 1 | Fifth Mystic Statue reward |
| sE6 | `dark_space` | 24 | Gaia system: save, heal, transform, hints |
| sE9 | `mansion` | 1 | Mansion awakening |
| sEA | `solid_arm_lair` | 1 | Solid Arm boss fight |

---

## 5. Notable Patterns

### Narrative Arc Coverage
Bank $08 covers the complete **North-western Hemisphere chapter**:
1. **Native Village** — Sacrifice feast, Hamlet's death, emotional `DialogueOptions` villager interactions
2. **Angkor Wat** — Temple exploration, Gorgon Flower acquisition, spirit prophecy
3. **Dao** — Desert town, labor trade, Snake Panic minigame, Neil reunion
4. **Pyramid** — Jackal boss, hieroglyph puzzle, Mummy Queen lead-up
5. **Dark Space** — Complete Gaia save/transform system (global)
6. **Mansion** — Jeweler Gem reveal as Solid Arm

### DialogueOptions Pattern
The Native Village uniquely uses `DialogueOptions` for emotional player-choice
interactions (most other banks use Yes/No prompts):
- `nvAC_hand_man` — *"Take his hand?"*
- `nvAC_dumpling_man` — *"Eat some?"*
- `nvAC_staring_man` — *"Stare back?"*
- `nvAC_map_kid` — *"Show him the map?"*
- `nvAC_beckon_kid` — *"Go with him?"*

### Shared Interact Handlers
The three villager pairs share interact code across their primary/secondary variants:
- `code_088CC6` — hand men (both instances)
- `code_088DC4` — dumpling men (both instances)
- `code_088EC2` — staring men (both instances)

### Jeweler Gem Reward Tiers

| Jewels | Flag | Reward |
|--------|------|--------|
| ≥3 | `#E9` | Herb (`GiveItem #06`) |
| ≥5 | `#EA` | +1 DEF (`$playerDef`) |
| ≥8 | `#EB` | +1 Max HP (`$playerMaxHp`), damage flash |
| ≥12 | `#EC` | +1 STR (`$playerStr`) |
| ≥20 | `#ED` | Psycho Dash power (`$0B16=1`) |
| ≥30 | `#EE` | Dark Friar upgrade (`$0B1C=2`) |
| ≥50 | — | Secret mansion warp (`QueueMapChange #E9`) |

### Gaia Ability Unlock Table

| Source Scene | Ability | Bitmask | Character |
|-------------|---------|---------|-----------|
| `#15` Itory Village | Psycho Dash | `$01` | Will |
| `#62` Mu West | Psycho Slider | `$02` | Will |
| `#86` Wall Blind Pit | Spin Dash | `$04` | Will |
| `#42` Mine Elevator | Dark Friar | `$10` | Freedan |
| `#A7` Kress Maze | Aura Barrier | `$20` | Freedan |
| `#B8` Angkor Inner East | Earthquaker | `$40` | Freedan |

### Cross-System Flag Links

| Flag | Set by | Consumed by | Effect |
|------|--------|-------------|--------|
| `#E8` | `sEA_solid_arm` | `jeweler_gem` | Solid Arm intro → Gem NPC dies globally |
| `#BB` | `pyCD_jackal` | `pyCD_kara`, `daC4_kara` | Jackal defeated → Kara advances, Dao Kara removed |
| `#D0` | `pyCD_kara` | `pyCD_kara`, `daC8_neil`, `daC4_kara` | Pyramid arc complete → Neil offers Babel flight |
| `#D1` | `pyCD_puzzle` | `pyCC_portal` | Puzzle solved → Mummy Queen portal appears |
| `#BE` | `awBF_spirit_guide` | `awB0_intro` | Spirit guide done → intro suppressed |

### Key Story Flags

| Flag | Meaning |
|------|---------|
| `#29` | Mansion first visit |
| `#AC` | Native Village intro cutscene done |
| `#AD` | Kara skeleton-house dialogue seen |
| `#AE` | Vacant hut intro seen |
| `#AF` | Morning after sleep; bonfire cleared; villagers active |
| `#B0` | Leave vacant hut |
| `#B1` | Map kid showed temple location |
| `#B2` | Hamlet sacrifice complete |
| `#B3` | Angkor intro played |
| `#B4` | Neil dorm reunion played / Shadow-era gate |
| `#B5` | Snake pit first visit |
| `#B6` | Dao arrival narration |
| `#B7` | Shrine blinding light first entry |
| `#B8` | Luggage man letter delivery done |
| `#BA` | Black Crystal Glasses collected |
| `#BB` | Jackal defeated |
| `#BD` | Spirit guide vision started |
| `#BE` | Spirit guide vision complete |
| `#BF`–`#C1` | Stone girls 1/2/3 transformed |
| `#C2`–`#C7` | Hieroglyph Stones 1–6 collected |
| `#CF` | Gorgon hut Kara intro complete |
| `#D0` | Pyramid arc complete (post-Flute) |
| `#D1` | Hieroglyph puzzle solved |
| `#D2` | Dao departure |
| `#DC` | First Gaia pedestal visit |
| `#DD` | First Shadow transform offer |
| `#E6` | Stone girl 2 Red Jewel given |
| `#E7` | Snake Panic high score achieved |
| `#E8` | Jeweler Gem removed (post–Solid Arm) |
| `#E9`–`#EE` | Jeweler reward tiers 1–6 claimed |
| `#F7` | First Freedan transform |
| `#FC` | Post-pyramid completion (portal removed) |
| `$016B` | Angkor east stair used (word) |
| `$016E` | Angkor north ladder used (word) |
| `$0170`/`$0171` | Pyramid ladder used (word, per-variant) |
