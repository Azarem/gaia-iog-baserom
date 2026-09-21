# Bank $06 — Late Mid-Game Actors: Sky Garden Descent, Seaside Palace, Mu & Angel Village

> ROM bank $06 (`$068000`–`$06FFFF`, 32,768 bytes) contains **NPC and cutscene
> actor definitions** for the late mid-game story arc of Illusion of Gaia — from
> the Sky Garden descent through the Seaside Palace, the ruins of Mu, and the
> entirety of Angel Village including its underground tunnels. This bank spans
> the transition from the third chapter into the fourth, covering Will's crash
> landing, the ghost palace, the Vampire boss sequence, and the Angel Tribe's
> isolated community.
>
> The bank is almost entirely actor-def scripts (75 of 84 pieces), with a small
> handful of Code stubs (7 — mostly destroy callbacks) and DialogStrings (2).
> There are no enemy stat tables, data tables, or thinker-defs; all enemies in
> this bank (Phantom Ribber, floor spikes, force balls) reference stats from
> bank $00's `enemy_stats_table`. The bank is 72.5% mapped with a 9,000-byte
> unmapped tail gap that is likely padding or engine-auto-discovered content.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$068000`–`$06FFFF` (425,984–458,751) |
| Total bank size | 32,768 bytes |
| Mapped | 23,768 bytes (72.5%) |
| Unmapped tail gap | 9,000 bytes (`$06DCD8`–`$06FFFF`) |
| Parent groups | 4 major areas (Sky Garden, Seaside Palace, Mu, Angel Village) |
| Total pieces | 84 (75 × `actor-def`, 7 × `Code`, 2 × `DialogString`) |
| Scene groups | 23 distinct scenes across 4 game areas |

---

## 2. Area Overview

| Area | Scenes | Pieces | Bytes | Narrative Role |
|------|--------|--------|-------|----------------|
| Sky Garden (descent) | `garden_descent` | 4 | 1,174 | Post-boss falling sequence, Red Eye aftermath, transition to Seaside Palace |
| Seaside Palace | `palace_main`, `palace_rooms`, `palace_coffins`, `palace_fountain`, `palace_passageway` | 13 | 4,880 | Ghost palace NPCs, Phantom Ribber enemy, coffin puzzles, fountain event |
| Mu | `mu_south`, `mu_west`, `mu_prayer_room`, `mu_altar_room`, `mu_connector`, `mu_vampire_lair` | 14 | 4,578 | Ruins exploration, spirit encounters, Rama spirits, Vampire boss lair party events |
| Angel Village | `undersea_tunnel`, `angel_entrance`, `angel_annex`, `angel_village`, `angel_rooms`, `angel_tunnel_*` (6 sub-scenes) | 52 | 13,097 | Tunnel camp, village NPCs, Ishtar's trials, Kara rescue, companion dialogues |
| Utility | — | 1 | 23 | Shared NPC facing helper function |

---

## 3. Memory Map

### 3.1 Sky Garden — Descent Sequence (scene `garden_descent`, sp58)

After defeating the Sky Garden bosses, Will falls from the floating garden.
These actors control the descent cutscene, Neil's failed rescue attempt,
the Red Eye post-fight transition, and Will's monologue before washing up
at the Seaside Palace.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$068000` | `$068111` | 273 | `sp58_missed_flight` | actor-def | **Neil mid-air rescue fail.** Gates on `$0AA6 == 0`. Sets `$12` bit `$1000`, positions Neil at X `$FFA4`. Neil approaches horizontally (`#03`, 42px, speed 1), spawns helper `code_068042` with `SpawnAfterFlags #$2000`. Helper waits 29 frames, prints party dialogue (Neil drops contact lens, Kara scolds, Lance encourages retry), then monitors Will's Y position — sets flag `#01` when Y ≥ `$0120`. Main actor catches the signal, sets `#02`, retreats infinite loop (frame `#83`, speed 2). Frames: `#03` forward, `#83` reverse |
| `$068111` | `$068190` | 127 | `sp58_actor_068111` | actor-def | **Descent scene controller.** Gates on `$0AA6 == 0`. Disables joypad (`$EFF0`), sets `TM = #$15`, ORs `$2000` on player `$10` (translucent body). Spawns music helper `code_068185` (starts music `#06`, writes APUIO1 `$0A`). Will falls continuously (frame `#00`, Y +17) until `#01` set by `missed_flight`. Then Y-loop 52px at speed `$11`, sound `#$2C2C` (impact), X-slide 160px. Sets `$0AA6 = 2`, `$gfxCacheIdxB = $0404`, queues map `#58` reload (same scene, next phase). Frames: `#00` fall, `#02` slide |
| `$068190` | `$068380` | 496 | `sp58_red_eye` | actor-def | **Red Eye boss aftermath — party relief dialogue.** Gates on `$0AA6 == 2`. `FadeThenStartMusic #02`. Player translucent. Spawns helper `code_06821C` which waits ~299 frames then prints party exchange (Neil: close call; Kara sobbing; Erik sniffing; Lance: Will saved; Lilly praises Neil's invention; Neil: to the ocean, Mu lies somewhere). Sets `#01`. After `#01`, sets companion actor state to `2`, moves X 60px, **`ClearAllWramFlags`** (clean slate for next area), queues map `#59`. Frame: `#07` throughout |
| `$068380` | `$068496` | 278 | `sp58_monologue` | actor-def | **Will's post-escape monologue + palace transition.** Contains two actor-defs: stub `sp58_sp58_actor_068380` (falls through to shared Y-drift loop if `$0AA6 == 1`) and main `sp58_monologue`. Spawns dialogue helper `code_0683C2` which waits ~478 frames, prints Will's internal monologue (escaped airplane; Neil good inventor but something always missing), waits 119 frames, sets GFX cache, **queues map `#5A`** (Seaside Palace entry at `$0090,$0070`, dir `#83`). `StartMusic #1B`. Frame: `#05`, continuous Y-drift |

**Subtotal:** 4 pieces, 1,174 bytes

---

### 3.2 Seaside Palace — Main Hall (scene `palace_main`, sp5A)

The Seaside Palace is a haunted underwater structure where the party takes
shelter after Sky Garden. The main hall contains monologue triggers, the
Phantom Ribber enemy, ambient whisper voices, and post-rescue villagers.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$068496` | `$06861E` | 390 | `sp5A_monologue` | actor-def | **Scene-indexed one-shot narration.** Locks joypad `$CFF0`. Branches on `$sceneCurrent`: scene `$5A` → if `#6E` clear, set `#6E`, print palace arrival monologue (standing in huge palace, can't remember since landing, asks if everyone is safe); scene `$5F` → if `#77` clear, set `#77`, print Mu arrival line (Lilly and he set foot on Mu); scene `$61` → requires `#7B` set (prayer-room spirits done) and `#7C` clear, set `#7C`, print water-receding line (Lilly: less water, new areas to explore). Unlocks joypad, dies |
| `$0689A3` | `$068A59` | 182 | `sp5A_phantom_ribber` | actor-def | **Phantom Ribber — invulnerable ghost enemy.** Dies if `#70` set. Sets `$currentHp = $00FF`, loads `enemy_stats_table+44`. Infinite ping-pong patrol: frames `#07`/`#08` east X+18 each, hold `#00` for 20 frames, then `#87`/`#88` west X+17, hold 20. Hit callback `code_0689F3` spawns `ToggleActorVisibilityFlag` (flags `#$2800`), sets `$12` bit `$0200`, converts to interactable NPC. Interact dialogue: "odd, touching causes no damage." **Not actually killable** — conversion to NPC happens via hit callback; flag `#70` (set by fountain) despawns it |
| `$068A59` | `$068FEB` | 1,426 | `sp5A_villagers` | actor-def | **Rescued palace villagers — 14-variant wandering NPCs.** Hidden until `#70` set. Uses `NpcRandomWanderAI` + `ActorDisplayModeSwap` facing helper. `$24` selects dialogue (0–13): cases cover demon backstory, vampire couple lore, Mu connection, palace layout hints. **Case 9 special (key giver):** if `#85` clear and no music playing → `GiveItem #10` (Seaside Palace Key), set `#85`, `MusicAndText #17`. Inventory-full path provides alternate dialogue. Sets `$playerFlags` bit `$0008` on init |
| `$069535` | `$069736` | 513 | `sp5A_voice` | actor-def | **Invisible whisper zone triggers.** Runs each frame via `SetEntryHere`; if `#70` set → RTL (silenced after Ribber defeated). Checks **5 absolute tile zones**, each one-shot: zone 1 (`#37–38,#28–29`) → `#71`, "Palace of Vampires, fountain produces demons"; zone 2 (`#0E–0F,#38–39`) → `#72`, "basement fountain, stone is there, hurry"; zone 3 (`#2B–2C,#59–5A`) → `#73`, "Purification Stone in castle"; zone 4 (`#36–3B,#07–0B`) → `#83`, Will senses life from right room; zone 5 (`#08–0B,#18–1A`) → `#84`, life from left room. Uses shared preamble `dialogstring_069705` ("soft voice from somewhere") |

**Subtotal:** 4 pieces, 2,511 bytes

---

### 3.3 Seaside Palace — Guest Rooms (scene `palace_rooms`, sp5B)

Party member rooms where each companion paces and offers dialogue before
the palace event is resolved. All room companions (except Lilly) share:
hidden until `#70` set, spawn `ToggleActorVisibilityFlag #$2800`,
pacing patrol loop, interact dialogue.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06861E` | `$068685` | 103 | `sp5B_kara` | actor-def | **Kara pacing in guest room.** Dies if `#70`. Patrol loop: `#20` east X+4 speed `$12` → hold `#1C` 120f → `#21` west X+4 speed `$11` → hold `#1D` 120f → repeat. Interact: *"Will... Where... Where is it...??"* Frames: `#1C`, `#1D`, `#20`, `#21` |
| `$068685` | `$068876` | 497 | `sp5B_lily` | actor-def | **Lilly pocket emergence cutscene.** Dies if `#6F`. Proximity trigger (2-tile radius). Locks joypad, `StartMusic #1B`, waits. Print "Waaah!!" with `[CLD]` cloud effect. Multi-stage: Lilly emerges (frame `#28` move X+3), scolds Will for scaring her, examines Erik in other room (transparent/unconscious), multi-frame fidget (`#24`/`#23`/`#25`/`#22` ×4, `#33` ×8). Borrows Will's pocket, "Well, let's go." **Sets `#6F`**, clears `$0688`. **Flag `#6F` unlocks coffin puzzles and fountain.** Frames: `#22`–`#25`, `#28`, `#33` |
| `$068876` | `$0688F0` | 122 | `sp5B_erik` | actor-def | **Erik pacing.** Dies if `#70`. Patrol: `#10` east X+4 speed `$12` → hold `#0C` 120f → `#11` west X+4 speed `$11` → hold `#0D` 120f. Interact: *"What is this place? Dark and lonely. Mother, save me..."* Frames: `#0C`, `#0D`, `#10`, `#11` |
| `$0688F0` | `$06894C` | 92 | `sp5B_lance` | actor-def | **Lance pacing.** Patrol: `#08`/`#09` with holds `#04`/`#05`, 120f each. Interact: *"Uhhhn. Uhhhn."* (unconscious groan). Frames: `#04`, `#05`, `#08`, `#09` |
| `$06894C` | `$0689A3` | 87 | `sp5B_neil` | actor-def | **Neil pacing.** Patrol: `#18`/`#19` with holds `#14`/`#15`, 120f each. Interact: *"Uhhhn. Uhhhn."* (same groan). Frames: `#14`, `#15`, `#18`, `#19` |

**Subtotal:** 5 pieces, 901 bytes

---

### 3.4 Seaside Palace — Coffin Rooms (scene `palace_coffins`, sp5C)

Two push-puzzle coffin actors. Both require `#6F` (Lilly emerged) and use
Neil's push animation from `@table_0EE000` frame `#33`, joypad lock, and
BG tile swaps to reveal items inside.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$068FEB` | `$0691AC` | 449 | `sp5C_key_coffin` | actor-def | **Key coffin push puzzle.** Dies if word `#$013A` set. Offsets +8 X. Interact (pre-`#6F`): *"Coffins are lined up..."* Interact (post-`#6F`): Lilly describes hole in coffin, sets byte `#01` (triggers push on re-entry). Auto-cutscene: locks joypad, clears player `$10` bit `$2000`, sets Neil metasprite `@table_0EE000`. Neil walks Y−16, pushes `#33` X+4 loop toward (`$0300,$009C`). `StageBgChange #3A` + `ApplyBgChange` — reveals key in coffin. Sets word `#$013A`. Lilly: *"key fastened inside — that's why lid wouldn't open."* Neil returns to player position, unlocks joypad |
| `$0691AC` | `$0693F8` | 588 | `sp5C_stone_coffin` | actor-def | **Stone coffin push → Purification Stone.** Dies if word `#$013B`. Same Neil push choreography targeting (`$02C0,$009C`). `StageBgChange #3B`. **`GiveItem #11`** (Purification Stone) + `MusicAndText #17`. Polls `$APUIO1` for `$FF` (melody end) before Neil walks back. **Inventory-full retry:** clears `#$013B` and byte `#02`, `SetTilePos (#2B,#0A)` to reset map tile, jumps back to cutscene start. Interact pre-`#6F` same coffin text; post-`#6F` Lilly inspects, sets byte `#02` |

**Subtotal:** 2 pieces, 1,037 bytes

---

### 3.5 Seaside Palace — Fountain (scene `palace_fountain`, sp5D)

The palace fountain is the key event trigger — using the Purification Stone
here causes the water to rise, resolving the palace chapter.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$0693F8` | `$069535` | 317 | `sp5D_fountain` | actor-def | **Palace fountain purification event.** Clears `$066D`. Dies if `#70` set, `#6F` not set, or **item `#11` missing**. Locks joypad. Lilly: strange fountain, connection to the rock. If `#0E` set (stone already used via inventory elsewhere) → exits. Positions at player, spawns marked helper `code_069502`. Sound `#$2525`. **40-iteration rise loop:** fountain frame `#26` Y+2 per step, priority `#30`. Moves toward (`$0100,$0160`). Sets `CGADSUB = #$03` (additive blend). Spawns 2 palette flash thinkers. Sets `#0F`, waits, spawns palette reset thinker. Waits ~689 frames. Clears `#0F`. **Sets `#70`** (palace chapter resolved — same flag as "Ribber defeated"; dual-role flag that shows villagers and removes room companions). `ClearSolidAbs (#0D,#0F)` removes fountain tiles. Helper `code_069502` periodically spawns RNG demon visual (`code_06951E`) using `table_0EE000` frame `#02` — random X scatter, immediately dies after one display frame |

**Subtotal:** 1 piece, 317 bytes

---

### 3.6 Seaside Palace — Passageway (scene `palace_passageway`, sp5E)

A hidden passage connecting the palace to Mu, discovered by Lilly.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$069736` | `$0697A6` | 112 | `sp5E_passageway` | actor-def | **Hidden passageway trigger.** Dies if `#7D` set. Polls each frame via `SetEntryHere`. If player in tiles `#14–16, #08–0C` → sets `#7D`, prints Lilly: *"A passageway — wonder if it goes clear to Mu?"* |

**Subtotal:** 1 piece, 112 bytes

---

### 3.7 Mu — Southern Ruins (scene `mu_south`, mu61)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$0697A6` | `$0698A2` | 252 | `mu61_hint` | actor-def | **Lilly's statue sight-line hint.** Dies if `#7A` set or `#78` not set (Hope statue not found). Polls each frame. If player in tile rect `(0A,30)–(0C,37)` → sets `#7A`, Lilly: *"The treasure chest sits where the lines of sight between both statues cross."* Pure positional one-shot gated by `#78` → `#7A` chain |

**Subtotal:** 1 piece, 252 bytes

---

### 3.8 Mu — Western Ruins (scene `mu_west`, mu62)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$0698A2` | `$0699C7` | 293 | `mu62_hope_statue` | actor-def | **Hope Statue — key item source.** Contains **two actor defs** (statue A and statue B) for duplicate rooms. **Statue A:** sets `#78` on init (unlocks mu61 hint), interact → if `#79` clear and no music playing: `GiveItem #12` (Statue of Hope), set `#79`, `MusicAndText #17` + dialogue (`[SFX:0]`). Full inventory → alternate text. **Statue B:** identical flow but uses flag `#7F` instead of `#79`; alternate dialogue: *"Was there another room with the same name…?"* Music guard prevents overlapping fanfare |

**Subtotal:** 1 piece, 293 bytes

---

### 3.9 Mu — Prayer Room (scene `mu_prayer_room`, mu63)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$0699C7` | `$069C2A` | 611 | `mu63_spirits` | actor-def | **Spirit apparition sequence — 10+ child actors.** Body `#0E`. **Layout fork** based on player tile position: south layout (`#7B`) vs north layout (`#7E`). If corresponding flag set → spawns sun sprite only and dies. **Full cutscene (first visit):** spawns sun `code_069ABB` at `($80,$58)`. Locks joypad. Music `#1B`. Palette flash `oneshot_palette_flash_1B`. Timed spawns of 6 wandering spirits (`code_069C14` — metasprite `@table_0EDA00`, frame `#06`, sound `#$2525`, loop until `#02`) and 4 solid blocking spirits (`code_069BDA` — body `#0E`, sound `#$2626`, visibility flicker via `$10` bit `$2000` toggle). Dialogue: *"The Sun god… Rama… The ocean holds a power…"* Sets `#02` (syncs all children to end). Palette flash `oneshot_palette_flash_1C`, clears `$0688`, unlocks joypad. Spawn flag words: `#$1000`, `#$1800` |

**Subtotal:** 1 piece, 611 bytes

---

### 3.10 Mu — Altar Room (scene `mu_altar_room`, mu66)

The central altar room of Mu, containing the Rama spirit encounter and
burial ground flavor text.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$069C2A` | `$069C6D` | 67 | `mu66_altar1` | actor-def | **Altar warp trigger.** Body `#2D`, offset Y−8. Dies if `#80` set. Displays frame `#2D`. Dies if `#81` set. If player **outside** center 32×32 tile zone `(00,00)–(20,20)` → locks joypad, sets `$gfxCacheIdxA/B = $0303/$0404`, **queues map `#66`** at (`$F8,$1D8`, layer `#80`, attr `$2200`). Edge-entry triggers transition |
| `$069C6D` | `$069C85` | 24 | `mu66_altar2` | actor-def | **Secondary altar prop.** Body `#2D`, offset Y−8. Dies if `#81`. Displays frame, `SetEntryHere` idle. Visual companion to altar1 |
| `$069C85` | `$069CE9` | 100 | `mu66_actor_069C85` | actor-def | **Dual-purpose: flavor text + camera bounds.** If player in tiles `(20,00)–(30,10)` → sets `$cameraBoundsY = $0100`, dies (camera limit patch in north band). Otherwise: if `#82` clear → sets `#82`, locks joypad, prints *"Ancient Mu burial ground."*, unlocks. Idle after |
| `$069E3C` | `$06A2BE` | 1,154 | `mu66_rama_spirits` | actor-def | **Rama spirit encounter — 6 indexed lore spirits.** Dies if word `#$0139` set. Offset (+8,+2). Interact handler. Spawns **6 spirits** `code_06A01E` at fixed coords with `$24` indices 0–5 (each is solid interactable, metasprite `@table_0EDA00` body `#04`, `$12` bit `$0200`). **Intro cutscene** (if `#0F` clear): joypad lock `$EFF0`, SNES color math (`CGWSEL=$80`, `CGADSUB=$03`), palette flash `#18`, `StageBgChange #39` + apply, sets word `#$0139`, palette flash `#19`, writes scene transition regs, **queues map `#FD`** (vision flash). **Spirit interact** (`SwitchCase $24`): 0=ray of light from sky, 1=bodies changing, 2=friends becoming monsters, 3=despair, 4=debate over fleeing, 5=undersea tunnel construction. Each sets flags `#02`–`#07`. **Main interact:** if `$eventFlags & $FF == $FE` → Mystic Statue reward text + set `#0F`; if `#01` clear → Rama introduction + set `#01`; else → "Hear the words of spirits awakened" |

**Subtotal:** 4 pieces, 1,345 bytes

---

### 3.11 Mu — Shared Hazards (scenes `mu60_*` / `mu_connector`)

Reusable hazard actors deployed across multiple Mu dungeon rooms.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$069CE9` | `$069D1F` | 54 | `mu60_floor_spikes` | actor-def | **Floor spike trap.** Body `#28`. Dies if on solid tile. Loads `enemy_stats_table`. Infinite 4-frame cycle: `#28` (wait `$27`) → `#29` (clears `$10` bits `$0101` — hitbox active/damaging) → `#2A` (wait `$3B`) → `#2B` (sets `$10` bits `$0101` — hitbox inactive) → repeat. Damage window toggles mid-animation |
| `$069D1F` | `$069D4D` | 46 | `mu64_switch_spikes` | actor-def | **Switch-activated retractable spikes.** Body `#2A`. Loads `enemy_stats_table`. Frame `#2A` + `MarkSolidHere` (extended, damaging). If `#0F` set → `ExitIfFlagByte` (stays retracted). When `#0F` clear: `ClearSolidHere` removes collision. Retract frames `#2B` → `#28` → wait `$C7` → `#29`. **Self-clears `#0F`** so spikes re-extend. External switch actor sets `#0F` to retract |
| `$069D4D` | `$069E3C` | 239 | `mu60_force_ball` | actor-def | **Force Ball energy orb.** Body `#25`. Dies on solid tile. Sets `$12` bit `$0021`, priority `#30`. `$currentHp = #$FF` (255 HP — pushable). Spawns **`push_handler_forceball`** child after (`#$2400`) + follower **`code_069D79`** before (`#$2000`). Follower tracks parent, detects player adjacency within 16px, probes solidity, **injects player velocity** (`$playerSpeedEw`/`$playerSpeedNs` = ±8) to create force-field pushback. `PlaySoundCh2 #1D` on push impulse |

**Subtotal:** 3 pieces, 339 bytes

---

### 3.12 Mu — Vampire Lair (scene `mu_vampire_lair`, mu67)

The Vampire boss lair containing pre-fight party interactions, the bomb
puzzle, and the post-rescue reunion cutscene. Note: the actual Vampire
boss AI (`mu67_vampires.asm`) resides in bank `$0A`, not bank $06.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06A2BE` | `$06A410` | 338 | `mu67_erik` | actor-def | **Erik in vampire lair.** Body `#0C`. If `$characterForm != 0` (Gaia disguise) → `$24 = $FFFF` (hidden variant). Solid, offset +8 X, `$12` bit `$0200`. If `#86` clear: polls player in tiles `(01,13)–(0F,15)` → locks joypad, music `#1B`, prints *"Heeeeelp!! Someone save me!"*, sets `#86`. Post-`#86`: if `#04` set → exits (Neil reunion started). Unless `#88` or `#06` set, performs complex walk-out choreography (Y/X moves using `#0E`/`#11`/`#10` frames, exits to frame `#0B` idle). Interact: pre-`#01` → *"Defuse the bomb! Hurry!"*; post-`#01` normal → *"Once again Will has saved me…"*; disguised (`$24=$FFFF`) → *"Don't tell anyone Will's in disguise"* |
| `$06A410` | `$06A745` | 821 | `mu67_bomb` | actor-def | **Bomb detonation puzzle — fake choice.** Body `#24`. Spawns countdown HUD `code_06A69E` at (`$80,$F0`) with flags `#$2B00`. Solid, offset +8 X. If `$characterForm != 0` (Gaia): repoints player actor to `sE6_gaia.Transform_FreedanToWill`, sets `$playerFlags` bit `$0800`. BG alarm layers: `StageBgChange #46`/`#47` + apply, sets word flags `#$0146`/`#$0147`. **Wire puzzle interact:** "Red wire or blue wire?" → **both choices set `#01`** + confirmation text (fake puzzle — either works). **Detonation wait:** waits for `#01`, locks joypad, music `#1B`, waits 119f. Sound `#$2C2C`. 60-frame shake loop (`$10` toggle). Shifts left 8px, clears collision. Post-defuse dialogue (Will, Erik, Lilly apology). Sets `#03`. `StageBgChange #93` + apply (clears alarm BG). **Countdown child:** displays `$26` from `$0140` (320), BCD-decrements each second with sound `#10` (tick). At 0: if `$0AEC != 0` → sound `#$1515`, `$playerHp = 0` (lethal); else → "It was a dud. I'm saved…" |
| `$06A745` | `$06A828` | 227 | `mu67_neil` | actor-def | **Neil reunion (part of `mu67_neil_lily`).** Body `#13`. Waits for `#03` (bomb defused). Player in tiles `(01,19)–(0F,1B)` triggers: locks joypad `$FFF0`, sets `#04`. **Runtime VRAM reload:** `Decompress` + `AdhocVramDma` for `gfx_nazca_sprites`, `spm_nazca_sprites`, palette copy. Sets `#88`. Music `#01`. Neil walks in (frame `#17` Y ×2, speed 2), dialogue: *"Will! Are you OK?!"*, Lance asks about Lilly. **Spawns `e_mu67_lily`** with flags `#$1002` |
| `$06A828` | `$06A846` | 30 | `mu67_actor_06A828` | actor-def | **Party member entrance walker (likely Lance).** Body `#03`. Waits for `#88`. Wait 29f. Clears `$10` bit `$2000`. Walks Y (frame `#07`, ×2, speed 2). Holds frame `#03` idle. Simple timed entrance synchronized to Neil reunion |
| `$06A846` | `$06A9E7` | 417 | `mu67_kara` | actor-def | **Kara post-lair dialogue — ends Mu arc.** Body `#1B`. Waits for `#88`. Clears `$10` bit `$2000`. Walks in (frame `#1F` Y ×2, speed 2), holds `#1B`. Reacts to Lilly's line (frame `#1C` if `#05` set). Waits for `#06` (Neil/Lilly exchange done). Extended idle `#1B ×30`. Group dialogue: Kara: leave Mu; Lilly: heard from Rama; Will: Mu history recap; Neil: try the tunnel; Lance: *"Let's get out of here!!"* Sets **`$0AA6 = 0`** (seeds undersea tunnel camping phases). Sets `$gfxCacheIdxB = $0404`. **Queues map `#68`** (Undersea Tunnel at `$70,$C0`) |
| `$06A9E7` | `$06AAAD` | 198 | `e_mu67_lily` | Code | **Lilly reunion entrance (spawned by `mu67_neil`).** Positions from player Y−16. Runs in (frame `#33` Y ×4, speed `$14`). Fidget anims (`#33`/`#24`/`#23`/`#25`/`#22` ×4 each). *"Sorry I worried you…"* → sets `#05`. Neil: *"Will seems to have really grown up."* → sets `#06` |

**Subtotal:** 6 pieces, 2,031 bytes

---

### 3.13 Angel Village — Undersea Tunnel (scene `undersea_tunnel`, st68)

The undersea passage connecting Mu to Angel Village. The party camps here
for an extended rest, with multiple phased cutscenes controlled by `$0AA6`
(phase 0 = initial camp, 1 = post-Erik day-skip, 2 = post-Lily night/Seth Morse).

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06AAAD` | `$06AAD5` | 40 | `st68_campfire` | actor-def | **Campfire prop.** `SwitchCase $0AA6`: phase 0 → `SetMetasprite @table_0EDA00`, `StageSprAndHitbox #08`, `MarkSolidHere`, animate. Phases 1–2 → `Die`. Static solid animated campfire |
| `$06AAD5` | `$06ADED` | 792 | `st68_neil` | actor-def | **Neil at camp — 3-phase diary narrator.** Phase 0: `MarkSolidHere`, locks joypad, waits 29f. **Major dialogue:** *"5 days in tunnel, monotonous scenery"* + full party banter (Neil: rest here; Erik: walked 500 miles; Lance: crazy; Kara: stop complaining; Lilly: hungry). **Sets `#01`** (camp intro complete). Frame `#14` idle. Interact → Neil on ancient travelers. If `#02` not set (mushrooms not gathered), polls player tile rect `(0B,00)–(0C,10)` and sets `#03` on proximity. Phase 1: dies. Phase 2: teleports to `(24,26)`, locks joypad, diary dialogue: *"Two weeks in tunnel, no end"*, Kara hears odd sound. Sets `#01` |
| `$06ADED` | `$06AEB0` | 195 | `st68_erik` | actor-def | **Erik — walk-in + day-skip narrator.** Phase 0: skips choreography if `#01` set. Multi-segment walk-in (north, west, east, south using `#0E`/`#10`/`#11` frames). Solid, interact: *"Hey, don't look!"* Skips departure if `#04` (Kara dinner) set. Otherwise walks east, narrates: *"In this way, another day passed slowly..."*, **increments `$0AA6`** (0→1), queues scene `#68` reload at `($70,$1A0)`. Phase 2: teleports to `(23,26)` |
| `$06AEB0` | `$06AF2F` | 127 | `st68_lance` | actor-def | **Lance — walk-in + idle.** Phase 0: skips if `#01`. Walk-in loop (frames `#07`/`#09` mixed directions). Solid, interact: *"I wonder how far this tunnel goes..."* Skips departure walk if `#04`. Otherwise walks north to frame `#02` idle. Phase 2: teleports to `(24,29)`, frame `#03` |
| `$06AF2F` | `$06B4EC` | 1,469 | `st68_kara` | actor-def | **Kara — largest tunnel actor. Seth Morse code revelation + Angel Village exit.** Phase 0: skips walk-in if `#01`. Walk-in north (frame `#1E` ×30). Solid, interact: *"I want steak/salad, skin dry."* Skips mushroom dinner if `#03` (Neil proximity). Otherwise: animates `#1A` ×6, dinner dialogue (Kara: mushrooms again; Lilly: better than starving), **sets `#04`**. Walks east, idle. **Phase 2 (Seth sequence):** teleports `(21,27)`, frame `#1D`. Sound `#1E` ×3 (Morse/rumble). Looking-around anims (`#1B`/`#1D`/`#1A`). Kara: hears the sound. Camera shake via `CameraDriftLoopShip` spawned 3× total (1 + `LoopInit #02`). Music `#06`. Erik: "Riverson?"; Kara: "Run!"; Lilly: "Run where?" **Morse beep pattern** (`CallScript code_06B03C`): `LoopInit #02` × 6× `PlaySoundCh1 #1E` with varied waits. `FadeThenStartMusic #1B`. Neil identifies Morse code. **Seth's message:** swallowed by Riverson, body changed, Riverson = ocean creature evolved by comet light, can't continue journey, party must solve riddle. Party reactions. **`ClearAllWramFlags`**. **Queues map `#69`** (Angel Village entrance at `$02A0,$00C0`) |
| `$06B4EC` | `$06B840` | 852 | `st68_lily` | actor-def | **Lilly — night river cutscene.** Phase 0: skips if `#01`. Wait 63f, frame `#25`. Solid, interact: *"forgetting purpose of journey."* Skips frame change if `#04`. Phase 1: teleports `(17,28)`, locks joypad, diary: *"8th day, unable to sleep, stared at underground river."* Lilly walks east 40px then back (frame `#28`), idle anims. Lilly: *"Can't sleep?"* **`InitPlayerScriptVariant #03`** (forces Will to east-facing idle). Extended Will/Lilly conversation (joking about mushrooms, strange warrior power since father went to Babel, Lilly joined for fun). **Increments `$0AA6`** (1→2). Queues scene `#68` reload at `($160,$1C0)`. Phase 2: teleports `(25,29)` |
| `$06B840` | `$06B937` | 247 | `st68_mushrooms` | actor-def | **Mushroom gather point.** Phase 0 only (phases 1–2 die). `$12` bit `$0200`. Solid, interact → diary narration: *"Mushrooms only food — yesterday baked, day before boiled, before that raw."* `ClearSolidHere` (remove collision). **Sets `#02`** (mushrooms gathered — gates Neil's proximity check). No `GiveItem` — purely narrative |
| `$06B937` | `$06B9F2` | 187 | `st68_actor_06B937` | actor-def | **Ambient tunnel critter spawner.** `$12` bit `$1000`. Rate-limited by `$0036 & $3F == 0`. `RngByte & 3`: nonzero (75%) → variant A body `#35`, zero (25%) → variant B body `#34`. Each variant: `code_06B9E4` randomizes X from `$cameraTargetX + RNG`, Y from `$cameraTargetY`. Creatures perform multi-directional wander loops then **gravity fall** (`StageSpriteMoveY + BranchIfSolid` loop until hitting ground). On ground: idle until off-screen (`$10` bit `$4000`) or ~12.5% RNG chance → dies. Spawn flag word `#$0B02` |

**Subtotal:** 8 pieces, 3,909 bytes

---

### 3.14 Angel Village — Utility Function

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06B9F2` | `$06BA09` | 23 | `ActorDisplayModeSwap` | Code | **NPC facing/variant initializer (23 bytes).** Copies low nibble of `$0E` → `$24` (dialogue variant index). Sets `$0E = $2000` (actor class bits). Clears `$10` bit `$2000`, sets `$10` bit `$1000` (sprite layering). Called by `sp5A_villagers`, `av69_signs`, `av6B_ocean_ache`, `av6B_villagers1` |

**Subtotal:** 1 piece, 23 bytes

---

### 3.15 Angel Village — Entrance (scene `angel_entrance`, av69)

The village entrance where the party arrives one by one in a scripted
parade sequence. Scene-local flags `#01`–`#04` control choreography.
All actors die if global `#8D` or `#75` is set.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06BA09` | `$06BA85` | 124 | `av69_signs` | actor-def | **Angel Tribe welcome signs.** `ActorDisplayModeSwap` for variant. `SetMetasprite @table_0EDA00`, frame `#05`. Solid. `$24 == 0` → *"Travellers / Please use this room. / Angel Tribe."* `$24 != 0` → *"Angel Village Entrance."* Two map instances with different spawn params |
| `$06BA85` | `$06BBEF` | 362 | `av69_lance` | actor-def | **Lance — drives the parade sequence.** Locks joypad `$CFF0`. Wait 29f. Dialogue 1 (Neil: *"We're here at last… walked through the tunnel for almost a month…"* / Lance: *"Look! A sign!"*). Walk in: `#07` north Y ×2, `#08` east X+18. Dialogue 2: reads sign, discusses Angel Tribe. **Sets `#01`** (unlocks Neil/Lily/Erik). Idle at sign (`#05` ×30 ticks, `#02`). If `#04` set (Lily/Kara race) → ends here (no `#75`, no exit walk). Otherwise **sets `#75`** (Lance done globally). Exit walk: east+south off-screen, unlocks joypad mid-walk |
| `$06BFFA` | `$06C038` | 62 | `av69_neil` | actor-def | **Neil entrance — silent walk-in.** Waits for `#01`. Multi-segment wander path: `#17` south ×4, `#19` west ×2, `#17` south ×4, `#18` east ×2. Exit south: `#16`/`#17`. No dialogue, no interact — pure choreography |
| `$06C1B2` | `$06C28E` | 220 | `av69_lily` | actor-def | **Lily entrance — unlocks Kara, optional mediation.** Waits for `#01`. Walk in: `#27` south, `#28` east, frame `#22`. Dialogue: *"Will, let's go."* **Sets `#02`** (unlocks Kara). If `#03` not yet set (Kara hasn't run off): frame `#24`, dialogue: *"Why are you so grouchy…"* / Lance: *"Maybe she's just tired."* **Sets `#04`** (truncates Lance exit). Fidget loop (`#24`/`#23`/`#25`/`#22` ×4, `#33` extra). Moves toward pixel `($02A8,$0060)` |
| `$06C348` | `$06C382` | 58 | `av69_kara` | actor-def | **Kara entrance — storms off alone.** Waits for `#02`. Frame `#1D`. Dialogue: *"What! Will! Come with me! What are you grinning about? I'll explore this place myself!"* Raises `$10` bit `$0800` (priority boost). Walks east: `#20` X+2, `#1F` Y ×2. **Sets `#03`**. Continues east `#20` ×5 off-screen |
| `$06C3B1` | `$06C417` | 102 | `dialogstring_06C3B1` | DialogString | Kara's entrance confrontation dialogue text |
| `$06C46A` | `$06C4B9` | 79 | `av69_erik` | actor-def | **Erik entrance — silent walk-in.** Waits for `#01`. Wait 29f. Walk in: `#0F` south ×5, `#11` north, `#0F` south ×4, hold `#0C` ×30. Frame `#0A`. If `#04` not set: east walk `#10` ×2. Exit south: `#0E`/`#0F`. No dialogue |

**Subtotal:** 7 pieces, 1,007 bytes

---

### 3.16 Angel Village — Annex (scene `angel_annex`, av6A)

Indoor annex scenes where party members settle. Two phases: **Phase A** (default,
before Kara rescue) — initial positions + dialogue; **Phase B** (`#8C` set, post
`av74_kara` rescue) — repositioned actors, new dialogue, Erik reconciliation.
All actors die if `#8D` is set (global cleanup at Watermia).

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06BAF8` | `$06BAFA` | 2 | `av6A_lance_destroy` | Code | Destroy callback stub |
| `$06BBEF` | `$06BFFA` | 1,035 | `av6A_lance` | actor-def | **Lance — love confession + gift advice.** Phase A: solid, interact. First-time interact (if `#74` clear): sets `#74`, confesses love for Lilly, 2-choice menu: *"Right / Not true."* If supportive → asks gift advice for Lilly's 15th birthday, 4-choice menu: 0=loop, 1=flowers (*"rose buds"*), 2=necklace (*"stones/necklace"*), 3=kiss (*"might be too sudden"*). All merge to *"Thanks for the advice…"* `[JMP:]` Post-`#74`: thanks-only repeat. **Phase B (`#8C`):** teleports to `(28,12)`, interact → Lilly's birthday in the Floating City |
| `$06C036` | `$06C038` | 2 | `av6A_neil_destroy` | Code | Destroy callback stub |
| `$06C038` | `$06C1B2` | 378 | `av6A_neil` | actor-def | **Neil — departure to Watermia (only annex actor with map transition).** Phase A: interact → *"Angels are descendants of Mu people."* If `#8C` set pre-`#A9`: teleports `(15,14)`, paces east-west (`#19` ×4, speed 1). **Post-`#A9`:** teleports `(23,14)`, interact → *"Can we go now? Yes / Wait a minute."* Yes: *"No hurry."* Wait: heat-stroke warning, zeros companion array `$0D60–$0D6A`, `StageWorldMapMove (900,356)` move ID `#11`, **queues map `#78`** at `($250,$370)` dir `#06` cam `$4500` — **Watermia / Floating City** |
| `$06C222` | `$06C224` | 2 | `av6A_lily_destroy` | Code | Destroy callback stub |
| `$06C28E` | `$06C348` | 186 | `av6A_lily` | actor-def | **Lily — pre/post-rescue NPC.** Phase A: interact → *"Why do angels live in such a dark/gloomy place?"* Phase B (`#8C`): teleports `(26,14)`, interact → *"Kara looks strange; something happened"* |
| `$06C380` | `$06C382` | 2 | `av6A_kara_destroy` | Code | Destroy callback stub |
| `$06C382` | `$06C3B1` | 47 | `av6A_kara` | actor-def | **Kara — inverted `#8C` logic.** Dies on `#8D`. **Exits script if `#8C` set** (Kara handled elsewhere post-rescue). Clears `$10` bit `$2000`. If `#A9` not set: walk-in `#21` east, frame `#1A`. Interact → *"In the Floating City, houses built on rafts. Romantic. I like it."* Priority `#30` |
| `$06C417` | `$06C46A` | 83 | `dialogstring_06C417` | DialogString | Kara's annex dialogue text |
| `$06C4B7` | `$06C4B9` | 2 | `av6A_erik_destroy` | Code | Destroy callback stub |
| `$06C4B9` | `$06C6DA` | 545 | `av6A_erik` | actor-def | **Erik — post-rescue reconciliation (central Phase B event).** Phase A: interact → *"Sun is really bright."* **Phase B (`#8C`, `#A9` clear):** teleports `(15,12)`, solid, locks joypad `$CFF0`. Walk-in `#11`, hold `#0D` ×40, walk `#11` ×3. Group dialogue with embedded SFX (`[SFX:1A]` Neil ×2, `[SFX:19]` Lilly, `[SFX:1B]` Kara): Neil worried → Lilly scolds Kara → Kara apologizes → Neil forgives → Floating City 3 days south, *"tell me when you're ready."* **Sets `#A9`** (unlocks Neil departure + Kara static state). Unlocks joypad. **Post-`#A9`:** teleports `(22,12)`, interact → *"Saw a Red Jewel in Angel Village"* |

**Subtotal:** 11 pieces, 2,284 bytes

---

### 3.17 Angel Village — Village Exterior (scene `angel_village`, av6B)

The main Angel Village overworld with wandering NPCs, a musician,
doors, and flame decorations.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06C6DA` | `$06C755` | 123 | `av6B_ocean_ache` | actor-def | **Melancholy wandering villager.** Body `#02`. `ActorDisplayModeSwap` + `SyncActorPosFromDP`. `$currentHp = 2` (wander seed). `NpcRandomWanderAI` loop. Interact: all 4 `$24` cases identical → *"I don't know when we started living here. When I look at the ocean, my heart aches."* |
| `$06C755` | `$06CA10` | 699 | `av6B_villagers1` | actor-def | **Village NPCs set 1 — 6-case dialogue.** Body `#02`. Custom facing decode: extracts bits 4–6 of `$0E` (`AND $0070` >> 4) → `$28` (facing offset). `ActorDisplayModeSwap` for `$24`. Static solid. Cases 0/1/2/5: *"This is Angel Village. Sun exposure = perish."* Case 3: Ishtar question — Yes/No menu: Yes → *"Speak with everyone."* No → Ishtar studio directions, hate creatures warning, *"If you must go, open the door."* Case 4: *"I am a sculptor, 1000 statues in my lifetime…"* |
| `$06CACA` | `$06CBAF` | 229 | `av6B_villagers2` | actor-def | **Village NPCs set 2 — wandering.** Body `#0A`. `$currentHp = $0A` (10). `NpcRandomWanderAI`. 3 cases: 0/2: *"We have no emotions… neither laughed nor cried since the day I was born."* 1: *"A human woman named Kara came here. Ishtar praised her beauty. Then she went to his studio."* |
| `$06CBAF` | `$06CD47` | 408 | `av6B_villagers3` | actor-def | **Village NPCs set 3 — static with directions.** Body `#0A`. Facing from bits 4–5 of `$0E`. 3 cases: 0/2: *"We are the form into which humans evolve."* 1: Detailed directions to Ishtar's studio: *"follow torch flame bend → dark street → wind tunnel → waterfall sound → loud waterfall = studio entrance. Be careful."* |
| `$06D0AB` | `$06D124` | 121 | `av6B_musician` | actor-def | **Harp-playing woman.** Body `#18`. Solid. `$12` bit `$0200`. `StageSpriteFrame #98` (harp pose). Interact → *"Music is the best medicine for the soul. The right song will cure any disease."* |
| `$06D745` | `$06D784` | 63 | `av6B_door` | actor-def | **Studio door — WRAM collision patching.** Body `#00`. Writes collision byte `$0F` to WRAM `$7FC568`/`$7FC56A`/`$7FCA52`/`$7FCA54`. Offset +8 X. If player near (`BranchIfPlayerNear #01`): auto-open → `PlaySoundCh2 #06`, `StageBgChange #45` + `ApplyBgChange`, **sets `$0AA6 = 0`** (resets voice-trial door counter). Interact (manual): **sets `#01`** only. `ExitIfFlagByte #01` after interact registration (script ends if already opened) |

**Subtotal:** 6 pieces, 1,643 bytes

---

### 3.18 Angel Village — Interior Rooms (scene `angel_rooms`, av6C)

Indoor scenes of Angel Village homes with dancing NPCs and decorations.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06CA10` | `$06CACA` | 186 | `av6C_villagers4` | actor-def | **Dancing NPCs.** Body `#02`. `ActorDisplayModeSwap`. `$12` bit `$0200`. Horizontal dance loop: `#09` east X+20 speed 2 → hold `#05` ×32f → `#09` west X+19 speed 4 → hold → `#09` east X+20 → repeat. 2 cases: 0 → *"People here love to dance."* 1 → *"The picture on that wall was painted by Ishtar. But the model in the painting was lost."* |
| `$06CD47` | `$06CE82` | 315 | `av6C_villagers5` | actor-def | **More dancing NPCs.** Body `#0A`, move body `#10`. Same dance pattern. 3 cases: 0 → *"I dance to remember what it feels like to be human."* 1 → *"Ishtar painted us with faces overflowing with human kindness. People wanting to be painted flocked here."* 2 → *"I used to dance with the person in that picture."* |
| `$06D04D` | `$06D0AB` | 94 | `av6C_only_sleeping` | actor-def | **Sleeping villager.** Body `#0A`. Solid, `$12` bit `$0200`. Interact → Will: *"She appears to be sleeping. It's like the spirit's drawn out…"* |
| `$06D124` | `$06D134` | 16 | `av6C_harpist` | actor-def | **Indoor harpist — display-only.** Body `#18`. `$12` bit `$0200`. Frame `#18` (indoor harp pose, different from outdoor `#98`). **No interact handler** — purely decorative. 3 instances at staggered positions |

**Subtotal:** 4 pieces, 611 bytes

---

### 3.19 Angel Village — Tunnel Rooms & Ishtar's Trials (scenes `angel_tunnel_rooms` av74, `angel_tunnel_test` av75)

The underground tunnels beneath Angel Village where Ishtar guides Will
through puzzle trials to earn passage. Contains the Kara portrait rescue
sequence and the voice puzzle doors.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06CE82` | `$06D04D` | 459 | `av74_ishtar` | actor-def | **Ishtar — trial gatekeeper.** Body `#12`, offset Y−4, `$12` bit `$0200`. Spawns blocking child `code_06CEB8` at Y−16 (`SpawnAfterRelFlags $0000,$FFF0,$0300`). **If `#89` clear (trials incomplete):** shows Ishtar sprite, interact → *"I wonder if you're here to get Kara… Go into this room. Solve all the riddles, I'll give back the girl."* **If `#89` set:** actor dies. **Child body `#13`:** if `#89` clear → solid blocker at abs `(25,08)`; if `#89` set → frame `#15`, `$10` bit `$1000`, interact → Ishtar's final instruction. **Post-trial interact (if `#8B` clear):** *"Sprinkle magic powder on the painting, give it a kiss… I painted a self-portrait. Soon I will become the painting… You must take care of her…"* Sets `#8B`. **If `#8B` set:** *"………………"* |
| `$06D14E` | `$06D55B` | 1,037 | `av74_kara` | actor-def | **Kara portrait rescue — VRAM swap cutscene.** Body `#16`. Dies if `#8C` (done). Offset `(+8,−3)`, priority `#10`. Spawns interact child `code_06D251` at Y+16. **If item `#14` (Magic Dust) missing:** enters auto-cutscene `code_06D171` (exits if `#01`/`#8A`). Locks joypad `$FFF0`. Color math: palette adds/subs + 2× `SpawnThinker oneshot_palette_flash_40`. **Heavy GFX:** decompresses `gfx_nazca_sprites` → VRAM `$5000–$5C00`, copies `spm_nazca_sprites` tiles + `pal_nazca_sprites`. Kara emerges: Y/X moves (`#1F`/`#20`/`#1B`/`#1C` frames), extended dialogue: Kara apology → Will angry → Kara crying (castle life vs journey) → Will lecture → acceptance. Sounds `[SFX:10]`/`[SFX:1B]`. Sets `#8C`. Queues **map `#6A`** at `($01A0,$00B0)`. **Interact** (`#89` clear) → *"Kara's picture, she is contained inside it…"* (`#01` set + dust) → *"Will gently kisses the picture of Kara…"* Sets `#8A`. **Requires item `#14`** (Magic Dust) |
| `$06D784` | `$06D8BC` | 312 | `av75_voice_doors` | actor-def | **8 sequential trial doors.** Body `#00`. Dies if `#89`. `$12` bit `$0200`. `SetMetasprite @table_0EE000`, frame `#00`. Activates only if `$playerYPos ≥ $F0`. Copies `$0E` low nibble → `$24` (door index 0–7). Interact: requires `$0AA6 ≥ $24` (doors must be opened in order from left). Match → `PlaySoundCh1 #0E`, `StageBgChange #49–50` per index, `ApplyBgChange`, set word flag `#$0149–#$0150`. Too early → Ishtar's voice: *"Don't hurry. Open the doors in order from the left."* Already open → *"That door is already open."* |
| `$06D8BC` | `$06DC50` | 916 | `av75_voice_rooms` | actor-def | **Voice trial room controller — spot-the-difference puzzle.** Controller at `(00,01)`. If `$playerYPos ≥ $F0` → unmask joypad, die (exit corridor). On room entry: clears word flags `#$0149–#$0150`. **X-tile parity split** (`$playerXTile & $10`): even → `$0AA6++`, instruction dialogue, wait; odd → different instruction, **spawns movable observation actor** `code_06DBF3` at player position (frame `#19`, priority `#30`, D-pad controlled: 2px/input, Y clamp `$08–$D0`, X clamp `$08–$F8`). On button `$8001` → checks answer position vs room-specific rectangles (R0: X`$1B0–1C0` Y`$70–90`; R1: X`$330–350` Y`$A0–C0`; R2: X`$570–590` Y`$70–90`; R3: X`$790–7B0` Y`$A0–C0`). Correct → praise + `$0AA6++`. Wrong → failure + `$0AA6--`. **Room 3 correct:** also sets `#89` + word `#$0151` (all trials passed) |
| `$06DC50` | `$06DCD8` | 136 | `av75_apprentice` | actor-def | **Ishtar's apprentice — trial guide.** Body `#04`. If player in tiles `(70,00)–(80,10)` → sets `#00`, freezes `$playerSpeedNs = $FFFF`. **Relocates with trial progress** (`$0AA6 >> 1`): 1 → tile `(3A,1D)`, 2 → `(57,1D)`, 3 → `(00,71)` (off-map hide). Solid, interact → *"When you solve the puzzle of the room you may pass."* |

**Subtotal:** 5 pieces, 2,860 bytes

---

### 3.20 Angel Village — Tunnel Sub-scenes & Decorative Props

Environmental actors for tunnel connector scenes — flames (directional
navigation hints), hidden passages, wind hazard, waterfall audio, and
the portrait wall decoration.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$06D134` | `$06D14E` | 26 | `av6C_portrait` | actor-def | **Ishtar portrait — 3-layer wall decoration.** Three sub-defs all body `#17`: `portrait` → shared tail; `portrait2` → `SetSpritePalette #0C` then tail; `portrait3` (tail) → offset `(+8,−3)`, priority `#10`, idle. Deployed in av6C rooms and av75 trial rooms. No interact |
| `$06D55B` | `$06D56F` | 20 | `av6B_flame` | actor-def | **Outdoor flame torch.** Body `#06`. Offset `(+9,+3)`. `SetMetasprite @table_0EDA00`, frame `#06`. Multi-frame animated campfire. 5 instances in av6B, 6 in av6C. Flame bend direction serves as navigation hint per NPC instructions |
| `$06D56F` | `$06D57E` | 15 | `av6D_flame_left` | actor-def | **Left-biased flame.** Body `#19`. Offset `(+9,+3)`. Frame `#19`. Single sprite frame (no metasprite table). Deployed across tunnel scenes av6D/av6E/av6F/av71 |
| `$06D57E` | `$06D58F` | 17 | `av6D_flame_right` | actor-def | **Right-biased flame (H-flipped left).** Body `#19`. `ToggleHFlip`. Offset `(+9,+3)`. Frame `#99` (mirrored). Left/right flame placement encodes navigation direction through tunnel chain |
| `$06D58F` | `$06D59E` | 15 | `av70_flame_center` | actor-def | **Center flame torch.** Body `#18`. Offset `(+9,+3)`. Frame `#18`. 3 instances in av70 tunnel river |
| `$06D59E` | `$06D62F` | 145 | `av70_hidden_passage` | actor-def | **Hidden wall passage — scene-dependent reveals.** Body `#00`. **Scene `$70` (av70):** dies if word `#$0143` set; interact + auto-reveal → `PlaySoundBoth #$0F0F`, `StageBgChange #43`, sets `#$0143`. **Scene `$73` (av73):** dies if `#$0144`; `StageBgChange #44`, sets `#$0144`. Interact → sets byte `#01`, dialogue: *"The wind blows through a crack. Found a hidden pass!"* |
| `$06D62F` | `$06D68D` | 94 | `av70_crawlspace` | actor-def | **Crawlspace gate.** Body `#00`. Scene `$70`: checks `$playerYPos == $01D0`; scene `$73`: `$02D0`. On button `$0400` (crawl/duck): if `$playerFlags` bit `$0002` set (crawl form) → allows passage (RTL). Else → *"The entrance is too small!"* |
| `$06D68D` | `$06D6F4` | 103 | `av71_actor_06D68D` | actor-def | **Wind tunnel spawner + velocity field.** Body `#00`. `SpawnAfterFlags @code_06D6A0 #$2800`. Sets **`$extVelocityX = $FFF7`** (persistent leftward wind push). Spawner runs when `$0036 & $F == 0`: 50/50 RNG → body `#1C` or `#1D` debris particle. Particle X = `$cameraTargetX + $110`, random Y, random speed 10–16px/tick horizontal. `StageSprAndHitbox` + `ReloadForceMove` loop until X goes negative → dies |
| `$06D6F4` | `$06D745` | 81 | `av73_actor_06D6F4` | actor-def | **Waterfall ambient volume controller.** Body `#00`. Zone A tiles `(00,00)–(40,10)`: sets byte `#00`, dies (disables controller). Spawns helper `code_06D733` (`SpawnAfterFlags #$2000`). Main loop (rate-limited `$0036 & 3 == 0`): computes |playerXTile − `$2C`|, scales to `$APUIO0` (`$2140`) volume = `min(dist×2, $30) + $40` — louder near tile column `$2C`. Helper toggles byte `#00` based on player in tiles `(2A–2F, 17–1D)` (waterfall proximity zone) |

**Subtotal:** 9 pieces, 516 bytes

---

### 3.21 Unmapped Tail Gap

| Address | End | Size | Description |
|---------|-----|------|-------------|
| `$06DCD8` | `$070000` | 9,000 | **Unmapped** — no entries in `blocks.json`, `names.json`, or `overrides.json`. Likely padding, free space, or engine-auto-discovered content not yet cataloged |

---

## 4. Scene Group Cross-Reference

| Scene ID | Scene Group | Area | Pieces | Bytes |
|----------|-------------|------|--------|-------|
| `sp58` | `garden_descent` | Sky Garden — Descent | 4 | 1,174 |
| `sp5A` | `palace_main` | Seaside Palace — Main Hall | 4 | 2,511 |
| `sp5B` | `palace_rooms` | Seaside Palace — Guest Rooms | 5 | 901 |
| `sp5C` | `palace_coffins` | Seaside Palace — Coffin Rooms | 2 | 1,037 |
| `sp5D` | `palace_fountain` | Seaside Palace — Fountain | 1 | 317 |
| `sp5E` | `palace_passageway` | Seaside Palace — Passageway | 1 | 112 |
| `mu61` | `mu_south` | Mu — South | 1 | 252 |
| `mu62` | `mu_west` | Mu — West | 1 | 293 |
| `mu63` | `mu_prayer_room` | Mu — Prayer Room | 1 | 611 |
| `mu64` | `mu_connector` | Mu — Connector | 1 | 46 |
| `mu66` | `mu_altar_room` | Mu — Altar Room | 4 | 1,345 |
| `mu60` | *(shared)* | Mu — Reusable Hazards | 2 | 293 |
| `mu67` | `mu_vampire_lair` | Mu — Vampire Lair | 6 | 2,031 |
| `st68` | `undersea_tunnel` | Angel Village — Undersea Tunnel | 8 | 3,909 |
| `av69` | `angel_entrance` | Angel Village — Entrance | 7 | 1,007 |
| `av6A` | `angel_annex` | Angel Village — Annex | 11 | 2,284 |
| `av6B` | `angel_village` | Angel Village — Village Exterior | 6 | 1,643 |
| `av6C` | `angel_rooms` | Angel Village — Interior Rooms | 4 | 611 |
| `av70` | `angel_tunnel_river` | Angel Village — Tunnel River | 3 | 254 |
| `av71` | `angel_tunnel_wind` | Angel Village — Tunnel Wind | 1 | 103 |
| `av73` | `angel_tunnel_waterfall` | Angel Village — Tunnel Waterfall | 1 | 81 |
| `av74` | `angel_tunnel_rooms` | Angel Village — Tunnel Rooms | 2 | 1,496 |
| `av75` | `angel_tunnel_test` | Angel Village — Ishtar's Trial | 3 | 1,364 |

---

## 5. Narrative Flow

```
$068000 ─── Sky Garden descent (sp58) ──────────── Will falls, party rescue attempt,
   │         $0AA6: 0=fall, 1=monologue, 2=Red Eye       Red Eye aftermath → palace
   │
$068496 ─── Seaside Palace (sp5A–sp5E) ─────────── #6F: Lilly emerged → unlock puzzles
   │         #70: fountain purifies (ends horror)         Coffin puzzles → item #11
   │         Villagers appear, key #10 given              Fountain → #70 → villagers
   │
$0697A6 ─── Mu ruins (mu61–mu67) ───────────────── #78→#7A: statues → hint chain
   │         #7B/#7E: prayer spirits                      Rama spirits (#$0139)
   │         #86→#01→#03: Erik help → bomb → defuse      Reunion (#88, #05, #06)
   │         Kara seeds $0AA6=0 → map #68
   │
$06AAAD ─── Undersea Tunnel (st68) ─────────────── $0AA6=0: 5-day camp (#01→#02→#03→#04)
   │         $0AA6=1: Lilly night river scene             $0AA6=2: Seth Morse → map #69
   │
$06B9F2 ─── Utility function ───────────────────── ActorDisplayModeSwap NPC facing helper
   │
$06BA09 ─── Angel Village entrance (av69) ──────── Parade: #01→#02→#03 (optional #04)
   │         Lance sets #75 when done
   │
$06BBEF ─── Angel Village annex (av6A) ─────────── Phase A: rest/talk (#74 confession)
   │         Phase B: #8C → Erik reconciliation → #A9
   │         Neil departure → map #78 (Watermia)
   │
$06C6DA ─── Angel Village proper (av6B/av6C) ───── Village NPCs, flame directions,
   │         Studio door resets $0AA6                      Dancing, portraits, Ishtar lore
   │
$06CE82 ─── Angel tunnels (av70–av75) ──────────── Navigation: flames → wind → waterfall
   │         Ishtar trials: 8 doors, 4 spot-the-diff rooms
   │         Kara rescue: dust #14 + kiss → #8C → annex
   │
$06DCD8 ─── [unmapped tail gap] ─────────────────── 9,000 bytes
```

---

## 6. Key Flags & Event State

### Seaside Palace

| Flag | Type | Set By | Purpose |
|------|------|--------|---------|
| `#6E` | Byte | `sp5A_monologue` | Palace arrival monologue shown |
| `#6F` | Byte | `sp5B_lily` | Lilly pocket emergence — **unlocks coffin puzzles + fountain** |
| `#70` | Byte | `sp5D_fountain` | Fountain purified — **dual role**: shows villagers, removes room companions, silences whispers |
| `#71`–`#74` | Byte | `sp5A_voice` | Individual whisper zone triggers (one per zone) |
| `#77` | Byte | `sp5A_monologue` | Mu arrival monologue shown |
| `#7C` | Byte | `sp5A_monologue` | Water receding monologue (requires `#7B`) |
| `#7D` | Byte | `sp5E_passageway` | Hidden passageway discovered |
| `#83`, `#84` | Byte | `sp5A_voice` | Will senses life from right/left rooms |
| `#85` | Byte | `sp5A_villagers` | Seaside Palace Key given (item `#10`) |
| `#$013A` | Word | `sp5C_key_coffin` | Key coffin pushed |
| `#$013B` | Word | `sp5C_stone_coffin` | Stone coffin pushed |

### Mu

| Flag | Type | Set By | Purpose |
|------|------|--------|---------|
| `#78` | Byte | `mu62_hope_statue` | Hope statue discovered — unlocks mu61 hint |
| `#79`, `#7F` | Byte | `mu62_hope_statue` | Statue A/B item given |
| `#7A` | Byte | `mu61_hint` | Lilly sight-line hint shown |
| `#7B`, `#7E` | Byte | *(external — item use)* | Prayer room pedestal A/B placed |
| `#80`, `#81` | Byte | `mu66_altar1` | Altar room progression |
| `#82` | Byte | `mu66_actor_069C85` | Burial ground flavor text shown |
| `#86` | Byte | `mu67_erik` | Erik help scream done |
| `#88` | Byte | `mu67_neil` | Party reunion in progress — gates Kara/Lance walkers |
| `#$0139` | Word | `mu66_rama_spirits` | Rama intro cutscene complete |
| `#$0146`, `#$0147` | Word | `mu67_bomb` | Bomb alarm BG layers |

### Mu — Vampire Lair Scene-Local

| Flag | Type | Set By | Purpose |
|------|------|--------|---------|
| `#01` | Byte | `mu67_bomb` interact | Wire cut / bomb countdown stopped |
| `#03` | Byte | `mu67_bomb` detonation | Bomb defused — gates Neil reunion |
| `#04` | Byte | `mu67_neil` | Neil reunion triggered |
| `#05`, `#06` | Byte | `e_mu67_lily` | Lilly dialogue phases — gate Kara's anim |

### Undersea Tunnel Scene-Local

| Flag | Type | Set By | Purpose |
|------|------|--------|---------|
| `#01` | Byte | `st68_neil` | Camp intro complete — skips walk-in for all others |
| `#02` | Byte | `st68_mushrooms` | Mushrooms gathered — skips Neil proximity check |
| `#03` | Byte | `st68_neil` proximity | Neil repositioned — Kara skips mushroom dinner |
| `#04` | Byte | `st68_kara` dinner | Dinner done — gates Erik/Lance/Lily departure walks |

### Angel Village

| Flag | Type | Set By | Purpose |
|------|------|--------|---------|
| `#74` | Byte | `av6A_lance` | Lance love confession shown (one-shot) |
| `#75` | Byte | `av69_lance` | Lance entrance cutscene complete |
| `#89` | Byte | `av75_voice_rooms` | Voice trials complete → Ishtar vanishes, doors removed |
| `#8A` | Byte | `av74_kara` | Kara kiss performed |
| `#8B` | Byte | `av74_ishtar` | Ishtar powder/kiss instructions given |
| `#8C` | Byte | `av74_kara` | Kara rescue complete → annex Phase B |
| `#8D` | Byte | *(external — Watermia)* | Global cleanup — removes all entrance/annex actors |
| `#A9` | Byte | `av6A_erik` | Erik reconciliation complete → Neil departure ready |
| `#$0143`, `#$0144` | Word | `av70_hidden_passage` | Hidden passages revealed (av70/av73) |
| `#$0149`–`#$0150` | Word | `av75_voice_doors` | Trial doors 0–7 opened |
| `#$0151` | Word | `av75_voice_rooms` | All voice trials passed |

### Items in Bank $06

| Item | ID | Given By | Required By |
|------|----|----------|-------------|
| Seaside Palace Key | `#10` | `sp5A_villagers` (case 9, flag `#85`) | *(external)* |
| Purification Stone | `#11` | `sp5C_stone_coffin` | `sp5D_fountain` |
| Statue of Hope | `#12` | `mu62_hope_statue` | *(Angel Village pedestals)* |
| Magic Dust/Powder | `#14` | *(external)* | `av74_kara` (portrait rescue) |

---

## 7. Notable Patterns

### Actor Pairing: Entrance + Annex (av69/av6A)
The five party members each have paired actors: an `av69_*` entrance
cutscene actor and an `av6A_*` annex NPC with a 2-byte `_destroy` stub.
The entrance actors occupy interleaved address space with the annex actors'
destroy stubs, creating an interlocked ROM layout. Entrance parade is
sequenced by scene-local flags `#01`→`#02`→`#03`, with `#04` as an
optional race condition between Lily's mediation and Kara's storm-off.

### Scene Phase via `$0AA6`
Three different areas use `$0AA6` as a state machine:
- **Sky Garden descent:** 0=fall, 1=monologue, 2=Red Eye
- **Undersea tunnel:** 0=initial camp, 1=post-day-skip, 2=post-night/Seth Morse
- **Angel Village trials:** door-progress counter (0–8), reset by studio door

### Dual-Role Flag `#70`
Flag `#70` serves double duty in Seaside Palace: conceptually "Phantom
Ribber defeated" (checked by room companions and whispers) and "fountain
purified" (set by `sp5D_fountain`). This works because the fountain IS
the event that resolves the Ribber — they are the same story beat.

### Runtime VRAM Swaps
Two actors perform mid-cutscene graphics replacement:
- `mu67_neil`: loads Nazca party sprites for the reunion sequence
- `av74_kara`: loads Nazca sprites for the portrait rescue scene
Both use `Decompress` + `AdhocVramDma` + `CopyPalette`.

### Cross-Bank References
- **Vampire boss AI** (`mu67_vampires.asm`) — lives in bank `$0A` (`$0AF***`)
- **Enemy stats** — all enemies reference `enemy_stats_table` in bank $01
- **NPC wander AI** — `NpcRandomWanderAI` lives in bank $00
- **Metasprite tables** — `table_0EDA00` (bank $0E) and `table_0EE000` used extensively

### Navigation Flame System
Angel Village tunnels use left/right/center flame actor variants as a
directional hint system. NPC dialogue explicitly instructs players to
"follow the torch flame bend" through the dark streets. `av6D_flame_right`
is simply `av6D_flame_left` with `ToggleHFlip` applied.
