# Bank $07 — Watermia, Euro, Great Wall & Mt. Kress NPC Actors

> ROM bank $07 (`$078000`–`$07FFFF`, 32,768 bytes) contains **NPC actor definitions**
> for the mid-to-late-game story arc of Illusion of Gaia — covering the town of
> Watermia (including the Russian Glass minigame), the Great Wall of China
> (NPC/puzzle actors only — enemies reside in other banks), the Euro town and its
> sub-locations, and a small group of actors for the Mt. Kress / Mountain Temple
> entrance. This bank spans the fourth major chapter of the narrative, from Will's
> arrival in Watermia through Euro's Rolek Company plotline and the Mt. Kress
> expedition.
>
> The bank holds **88 mapped pieces** across 4 parent groups: primarily actor-def
> scripts with a few embedded DialogString blocks and Code helpers. It is
> overwhelmingly NPC scripting — no enemies reside in this bank.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$078000`–`$07FFFF` (491,520–524,287) |
| Total bank size | 32,768 bytes |
| Mapped | 26,919 bytes (82.2%) |
| Unmapped tail | 5,849 bytes (`$07E927`–`$07FFFF`) |
| Parent groups | 4 (`watermia`, `great_wall`, `euro`, `mountain_temple`) |
| Total pieces | 88 (actors, dialog strings, code helpers) |
| Block types | ~75 × `actor-def`, ~6 × `Code`, ~1 × `DialogString` |
| Scene groups | 4 major areas, ~20 distinct scenes |

---

## 2. Memory Map

### 2.1 Watermia — Town Exterior (scene `watermia`, wa78)

The main Watermia overworld area. Contains the intro cutscene, wandering
townspeople, the Russian Glass minigame, decorative props, and the Kara's
diary sidequest. This is the largest contiguous region in the bank.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$078000` | `$0781BE` | 446 | `wa78_intro` | actor-def | **Watermia intro cutscene** — gated on flag `#8D`. Locks joypad (`$CFF0`), hides player, spawns camera helper and narration child actor. Stages the party walking into town with sprite movement, then prints Luke's house welcome dialogue. Sets `gfxCacheIdxB=$0404` and queues map change to scene `$79` (Luke's house) |
| `$0781BE` | `$078282` | 196 | `wa78_actor_0781BE` | actor-def | **Camera bobbing controller** — invisible actor that sets `cameraBoundsY=$0400` and reads a 37-entry `camera-keyframe` table to produce a slow sinusoidal camera Y-scroll effect, simulating the floating raft-houses of Watermia. Exits if flag `#8D` is set (intro done). Keyframe data at `$078238` (ramp up → hold → ramp down → pause → loop) |
| `$078282` | `$0783ED` | 363 | `wa78_centipede_man` | actor-def | **Centipede Man NPC** — wandering townsman (body `#02`). Uses `NpcRandomWanderAI` loop. Two dialogue paths via `SwitchCase($24)`: talks about the Sand Fanger's curative fluid and warns about Russian Glass |
| `$0783ED` | `$07849B` | 174 | `wa78_moving_woman` | actor-def | **Walking woman NPC** — wandering townswoman (body `#02`). Wander AI, single interact branch. Before flag `#96`: describes Watermia. After: reports a woman chanting over a lotus leaf |
| `$07849B` | `$078501` | 102 | `wa78_water_kid` | actor-def | **Water kid NPC** — wandering child (body `#12`). Single dialogue: "We drink this water, cook with it, wash with it" |
| `$078501` | `$078962` | 1,121 | `wa78_men` | actor-def | **Town men (12 instances)** — multi-NPC actor (body `#02`). Sprite index derived from `$0E` parameter (`($0E>>4)&3 + 2`). 12-entry `SwitchCase` dispatch on `$24`. Includes: town greeter, Kruk explainer, gambling house warning, **Sky Deliveryman** (instance 3 — offers Yes/No to fly to South Cape via `StageWorldMapMove`/`QueueMapChange`), Luke, gambling advisors, crazy man references, and two empty-dialogue instances. Instance 5 self-destructs when flag `#9D` is set |
| `$078962` | `$078BBF` | 605 | `wa78_women` | actor-def | **Town women (6 instances)** — multi-NPC (body `#0A`, sprite `($0E>>4)&3 + $0A`). 6-entry `SwitchCase`. Topics: water philosophy, Nana's missing father, gambling warnings, drinking contest explanation, pregnancy/family (flag-gated on `#95`), crazy old man backstory |
| `$078BBF` | `$078D71` | 434 | `wa78_children` | actor-def | **Town children (5 instances)** — multi-NPC (body `#12`, sprite `($0E>>4)&3 + $12`). 5-entry `SwitchCase`. Topics: snake bite advice, Great Wall snake warning, Sabas (father is an explorer), lotus leaf tip, Watermia greeting |

**Subtotal:** 8 pieces, 3,441 bytes

### 2.2 Watermia — Russian Glass Game (scenes `glass_players_house` wa7D, `watermia` wa78)

The Russian Glass drinking minigame — one of the most complex actor scripts in
the bank. The game state machine at `wa78_glass_game` uses bitmask flags in
`$0AA6` to track which glasses have been drunk in which order.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$078D71` | `$078FC7` | 598 | `wa7D_glass_opponent` | actor-def | **Glass game opponent's wife** — NPC in the player's house (body `#2C`). Three-way flag gate: if `#95` set → dead. If `#97` set (opponent died) → sets flag `#95`, moves to tile, gives item `#18` (Will). Handles Inventory Full by exchanging Red Jewels (`#01`/`#06`) for jewel counter via BCD add to `$0AB0`. Default pre-game: "Cough, cough." After win: delivers opponent's will and Kruks |
| `$078FC7` | `$079AD3` | 2,828 | `wa78_glass_game` | actor-def | **Russian Glass minigame engine** — full state machine. Pre-game: uses `NpcRandomWanderAI` as wandering NPC. Post-flag `#96`: spawns 10 child actors at absolute positions (5 glasses, 5 spectators). Glass tracking via `$0AA6` bitmask (`$01/$02/$04/$08/$10`). Each round: opponent drinking animation → sound effect `#2E` → set interact handler for player's turn → player drinks (flag `#0F` handshake). Round 5: opponent's final glass → music change to `#1B` → dramatic spectator dialogue → opponent drinks and dies → flag `#97` set, map change to `wa7D`. Player's last glass offers Yes/No — "Yes" sets `playerHp=0` (death). Spectator/glass child actors have individual dialogue |

**Subtotal:** 2 pieces, 3,426 bytes

### 2.3 Watermia — Props & Decorations (scene `watermia`, wa78)

Small actors for environmental objects and interactive items.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$079AD3` | `$079B06` | 51 | `wa78_kruk` | actor-def | **Kruk (animal)** — body `#1A`, static. Solid collision, waits while offscreen, displays sprite `#1C`. Interact: "Kyaah!!...kyaah!!..." |
| `$079B06` | `$079B67` | 97 | `wa78_prize_kruk` | actor-def | **Prize Kruk** — body `#1A`. Gated: dies if flag `#94` set (game over) or `#97` not set (opponent hasn't died yet). Otherwise identical to normal Kruk. Interact: Will reflects on receiving the Kruks |
| `$079B67` | `$079B7C` | 21 | `wa78_flower` | actor-def | **Animated flower** — body `#1E`. Randomizes delay (`RngByte & $0F`) before playing sprite `#1E` animation. Purely decorative |
| `$079B7C` | `$079B88` | 12 | `wa78_lily_pad` | actor-def | **Lily pad (small)** — body `#1F`. Clears its own collision tile; used as a static decorative marker |
| `$079B88` | `$079BF5` | 109 | `wa78_full_pad` | actor-def | **Occupied lily pad** — body `#1F`. Spawns a `wa78_men` child actor (a man sitting on the pad with body `#48`, instance 4). Loops a rectangular movement cycle: east → south → west → north, updating the child's position each step. Represents the occupied pad that blocks the player |
| `$079BF5` | `$079E22` | 557 | `wa78_diary` | actor-def | **Kara's diary** — invisible interactable. On interact: "Kara's diary is secret. Read it? Yes/No". If "Yes": reads Kara's entry about arriving in Watermia, blisters, caring for someone, and the lotus leaf wishing legend |
| `$079E22` | `$079F9E` | 380 | `actor_079E22` | Code | **Moving pad platform code** — calculates collision bounds from the pad's metasprite data (inverted widths/heights), performs player proximity detection and clamping. Tracks 3 states via parent's `$26`: 0=checking entry, 1=player outside, 2=player riding. When riding, constrains player position to pad bounds |
| `$079F9E` | `$07A08C` | 238 | `wa78_moving_pad` | actor-def | **Moving lily pad (rideable)** — body `#1F`. Spawns `actor_079E22` as helper. Waits, then moves in alternating vertical loops (south ×4 passes, then north ×4 passes). When player is riding (`$26≠0`), spawns a child that mirrors pad movement to player position. Uses `KillNext` to detach player between cycles |
| `$07A08C` | `$07A0F0` | 100 | `wa78_crazy_man` | actor-def | **Old man NPC** — body `#22`, static. Solid, sprite `#22`. Dialogue: describes a crazy old man who came 2 years ago raving about the Tower of Babel (reference to Seth/Olman expedition) |

**Subtotal:** 9 pieces, 1,565 bytes

### 2.4 Watermia — Gambling House (scene `gambling_house`, wa7B)

The gambling house interior. Both actors spawn groups of seated spectators
using relative-offset spawn calls.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07A0F0` | `$07A146` | 86 | `wa7B_competitor_left` | actor-def | **Left-side group** — body `#05`. Spawns 4 seated spectator children (via `wa7B_competitor_right.code_07A192`) at relative offsets. Interact: "You can still do it!!" |
| `$07A146` | `$07A19C` | 86 | `wa7B_competitor_right` | actor-def | **Right-side group** — body `#24`. Spawns 4 seated spectators on opposite side. Interact: "Uhnn..." Contains shared spectator code (`code_07A192`) that renders sprite `#23` and sets solid |

**Subtotal:** 2 pieces, 172 bytes

### 2.5 Watermia — Luke's House (scene `lukes_house`, wa79)

Party gathering point in Watermia. Contains the main cast NPCs with deep
flag-branching for progression: pre-Glass game, Glass night, post-Glass
(opponent dead), and Euro departure. Flag `#96` = Glass game active,
`#97` = opponent died, `#91` = Lance/Lily cutscene done, `#94` = leave for Euro.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07A19C` | `$07A428` | 652 | `wa79_neil` | actor-def | **Neil** — body `#14`. Dies on `#94`. Pre-Glass `#96`: "The house on this raft gives me an idea." Post-Glass/pre-Kruk: "If you go west, there's a desert. You need Kruks." Post-flag `#97` + `#01`: triggers departure to Euro — sets `$0D60`–`$0D66` companion slots, `StageWorldMapMove` to Euro, `QueueMapChange($91)` |
| `$07A428` | `$07A537` | 271 | `wa79_erik` | actor-def | **Erik** — body `#0A`. Dies on `#94`. Pre-Glass: positioned at spawn point, dialogue about finding something behind the house. Post-Glass `#96`: repositioned to tile `05,09`, talks about the full moon. Post-`#97`: wishes Lance and Lily were coming |
| `$07A537` | `$07A86D` | 822 | `wa79_kara` | actor-def | **Kara** — body `#1D`. The largest party script. Pre-Glass: multi-phase animation (walking, looking), spawns a flower-carrying sprite child. If flag `#91` not set and `#92` not set: gives Lola's Letter item (`#16`); handles inventory-full by exchanging Red Jewel. Post-`#91` flag: prints Lily's birthday party cutscene dialogue (cake scene with Neil, sets flag `#03`). Post-Glass: worries about Lance/Lily. Post-`#97`: talks about Neil's family in Euro |
| `$07A86D` | `$07AAF5` | 648 | `wa79_lily` | actor-def | **Lily** — body `#22`. Post-`#97` / post-`#96`: repositioned to `08,09`. Pre-Glass, pre-`#91`: animated idle cycle, then birthday surprise dialogue with Erik and Neil. Sets flag `#02`. Post surprise (pre-flag `#04`): Lily runs off to another room, `QueueMapChange` to scene `$7F` (Lance/Lily exchange). Post-`#96`: talks about Lance's father. Post-`#97`: staying in town, ask Lance why |
| `$07AC7C` | `$07AFCA` | 846 | `wa79_lance` | actor-def | **Lance** — body `#03`. Includes `hidden_red_jewel`. Dies on various flags. Pre-birthday (flag `#90` set, `#91` not): locks joypad, nudges player Y, prints "Let's have Lily's birthday party", sets `#01`. Triggers Lance walking to door after flag `#03`. Post-Glass `#96`: at tile `07,09`, talks about making father happy. Post-`#97`, pre-`#A5`: dialogue about staying behind with Lily, sets flag `#01`. Post-`#A5` + pre-`#E2`: gives Red Jewel |

**Subtotal:** 5 pieces, 3,239 bytes

### 2.6 Watermia — Lance's Father's House (scene `lances_fathers_house`, wa7A)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07AAF5` | `$07AC7C` | 391 | `wa7A_lance` | actor-def | **Lance visiting his father** — body `#15`. Gated on flag `#90`. First visit: locks joypad, plays music `#1B`, prints "Do you recognize this person? He's my father." Sets flag `#02`. On return with flag `#01` (from Luke's house): "He's lost his memory…", sets flag `#90`. Proximity trigger (`BranchIfPlayerInAbsTiles $07,$07,$08,$0A`): Lance walks to player, dialogue about preparing Lily's birthday party |
| `$07B39A` | `$07B4BB` | 289 | `wa7A_lances_father` | actor-def | **Lance's father** — body `#24`, static. Solid, NPC-priority sprite. Pre-`#A5`: "I went on an expedition with Olman. It was scary, but fun." Sets flag `#01`. Post-`#A5`: fully recovered, gratitude dialogue about Lance and Lily nursing him |
| `$07B4BB` | `$07B52F` | 116 | `fireplace_journal` | actor-def | **Fireplace journal** — body `#22`. Gated on flag `#8F` — dies if already collected. On interact: "There's a journal in a crack in the fireplace." Gives item `#15` (Father's Journal), sets flag `#8F` |

**Subtotal:** 3 pieces, 796 bytes

### 2.7 Watermia — Lance & Lily Exchange (scene `lance_lily_exchange`, wa7F)

The romantic Lance/Lily cutscene outside Luke's house at night. This is a
multi-phase, multi-actor scripted cutscene driven entirely by local flags
`#01`–`#05`.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07AFCA` | `$07B1CD` | 515 | `wa7F_lance` | actor-def | **Lance in cutscene** — body `#05`. Five exit-gated phases: spawns bouquet sprite child, presents bouquet to Lily, confession dialogue ("Lily…I love you…"), waits, then walks toward coordinates `$02F8,$0120` via `MoveToward`. Spawns narration child: "We had no idea what had happened." Sets flag `#91`, changes GFX cache, `QueueMapChange` back to scene `$79` |
| `$07B1CD` | `$07B1D8` | 11 | `code_07B1CD` | Code | **Bouquet sprite** — renders sprite `#BA` (rose bouquet). Held until flag `#04` |
| `$07B1D8` | `$07B39A` | 450 | `wa7F_lily` | actor-def | **Lily in cutscene** — body `#24`. Locks joypad and hides player. Prints "What? Relax." Lance presents bouquet → Lily: "Oh, Lance! A bouquet of roses!" Sets flag `#01`. Then "They smell wonderful…Thank you." Lance's confession. Sets flags `#02`, `#03`. Post-flag `#04`: Lily turns, runs off-screen diagonally (sprite `#33` moving XY), dies |

**Subtotal:** 3 pieces, 976 bytes

---

### 2.8 Great Wall — Trail Entrance & NPC Encounters (scenes `wall_entrance` gw82, `wall_dive` gw83, `wall_inner` gw8B)

NPC actors for the Great Wall exploration — Lily and Lance companions,
story-trigger cutscenes, and interactive stone objects. Great Wall
**enemy** actors (archers, fire bugs, eyesores) reside in other banks.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07B52F` | `$07B59E` | 111 | `gw82_trail_intro` | actor-def | **Trail intro** — one-shot (flag `#9D`). Locks joypad, prints "I followed Lance's trail to the Great Wall. A corridor stretched to the distant horizon." |
| `$07B59E` | `$07B677` | 217 | `gw82_necklace_stone` | actor-def | **Necklace stone pickup** — body `#02`, multi-instance via `$0E`. Checks flags `#98`–`#9C` (one per instance from `byte_07B5F5` lookup table). If flag clear: displays animated sprite via `SetMetasprite(@table_0EE000)`, on interact gives necklace item `#17`. Sets corresponding flag on pickup. Handles inventory-full fallback |
| `$07B677` | `$07B773` | 252 | `gw83_lily` | actor-def | **Lily at wall dive** — invisible trigger (body `#00`). Gated on `#93`. Waits for player in tile region `$3B,$08–$3D,$0B`. Then: sets display mode flag, prints "Wait!", renders Lily (sprite `#33`) walking toward player via `MoveToward`. Dialogue: "Are you looking for Lance? I'll go with you!" — Lily joins the party |
| `$07B773` | `$07B824` | 177 | `gw8B_lance` | actor-def | **Lance at inner wall** — body `#05`. Gated on `#C8`. Sets solid, waits for player in region `$07,$17–$09,$1B`. Spawns `e_gw8B_lily`. Proximity trigger for deeper region `$12,$17–$14,$1B`: plays music `#15`, long cutscene — Lance gives necklace stones back, repairs necklace for Lily. Walks east, sets flags `#96` (Glass active) and `#C8`, `QueueMapChange` back to Watermia (scene `$79`) |
| `$07B824` | `$07BABD` | 665 | `dialogstring_07B824` | DialogString | **Lance & Lily reunion dialogue** — five dialogue blocks covering: Lily scolding Lance for running off, Lance explaining he got medicine, Will returning the necklace stones, Lance whispering "Will you take care of Lily for me?", and the necklace-giving / love confession sequence |
| `$07BABD` | `$07BCE8` | 555 | `e_gw8B_lily` | Code | **Lily inner wall behavior** — spawned by `gw8B_lance`. Locks joypad, moves Lily to position `$0068,$01A0` via `MoveToward`. Runs idle animation cycle, sets solid, prints reunion dialogue (flag `#01`). Extended cutscene: Lance's halting confession → Lily: "I won't run this time…I'm crying from happiness…" → Lily: "I love you, too." Sets flag `#04`, Lily walks east |

**Subtotal:** 6 pieces, 1,977 bytes

### 2.9 Great Wall — Rampway & Tomb Puzzle Actors (scenes `wall_rampway` gw85, `wall_dive` gw83, `wall_tomb` gw88)

Switch-activated spear traps and puzzle objects in the Great Wall dungeon rooms.
The four spear actors share identical logic: display sprite `#1D` (extended),
set solid on two tiles, watch for their flag to trigger retraction (sprite `#1E`),
then re-extend after a delay.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07BCE8` | `$07BD17` | 47 | `gw85_actor_07BCE8` | actor-def | **Retractable spear A** — body `#1C`. Solid on self + offset `(0,3)`. Watches flag `#01`: when set, clears flag, removes collision, plays retract animation (sprite `#1E` with priority bit), waits `$77` frames, re-extends |
| `$07BD17` | `$07BD46` | 47 | `gw85_short_switch_spear` | actor-def | **Retractable spear B** — identical logic, keyed to flag `#02` |
| `$07BD46` | `$07BD75` | 47 | `gw85_long_switch_spear` | actor-def | **Retractable spear C** — identical logic, keyed to a different flag |
| `$07BD75` | `$07BDA4` | 47 | `gw85_multi_switch_spear` | actor-def | **Retractable spear D** — identical logic, keyed to yet another flag |
| `$07BDA4` | `$07BDE8` | 68 | `gw83_switch` | actor-def | **Diving switch** — invisible trigger (body `#00`). Gated on flag word `$0152`. Uses `SetMetasprite(@table_0EE000)`. Moves toward coordinates `$0278,$0190` with `StageMove`, spawns `SpawnDebrisBurst` on impact, applies `StageBgChange(#52)`, sets flag word `$0152` |
| `$07BDE8` | `$07BE22` | 58 | `gw88_actor_07BDE8` | actor-def | **Tomb dark space trigger** — invisible (body `#00`). Gated on flag word `$0174`. Monitors `$0A9F` (scene-clear counter); when value equals `$3F` (all enemies killed): applies `StageBgChange(#74)`, sets flag word `$0174`. Post-flag: spawns a Dark Space portal (`dark_space.DarkSpacePortalInit`) at `$01C8,$0280` with `$2B00` flags |

**Subtotal:** 6 pieces, 314 bytes

---

### 2.10 Euro — Town Exterior & Shops (scene `euro` eu91)

The main Euro town area. The intro cutscene, market stalls, merchants,
townspeople, and the shop queue system.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07BE22` | `$07C05B` | 569 | `eu91_intro` | actor-def | **Euro intro cutscene** — gated on flag `#A5`. Identical structure to `wa78_intro`: locks joypad, hides player, spawns camera helper and narration actor. Narration describes crossing the desert, arriving in Euro, Neil's parents, fireworks and dancing. Post-animation: sets flag `#A5`, print "This is the house where Neil's parents live", then `QueueMapChange` to scene `$96` (guest room) |
| `$07C05B` | `$07C266` | 523 | `eu91_merchant_counter` | actor-def | **Merchant counter (8 instances)** — invisible (body `#00`). Sprite index from `($0E & $F) + $1B`. 8-entry `SwitchCase`: instance 0 is mute, instance 1 checks for apple item (`#28`) and gives it (handles inventory-full), others have unique market dialogue (green apple, soft fruit, fish shop from Watermia, corn meal, Tear Pot history) |
| `$07C266` | `$07C286` | 32 | `eu91_crate` | actor-def | **Shop crate** — body `#24`. Solid on self + offset `(1,0)`. Contains a second inline actor `eu91_crate2` (body `#25`) with identical logic |
| `$07C286` | `$07C402` | 380 | `eu91_merchant` | actor-def | **Market merchant (11 instances)** — body `#12`, sprite from `($0E>>4)&7 + $12`. Contains two inline actor-defs (`eu91_merchant2` body `#12`, `eu91_merchant3` body `#1A`, `eu91_merchant4` body `#17`). 11-entry `SwitchCase`: instance 0 barks "Don't go over there!", others mostly empty dialogue (`[DEF][END]`). merchant3/merchant4 are standalone solid NPCs with fixed dialogue |
| `$07C402` | `$07C751` | 847 | `eu91_men1` | actor-def | **Town men group 1 (multi-instance)** — body `#02`, sprite from `($0E>>4)&3 + 2`. `SwitchCase` dispatch with individual Euro-themed dialogue per instance |
| `$07C751` | `$07C92A` | 473 | `eu91_women1` | actor-def | **Town women group 1 (multi-instance)** — body `#0A`, sprite from `($0E>>4)&3 + $0A`. Individual dialogue per instance |
| `$07C92A` | `$07CA65` | 315 | `eu91_men2` | actor-def | **Town men group 2** — additional male NPCs for Euro |
| `$07CA65` | `$07CB95` | 304 | `eu91_women2` | actor-def | **Town women group 2** — additional female NPCs for Euro |
| `$07D051` | `$07D08C` | 59 | `eu91_peeking_man` | actor-def | **Peeking man** — body `#02`. Purely animated: bobs up (sprite move Y ↑), waits, bobs down, waits, then walks side-to-side in a loop. Uses `SetSpritePriority(#10)` to render behind buildings. No interact handler — decorative only |
| `$07D08C` | `$07D099` | 13 | `euro_bg_scroll_actor` | actor-def | **Behind-wall prop** — body `#02`. Adjusts position by `(0, -2)`, sets sprite priority `#30`. Purely decorative static actor behind scenery |
| `$07D252` | `$07D5D5` | 899 | `eu91_shop_queue` | actor-def | **Shop queue system** — invisible (body `#00`, flags `$30`). The most complex non-combat actor in Euro. Spawns multi-instance queuing NPCs (sprite from `($0E>>1)&$38 + 2`). Links to siblings via `$20` pointer chain. Each NPC walks a fixed path: south to `Y=$0420` → west to `X=$0228` → north to `Y=$0400` → enters shop (teleports to `$2C,$40`, loops). Collision-checks against other queue members and player proximity (`$0D` pixel threshold) before advancing. 6-entry `SwitchCase` dialogue: market praise, queue complaints, life medicine tips |
| `$07D5D5` | `$07D5E7` | 18 | `eu91_shop_door` | actor-def | **Shop door** — invisible (body `#00`, flags `$20`). Monitors its own collision tile; when a queue NPC steps on it (`BranchIfSolid`), waits `$0707` frames then clears the collision, allowing the next NPC through |
| `$07E4BC` | `$07E50B` | 79 | `eu91_book` | actor-def | **Rofsky's book** — body `#27`. Sprite priority `#30`. Interact: "This is the book that Rofsky wrote about the future of mankind." |

**Subtotal:** 13 pieces, 4,511 bytes

### 2.11 Euro — Flea Market (scene `flea_market`, eu97)

The Rolek-managed flea market. Clerk2 recognizes Neil and escorts
the party through. The medicines are one-time permanent stat upgrades.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07CB95` | `$07CC39` | 164 | `eu97_clerk1` | actor-def | **Exit clerk** — body `#04`. Solid. Monitors player position at `$0170,$00D0`: if player approaches exit, clerk walks over, pushes player back 1 pixel (`$0016,Y += 1`), prints "This is the exit. Please use the entrance!" Otherwise: "Going home? Thank you very much." |
| `$07CC39` | `$07CCF3` | 186 | `eu97_clerk2` | actor-def | **Entrance clerk / escort** — body `#2C`. If player not at `$0170,$00D0`, recognizes Neil: "Aren't you Neil? Rolek manages this store. Please take whatever you like." Spawns `EscortFollowPathTracker` child for escort behavior (orbit angle=4, diameter=`$2A`). If player already at position: dies (shop already entered) |
| `$07CCF3` | `$07CDDA` | 231 | `eu97_life_medicine` | actor-def | **Life Medicine** — invisible (body `#00`). Spawns visible medicine sprite child (`#26`). On interact: Yes/No prompt. If accepted: sets flag `#F0`, increments `playerMaxHp` and `playerHp` by 1, "Your power is increased!" One-time only: "One to a customer" |
| `$07CDDA` | `$07CEFA` | 288 | `eu97_dark_medicine` | actor-def | **Dark Medicine** — invisible (body `#00`). Gated on flag `#F1`. Spawns medicine sprite child. On accept: checks if Dark Friar already at max power (`$0B1C == 2`); if so, "The Dark Friar's power is strong enough!" Otherwise sets `$0B1C=1`, flag `#F1`, "Freedan's Dark Power has increased! The Dark Friar's power is increased!" |

**Subtotal:** 4 pieces, 869 bytes

### 2.12 Euro — Rolek Company Office (scene `rolek_office`, eu94)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07CEFA` | `$07D051` | 343 | `eu94_employee` | actor-def | **Rolek Company employee** — body `#15`. Solid. On interact: "What?! A child… The old guys are talking about work. Go over there!" Player proximity trigger at tiles `06,07–07,08`: overhears the employee offering to get "anything — tea, fruit, furs… and workers, too" — revealing the Rolek Company's labor trade |

**Subtotal:** 1 piece, 343 bytes

### 2.13 Euro — Dark Chapel / Slaves (scene `dark_chapel`, eu9D)

The underground chapel beneath Euro — the slave labor operation's dark secret.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07D099` | `$07D237` | 414 | `eu9D_slaves` | actor-def | **Enslaved workers (5 instances)** — body `#36`. Solid. 5-entry `SwitchCase` dispatch: dialogue about diseases turning bodies to stone, missing their language, skeleton friends killed by orders, learning the local language to be resold, speaking only a little of the language |
| `$07D237` | `$07D252` | 27 | `eu9D_bones` | actor-def | **Skeleton remains** — body `#02`. Uses `SetMetasprite(@table_0EDA00)`, sprite `#02`. Solid, purely decorative prop representing dead laborers |
| `$07E56D` | `$07E604` | 151 | `eu9D_altar` | actor-def | **Dark Chapel altar** — invisible (body `#00`). Proximity trigger at tiles `$0F,$07–$10,$09`: sets/clears flag `#00` based on player position. On interact with flag `#01` set: "The wind is blowing from behind the statue… Look? Yes/No". If "Yes": sets flag `#01`, triggers `StageBgChange(#69)` with sound (reveals passage behind the statue). Loops back to monitoring |

**Subtotal:** 3 pieces, 592 bytes

### 2.14 Euro — Geezer Central (scene `geezer_central`, eu92)

The hall where Rofsky and Erasquez — the two old scholars — argue.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07D5E7` | `$07D79E` | 439 | `eu92_rofsky` | actor-def | **Rofsky** — body `#24`. First visit (flag `#9E` not set): auto-cutscene, locks joypad, plays the two geezers arguing: "True genius is a violent thing! / You just dash off packs of lies!" Sets flag `#9E`. Post-intro: solid, interactable. If player has Teapot (item `#19`): discusses Mt. Kress temple dispute. Otherwise: general dialogue |
| `$07D79E` | `$07D985` | 487 | `eu92_erasquez` | actor-def | **Erasquez** — body `#2D`. Solid, interactable. If player has Teapot (item `#19`): pre-flag `#9F` — senses strange power, tells Will to visit Mt. Kress and marks the map, sets flag `#9F`. Post-`#9F`: "The spirits' tears reflect your true form." Without Teapot: warns about presence of evil in town, suspects demons among townspeople, suggests using Teapot on suspects |

**Subtotal:** 2 pieces, 926 bytes

### 2.15 Euro — Guest Room (scene `guest_room`, eu96)

The party's guest quarters in the Rolek mansion.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07D985` | `$07DA9D` | 280 | `eu96_kara` | actor-def | **Kara** — body `#1A`. Dies on `#AC`. Pre-`#AB`: solid, interact dialogue. Pre-`#AA`: animated walking loop with exit-gated phases. Post-`#AB`: solid, interact triggers departure to Angkor Wat — sets companion slots `$0D60`–`$0D66`, `StageWorldMapMove`, `QueueMapChange($AC)` |
| `$07DA9D` | `$07DB25` | 136 | `eu96_erik` | actor-def | **Erik** — body `#0A`. Dies on `#AC`. Pre-`#AA`: "I'm scared! What if I can't find the bathroom?" Post-`#AA`: "I just don't understand women." |
| `$07DB25` | `$07DF04` | 991 | `eu96_neil` | actor-def | **Neil** — body `#13`. Dies on `#AC`. Four-flag cascade: `#AC`→die, `#AB`→repositioned. `#AA`→morning cutscene: Neil announces he'll inherit Rolek Company to stop the labor trade. Kara: "You're going to become president? Amazing!" Then music change `#1B`, Neil tells Kara someone's asking about her. Spawns **Hamlet** (the pig, `code_07DECB`) who walks in with oink sfx. Hamlet was sent from Watermia by Lily via Rolek delivery. Sets flag `#AB`. Pre-`#A4`: first-time greeting, sets `#A4`. Post-all: "Take care, everyone." |

**Subtotal:** 3 pieces, 1,407 bytes

### 2.16 Euro — Rolek Mansion (scene `rolek_mansion`, eu95)

Neil's family home. Features the Moon Tribe reveal and the Ann apple sidequest.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07DF04` | `$07E1BA` | 694 | `eu95_ann` | actor-def | **Ann (maid)** — body `#14`. Solid. Includes `hidden_red_jewel`. First interact (pre-`#D6`): Ann tells about a cloaked man asking about Kara. Yes/No: "Should I tell Kara?" "If you must" → sets `#D6`, gives weakness hint. "No" → Ann complains about Kara acting like a princess. Post-`#D6`: **apple side-quest** — if player has apple (`#28`): "I can't eat any more." If visited twice without apple (flags `#E3`, `#E4`): removes apple, gives Red Jewel, sets `#E5` |
| `$07E1BA` | `$07E2D7` | 285 | `eu95_neils_father` | actor-def | **Neil's father** — body `#02`. Dies on flag `#A8`. On first load (pre-`#A8`): animated cutscene — walks south, pauses, **Moon Tribe reveal dialogue**: "The previous owner of this body is now a skeleton sleeping under the shrine." Then walks toward `$0268,$0060` via `MoveToward`, music changes to `#04`. Post-`#A8`: interact: "You can't go wrong by taking over the Rolek Company." |
| `$07E2D7` | `$07E37A` | 163 | `eu95_neils_mother` | actor-def | **Neil's mother** — body `#0D`. Dies on flag `#A8`. Similar movement cutscene to father (walks south then toward `$0268,$0060`). Post-`#A8`: "We've made money and wish to spend our remaining years enjoying life. Why don't you succeed us…" |
| `$07E37A` | `$07E4BC` | 322 | `eu95_neil` | actor-def | **Neil at mansion** — body `#1A`. Dies on `#AA`. Pre-`#A8`: "To live for yourself or for others, that's the question…" Post-`#A8`: extended emotional dialogue — Neil realizes how important his parents are, asks to be left alone. Sets flag `#AA`, `QueueMapChange` back to guest room (`$96`) |

**Subtotal:** 4 pieces, 1,464 bytes

### 2.17 Euro — Power House & Friezer's House (scenes `power_house` eu93, `friezers_house` eu9A)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07E50B` | `$07E56D` | 98 | `eu93_found` | actor-def | **Power house discovery** — body `#02`. Solid, interactable. Pre-`#A6`: "You found it here. I'll give you the power at once." Increments `playerStr` by 1, sets flag `#A6`. Post: "Well, go." |
| `$07E604` | `$07E696` | 146 | `eu9A_friezer` | actor-def | **Friezer** — body `#0A`. Dies on flag `#A7`. Interact: "I am the explorer, Friezer. I plan on leaving my name in history as the discoverer of the Tower of Babel." |
| `$07E696` | `$07E713` | 125 | `eu9A_max` | actor-def | **Max** — body `#05`. Dies on `#A7`. Interact: "I wonder where you're taking us exploring this time… It's up to the whims of the captain." |
| `$07E713` | `$07E75D` | 74 | `eu9A_rudy` | actor-def | **Rudy** — body `#04`. Dies on `#A7`. Interact: "The ruins are a great place. They just take my breath away." |

**Subtotal:** 4 pieces, 443 bytes

---

### 2.18 Mountain Temple / Mt. Kress (scenes `kress_entrance` mtA0, `kress_crossroads` mtA2, `kress_circuit` mtA5)

Puzzle actors for the Mountain Temple dungeon. Each crossroads/circuit actor
uses the Mushroom Drops item (`#1A`) to trigger a sequence of 6–9
`StageBgChange`/`ApplyBgChange` pairs that visually unlock barrier tiles.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$07E75D` | `$07E7F0` | 147 | `mtA0_intro` | actor-def | **Kress entrance intro** — invisible (body `#00`). One-shot on flag `#A7`. Locks joypad, prints "There's a strange place at the summit of Mt. Kress. There are mushrooms many times bigger than me, and plant stalks are scattered around." |
| `$07E7F0` | `$07E843` | 83 | `mtA2_actor_07E7F0` | actor-def | **Crossroads barrier unlock** — invisible. Gated on flag word `$0159`. Removes Mushroom Drops (`#1A`), plays 6 sequential `StageBgChange` (`#54`–`#59`) with sound `#0F` each. Sets flag word `$0159`. Unlocks the crossroads path |
| `$07E843` | `$07E896` | 83 | `mtA5_actor_07E843` | actor-def | **Circuit barrier A** — invisible. Gated on flag word `$015F`. Same pattern: removes item `#1A`, 6 `StageBgChange` (`#5A`–`#5F`). Sets `$015F` |
| `$07E896` | `$07E901` | 107 | `mtA5_actor_07E896` | actor-def | **Circuit barrier B** — invisible. Gated on flag word `$0167`. Uses flag `#02` for local gating. 9 `StageBgChange` (`#60`–`#67` plus repeated `#61`). Sets `$0167` |
| `$07E901` | `$07E927` | 38 | `gw85_actor_07E901` | actor-def | **Will-only passage block** — invisible (body `#00`). Monitors player position at `$0458,$00D0`. If the player is Will (form 0) without Psycho Dash unlocked (ability bit `$04`), teleports player X to `$03C0` — preventing passage. Freedan or Will-with-Dash can pass |

**Subtotal:** 5 pieces, 458 bytes

---

## 3. Unmapped Region

| Address | End | Size | Notes |
|---------|-----|------|-------|
| `$07E927` | `$080000` | 5,849 | **Free space** — no blocks, no named labels. Available for patches or expansion. 17.8% of the bank |

---

## 4. Group Summary by Parent

| Parent Group | Scene Count | Pieces | Bytes | % of Bank | Address Range |
|--------------|-------------|--------|-------|-----------|---------------|
| `watermia` | 6 scenes | 37 | 13,615 | 41.6% | `$078000`–`$07B52F` |
| `great_wall` | 5 scenes | 12 | 2,291 | 7.0% | `$07B52F`–`$07BE22` + tail |
| `euro` | 10 scenes | 33 | 10,661 | 32.5% | `$07BE22`–`$07E75D` + overlaps |
| `mountain_temple` | 3 scenes | 5 | 458 | 1.4% | `$07E75D`–`$07E927` |
| *(unmapped)* | — | — | 5,849 | 17.8% | `$07E927`–`$07FFFF` |

---

## 5. Scene Cross-Reference

| Scene ID | Scene Name | Actors in Bank | Primary Purpose |
|----------|------------|----------------|-----------------|
| `wa78` | `watermia` | 20 | Main town NPCs, Russian Glass, props |
| `wa79` | `lukes_house` | 5 | Party members at Luke's house |
| `wa7A` | `lances_fathers_house` | 3 | Lance's father, journal |
| `wa7B` | `gambling_house` | 2 | Russian Glass spectators |
| `wa7D` | `glass_players_house` | 1 | Glass game opponent's wife |
| `wa7F` | `lance_lily_exchange` | 3 | Lance & Lily love confession |
| `gw82` | `wall_entrance` | 1 | Trail intro |
| `gw83` | `wall_dive` | 2 | Lily companion, diving switch |
| `gw85` | `wall_rampway` | 5 | Retractable spear traps, passage block |
| `gw88` | `wall_tomb` | 1 | Enemy-clear dark space trigger |
| `gw8B` | `wall_inner` | 3 | Lance/Lily necklace reunion |
| `eu91` | `euro` | 13 | Town NPCs, shops, queue, intro |
| `eu92` | `geezer_central` | 2 | Rofsky & Erasquez (scholars) |
| `eu93` | `power_house` | 1 | STR+1 discovery |
| `eu94` | `rolek_office` | 1 | Labor trade eavesdrop |
| `eu95` | `rolek_mansion` | 4 | Ann, Moon Tribe reveal, Neil's grief |
| `eu96` | `guest_room` | 3 | Kara, Erik, Neil + Hamlet the pig |
| `eu97` | `flea_market` | 4 | Clerks, permanent stat medicines |
| `eu9A` | `friezers_house` | 3 | Friezer, Max, Rudy |
| `eu9D` | `dark_chapel` | 3 | Enslaved workers, altar passage |
| `mtA0` | `kress_entrance` | 1 | Intro dialogue |
| `mtA2` | `kress_crossroads` | 1 | Mushroom Drop barrier unlock |
| `mtA5` | `kress_circuit` | 2 | Mushroom Drop barrier unlock ×2 |

---

## 6. Notable Patterns

### Multi-Instance NPC Actors
Several actors in this bank use parameter dispatch (`$0E` register) to spawn
multiple distinct NPCs from a single actor definition:
- `wa78_men` (12 instances) / `wa78_women` (6) / `wa78_children` (5) — Watermia
- `eu91_men1` / `eu91_women1` / `eu91_men2` / `eu91_women2` — Euro town
- `eu91_merchant_counter` (8 instances) — Euro market stalls
- `eu91_merchant` (11 instances + 3 inline variant actors) — Euro merchants
- `eu9D_slaves` (5 instances) — Dark Chapel workers
- `eu91_shop_queue` (6 instances with linked-list path-following) — Euro shop

### Intro Cutscene Template
Both `wa78_intro` and `eu91_intro` follow an identical pattern:
1. Check progression flag → die if already played
2. Set bits in `$12`, mask `joypadMaskStd` with `$CFF0`
3. Spawn camera-fix helper and narration child actor
4. Stage sprite movement (walk into town), restore player position
5. Set progression flag, print welcome dialogue, `QueueMapChange` to interior

### Russian Glass — Largest Single Actor
`wa78_glass_game` at 2,828 bytes is the largest actor in this bank,
implementing the complete Russian Glass minigame: 10 spawned child actors
(5 glasses + 5 spectators), bitmask state tracking in `$0AA6`, alternating
turns between opponent and player, and a death outcome if the player drinks
the final poisoned glass.

### Key Story Flags Used in This Bank

| Flag | Meaning |
|------|---------|
| `#8D` | Watermia intro played |
| `#8F` | Fireplace journal collected |
| `#90` | Lance met his father |
| `#91` | Lance/Lily cutscene complete |
| `#92` | Kara gave Lola's Letter |
| `#94` | Party departs for Euro |
| `#95` | Glass opponent's will delivered |
| `#96` | Russian Glass game active / Lance/Lily staying behind |
| `#97` | Russian Glass opponent died |
| `#9D` | Great Wall trail intro played |
| `#9E` | Rofsky/Erasquez intro played |
| `#9F` | Erasquez marked Mt. Kress on map |
| `#A4` | Neil first-time guest room greeting |
| `#A5` | Euro intro played / Lance's father recovered |
| `#A6` | Power house STR reward collected |
| `#A7` | Kress intro played / Friezer's group exists |
| `#A8` | Moon Tribe reveal complete (parents gone) |
| `#AA` | Neil learns truth about parents |
| `#AB` | Hamlet arrives / Neil announces company succession |
| `#AC` | Party departs for Angkor Wat |
| `#C8` | Great Wall inner Lance/Lily reunion complete |
| `#D6` | Ann told about cloaked man |
| `#E2` | Lance gives Red Jewel |
| `#E3`–`#E5` | Ann apple sidequest stages |
| `#F0` | Life Medicine consumed |
| `#F1` | Dark Medicine consumed |
| `$0152` | Great Wall diving switch activated |
| `$0159` | Kress crossroads barrier unlocked |
| `$015F` | Kress circuit barrier A unlocked |
| `$0167` | Kress circuit barrier B unlocked |
| `$0174` | Great Wall tomb all-clear, Dark Space revealed |
