# Bank $04 — NPC Actors: South Cape, Edward Castle & Itory

> ROM bank $04 (`$048000–$04FFFF`, 32,768 bytes) contains **NPC actor definitions**
> for the first three overworld areas of the game: **South Cape**, **Edward Castle**,
> and **Itory Village**. These are the earliest locations the player visits in the
> story and represent the introductory chapters of Illusion of Gaia.
>
> All 88 mapped pieces are `actor-def` type (COP-script NPC actors), with two small
> `Code` helper pieces. There are no enemies, no data tables, and no engine code
> in this bank — it is purely NPC scripting.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$048000`–`$04FFFF` (294,912–327,679) |
| Total bank size | 32,768 bytes |
| Mapped | 31,551 bytes (96.3%) |
| Unmapped tail | 1,217 bytes (`$04FB3F`–`$04FFFF`) |
| Total blocks | 88 actor definitions + code pieces |
| Block types | 86 × `actor-def`, 2 × `Code` |
| Scene groups | 3 major areas, 18 distinct scenes |

---

## 2. Memory Map

### 2.1 South Cape — Town Square (scene `south_cape`, sc01)

NPCs populating the main South Cape overworld map. Includes ambient
decoration, a self-contained Red Light/Green Light minigame, position-triggered
cutscenes, and townsfolk with story-reactive dialogue.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$048000` | `$048003` | 4 | `sc01_smoke` | Chimney smoke puffs at seven map locations; bare RTL (animation from sprite set only) |
| `$048004` | `$0480A7` | 164 | `sc01_actor_048004` | Ambient seabirds (×3) — RNG-timed east/west flight paths with wing-flap animation and bird cry SFX |
| `$0480A8` | `$048133` | 140 | `sc01_girl1` | Red Light/Green Light counter — counts aloud, toggles flag `#02` (red/green), checks `#03` (catch) |
| `$048134` | `$0481A7` | 116 | `sc01_girl2` | Red Light runner — sneaks west while green, gets caught at wall, sets `#03`, returns east |
| `$0481A8` | `$0481EC` | 69 | `sc01_girl3` | Second runner — sneaks west, retreats after girl2's catch (`#03`); paired with girl1/girl2 |
| `$0481ED` | `$04836E` | 386 | `sc01_salesman` | Weapons salesman — long patrol loop around town with idle pauses; refuses to sell to children |
| `$04836F` | `$048493` | 293 | `sc01_fisherman` | RNG-placed fisherman (3 variants); variant C spawns `e_sc01_pot` teapot Red Jewel pickup (`#D7`) |
| `$048494` | `$048530` | 157 | `sc01_roof_man` | Rooftop NPC — random wander via `NpcRandomWanderAI`; scolds Will for climbing |
| `$048531` | `$048653` | 291 | `sc01_guard` | North-gate guard — blocks town exit until `#35` (castle summons); opens passage and sets `#27` |
| `$048654` | `$048761` | 270 | `sc01_worried_woman` | Timed choreography — opens door, walks out to water plants, returns; two full cycles then idles |
| `$048762` | `$04884E` | 237 | `sc01_startled_woman` | Position-triggered cutscene — confronts Will on the cliff edge, scolds him, returns inside |
| `$04884F` | `$048939` | 235 | `sc01_astronomer` | Stargazer — three-leg patrol around town gazing upward; warns of a star approaching Earth |
| `$04893A` | `$0489ED` | 180 | `sc01_sympathetic_woman` | Walks to Seth's house door, opens it, enters; feels sorry for Seth's quarreling parents |
| `$0489EE` | `$0489F1` | 4 | `sc01_actor_0489EE` | Unused 4-byte stub — immediate RTL, replaced by `sc01_jar_door`; never spawned |
| `$0489F2` | `$048A8B` | 154 | `sc01_jar_door` | Invisible trigger — plays the flying-jar cutscene at Seth's door once (`#11`); also resets neighbor doors |

**Subtotal:** 15 actors + 1 unused stub, 3,244 bytes

Later in the bank, two additional sc01 actors appear:

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04922C` | `$049278` | 77 | `sc01_sprint_man` | Static tutorial NPC — explains the double-tap sprint control |
| `$04BC65` | `$04BE37` | 467 | `sc01_house_intro` | Invisible position-trigger — house flavor text (sets `#12`–`#14`), cave-exit narration (`#16`→`#17`), Will's house auto-entry (`#21`/`#26`) |

### 2.2 South Cape — Church (scene `church`, sc08)

NPCs inside the South Cape church for the opening-day lesson sequence.
Flag `#10` is the master switch: clear = opening cutscene runs; set = lesson
complete and the friend roster changes.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$048A8C` | `$048D20` | 661 | `sc08_priest` | Teacher — runs Will's opening monologue + class dismissal cutscene (sets `#10`); post-lesson interactable with `#21`-aware dialogue |
| `$048D21` | `$048D6D` | 77 | `sc08_lance` | Lance — only appears after `#10`; tells Will to meet at the seashore cave |
| `$048D6E` | `$048D94` | 39 | `sc08_seth` | Seth — pre-lesson wanderer who paces pews; dies after `#10` set; synced via `#01` from Erik |
| `$048D95` | `$048E83` | 239 | `sc08_erik` | Erik — pre-lesson actor; plays Seth's farewell line, delivers his own exit line, sets `#01` sync flag, walks out |

**Subtotal:** 4 actors, 1,016 bytes

### 2.3 South Cape — Lance's House (scene `lances_house`, sc03)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$048E84` | `$048F79` | 246 | `sc03_lances_mother` | Lance's mother — infinite scripted patrol loop through the house; talks about Lance's father lost at Tower of Babel |

**Subtotal:** 1 actor, 246 bytes

### 2.4 South Cape — Erik's House (scene `erics_house`, sc04)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$048F7A` | `$048FDD` | 100 | `sc04_poverty` | Random-walking NPC via `NpcRandomWanderAI` — muses about wealth and gossip |
| `$048FDE` | `$049051` | 116 | `sc04_eriks_father` | Static solid NPC — brags about Erik's family being the town's original wealthy residents |
| `$049052` | `$0490FE` | 173 | `sc04_eriks_mother` | Solid NPC with spawned steam/heat-treatment VFX child actor; explains she isn't on fire |

**Subtotal:** 3 actors, 389 bytes

### 2.5 South Cape — Seth's House (scene `seths_house`, sc05)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$0490FF` | `$049181` | 131 | `sc05_seths_mother` | Static NPC — complains about Seth's father; says she'd leave if not for Seth |
| `$049182` | `$0491DB` | 90 | `sc05_seths_father` | Static NPC — defends spending money on fun; paired with `seths_mother` for domestic conflict flavor |

**Subtotal:** 2 actors, 221 bytes

### 2.6 South Cape — Chef's House (scene `chefs_house`, sc07)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$0491DC` | `$04922B` | 80 | `sc07_chef` | Static cook — comments on pot cooking since there's no stove in the house |

**Subtotal:** 1 actor, 80 bytes

### 2.7 South Cape — Will's House (scene `wills_house`, sc06)

The largest scene group in bank $04. Will's house is the game's narrative hub
for the South Cape chapter. Contains Will's grandparents (Bill and Lola), Princess
Kara's first visit with Hamlet the pig, the soldier invasion cutscene, the
snail-pie dinner dream, and the post-kidnapping Kara/Lilly departure sequence.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$049279` | `$049861` | 1,513 | `sc06_bill` | Will's grandfather — evening singing duet with Lola, scream reaction, runs downstairs during invasion; post-`#1B` gives prison/architect talk (sets `#0B`); morning crystal-ring dialogue |
| `$049862` | `$049DAB` | 1,354 | `sc06_lola` | Will's grandmother — welcome/singing scene, synchronized panic run, gives melody item `#09` + teaches Lola's Melody (sets `#35`); triggers dinner transition (`#3E`) |
| `$049DAC` | `$04A1D6` | 1,067 | `sc06_kara` | Princess Kara — enters with Hamlet, long intro conversation, inspects house; reacts to soldier invasion, reveals identity as Edward's daughter; sets `#1B` when taken away |
| `$04A1D7` | `$04A35F` | 393 | `sc06_hamlet` | Kara's pig — room-wrecking intro, nudges Will via position trigger into Kara cutscene (sets `#01`), panics during soldier invasion; says "oink oink" |
| `$04A360` | `$04A42E` | 207 | `sc06_main_soldier` | Edward Castle soldier — enters when `#04` set, walks in, demands "Princess! I've been looking for you!"; sets `#07` |
| `$04A42F` | `$04A460` | 50 | `sc06_actor_04A42F` | Secondary soldier — background patrol during invasion; no dialogue, gates on `#04`/`#08` |
| `$04A461` | `$04A5AE` | 334 | `sc06_monologue` | Invisible scene controller — triggers snail-pie dinner dream and "next morning" narration; sets `#1C`/`#1D`, fires map transitions |
| `$04A5AF` | `$04AAF8` | 1,354 | `sc06_kara_return` | Kara's return after kidnapping — Jackal-mark discovery, Lilly introduction, party assembly, yes/no departure to Itory (`#26`); spawns door blocker `e_sc06_actor_04AF48` |
| `$04AAF9` | `$04AF47` | 1,103 | `sc06_lily` | Lilly of Itory — arrives post-kidnapping, explains the hidden village, argues with Kara, "ready to go?" yes/no departure handler |
| `$04AF48` | `$04AFB1` | 106 | `e_sc06_actor_04AF48` | Door blocker code — spawned by `sc06_kara_return`; places solid tiles at exit, A-button hint until `#25` |

**Subtotal:** 10 actors (9 actor-def + 1 Code), 7,481 bytes

### 2.8 South Cape — Coastal Cave (scene `coastal_cave`, sc02)

The seaside cave where Will and his friends gather after school. Contains
Lance's four-card trick (spawns the Ace of Diamonds), Seth's pushable statue
for the psychic power demo, and Erik's dramatic entrance with the princess
news. The `sc02_entry` controller gates the cave exit during active scenes.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04AFB2` | `$04B050` | 159 | `sc02_card` | Ace of Diamonds card prop — spawned by Lance during four-card trick; proximity + A-button pickup sets `#08` |
| `$04B051` | `$04B061` | 17 | `e_sc02_actor_04B051` | Pushable statue object — spawned by Seth; used for Will's telekinesis demo during psychic-power scene |
| `$04B062` | `$04B454` | 1,011 | `sc02_lance` | Lance — hosts card game, spawns `sc02_card`, orchestrates four-card trick; reacts to psychic demo; post-story dialogue branches |
| `$04B455` | `$04B8B0` | 1,116 | `sc02_seth` | Seth — spawns pushable statue, coordinates psychic power explanation ("face statue, push L/R"), delivers sixth-sense lecture (sets `#0A`) |
| `$04B8B1` | `$04BC64` | 948 | `sc02_erik` | Erik — bursts in with "Princess ran away!" news (sets `#16`/`#04`), drives opening cave cutscene with music change; reacts to psychic demo |
| `$04BE38` | `$04BF8F` | 344 | `sc02_entry` | Invisible cave entry controller — first-visit "second home" narration (`#15`); blocks south exit with Lance's line when `#04` set |

**Subtotal:** 6 actors (4 actor-def + 1 card + 1 Code), 3,595 bytes

---

### 2.9 Edward Castle — Castle Interior (scene `edward_castle`, ec0A)

The castle proper. Contains King Edward on the throne (Crystal Ring interview),
patrolling entrance guards (one gives a Red Jewel), a shy guard / caring maid
pair, Kara's locked room with her guard, and the arrest-to-prison transition
controller in `ec0A_throne_guards`. The `ec0A_kara` actor (1,401 bytes) handles
the first meeting, rescue plea, and post-escape escort requiring the yak roast.
Flag `#21` is the post-prison master switch — guards sleep, torches despawn,
and Kara's rescue path opens.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04BF90` | `$04BFB9` | 42 | `ec0A_torch1` | Animated wall torch — RNG-phase flame loop; despawns after `#21` (post-prison state) |
| `$04BFBA` | `$04BFE3` | 42 | `ec0A_torch2` | Second wall torch — different position offset and animation phase; same `#21` despawn |
| `$04BFE4` | `$04C1B1` | 462 | `ec0A_left_guard` | Left entrance guard — patrol loop, letter scene unlocks passage (`#3F`); post-`#21` warns Will to flee |
| `$04C1B2` | `$04C2FD` | 332 | `ec0A_right_guard` | Right entrance guard — long patrol; gives one-time Red Jewel (`#D8`) for quiet conversation; sleeps after `#21` |
| `$04C2FE` | `$04C3C7` | 202 | `ec0A_stair_guard` | Stair guard — blocks upstairs with breakfast/interview lines (`#19`); dozes after `#21` |
| `$04C3C8` | `$04C569` | 418 | `ec0A_edward` | King Edward — Crystal Ring interview (Yes/No both lead to prison); sets `#0A`/`#05`; locks joypad during scene |
| `$04C56A` | `$04C56D` | 4 | `ec0A_actor_04C56A` | Empty placeholder stub — immediate RTL, sits between Edward and Edwina in throne row |
| `$04C56E` | `$04C5C7` | 90 | `ec0A_edwina` | Queen Edwina — tells Will the King sent for him; sets `#0C` to trigger throne-guard chain |
| `$04C5C8` | `$04C619` | 82 | `ec0A_door_guard` | Throne room door guard — static; tells Will it's time to see King Edward |
| `$04C61A` | `$04C7AD` | 404 | `ec0A_throne_guards` | Two actors: guard1 steps aside after `#0A`; **guard2 is the arrest controller** — triggers "Ma'am!" cutscene (sets `#0B`), spawns player-nudge thinkers, fades screen, `QueueMapChange` to prison (`#0B`), sets `#21` |
| `$04C7AE` | `$04C7FB` | 78 | `ec0A_bed_maid` | Bedroom maid — gossips about a newly hired hunter |
| `$04C7FC` | `$04C8AF` | 180 | `ec0A_stair_maid` | Stair maid — warns about Edward; after `#21` urges Will to smuggle Kara out |
| `$04C8B0` | `$04C8E5` | 54 | `ec0A_shy_guard` | Shy guard — awkwardly confesses love ("I… I love… you…"); paired with caring maid |
| `$04C8E6` | `$04C946` | 97 | `ec0A_caring_maid` | Caring maid — responds warmly to shy guard's confession; decorative character pair |
| `$04C947` | `$04CB59` | 531 | `ec0A_kara_guard` | Princess-room door guard — triple-solid blocking, Kara blackmails him ("old nickname"); escort mode (`#19`); sleeps after `#21` |
| `$04CB5A` | `$04D0D2` | 1,401 | `ec0A_kara` | **Kara** — first meeting ("Who is it?"), plea to be rescued (sets `#19`), post-escape escort via `EscortFollowPathTracker`; requires item `#0A` (roast) to leave; sets `#22`/`#0119` on castle exit |
| `$04D0D3` | `$04D19C` | 202 | `ec0A_barrel_roast` | Cellar barrel — gives yak roast item `#0A` needed for Kara's escape (sets `#46`); inventory-full fallback |
| `$04D19D` | `$04D201` | 101 | `ec0A_prison_guard` | Underground prison entrance guard — blocks "innocent" visitors; despawns after `#21` |

**Subtotal:** 18 actors, 4,722 bytes

### 2.10 Edward Castle — Prison (scene `castle_prison`, ec0B)

The castle prison where Will is locked up after the Edward interview. The
`ec0B_cell` actor is the largest single piece in the bank at 2,320 bytes —
it handles the opening monologue, timed bread drop from a guard above, the
evening flute vision (father's voice), Hamlet delivering the prison key,
and wall gem spawning. The three examination objects (door, moss, ball) each
set a flag byte and die, gating the cell actor's later phases.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04D202` | `$04DB11` | 2,320 | `ec0B_cell` | **Prison cell master controller** — opening monologue, timed bread drop from guard, evening flute vision (father's voice), Hamlet delivers prison key (item `#02`, sets `#23`), wall gem spawn; gates on `#02`/`#03`/`#04` (door/moss/ball examined). Largest actor in bank |
| `$04DB12` | `$04DB49` | 56 | `ec0B_door` | Locked cell door — one-shot "It's locked…" interaction; sets `#02` and dies |
| `$04DB4A` | `$04DBD8` | 143 | `ec0B_moss` | Wall moss — philosophical reflection on prisoners finding hope in life; sets `#03` and dies |
| `$04DBD9` | `$04DC18` | 64 | `ec0B_ball` | Chained iron ball — "Someone was chained to this ball…"; sets `#04` and dies |
| `$04DC19` | `$04DC91` | 121 | `ec0B_guard` | Fellow prisoner (not a guard) — proud, refuses help; collision opens via `#42`/`#43` flags for escape progression |

**Subtotal:** 5 actors, 2,704 bytes

### 2.11 Edward Castle — Aqueduct Entrance (scene `aqueduct_entrance`, ec0C)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04DC92` | `$04DCFC` | 107 | `ec0C_force_hint` | One-time tutorial spirit — explains Red Jewels appear after enemy clears; only runs if `$playerMaxHp == 8`, waits on `#27` |

**Subtotal:** 1 actor, 107 bytes

### 2.12 Edward Castle — Aqueduct Treasure (scene `aqueduct_treasure`, ec10)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04DCFD` | `$04DDB5` | 185 | `ec10_dp_hint_spirit` | Visible spirit NPC — explains Dark Gems (silver gems) and the 100-gem extra-life system; animated metasprite |

**Subtotal:** 1 actor, 185 bytes

---

### 2.13 Itory Village — Couple's House (scene `itory_couple_house`, it18)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04DDB6` | `$04DE20` | 107 | `it18_warning_man` | Static NPC — warns about treasure hunters vanishing in the Incan ruins |
| `$04DE70` | `$04DEB2` | 67 | `it18_warning_woman` | Static NPC — pleads for the ancient tomb to be left alone |

**Subtotal:** 2 actors, 174 bytes

### 2.14 Itory Village — Town Square (scene `itory_village`, it15)

The main Itory Village area. This is a story-dense scene — the Elder alone
occupies 1,611 bytes of COP script, making it the second-largest actor in
the bank. Many NPCs here react to story progression flags relating to
Lily, the Incan Melody quest, and the Moon Tribe.

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04DE21` | `$04DE6F` | 79 | `it15_running_man` | Static NPC — tells Will to run down the hill for a surprise (hints at the village barrier) |
| `$04DEB3` | `$04DF0B` | 89 | `it15_fable_man` | Apocalypse lore NPC — recounts legend of a messenger before the ancient world's destruction |
| `$04DF0C` | `$04DF84` | 121 | `it15_fable_woman` | Paired lore NPC — continues the apocalypse fable (disease, famine spreading worldwide) |
| `$04E022` | `$04E069` | 72 | `it15_friendly_woman` | Static NPC — asks Will to befriend Lilly because she has no peers in the village |
| `$04E06A` | `$04E1B2` | 329 | `it15_kara` | Kara — synced walk with Lilly after barrier reveal, "feet hurt" dialogue; later repositioned as sad idle NPC (`#37`) |
| `$04E2A3` | `$04E5A0` | 766 | `it15_lily` | **Lilly** — main story driver; forces Edward melody, triggers barrier reveal with palette flash + camera scroll (sets `#2B`), escorts Kara with staged movement |
| `$04E929` | `$04EF73` | 1,611 | `it15_elder` | **Flower Spirit Elder** — ambush intro in flower garden (sets `#41`); Incan Statue quest with Yes/No branches, Larai Cliff legend, Moon Tribe redirect; spawns solid helper thinker |
| `$04EF74` | `$04F0A2` | 303 | `it15_bill` | Bill — points Will to the Elder; after `#47` explains Red Jewel revival mechanic; idle looking-around animation |
| `$04F0A3` | `$04F358` | 694 | `it15_lola` | Lola — triggers the Jackal attack reunion cutscene (sets `#3B`/`#04`); after `#47` shares the Itory prophecy (child with Dark Power, comet, world-saving legend) |

**Subtotal:** 9 actors, 4,064 bytes

### 2.15 Itory Village — Legend House (scene `itory_legend_house`, it16)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04DF85` | `$04E021` | 157 | `it16_song_woman` | Static lore NPC — explains Inca history survives through song, not writing; melodies carry hidden messages |

**Subtotal:** 1 actor, 157 bytes

### 2.16 Itory Village — Lily's House (scene `lilys_house`, it17)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04E1B3` | `$04E2A2` | 240 | `it17_kara` | Kara — insists on joining Moon Tribe trip, sets `#03` sync for Lilly; walks off to talk to Lola; dies after `#37` |
| `$04E5A1` | `$04E928` | 904 | `it17_lily` | Lilly — argues with Kara, Yes/No to Moon Tribe trip; sets `#37` + world-map warp to camp (`#1A`); also handles Statue B hint and Elder redirect |

**Subtotal:** 2 actors, 1,144 bytes

### 2.17 Itory Village — Cave (scene `itory_cave`, it19)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04F359` | `$04F3CC` | 116 | `it19_inca_statue_a` | Inca Statue A collectible — `GiveItem #03` on interaction; applies BG change, sets `#2D` + word `#$011B` |
| `$04F3CD` | `$04F440` | 116 | `it19_actor_04F3CD` | Breakable cave wall (enemy-type) — must be attacked to reveal the statue chamber; spawns `SpawnDebrisBurst` on destruction, sets word `#$011A` |

**Subtotal:** 2 actors, 232 bytes

### 2.18 Itory Village — Moon Tribe Camp (scene `moon_tribe_camp`, it1A)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04F441` | `$04F894` | 1,108 | `it1A_lily` | Lilly — arrival cutscene with `EscortFollowPathTracker`, spawns west-exit blocker + south-area guide; Yes/No to Incan ruins warp (`#4A`); handles Statue B encouragement |

**Subtotal:** 1 actor, 1,108 bytes

### 2.19 Itory Village — Moon Tribe Cave (scene `moon_tribe_cave`, it1B)

| Address | End | Size | Block Name | Description |
|---------|-----|------|------------|-------------|
| `$04F895` | `$04FAC4` | 560 | `it1B_trial` | Moon Tribe combat trial — 20-second countdown via `oam_digit_compose`; destroy all enemies to earn Statue B; success: BG change + word `#$011C`; failure: must retry |
| `$04FAC5` | `$04FB3E` | 122 | `it1B_inca_statue_b` | Inca Statue B collectible — `GiveItem #04` reward for passing the trial; applies BG change, sets `#48` + word `#$011D` |

**Subtotal:** 2 actors, 682 bytes

### 2.20 Unmapped Tail

| Address | End | Size | Description |
|---------|-----|------|-------------|
| `$04FB3F` | `$04FFFF` | 1,217 | Unmapped — no blocks, names, or overrides in this region |

---

## 3. Scene Group Summary

| # | Area | Scene ID(s) | Actors | Bytes | % of Bank |
|---|------|-------------|--------|-------|-----------|
| 1 | **South Cape — Town** | sc01 | 17 | 3,711 | 11.3% |
| 2 | **South Cape — Church** | sc08 | 4 | 1,016 | 3.1% |
| 3 | **South Cape — Lance's House** | sc03 | 1 | 246 | 0.8% |
| 4 | **South Cape — Erik's House** | sc04 | 3 | 389 | 1.2% |
| 5 | **South Cape — Seth's House** | sc05 | 2 | 221 | 0.7% |
| 6 | **South Cape — Chef's House** | sc07 | 1 | 80 | 0.2% |
| 7 | **South Cape — Will's House** | sc06 | 10 | 7,481 | 22.8% |
| 8 | **South Cape — Coastal Cave** | sc02 | 6 | 3,595 | 11.0% |
| | ***South Cape total*** | | **44** | **16,739** | **51.1%** |
| 9 | **Edward Castle — Interior** | ec0A | 18 | 4,722 | 14.4% |
| 10 | **Edward Castle — Prison** | ec0B | 5 | 2,704 | 8.3% |
| 11 | **Edward Castle — Aqueduct Entrance** | ec0C | 1 | 107 | 0.3% |
| 12 | **Edward Castle — Aqueduct Treasure** | ec10 | 1 | 185 | 0.6% |
| | ***Edward Castle total*** | | **25** | **7,718** | **23.6%** |
| 13 | **Itory — Couple's House** | it18 | 2 | 174 | 0.5% |
| 14 | **Itory — Village** | it15 | 9 | 4,064 | 12.4% |
| 15 | **Itory — Legend House** | it16 | 1 | 157 | 0.5% |
| 16 | **Itory — Lily's House** | it17 | 2 | 1,144 | 3.5% |
| 17 | **Itory — Cave** | it19 | 2 | 232 | 0.7% |
| 18 | **Itory — Moon Tribe Camp** | it1A | 1 | 1,108 | 3.4% |
| 19 | **Itory — Moon Tribe Cave** | it1B | 2 | 682 | 2.1% |
| | ***Itory total*** | | **19** | **7,561** | **23.1%** |
| | **Unmapped/unused** | — | 1 | 1,221 | 3.7% |
| | **BANK TOTAL** | | **89** | **32,768** | **100%** |

---

## 4. Architectural Notes

### 4.1 Actor Script Pattern

Every actor in this bank follows the standard IOG `actor-def` pattern:

```
block_name [
  actor-def < body_id, flags, sprite_page, {
    COP [commands...]
    ...
  } >
]
```

The COP bytecode drives NPC behavior: dialogue, movement, flag checks,
spawning child actors, and cutscene choreography. Native 65C816 instructions
(`LDA`, `TSB`, `TRB`, `STA`, etc.) appear inline when actors need to
manipulate hardware registers, WRAM flags, or actor struct fields directly.

### 4.2 Story Flag Usage

Actors in this bank make heavy use of `BranchIfFlagByte` and `SetFlagByte`
COP commands to track story progression. Flag bytes are **scene-local** — the
same byte number (e.g. `#01`) has different meanings in different scenes.
Key progression flags by scene:

**South Cape Town (sc01):** `#02`/`#03` Red Light game, `#11` jar cutscene,
`#12`–`#14` house intros, `#27`/`#35` guard gate, `#D7` teapot jewel

**Church (sc08):** `#10` lesson complete (master switch for friend roster),
`#01` Erik→Seth sync, `#21` late-game priest line

**Will's House (sc06):** `#16` evening intro, `#03`–`#09` singing/invasion phases,
`#1B` soldiers done, `#1C`/`#1D` dream/morning, `#3E` dinner, `#35` melody taught,
`#21` kidnapping state, `#25`/`#26` Kara return → Itory departure

**Edward Castle (ec0A):** `#3F` letter shown, `#0A`/`#05` Edward interview,
`#0B`/`#0C` throne guard arrest, `#19`/`#1A` Kara rescue, `#21` post-prison state,
`#22` Kara left castle, `#D8` right-guard jewel, `#46` barrel roast

**Castle Prison (ec0B):** `#02`–`#04` door/moss/ball examined, `#23` key obtained,
`#24` sequence complete, `#42`/`#43` fellow prisoner collision

**Itory Village (it15):** `#40` melody played, `#2B` barrier reveal walk,
`#3B` Jackal reunion, `#41` Elder intro, `#47` quest accepted, `#44` Moon Tribe done

**Itory Cave/Moon Tribe:** Word flags `#$011A`–`#$011D` for cave wall,
statue pedestals, and trial completion; `#2D`/`#48` statue collected

### 4.3 Largest Actors

| Rank | Actor | Bytes | Scene |
|------|-------|-------|-------|
| 1 | `ec0B_cell` | 2,320 | Castle Prison — monologue, bread drop, flute vision, key from Hamlet, wall gem |
| 2 | `it15_elder` | 1,611 | Itory Village — ambush intro, Incan Statue quest, Larai Cliff legend, Moon Tribe redirect |
| 3 | `sc06_bill` | 1,513 | Will's House — singing duet, scream/invasion reaction, prison confession, crystal-ring morning |
| 4 | `ec0A_kara` | 1,401 | Edward Castle — first meeting, rescue plea, post-escape escort, barrel-gate departure |
| 5 | `sc06_lola` / `sc06_kara_return` | 1,354 | Will's House — Lola's melody + letter / Kara Jackal-mark + Itory departure |

### 4.4 Compilation Dependencies

Actors in this bank pull in shared includes from the engine:

- `EscortFollowPathTracker` — used by `ec0A_kara` and `it1A_lily` for follower escort
- `NpcRandomWanderAI` — used by `sc01_roof_man` and `sc04_poverty` for random wander
- `InitPlayerScriptVariant` — used by `it15_lily` and `it15_lola` for player-control cutscenes
- `f_inventory_full` / `interaction_handlers` — used by `ec0B_cell`, barrel roast, statue pickups
- `hidden_red_jewel` — Red Jewel fanfare used by `sc01_fisherman` and `ec0A_right_guard`
- `oneshot_palette_flash_*` — palette flash effects used by prison and barrier-reveal actors
- `oam_digit_compose` — digit display for `it1B_trial` countdown timer
- `table_0EE000` / `table_0EDA00` — metasprite tables referenced by prison and spirit actors

### 4.5 Narrative Flow

The bank's layout mirrors the game's early story progression:

```
South Cape Town (sc01)          ← ambient life, Red Light game, gate guard
  ├─ Church (sc08)              ← opening lesson, friends introduced
  ├─ Friends' Houses (sc03–05) ← family flavor NPCs
  ├─ Will's House (sc06)       ← narrative hub: singing, invasion, Kara, Lilly (22.8%)
  └─ Coastal Cave (sc02)       ← card game, psychic demo, Erik's princess news

Edward Castle (ec0A)            ← letter, King Edward interview, arrest
  ├─ Castle Prison (ec0B)      ← escape: bread, flute, Hamlet, key
  ├─ Castle post-escape (ec0A #21) ← sleeping guards, Kara rescue, barrel roast
  └─ Aqueduct hints (ec0C,ec10) ← Red Jewel + Dark Gem tutorials

Itory Village (it15–it19)       ← hidden village, Elder quest
  ├─ Lily's House (it17)       ← Moon Tribe departure
  ├─ Itory Cave (it19)         ← breakable wall → Inca Statue A
  └─ Moon Tribe (it1A–it1B)    ← camp escort, 20-second trial → Inca Statue B
```

### 4.6 Extracted File Locations

All actors are extracted into scene-organized subdirectories:

| Directory | Scenes |
|-----------|--------|
| `extracted/south_cape/south_cape/` | sc01 town actors |
| `extracted/south_cape/church/` | sc08 church actors |
| `extracted/south_cape/lances_house/` | sc03 |
| `extracted/south_cape/erics_house/` | sc04 |
| `extracted/south_cape/seths_house/` | sc05 |
| `extracted/south_cape/chefs_house/` | sc07 |
| `extracted/south_cape/wills_house/` | sc06 actors |
| `extracted/south_cape/coastal_cave/` | sc02 cave actors |
| `extracted/edward_castle/edward_castle/` | ec0A castle actors |
| `extracted/edward_castle/castle_prison/` | ec0B prison actors |
| `extracted/edward_castle/aqueduct_entrance/` | ec0C |
| `extracted/edward_castle/aqueduct_treasure/` | ec10 |
| `extracted/itory/itory_couple_house/` | it18 |
| `extracted/itory/itory_village/` | it15 village actors |
| `extracted/itory/itory_legend_house/` | it16 |
| `extracted/itory/lilys_house/` | it17 |
| `extracted/itory/itory_cave/` | it19 |
| `extracted/itory/moon_tribe_camp/` | it1A |
| `extracted/itory/moon_tribe_cave/` | it1B |
