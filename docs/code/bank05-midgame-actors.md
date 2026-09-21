# Bank $05 — Mid-Game Actors: Gold Ship, Freejia, Diamond Mine, Nazca & Sky Garden

> ROM bank $05 (`$058000`–`$05FFFF`, 32,768 bytes) contains **NPC actor definitions**
> for the mid-game story arc of Illusion of Gaia — from the Gold Ship voyage
> through Diamond Coast, Freejia, the Diamond Mine, Nazca Plains, and into
> Sky Garden. This bank spans roughly the second and third chapters of the game's
> narrative, covering Will's ocean journey, the slave-trade town, mine rescue,
> Neil's expedition, and the first Sky Garden puzzles.
>
> The bank holds ~121 mapped pieces across 7 parent groups: actors, dialog strings,
> camera keyframes, code helpers, and a large thinker-def block. It is predominantly
> NPC scripting with some puzzle/platforming handlers at the tail end.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$058000`–`$05FFFF` (360,448–393,215) |
| Total bank size | 32,768 bytes |
| Mapped | 32,467 bytes (99.1%) |
| Unmapped gap | 301 bytes (`$05FEB2`–`$05FFFF`) |
| Parent groups | 7 (gold_ship, freejia, diamond_mine, nazca, sky_garden, inca_ruins x-ref, system thinkers) |
| Total pieces | ~121 (actors, dialog strings, camera keyframes, code, thinker-defs) |
| Block types | ~100 × `actor-def`, 6 × `DialogString`, 3 × `camera-keyframe`, 5 × `Code`, ~7 × `thinker-def` |
| Scene groups | 6 major areas, ~25 distinct scenes |

---

## 2. Memory Map

### 2.1 Gold Ship — Shipwreck Deck (scene `ship_wreck`, gs2B)

The Gold Ship exterior wreck. Contains the camera/wave controller that reads
a keyframe table to produce an ocean-bobbing camera effect, a skeleton bones
prop, and references to Erik/Seth actors that live later in the bank.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$058000` | `$058026` | 39 | `dialogstring_058000` | DialogString | "An explorer who sought the Incan Gold Ship...?" — introductory shipwreck lore text |
| `$058027` | `$0580AF` | 137 | `ggs2B_wreck_wave_motion` | actor-def | **Camera wave controller** — reads `unk18_0580B0` keyframe table to apply sinusoidal camera Y-bobbing; scene-aware: subtracts `#$0020` from `cameraDeltaY` for scenes `$2D`–`$2E` (wreck interior); on scene `$2F` also writes `cameraTargetY`. Invisible, no sprite |
| `$0580B0` | `$058139` | 138 | `unk18_0580B0` | camera-keyframe | 69-entry keyframe table for ocean bobbing — alternating up/down deltas with duration counters; creates a slow swell, pause, then reverse pattern |

**Note:** `ggs2B_wreck_wave_motion` also has a helper `Code` part (`code_05F859`) at `$05F859`–`$05F8F6` (103 bytes) placed near the bank tail — identical logic but targets a different `$16` scratch register for independent camera offset.

**Subtotal:** 3 pieces, 314 bytes (+ 103 bytes code at tail)

### 2.2 Gold Ship — Ship Deck (scene `ship_gold`, gs2C)

The intact Gold Ship deck before the storm. Will is mistaken for the ancient
King by the ship's ghostly crew. The descent controller triggers the
below-deck transition, and the crow's nest crew member drives the storm
sequence with PPU register manipulation for weather effects.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05813A` | `$05816E` | 53 | `ggs2C_rain_spawner` | actor-def | **Seagull spawner** — infinite loop: waits 15 frames, spawns a child seagull actor with RNG X-position relative to player, metasprite from `table_0EE000`; priority #30; child plays frame #02 then dies |
| `$05816F` | `$058178` | 10 | `ggs2C_rain_particle` | actor-def | Barrel/rope prop — body #1E, adds position offset (-8, 0), `SetEntryHere` idle loop. Static deck decoration |
| `$058179` | `$058201` | 214 | `gs2C_descent` | actor-def | **Descent cutscene controller** — gates on `#4C`; locks joypad, sets flag word `#$0185`, configures PPU registers (`TM=#$15`, `CGADSUB=#$B1`, `COLDATA=#$FF` for color math whitewash), positions player at (D0, 20), forces player into walking code via `player_character.loc_02C63B`; waits until player reaches (D0, 240), fires palette flash `oneshot_palette_flash_1C`, sets `#4C`, prints "This is the Incan Gold Ship?!" dialogue |
| `$058202` | `$058236` | 53 | `gs2C_crew1` | actor-def | Crew member — solid, interactable; says "King! You're safe! Now we can set sail." Static |
| `$058237` | `$0582B7` | 129 | `gs2C_crew2` | actor-def | Patrolling crew — multi-leg walk loop (south, east, idle, north, west, idle); interactable: "It's a happy occasion! We have waited for you!" |
| `$0582B8` | `$058366` | 126 | `gs2C_crew3` | actor-def | Patrolling crew — similar multi-leg walk loop to crew2 but different directions; tells Will the Queen is in her stateroom |
| `$058367` | `$0583A9` | 67 | `gs2C_crew4` | actor-def | Static crew — solid, interactable; says "It's the King! You're safe!" then Will thinks "(I'm the King???)" |
| `$0583AA` | `$058426` | 94 | `gs2C_crew5` | actor-def | Crew with flag gates — after `#4E` (queen spoken to) AND `#F8` (rested), repositions +32px east; otherwise solid interactable: "Look, look! The King has returned! And he's much shorter!" Includes JMP to crew4's dialogue |
| `$058427` | `$05857A` | 372 | `gs2C_crow_crew` | actor-def | **Crow's Nest guard — storm sequence controller.** After `#4C` set, locks joypad, `StartMusic(#03)`, calls `VBlankWaitAndJoypad`, blacks backdrop colors, configures PPU (`TM=#$17`, `CGADSUB=#$A2`, `COLDATA=#$FF`), fires `oneshot_palette_flash_1C`, waits, prints guard dialogue, sets `#4F`. Spawns a helper thinker that maintains subtractive color math (`CGADSUB=#$A1`, `COLDATA=#$E0`) until `#4F` is set. Post-`#4F`: sets `musicRoomGroup=#$0002`, enters idle. Interact pre-`#4F`: "Oh short King, look there" + sets `#4F`; post-`#4F`: reflective dialogue about brightness and invaders |

**Subtotal:** 9 pieces, 1,118 bytes

### 2.3 Gold Ship — Erik Helper Code & Camera (parts of `gs2B_erik`, scene `ship_wreck`)

Helper code and camera data placed between the deck actors and interior actors.
These are parts of the `gs2B_erik` block but sit at a different ROM position
with `order` fields controlling logical placement.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05857B` | `$0585C8` | 110 | `code_058598` | Code | **Erik camera shake helper** — reads keyframe table `unk18_058606` (18-entry, larger deltas ±4/±8/±16 for violent rocking), applies to `cameraTargetY`; loops the table continuously when it reaches the end (resets index to `#$0020`). Produces the storm rocking camera effect |
| `$0585C9` | `$058605` | 38 | `unk18_058606` | camera-keyframe | 18-entry keyframe table for storm shaking — much more violent oscillation than `unk18_0580B0` (deltas of ±4, ±8, ±16 vs ±1) |

**Subtotal:** 2 pieces, 148 bytes

### 2.4 Gold Ship — Ship Interior (scene `ship_gold_interior`, gs2E)

The Gold Ship below-deck area. Contains the sleep/rest handler that triggers
the dream sequence, ambient crew NPCs with lore dialogue about the Inca
civilization, and the Queen who guards the Mystic Statue of the Wind.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$058606` | `$05879E` | 352 | `gs2E_sleep` | actor-def | **Bed/sleep handler** — solid interactable bed; sets `musicRoomGroup=#2` for interior music. After `#F8` set: monitors player position in tile area (B,4)–(C,6); when player walks in, locks joypad 30 frames, prints dream-entry monologue, forces player into idle animation, sets `#4D`, resets `musicRoomGroup`, reloads GFX cache, `QueueMapChange` to scene `#2A` (dream world) at (A0,70). Interact: pre-dream "Oh, King. Looking around the ship?"; post-dream "Please try to get some rest" |
| `$05879F` | `$058860` | 161 | `gs2E_crew0` | actor-def | Storyteller crew — offset (-8 Y), metasprite `$12` mode; interact dialogue recalls the ship emerging from the cave into light: "that light represented the freedom we had just won" |
| `$058861` | `$058977` | 184 | `gs2E_crew1` | actor-def | Lore crew — solid; tells Will about the Queen's ring: "She has thought of nothing but him" since the King and Queen were separated by invaders |
| `$058978` | `$058A01` | 229 | `gs2E_crew2` | actor-def | **Mystic Statue crew / item handler** — solid; if player has item `#38` (Mystic Statue), removes it, writes `$0AAC`/`$0B12`/`$0B08`-`$0B10` (scene config registers), `QueueMapChange` to scene `#FD`. Otherwise explains the Mystic Statue is in the jewel box and suggests visiting the crow's nest |
| `$058A02` | `$058A3F` | 53 | `gs2E_crew3` | actor-def | Melancholy crew — solid; says "Why must we flee? It is our home" |
| `$058A40` | `$058B2E` | 284 | `gs2E_queen` | actor-def | **Inca Queen** — pre-`#4F`: spawns a TM thinker that sets `TM=#$15` (enables layers, dies after `#4F`). Post-`#4F`: becomes interactable. First talk (sets `#4E`): explains she has been guarding the Mystic Statue of the Wind, says it's in the jewel box below. Subsequent talks: same message. Interact handler branches on `#4E` |

**Subtotal:** 6 pieces, 1,263 bytes

### 2.5 Gold Ship — Wreck Interior (scene `ship_wreck_interior`, gs2D) + Wreck Deck

The shipwreck interior where the party reunites after the storm. Lily's
actor is the scene controller — she manages the reunion cutscene with
camera drift effects and music changes, producing the storm-rocking
atmosphere of the wrecked ship.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$058B2F` | `$058BE6` | 152 | `gs2D_mummy` | actor-def | **Queen's mummy** — metasprite display from `table_0EE000` frame #00; first interact (sets `#01`): locks joypad; second interact (sets `#02`): "The Queen's mummy sleeps silently. There's a gold ring on her long, slender, bony finger..." |
| `$058BE7` | `$058C66` | 80 | `gs2B_bones` | actor-def | Skeleton bones (scene `ship_wreck`) — metasprite from `table_0EDA00` frame #02; solid with offset (+0,+4); interact: Will reflects "This is where the Inca were standing..." |
| `$058C67` | `$058CA4` | 159 | `gs2D_kara` | actor-def | **Kara** — solid, two interact states. Pre-`#02`: "They perished waiting for the King's return... I can't stand anything that disrupts people's peaceful lives..." Post-`#02`: "What...?" (reacts to mummy discovery) |
| `$058CA5` | `$059122` | 798 | `gs2D_lily` | actor-def | **Lily — wreck reunion master controller.** First visit sets `#50`, locks joypad, freezes player via `player_transition_handlers.PlayerFreedanRevealIdle`, prints "Will! Wake up!", restores player to `PlayerIdleEntry`. Post-`#50`: walks to position (1D,0D), reaches party, prints ring discussion dialogue (Lily/Kara argue about keeping the Queen's ring), starts music `#1B`, triggers `CameraDriftLoopShip` shaking effects (multiple spawns with #FFFF Y-delta), changes music to `#06` with APU channel #0A, sets `musicRoomGroup=#1`. Then enters idle with RNG-triggered camera drift. Interact post-setup: "Maybe it belongs to Riverson!" |
| `$059123` | `$05919B` | 473 | `gs2D_lance` | actor-def | **Lance** — solid; gates on `#01`. Pre-`#01`: walks to position (0F,0D) facing south, waits for player proximity, locks joypad, triggers camera drift, prints "That's Seth! It's coming from the deck!" (hearing Seth's cry), sets `#51`, walks east and dies. Post-`#01` interact: extended dialogue about following Will to a "strange town" (Itory); Kara/Lily interject; Lance says "Since we're friends, we have to share good times and bad" |

**Subtotal:** 5 pieces, 1,662 bytes

### 2.6 Gold Ship — Wreck Deck Continued (scenes `ship_wreck` gs2B, `dream` gs2A)

Erik and Seth actors on the shipwreck deck, plus the Shira dream sequence.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05919C` | `$059456` | 699 | `gs2B_erik` | actor-def | **Erik — storm awakening cutscene.** Pre-`#51`: solid, interact "Don't scare me!!" Post-`#51`: spawns child actor at (1D8,260), positions at tile (19,26), displays frame #0D. Waits, prints panicked dialogue about the giant fish. Sets `#02`, spawns `code_058598` (camera shaker) + helper actor that launches player with gravity physics. After `#02`: gravity-launches Erik off-screen, clears `#4D`, resets `$0AA6`, reloads GFX cache, `QueueMapChange` to scene `#2F` (adrift) at (70,B0). The spawned child actor at (1D8,260) walks east, prints Seth's scream, sets `#01`, then RNG-triggers camera drifts until `#02` is set, then gravity-jumps off-screen |
| `$059457` | `$059641` | 490 | `gs2A_shira` | actor-def | **Shira (Will's mother) — dream sequence.** Sets up PPU window masks (`W12SEL=#$33`, `WOBJSEL=#$03`) for spotlight effect, spawns joypad-lock thinker (`TSB $7000`). Interact sets `#0E`, prints motherly stargazing dialogue, presents Yes/No choice: "Unlucky star" or "Lucky star" — both lead to a farewell message ("I am always watching over you"), then `QueueMapChange` to scene `#2D` at (B0,50) (returning from dream) |
| `$059642` | `$05970D` | 188 | `gs2B_seth` | actor-def | **Seth — Red Jewel gift.** Pre-`#51`: solid interactable. Post-`#51`: dies. Interact: if `#E0` not set, gives Red Jewel item `#01` via `hidden_red_jewel.HiddenRedJewelInventoryFull`, sets `#E0`: "I found a strange jewel on board the ship. I'll give it to you." Post-`#E0`: "It's the first time I've ever given you anything. Take care of it." |

**Subtotal:** 3 pieces, 1,377 bytes

### 2.7 Diamond Coast — Adrift (scene `adrift`, dc2F)

The ocean-adrift sequence after the shipwreck — a multi-day survival story
between Will and Kara. The `dc2F_adrift` actor is the **largest single piece
in the bank** at 4,957 bytes, managing 7 phases via a `SwitchCase` dispatcher
on `$0AA6`. Each phase reloads the same scene with incremented state.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$0596FA` | `$05970E` | 21 | `dc2F_actor_0596FA` | actor-def | **Ocean sprite initializer** — loads animated ocean sprite from `misc_fx_1CD180`/`table_14C0C8`; `ResetSpriteInit` with flags `#$2010`. Ambient water effect actor |
| `$05970F` | `$05AA9F` | 4,957 | `dc2F_adrift` | actor-def | **Adrift master controller — 7-phase `SwitchCase` on `$0AA6`:** |

**Phase 0 (Day 1, `$059726`):** Solid interactable. Gates on `#03`. Waits, increments `$0AA6`, reloads scene. Interact: Kara asks "You've just come to???" with Yes/No choice ("Yes, I'm OK" / "I'm still unsteady"), sets `#01`. Second talk: Kara says "Don't be upset. Let's just enjoy drifting." Sets `#02`.

**Phase 1 (Day 2, `$059775`):** Sets `playerHp=8`. Spawns RNG fish enemies (body #42–#44 from `enemy_stats_table+4`, HP=255) that approach in wave patterns and can damage Will; hit callback plays damage SFX and triggers flash. Will starts fishing with frame #13/#14 loop. Each Kara interaction: "What are you doing!! The poor fish!!!" (she opposes fishing). After ~1800 frames of interaction, prints monologue about time passing slowly, sets `#4D`, advances phase.

**Phase 2 (Day 4, `$059941`):** Sets `playerHp=4`. Prints "Drifting, Day 4". Will walks on raft, spawns a jar at (FFF8,B0) that drifts in from the right — contains Sam's letter about being sold as forced labor. Interact progressions: Kara's premonition → jar found → extended argument about eating raw fish ("Fish feel pain!") → Kara goes silent. Sets `#4D`, advances.

**Phase 3 (Day 7, `$059ABA`):** Sets `playerHp=1`. Respawns fish enemies. Prints week-one starvation monologue. Kara starts speaking again — prints extended reconciliation dialogue about trying to eat fish. Sets flag word `#$0120`, `#52`. Advances.

**Phase 4 (Day 12, `$059B3B`):** Enables display mode flag `$4001`, spawns palette thinker (ID #73). Stargazing scene — Kara talks about stars and the extra red star near Cygnus, asks Will to make a wish. Will wishes for everyone's safety and his father. Locks player sprite, `StageForceMoveX(#13)`, clears `#$0120`, `#52`. Advances to phase 5 with new GFX cache.

**Phase 5 (Day 18, `$059BB7`):** Day 18 banner. Will sits idle, Kara interactable. Spawns two shark actors (frames #45/#C5, alternating directions) that circle but don't attack. After two shark passes: Kara's music starts (#06), extended dialogue about sharks not being hungry, Kara's revelation about humans. Timer-based: after ~1200 frames auto-advances with `FadeThenStartMusic(#15)`, Kara's insight, sets `#03`/`#4D`. Advances.

**Phase 6 (Day 21, `$059C7A`):** Sets player flags `$0008`. Prints "Day 21". Extended sunset dialogue — Kara's most emotional speech about watching sunrises together. Will collapses unconscious. Kara screams "Wake up!! Don't leave me here alone!" Music starts (#06). `QueueMapChange` to scene `#31` (Oakton) at (A0,60).

**Subtotal:** 2 pieces, 4,978 bytes

---

### 2.8 Oakton — Town (scene `oakton`, dc30)

The small coastal town where Will washes ashore after the adrift sequence.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05AAA0` | `$05AAD1` | 50 | `dc30_dog` | actor-def | **Turbo the dog** — metasprite mode (`$12` bit), solid; idle animation loop (frame #48, 16 ticks); interact barks "Woof woof!!" and sets `#01` to advance idle cycle. The dog who found Will's raft |
| `$05AAD2` | `$05AB8F` | 190 | `dc30_kara` | actor-def | **Kara — Freejia departure.** Gates on `#56` (only visible when set). Interact: "This dog's name is Turbo. Isn't he cute?" then triggers world map travel to (254,354) and `QueueMapChange` to scene `#32` (Freejia) at (130,350). Sets party roster entries `$0D60`–`$0D62` |

**Subtotal:** 2 pieces, 240 bytes

### 2.9 Oakton — Interior (scene `oakton_interior`, dc31)

The rescuer's house where Will recovers from scurvy.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05AB90` | `$05ADA9` | 594 | `dc31_rescuer` | actor-def | **Rescuer (doctor)** — solid. First visit (pre-`#56` and `#76`): locks joypad, freezes player, starts music `#1B`, waits, then extended medical scene: diagnoses scurvy ("a disease caused by a long-term lack of vitamin C"), Kara reacts, tells them to thank the dog, gives directions to Freejia. Sets `#01`, waits for `#02`, sets `#76`. Post-visit interact: same directions |
| `$05ADAA` | `$05AE9F` | 245 | `dialogstring_05ADAE` | DialogString | Kara's awakening dialogue — "Will! Will!! Wake up!!! We've reached land!! We're saved!!!" and Will's groggy response |
| `$05AEA0` | `$05AF2A` | 140 | `dialogstring_05AEA3` | DialogString | Rescuer's extended directions — explains location south of Oakton, half a day north to Freejia, suggests looking in a big town for friends |
| `$05AF2B` | `$05AF81` | 86 | `dialogstring_05AF2F` | DialogString | Kara's departure dialogue — "At any rate, let's go to Freejia. I'm going to thank the dog. Come back when you're ready." Sets `#56` |
| `$05AF82` | `$05B01D` | 153 | `dc31_kara` | actor-def | **Kara — interior reunion.** Pre-`#56`: interact sets `#56` (Freejia departure ready). Pre-`#76`: walks in from offscreen, prints awakening dialogue, freezes player via `PlayerIdleEntry`, explains they're at the rescuer's house ("You've been tossing in your sleep"), sets `#02`. Then choreographed walk-away loop that repeats until `#56`. Post-`#56`: dies. Includes `InitPlayerScriptVariant` for player script control |

**Subtotal:** 5 pieces, 1,218 bytes

---

### 2.10 Freejia — Town Square (scene `freejia`, fr32)

The main Freejia town area — a slave-trade hub. This is the densest scene
group in the bank by actor count. Kara arrives excited about the city's
beauty, unaware of its dark underbelly.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05B01E` | `$05B063` | 50 | `fr32_actor_05B01E` | actor-def | **Waterfall/fountain props** — sets camera Y bounds to `#$0420`; spawns two children loading animated water sprites from `misc_fx_1CD080`/`table_14C000` at different sprite init slots. Ambient town decoration |
| `$05B064` | `$05B198` | 325 | `fr32_kara` | actor-def | **Kara — town arrival/hotel escort.** Arrival cutscene (pre-`#64`): locks joypad, walks south, idles, prints excited dialogue ("Oh, it's nice!! What a great city!!!"), sets `#02`. Walks to face south-east, prints "Let's go!", sets `#64`/`#03`, choreographed walk to hotel. Post-`#64`: repositions at tile (27,25), solid, interact: "This is the hotel! Let's go in!", sets `#04`. Gates: dies after `#57` or `#65` |
| `$05B199` | `$05B32B` | 407 | `fr32_guide` | actor-def | **Hotel guide NPC** — escort path: walks east, south, east, south through town pointing out sights. Pre-`#57`: "What a cute couple. Have you decided where you're staying tonight?" Kara responds "Not yet," guide says "Why not base your search here?" Pre-`#64`: walking patrol; post-`#64`: static at tile (28,25), interact "Well, come in." Post-`#57`: spawns hotel door solid (via `town_door`), relocates to (29,24), interact "Recently tourists have avoided this town... Business is terrible." Also spawns a door metasprite from `table_0EDA00` that opens with SFX `#0E` when `#05` is set |
| `$05B32C` | `$05B33C` | 17 | `fr32_actor_05B32C` | actor-def | **Awning prop** — body #08, priority #10, position offset (-2,+5); static one-frame idle. Town decoration |
| `$05B33D` | `$05B35C` | 32 | `fr32_actor_05B33D` | actor-def | **Walking townsperson** — body #0A, priority #10; infinite east-west patrol loop with idle pauses |
| `$05B35D` | `$05B370` | 17 | `fr32_actor_05B35D` | actor-def | **Awning prop 2** — body #11, priority #10, position offset (+2,+5); static one-frame idle. Town decoration |
| `$05B371` | `$05B5AF` | 526 | `fr32_kidnapper` | actor-def | **Kidnapper — position-triggered ambush.** Guards Erik's prison. Gates on `#67`. Solid at tile (04,0D), priority #10. Waits offscreen, monitors player tile area (05,0E)–(0B,12). When triggered: walks east, spawns child actor at (48,E0) — child loads a door metasprite from `table_0EDA00`, copies South Cape sprite palette to `$7F0BE0`, enables attack mode via `EnemyInitBasic`, sets HP=5, enables collision. Child monitors player area (07,0E)–(08,12). Pre-`#66`: "If you don't want to lose your lives, go home!!" Post-`#66` (Sam has been talked to): extended scene with Erik's muffled voice heard, man threatens, Will resolves to break down the door. Sets `#67`, opens solid tiles |
| `$05B5B0` | `$05B6B6` | 231 | `fr32_slap` | actor-def | **Slap NPC** — body #02, priority #10. Waits offscreen, then interact: startled dialogue about someone dropping from the ceiling, gives a "gift" (sound effect #05), then slaps Will — "Kids! If you do something this dangerous again, you'll be in big trouble!!!" |
| `$05B6B7` | `$05B713` | 93 | `fr32_hotel_hint` | actor-def | **Hotel gossip woman** — body #12, priority #10; spawns a child hitbox 24px below. Child's interact: "A man working at the hotel was caught by a labor trader." Parent is invisible with passthrough |
| `$05B714` | `$05B7CC` | 217 | `fr32_creep` | actor-def | **Back-alley man — Red Jewel gift.** Solid. Pre-`#E1`: extended dialogue about understanding the town's underside ("Sometimes what you think is unimportant is the most important thing"), secretly gives Red Jewel item `#01` via `hidden_red_jewel.HiddenRedJewelInventoryFull`, sets `#E1`. Post-`#E1`: "Ha ha ha." |
| `$05B7CD` | `$05B859` | 125 | `fr32_alley_guard` | actor-def | **Alley guard — movement blocker.** Solid; on interact, checks player X vs actor X: if player is to the left (approaching), "Children don't come here. Go home." If passed: "This kid! Where did you come from?! Go home!" + sets `#01` which triggers collision clear and forces player west (`playerSpeedEw = -5`). Loop rearms after clear |
| `$05B85A` | `$05B895` | 60 | `fr32_slaver1` | actor-def | **Slaver 1** — body #1D; gates on `#5A`. Idle animation loop frame #21; when `#5A` set (slaver2 event complete): clears collision, walks east off-screen. Pre-`#5A` interact: "Where'd he go..." (searching for the escaped laborer) |
| `$05B896` | `$05BAF7` | 442 | `fr32_slaver2` | actor-def | **Slaver 2 — escaped laborer quest.** Solid, interact presents dialogue "A laborer escaped. Have you seen him?" with Yes/No. "Yes" → "Tell me if you see him." "No" → second choice "Tell location" / "Laugh and lie." If `#59` (sympathetic woman told Will) + "Tell location": gives Red Jewel item `#01`, sets `#5A`, locks joypad. If no `#59`: "But Will doesn't know where the laborer is." Post-`#5A`: dies. Unlocks `joypadMaskStd` after walk-off |
| `$05BAF8` | `$05BB44` | 69 | `fr32_fragrance` | actor-def | Static NPC — body #13, solid; "The Freejia is the city flower. Smells good, doesn't it?" |
| `$05BC11` | `$05BC7A` | 71 | `fr32_honest_life` | actor-def | Gravestone NPC — body #35, metasprite mode, solid; "A life lived honestly. A life of fun and laughter." |
| `$05BC7B` | `$05BCF9` | 145 | `fr32_doomsday` | actor-def | Gravestone NPC — body #35, metasprite mode, solid; prophecy dialogue: "Soon a great power will come from above... Then mankind will die out" — calls it a lie, says "I do this to forget" |
| `$05BCFA` | `$05BD4A` | 147 | `fr32_showman` | actor-def | **Street performer** — body #02; not movable. Solid, interact: "No one can put on a show like I can. Have a look!" sets `#0F`. Pre-`#0F`: idle loop, then spawns marked child actor that plays firework animation (frames #32→#33→#34, SFX #21), positions child on parent. After show: walks south-east off-screen, dies |
| `$05CEF8` | `$05CF03` | 12 | `fr32_actor_05CEF8` | actor-def | **Pigeon 1** — body #22, flag #02; waits offscreen 8 frames, plays frame #22, returns. Ambient bird |
| `$05CF04` | `$05CF0F` | 12 | `fr32_actor_05CF04` | actor-def | **Pigeon 2** — body #22, flag #02; waits offscreen 6 frames, plays frame #22. Ambient bird |
| `$05CF10` | `$05CF23` | 16 | `fr32_actor_05CF10` | actor-def | **Pigeon 3** — body #24, flag #02; position offset (+8,0), waits offscreen 7 frames, plays frame #24. Ambient bird |
| `$05CF24` | `$05CF88` | 101 | `fr32_herb` | actor-def | **Herb pickup** — body #26, metasprite mode, solid; interact: if `#53` not set, `GiveItem(#06)` (Herbs), sets `#53`, prints "You found the herbs!" Inventory-full fallback message included |
| `$05CF89` | `$05CFBF` | 55 | `fr32_hp_jewel` | actor-def | **HP Jewel pickup** — body #25, metasprite mode, solid; interact: if `#54` not set, sets `#54`, prints "You found the HP jewel!", increments `playerMaxHp` |
| `$05CFC0` | `$05D023` | 100 | `fr32_locked_door` | actor-def | **Locked door** — body #01, metasprite from `table_0EDA00`, priority #20. On player proximity: plays door-rattle animation (frame #00) with SFX `#0E`. Otherwise shows closed (frame #01), solid. Interact: "It's locked from the inside..." (Erik's prison door) |

**Subtotal:** 23 pieces, 3,269 bytes

### 2.11 Freejia — Adequacy Manor (scene `adequacy_manor`, fr38)

A Freejia house with three NPCs — a humorous domestic scene.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BB45` | `$05BB80` | 60 | `fr38_ashamed` | actor-def | Downstairs resident — body #02, solid; "The upstairs is a mess... I'm ashamed..." |
| `$05BB81` | `$05BBDA` | 90 | `fr38_girlfriend` | actor-def | Girlfriend — body #0D; walks in from offscreen, waits, does animated choreography (sprite/hitbox change, forced move), settles facing right; interact: "He had something in his eye... Ha ha ha." |
| `$05BBDB` | `$05BC10` | 96 | `fr38_boyfriend` | actor-def | Boyfriend — body #04; similar choreography offset (-4,0); interact: "She, uh, was just helping me... Ha ha ha." Paired with girlfriend |

**Subtotal:** 3 pieces, 246 bytes

### 2.12 Freejia — Mother's House (scene `mothers_house`, fr36)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BB4A` | `$05BCB2` | 168 | `fr36_mother` | actor-def | **Mother** — body #0C; infinite east-west patrol with idle pauses; interact: worried motherly dialogue about kidnapping fears — "Mothers are always worrying about things. My mother suffered like that." |

**Subtotal:** 1 piece, 168 bytes

### 2.13 Freejia — Messy House (scene `messy_house`, fr3B)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BCB3` | `$05BD19` | 103 | `fr3B_tornado` | actor-def | Messy resident — body #02, solid; "It's not like a tornado came through here. Maybe you'd be more comfortable in a place not quite so neat?" |

**Subtotal:** 1 piece, 103 bytes

### 2.14 Freejia — Harborer's House (scene `harborer_house`, fr3A)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BD1A` | `$05BDC2` | 169 | `fr3A_harborer` | actor-def | **Harborer** — body #02, solid; gates on `#5A` (dies after slaver2 quest). Extended dialogue about sheltering the escaped laborer: "There was nothing he could do about being found. I was prepared for the worst when I did it." |
| `$05C471` | `$05C4D8` | 103 | `fr3A_sympathetic` | actor-def | **Sympathetic woman (escaped laborer)** — body #27, metasprite mode, solid; gates on `#5A` (dies after). Interact: "Please! Don't tell! I don't care about myself, I just don't want to get him in trouble..." Sets `#59` — this flag gates whether slaver2 will accept Will's information |

**Subtotal:** 2 pieces, 272 bytes

### 2.15 Freejia — Thorn Tower (scene `thorn_tower`, fr37)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BDC3` | `$05BE5E` | 124 | `fr37_caution` | actor-def | Warning NPC — body #0A, solid; "Listen to me carefully. You'd better not go on the back streets. Just as a rose has thorns, a pretty town has another side." |

**Subtotal:** 1 piece, 124 bytes

### 2.16 Freejia — Slave Market (scene `slave_market`, fr3C)

The underground slave market. Contains the three named slaves (Imas, Remus,
Sam) who will later appear in the Diamond Mine, their overseer, and two
morally reflective bystanders.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05BE5F` | `$05BF0D` | 196 | `fr3C_imas` | actor-def | **Imas** — body #28, metasprite mode, solid; gates on `#6A` (dies after rescue). "I am Imas. I was brought here by boat from far-off Asia. We are a hunting tribe. All of the animals here have fallen victim to an unknown disease..." |
| `$05BF0E` | `$05BFC6` | 201 | `fr3C_remus` | actor-def | **Remus** — body #28, metasprite mode, solid; gates on `#6A`. Pre-rescue: "I am Remus. Our game disappeared and we had nothing to eat. We had no choice but to become laborers." Post-`#6A`: switches to frame #27, different dialogue "How can things like this happen?" |
| `$05BFC7` | `$05C0B7` | 225 | `fr3C_sam` | actor-def | **Sam** — body #28, metasprite mode, solid; gates on `#6A`. "I am Sam. We were rescued last night by a man named Erik who was working at the hotel. But we were caught... He's being held in a house on the corner of a back street. Please save him." Interact sets `#66` — critical flag that enables the kidnapper's Erik rescue dialogue |
| `$05C0B8` | `$05C1B9` | 218 | `fr3C_slaver` | actor-def | **Slave market overseer** — body #1A, solid; walks east, idles; interact: "Hey, boy! Kids can't come here! Go home!" with Yes/No "Did you come to get a laborer?" "Yes" → "I like your courage!" + sets `#01` (access granted). "No" → "Go home!" |
| `$05C1BA` | `$05C238` | 127 | `fr3C_man1` | actor-def | Bystander 1 — body #03, solid; empathetic dialogue: "When I think of myself in your position, I shudder... it's hard enough just taking care of myself." |
| `$05C239` | `$05C291` | 97 | `fr3C_man2` | actor-def | Bystander 2 — body #04, solid; "These laborers are the same age as you. Remember. There are people everywhere who live this way." |

**Subtotal:** 6 pieces, 1,064 bytes

### 2.17 Freejia — Labor Camp (menu `freejia_labor_camp`, fr35)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05C4D9` | `$05C508` | 48 | `fr35_slave1` | actor-def | Slave 1 — body #27, metasprite mode, solid; "Soon we will be sent away..." |
| `$05C509` | `$05C55B` | 83 | `fr35_slave2` | actor-def | Slave 2 — body #27, metasprite mode, solid; "I've tried not to think. The more I think, the more empty I become..." |
| `$05C55C` | `$05C5B9` | 94 | `fr35_slave3` | actor-def | Slave 3 — body #27, metasprite mode, solid; "I don't believe in the spirits. If there were spirits, things like status wouldn't matter..." |

**Subtotal:** 3 pieces, 225 bytes

### 2.18 Freejia — Hotel (scene `freejia_hotel`, fr39)

The party's hotel room. Kara and Lily reunite, Lance has amnesia from the
shipwreck, and his cure drives the extended Memory Melody scene.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05C5BA` | `$05C708` | 349 | `fr39_kara` | actor-def | **Kara — hotel reunion.** Pre-`#58`: positions player 8px up, walks south then idles, sets `#58`, prints Lily reunion scene ("Lilly? Is it Lilly?!"), walks to bed area. Post-`#58`: repositions at tile (14,1A). Interact: pre-`#68` "I am glad everyone is safe, but..." post-`#68` "What's wrong? You're crying." Gates: dies after `#65` or `#58` pre-set |
| `$05C709` | `$05C8B1` | 459 | `fr39_lily` | actor-def | **Lily — hotel arrival/amnesia exposition.** Pre-`#58`: locks joypad, choreographed walk (south, east, south), prints "Come in... Will and Kara...?!", sets `#01`. Walks to room, prints Lance amnesia exposition: "Lance hit his head escaping from the Incan ship... The doctor said that he has temporary amnesia." Also reports Erik missing. Post-`#65`: repositions at (16,1C). Multiple interact states based on `#68`/`#65` |
| `$05C8B2` | `$05CB53` | 946 | `fr39_lance` | actor-def | **Lance — amnesia cure / Memory Melody scene.** Pre-`#0F`: locks joypad, waits, spawns `code_05CD16` (random falling star particles from `table_0EE000`), prints Memory Melody scene — all four party members share emotional monologues in a mystical space. After melody plays: resets palette, `FadeThenStartMusic(#02)`, waits on word flag `#$012B`, Lance does confused idle animation, prints recovery dialogue ("What? What have I been doing?"), sets `#68`. Post-`#68` interact: "I guess everyone was worried." |
| `$05CB54` | `$05CD15` | 486 | `fr39_erik` | actor-def | **Erik — Nazca departure trigger.** Only appears after `#65` set. Interact pre-`#68`: "It is good to be among friends again. If only I wasn't so sad." Post-`#68`: extended departure dialogue about an eccentric inventor named Neil in the woods, Will recognizes the name ("Did you say Neil!!!"), sets party roster `$0D60`–`$0D68` (6 members), triggers world map move to (254,2D4) and `QueueMapChange` to scene `#49` (Neil's cottage) |

**Subtotal:** 4 pieces (+ 1 code), 2,240 bytes (+ 94 bytes code)

### 2.19 Freejia — Erik's Captivity (scene `eriks_captivity`, fr33)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05CD16` | `$05CD73` | 94 | `code_05CD16` | Code | **Falling star particle spawner** — spawns child actors at RNG X-positions from `table_0EE000` at Y=512, falling at various speeds (RNG 4 variants). Loops until `#0F` set (Lance's memory restored). Used by `fr39_lance` for the Memory Melody visual effect |
| `$05CD74` | `$05CEAB` | 388 | `fr33_erik` | actor-def | **Erik — prison rescue.** Solid. Pre-`#65`: choreographed walk (east, north) into the room. Interact: Erik's rescue dialogue — "Impossible! You've come to rescue me!!" Explains he tried to sneak into the slave camp to rescue three laborer brothers but was caught. Teaches Will the mine's location. Sets `#57`, `#58`, `#64`, `#65`, and `$0AA6=#7`. Post-`#65`: dies |

**Subtotal:** 2 pieces, 482 bytes

---

### 2.20 Diamond Mine — Main (scene `mine_main`, dm3F)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D024` | `$05D065` | 70 | `dm3F_switch` | actor-def | **Hittable orb switch** — body #0F, enemy-type (`$12=#$0030`), metasprite from `table_0EE000`; HP=255 (invincible), solid. Hit callback: cycles to frame #11 (pressed state), increments `$0A01` counter. Resets HP after each hit. Used with `dm3F_actor_05D066` to detect 4 hits |
| `$05D066` | `$05D091` | 40 | `dm3F_actor_05D066` | actor-def | **4-hit switch monitor** — invisible; gates on word flag `#$0121`. Monitors `$0A01` counter each frame; when it reaches 4: sets `#$0121`, applies BG change #21, plays SFX `#0E0E` (opens path). Not movable |
| `$05D555` | `$05D5CB` | 102 | `dm3F_elevator_door` | actor-def | **Elevator door** — body #35, metasprite mode, offset (+8,-2). If player has item `#0F` (Elevator Key) equipped: sets `#69`, removes key, prints "You used the elevator key!" Otherwise: "There's one keyhole in this door." Gates on `#69` → applies BG change #7B, sets `#$017B`, dies |
| `$05D5CC` | `$05D616` | 75 | `dm3F_elevator_sign` | actor-def | Elevator sign — body #36, metasprite mode, solid; "(Elevator Entrance) Use that door to get to the elevator." |
| `$05D617` | `$05D62D` | 23 | `dm41_actor_05D6F3` | actor-def | **Tile placement actor** (scene `mine_main`) — invisible; draws solid metatiles at (26,01) and (22,01) with tile #05, then dies. Creates blocked pathways |

**Subtotal:** 5 pieces, 310 bytes

### 2.21 Diamond Mine — Inner (scene `mine_inner`, dm47)

The rescue scene for Imas, Remus, and Sam. Each slave has a chain
metasprite spawned by `dm_actor_05D49E` and two interact states —
pre-rescue (chained) and post-rescue (freed).

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D092` | `$05D1DD` | 204 | `dm47_imas` | actor-def | **Imas — chained slave.** Body #28, metasprite mode, solid. Spawns chain prop (`dm_actor_05D49E`). Gates on `#5E`. Monitors parent actor flags bit #40 (attack hit). Pre-rescue: "Cut the chain!" Post-hit: "Thank you. All living things in our home country have grown strange. People have turned to stone..." |
| `$05D1DE` | `$05D226` | 201 | `dm47_remus` | actor-def | **Remus — chained slave.** Same structure as Imas. Pre-rescue: "Cut the chain!" Post-hit: "Thank you. Our home village is far across the ocean. If you could go there, help the villagers to regain their strength." Shared `dm47_remus_destroy` (2-byte `COP Die`) |
| `$05D227` | `$05D49D` | 635 | `dm47_sam` | actor-def | **Sam — chained slave + Memory Melody teacher.** Same chain structure but extended post-rescue. After cutting chain: starts music `#1E`, waits for SPC handshake via `APUIO1` ($2141) = #$FF. If player has item `#08` (Melody of Wind): removes both prison key and melody, teaches Memory Melody. Otherwise just removes prison key. "Legend says that there is a song that brings back the past. Please let him hear it." Gives item `#0D`. Sets `#5E` |
| `$05D49E` | `$05D4B2` | 17 | `dm_actor_05D49E` | Code | **Chain sprite helper** — sets `$12` bits `#$0030` (hittable+solid), enables actor flag `#$0080`, displays frame #29 (chain metasprite), idles. Shared by all three mine slaves |

**Subtotal:** 4 pieces (+ 2 code aliases), 1,057 bytes

### 2.22 Diamond Mine — Morgue (scene `mine_morgue`, dm45)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D4B3` | `$05D52B` | 121 | `dm45_key` | actor-def | **Mine Key pickup** — body #02, enemy-type, metasprite from `table_0EE000`; animates frame #02 in a loop. Interact: `GiveItem(#0B)` (Mine Key), sets `#5D`, enables `displayModeFlags` bit `#$0080`, plays `MusicAndText(#17)` with fanfare. Post-pickup: dies. Inventory-full fallback included |

**Subtotal:** 1 piece, 121 bytes

### 2.23 Diamond Mine — Foyer (scene `mine_foyer`, dm44)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D52C` | `$05D551` | 246 | `dm44_cell_door` | actor-def | **Double-locked cell door** — body #35, metasprite mode, offset (+8,0). Has two keyholes. Checks for items `#0B` (Mine Key) and `#0C` (second key). If both keys present: Yes/No to insert them; "Yes" removes both keys, sets `#5B`/`#5C` → applies BG change #7A, sets `#$017A`, dies. If one key: "Without both keys, the door won't open..." If no keys: "There are two keyholes" |

**Subtotal:** 1 piece, 246 bytes

### 2.24 Diamond Mine — Collapsed Tunnel (scene `mine_collapsed_tunnel`, dm40)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D552` | `$05D555` | 36 | `dm40_hidden_dark_space` | actor-def | **Hidden Dark Space** — body #24; gates on word flag `#$0132`. Waits until `#$0132` is set, then spawns `dark_space.DarkSpacePortalInit` (Dark Space portal) at the actor's position with Y-offset +1 and flags `#$2000`, then dies. Not movable |
| `$05D62E` | `$05D8A5` | 356 | `dm40_trapped_slave` | actor-def | **Trapped slave — enemy-type breakable.** Body #00, enemy-type (`$12=#$0031`), metasprite from `table_0EE000` frame #00, HP=255 from `enemy_stats_table+118`. Monitors player area (08,14)–(0A,17), sets/clears `#00`. When attacked (`playerFlags` bit #02): spawns `SpawnDebrisBurst` debris. On destruction (sets `#D9`): redraws 6 metatiles to open a passage, places collision tiles. Spawns child actor (frame #0C) that adds 3 Red Jewels to `jewelsCollected` (BCD addition), locks joypad, prints "Thank you. I was buried in the cave-in... We want to give you a present. I'm sending 3 Red Jewels to the Jeweler." Child walks north and dies |

**Subtotal:** 2 pieces, 392 bytes

### 2.25 Diamond Mine — Zigzag (scene `mine_zigzag`, dm41)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D62E` | `$05D6F2` | 44 | `dm41_actor_05D70A` | actor-def | **Dripping poison/lava hazard** — body #30; infinite loop: waits offscreen, plays 3-frame drip animation (#2F→#30→#31), spawns `dm_dm_follower_behavior` child at relative offset (0, CE), waits. Ceiling hazard that spawns falling projectiles |

**Subtotal:** 1 piece, 44 bytes

---

### 2.26 Nazca — Neil's Cottage (scene `neils_cottage`, na49)

Neil's inventor cottage where the party regroups. The introduction scene
features physical comedy (Neil's smelly socks) and the party examining
Neil's four inventions. Each invention sets a bit in `$0AA6`; when all
four bits (`#0F`) are set, Neil's main dialogue changes to advance the plot.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05D8AD` | `$05DC9F` | 1,186 | `na49_neil` | actor-def | **Neil — invention workshop master controller.** Spawns exit-blocker thinker (monitors player Y at $D0 + south button press). Arrival: locks joypad, positions player at (98,100), plays 2× door-knock SFX, prints "It's open, come in." Neil recognizes Will, forces player into south-walking animation via direct code pointer injection, sets `#01`. Three sequential dialogue phases: sets `#02` (friends greeted), `#03` (socks discussed), `#05` (make yourselves at home). Interact: if `$0AA6 != #$0F` (not all inventions checked): "I've invented lots of things... The four inventions in this room are my best work. Have a look." When `$0AA6 == #$0F`: extended Cygnus constellation / ruins connection monologue, sets `#06` |
| `$05DCA0` | `$05DF1B` | 732 | `na49_lily` | actor-def | **Lily — comic arrival + Cygnus exposition.** Choreographed walk south then east. Pre-`#01`: waits. Pre-`#02`: reacts to Kara insulting Neil's smell, defends him ("There's a wonderful smell in this room, isn't there?"). Pre-`#05`: walks east behind counter. Pre-`#07`: waits. Pre-`#08`: Yes/No dialogue about going to Nazca — Lily presents the red star in Cygnus, Neil gets excited. "No" loops back. "Yes" sets `#08`. Post-setup interact: commentary about the inventor |
| `$05DF1C` | `$05E025` | 298 | `na49_kara` | actor-def | **Kara — comic arrival + Cygnus reaction.** Walk south, idle. Pre-`#04`: "I can't believe it! I don't want to breathe the same air as him!" Pre-`#05`: walks east. Pre-`#06`: locks joypad, walks west toward Neil; prints "Cygnus?!" — Neil explains Babel is in the middle of the Cygnus ground painting. Sets `#07`. Post-setup interact: same complaint |
| `$05E026` | `$05E178` | 339 | `na49_lance` | actor-def | **Lance — departure trigger.** Walk south. Pre-`#03`: idle animation loop then jokes about socks ("I've only had mine on for three weeks. I guess I lose!"), sets `#04`. Pre-`#05`: walks to south-east corner. Pre-`#08`: waits. Post-`#08`: "We're going, too!" sets `#6D`, configures party roster (6 members), triggers world map move to (274,264) and `QueueMapChange` to scene `#4B` (Nazca) at (120,80). Main departure trigger actor |
| `$05E179` | `$05E1E8` | 112 | `na49_erik` | actor-def | **Erik** — walk south; pre-`#05`: walks south then east, settles. Interact: "Seth will be pleased when he sees this invention..." |
| `$05E1E9` | `$05E2B6` | 238 | `na49_tank` | actor-def | **Oxygen tank** — metasprite from `table_0EE000` frame #00. Interact: Neil explains it lets you breathe underwater for one minute. Sets `$0AA6` bit 0 (`OR #$0001`). One of four required inventions |
| `$05E2B7` | `$05E3CA` | 228 | `na49_wings` | actor-def | **Airplane wings** — metasprite, offset (+8,0). Interact: Neil explains they're part of a flying machine, body too big for indoor use, runway hidden in the desert. Sets `$0AA6` bit 1 (`OR #$0002`). One of four required inventions |
| `$05E3CB` | `$05E42D` | 99 | `na49_telescope` | actor-def | **Telescope** — metasprite. Interact: "You can see stars as if they were in your hand." Sets `$0AA6` bit 2 (`OR #$0004`). One of four required inventions |
| `$05E42E` | `$05E549` | 269 | `na49_camera` | actor-def | **Camera** — metasprite. Extended interact: Neil explains 30-minute exposure time, red-eye problem, scenery vs portrait limitations. Sets `$0AA6` bit 3 (`OR #$0008`). One of four required inventions |

**Subtotal:** 9 pieces, 3,501 bytes

### 2.27 Nazca — Plains (scene `nazca`, na4B)

The Nazca Plains overworld. The party explores the Condor ground painting.
Neil runs the Cygnus constellation puzzle, Lily has the eureka moment,
and the buried tile triggers the Sky Garden descent.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05E54A` | `$05E7D4` | 506 | `na4B_buried_tile` | actor-def | **Buried tile — Sky Garden trigger.** Spawns edge-of-map boundary checker (warns "don't go too far"). Gates on `#09`. Pre-`#0F`: interact depends on `#0B` (Neil's flute): if set, rumbling sound, palette fade via `COLDATA` animation (8 steps), prints "Something huge is coming down!!", spawns a descending ship metasprite (frame #1C) from `table_0EE000` at player position with SFX `#0C0C`, sets `#0D`. Then Kara screams "Will! Will!", and `QueueMapChange` to scene `#4C` (Sky Garden) at (168,40) with flags `#83`/`#$2200`. If `#0B` not set: Neil warns "Don't look yet!" |
| `$05E7D5` | `$05EC0E` | 1,098 | `na4B_neil` | actor-def | **Neil — Nazca exploration controller.** Arrival: locks joypad, prints greeting about the Condor ground painting, sets `#01`. After all party members regroup (`#02`): extended multi-character discussion about Cygnus constellation alignment. Presents 4-option puzzle: "Where is the red star?" — Head/Right Foot/Left Foot/Tail. Wrong answers: "I would think it would be at the bottom." Correct (Tail = "Condor's Tail", option 3): "Of course! At the joint of its left foot!", sets `#09`. Then choreographed walk south across the plain to the dig site, sets `#0B`. Post-puzzle interact: "Not bad! It's as exciting as inventing something!" |
| `$05EC0F` | `$05EE24` | 534 | `na4B_kara` | actor-def | **Kara — Nazca exploration.** Multi-phase choreographed walk across the plain, visiting various positions. Dialogue reacts to discoveries: "It must be great to paint such a huge painting on a natural canvas" → "the white lines look like an athletic event" → "This is the Condor's stomach. If you dig here, you might find eggs. It's a joke" → "What an exciting experience." Sets flags `#05`, `#06` at interact points |
| `$05EE25` | `$05EF8C` | 328 | `na4B_lance` | actor-def | **Lance** — choreographed walk south then west; reflective dialogue: "Up until now all I've done is go to school, study, and play." Post-regroup: "We're working on a puzzle that explorers and archeologists have never solved..." |
| `$05EF8D` | `$05F1BC` | 528 | `na4B_lily` | actor-def | **Lily — eureka moment.** Multi-phase walk across the plain. At Cygnus alignment phase: locks joypad, "Aaaah! I've got it!!!", forces player via `InitPlayerScriptVariant`, walks to vantage point: "Look! Look where the rocks are on the ground! They're positioned like the stars in the constellation of Cygnus!" Sets `#08`, `#0A`. Post-discovery: walks to dig site. Interact: "A riddle in a constellation. Kind of romantic." |
| `$05F1BD` | `$05F2BA` | 246 | `na4B_erik` | actor-def | **Erik** — choreographed walk south then east. Multiple idle states. Dialogue progression: "It's scary... I'll stay with Neil" → "What's going to happen? It's exciting!" |
| `$05F2BB` | `$05F358` | 103 | `na4B_spirit` | actor-def | **Moon Tribe spirit** — body #32, gates on `#06`/`#07`; invisible mode (`TRB $10 #$2000`), metasprite mode. Appears in 3 positions (loopInit #03), each time waiting for player proximity (#02 tiles) before jumping 112px east. After third appearance: locks joypad, prints "Ku ku ku...", sets `#02`, performs diagonal flyaway animation, dies |

**Subtotal:** 7 pieces, 3,343 bytes

---

### 2.28 Sky Garden — Main (scene `garden_main`, sg4C)

The Sky Garden entrance area with Moon Tribe spirits and moving platforms.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F359` | `$05F4C3` | 363 | `sg4C_spirits` | actor-def | **Three Moon Tribe spirits** (`sg4C_spirit1`/`spirit2`/`spirit3`) — each body #3C, metasprite mode, solid interactable. Spirit 1: "We meet again. Ku ku ku. You're a strong boy to have come this far." Spirit 2: "I brought you to the Sky Garden because of the spirits inside." Spirit 3: "There are 4 passages. Each connects to a room. A Crystal Ball is hidden in each room." Named in `names.json` at addresses 389974/390062/390227 |
| `$05F4C4` | `$05F507` | 67 | `sg___hint_spirit` | actor-def | **Hint spirit** — body #3C, same structure as above; shared across Sky Garden scenes. "Attack when the Crystal Bird cries." Combat strategy hint for the Viper boss |
| `$05F508` | `$05F5D9` | 218 | `sg4C_platforms` | actor-def | **Four moving platforms** (`sg4C_platform1`–`platform4`) — named in `names.json` at 390404/390451/390513/390560. Moving platform actors for Sky Garden traversal between areas |

**Subtotal:** 3 pieces, 648 bytes

### 2.29 Sky Garden — Southwest Underside (scene `garden_southwest_underside`, sg52)

Toggle switches that apply BG changes to open/close paths via word flags.

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F5DA` | `$05F658` | 119 | `sg52_actor_05F5DE` | actor-def | **Toggle switch A** — body #0F, enemy-type, metasprite, HP=255. Hit toggles between frames #0F (off) and #10 (on), alternately applying BG change #90 (reset) or #26 (open), toggling word flags `#$0125`/`#$0126`. Solid, rearms after each hit |
| `$05F659` | `$05F6D3` | 123 | `sg52_actor_05F655` | actor-def | **Toggle switch B** — body #0F, enemy-type, metasprite. More complex: toggles between two BG change pairs (#28 → flags `#$0127`/`#$0128`, or #2A → flags `#$0129`/`#$012A`). Each toggle clears the other pair's flags. Controls two separate paths |
| `$05F6D4` | `$05F74C` | 121 | `sg52_switch` | actor-def | **Pressure plate + actor detector** — invisible; gates on word `#$012E`. Monitors two conditions: player proximity (#01 tile) → prints "When you step on this tile it makes a sound..." OR actor #03 at position (258,330) → applies BG change #2E, sets `#$012D`/`#$012E`, repositions actor. Puzzle that requires pushing an object onto a specific tile |

**Subtotal:** 3 pieces, 363 bytes

### 2.30 Sky Garden — West Underside (scene `garden_west_underside`, sg54)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F74D` | `$05F76E` | 34 | `sg54_pressure_switch` | actor-def | **Pressure plate** — invisible; gates on word `#$012F`. Monitors actor #03 at position (348,2E0); when actor arrives: applies BG change #2F, sets `#$012F`, dies. One-shot puzzle trigger |

**Subtotal:** 1 piece, 34 bytes

### 2.31 Sky Garden — Jump Handler (shared across sg4D scenes)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F76F` | `$05F858` | 238 | `sg4D_jump_handler` | actor-def | **Table-driven inter-platform jump system** — body #00, invisible. Scans `spawn_trigger_05F7BB` table: each 6-byte entry is (sceneID, playerX, playerY). Matches current scene + player position; on match, freezes player via `player_transition_handlers.PlayerFreedanRevealIdle`, loads spawn code pointer from the table to execute the appropriate platform-jump transition. Handles all Sky Garden inter-area jumps from a single dispatcher |

**Subtotal:** 1 piece, 238 bytes

### 2.32 Gold Ship — Tail Code (part of `ggs2B_wreck_wave_motion`)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F859` | `$05F8F6` | 103 | `code_05F859` | Code | **Camera Y target driver** — same keyframe-reading logic as `ggs2B_wreck_wave_motion` but writes to `$16` scratch + `cameraTargetY` instead of `cameraDeltaY`. Used for independent Y camera control in post-storm wreck scenes |

**Subtotal:** 1 piece, 103 bytes

### 2.33 Sky Garden — Southwest (scene `garden_southwest`, sg51)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F8F7` | `$05F92A` | 55 | `sg51_statue` | actor-def | **Pushable enemy statue** — body #3D, enemy-type (`$12=#$0031`), solid. Has push handler spawned from `interaction_handlers.push_handler_solid`. Hit callback: only dies when `playerFlags` bit #02 (attack connecting) is set; jumps to `StandardEnemyDefeatHandler`. Otherwise re-arms. A statue that must be attacked to destroy |

**Subtotal:** 1 piece, 55 bytes

### 2.34 Inca Ruins — Cross-Reference (part of `ir1D_monologue`)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F92B` | `$05F99E` | 165 | `dialogstring_05F8F7` | DialogString | Larai Cliff monologue text — referenced by `ir1D_monologue` in the inca_ruins group (ordered at position 643119). Physically placed in bank $05 where space was available |

**Subtotal:** 1 piece, 165 bytes

### 2.35 Diamond Mine — Entrance (scene `mine_entrance`, dm3E)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05F99F` | `$05FB15` | 378 | `dm3E_intro` | actor-def | **Scene-aware intro monologue** — body #00, invisible. Locks joypad; checks `sceneCurrent`: scene `#3E` (mine) → one-shot monologue (sets `#6A`): "The Diamond Mine was as quiet as a tomb. A chill ran down Will's spine when he heard the screams from the back of the cave." Scene `#4C` (Sky Garden) → different one-shot monologue (sets `#6B`). Other scenes → exits. Reusable intro controller |

**Subtotal:** 1 piece, 378 bytes

### 2.36 System — Thinker Definitions (thinkers)

| Address | End | Size | Block Name | Type | Description |
|---------|-----|------|------------|------|-------------|
| `$05FB16` | `$05FEB1` | 956 | `thinkers_05FB16` | thinker-def | **HDMA circle/ellipse rasterizer suite** — multiple thinker-defs implementing Bresenham circle/ellipse algorithms. `crF7_thinker_05FB16`: reads parameters from `$F4`–`$FE` (center, radii, brightness), alternates double-buffered HDMA tables (`$7E7000`/`$7E7100`) via `QueueHdma` on channel 26. `thinker_def_05FB32`: enhanced version with delta detection (skips recompute if params unchanged). Core routines: `HdmaGradientBuildV1` draws circles with signed radius stepping, writes paired window entries at symmetric offsets with brightness blending. `HdmaGradientBuildV2` draws ellipses. Used for spotlight iris effects, screen wipes, and transition circles across multiple scenes |

**Subtotal:** 1 piece, 956 bytes

### 2.37 Unmapped Tail

| Address | End | Size | Description |
|---------|-----|------|-------------|
| `$05FEB2` | `$05FFFF` | 302 | Unmapped — no blocks, names, or overrides in this region |

---

## 3. Scene Group Summary

| # | Area | Scene ID(s) | Pieces | Bytes | % of Bank |
|---|------|-------------|--------|-------|-----------|
| 1 | **Gold Ship — Wreck Deck** | gs2B | 5 | 497 | 1.5% |
| 2 | **Gold Ship — Ship Deck** | gs2C | 9 | 1,118 | 3.4% |
| 3 | **Gold Ship — Erik Helper** | gs2B (code) | 2 | 148 | 0.5% |
| 4 | **Gold Ship — Interior** | gs2E | 6 | 1,263 | 3.9% |
| 5 | **Gold Ship — Wreck Interior** | gs2D | 5 | 1,662 | 5.1% |
| 6 | **Gold Ship — Wreck Deck (continued)** | gs2B, gs2A | 3 | 1,377 | 4.2% |
| 7 | **Diamond Coast — Adrift** | dc2F | 2 | 4,978 | 15.2% |
| | ***Gold Ship + Adrift total*** | | **32** | **11,043** | **33.7%** |
| 8 | **Oakton — Town** | dc30 | 2 | 240 | 0.7% |
| 9 | **Oakton — Interior** | dc31 | 5 | 1,218 | 3.7% |
| | ***Oakton total*** | | **7** | **1,458** | **4.5%** |
| 10 | **Freejia — Town** | fr32 | 23 | 3,269 | 10.0% |
| 11 | **Freejia — Adequacy Manor** | fr38 | 3 | 246 | 0.8% |
| 12 | **Freejia — Mother's House** | fr36 | 1 | 168 | 0.5% |
| 13 | **Freejia — Messy House** | fr3B | 1 | 103 | 0.3% |
| 14 | **Freejia — Harborer's House** | fr3A | 2 | 272 | 0.8% |
| 15 | **Freejia — Thorn Tower** | fr37 | 1 | 124 | 0.4% |
| 16 | **Freejia — Slave Market** | fr3C | 6 | 1,064 | 3.2% |
| 17 | **Freejia — Labor Camp** | fr35 | 3 | 225 | 0.7% |
| 18 | **Freejia — Hotel** | fr39 | 5 | 2,334 | 7.1% |
| 19 | **Freejia — Erik's Captivity** | fr33 | 2 | 482 | 1.5% |
| | ***Freejia total*** | | **47** | **8,287** | **25.3%** |
| 20 | **Diamond Mine — Main** | dm3F | 5 | 310 | 0.9% |
| 21 | **Diamond Mine — Inner** | dm47 | 4 | 1,057 | 3.2% |
| 22 | **Diamond Mine — Morgue** | dm45 | 1 | 121 | 0.4% |
| 23 | **Diamond Mine — Foyer** | dm44 | 1 | 246 | 0.8% |
| 24 | **Diamond Mine — Collapsed Tunnel** | dm40 | 2 | 392 | 1.2% |
| 25 | **Diamond Mine — Zigzag** | dm41 | 1 | 44 | 0.1% |
| 26 | **Diamond Mine — Entrance** | dm3E | 1 | 378 | 1.2% |
| | ***Diamond Mine total*** | | **15** | **2,548** | **7.8%** |
| 27 | **Neil's Cottage** | na49 | 9 | 3,501 | 10.7% |
| 28 | **Nazca Plains** | na4B | 7 | 3,343 | 10.2% |
| | ***Nazca total*** | | **16** | **6,844** | **20.9%** |
| 29 | **Sky Garden — Main** | sg4C | 3 | 648 | 2.0% |
| 30 | **Sky Garden — SW Underside** | sg52 | 3 | 363 | 1.1% |
| 31 | **Sky Garden — W Underside** | sg54 | 1 | 34 | 0.1% |
| 32 | **Sky Garden — Jump Handler** | sg4D | 1 | 238 | 0.7% |
| 33 | **Sky Garden — Southwest** | sg51 | 1 | 55 | 0.2% |
| | ***Sky Garden total*** | | **9** | **1,338** | **4.1%** |
| 34 | **Inca Ruins x-ref** | ir1D | 1 | 165 | 0.5% |
| 35 | **System — Thinkers** | — | 1 | 956 | 2.9% |
| | **Unmapped tail** | — | — | 302 | 0.9% |
| | **BANK TOTAL** | | **~121** | **32,768** | **100%** |

---

## 4. Architectural Notes

### 4.1 Bank Layout Pattern

Unlike bank $04 which follows a strict geographic/chronological order, bank $05
exhibits a more complex layout with interleaved pieces from different parent groups:

```
$058000–$05970D   Gold Ship (wreck, deck, interior, dream)     — 5,694 bytes
$05970F–$05AA9F   Adrift sequence                              — 4,978 bytes
$05AAA0–$05AB8F   Oakton                                       —   240 bytes
$05AB90–$05B01D   Oakton Interior                              — 1,218 bytes
$05B01E–$05D023   Freejia (town, houses, hotel, market)        — 8,287 bytes
$05D024–$05D8A5   Diamond Mine                                 — 2,170 bytes
$05D8AD–$05F358   Nazca (cottage + plains)                     — 6,844 bytes
$05F359–$05F858   Sky Garden (puzzles, platforms, jumps)        — 1,283 bytes
$05F859–$05FEB1   Tail: mixed code, dialogs, thinkers          — 1,845 bytes
$05FEB2–$05FFFF   Unmapped                                     —   302 bytes
```

The "tail" region (`$05F859`–`$05FEB1`) contains pieces from multiple parent groups
that were placed after the main sequential blocks: Gold Ship helper code, Sky Garden
statue, Inca Ruins dialogue cross-reference, Diamond Mine entrance intro, and the
HDMA thinker suite.

### 4.2 Dominant Actors

| Rank | Actor | Bytes | Scene | Notes |
|------|-------|-------|-------|-------|
| 1 | `dc2F_adrift` | 4,957 | Adrift | 7-phase ocean survival — SwitchCase on `$0AA6` |
| 2 | `na49_neil` | 1,186 | Neil's Cottage | Invention workshop + constellation exposition |
| 3 | `na4B_neil` | 1,098 | Nazca Plains | 4-option Cygnus puzzle + exploration walk |
| 4 | `thinkers_05FB16` | 956 | System | HDMA Bresenham circle/ellipse rasterizers |
| 5 | `fr39_lance` | 946 | Freejia Hotel | Memory Melody amnesia-cure scene |
| 6 | `gs2D_lily` | 798 | Wreck Interior | Party reunion + ring argument + camera drift |
| 7 | `na49_lily` | 732 | Neil's Cottage | Cygnus red star + comic relief + Yes/No departure |
| 8 | `gs2B_erik` | 699 | Shipwreck Deck | Storm-panic cutscene + gravity physics + map change |
| 9 | `dm47_sam` | 635 | Mine Inner | Chain rescue + Memory Melody teaching + SPC handshake |
| 10 | `na4B_kara` | 534 | Nazca Plains | Multi-position exploration with jokes |

### 4.3 Story Flag Usage

Key progression flags by scene group:

**Gold Ship (gs2B/2C/2D/2E):** `#4C` descent triggered, `#4D` dream/map-change ready,
`#4E` queen spoken to, `#4F` storm/guard event complete, `#50` Lily wreck reunion,
`#51` Seth's cry heard (enables Erik/Seth actors), `#F8` bed rest available,
`#0E` Shira dream interact, `#E0` Seth's Red Jewel given, `#$0185` (word) descent marker

**Adrift (dc2F):** 7-phase `SwitchCase` on `$0AA6` (0–6); per-phase local flags
`#01`–`#03` for interaction progression; `#4D` map-reload ready; `#52` starvation
state; `#$0120` (word) mid-drift lock

**Oakton (dc30/31):** `#56` Kara departure ready (to Freejia), `#76` rescuer exposition
complete, `#01`/`#02` sequential dialogue gates

**Freejia (fr32–fr3C):** `#57` guide/hotel complete, `#58` hotel party reunion,
`#59` sympathetic woman spoken to (gates slaver2 quest), `#5A` slaver2 quest complete
(harborer/slaver1/sympathetic die), `#64` Kara escort phase, `#65` Erik freed,
`#66` Sam's info about Erik (gates kidnapper), `#67` kidnapper resolved,
`#68` Lance memory restored, `#0F` showman/lance loop flag, `#53`/`#54` herb/HP jewel,
`#E1` creep Red Jewel, `#D9` trapped slave Red Jewels

**Diamond Mine (dm3E–dm47):** `#5B`/`#5C` cell door keys used, `#5D` mine key found,
`#5E` Sam freed (all slaves rescued), `#69` elevator key used, `#6A`/`#6B` intro
monologues, `#D9` trapped slave collectible, `#$0121`/`#$017A`/`#$017B` (word) BG changes

**Nazca (na49/na4B):** `#01`–`#08` sequential party choreography, `#09` Cygnus puzzle
solved, `#0A` Lily exposition, `#0B` Neil reached tile, `#0C`/`#0D` burial reveal,
`#0F` condor tile triggered, `#6D` departure flag. Invention tracking: `$0AA6`
bits 0–3 for tank/wings/telescope/camera

**Sky Garden (sg4C–sg54):** Word flags `#$0125`–`#$012F` for toggle switches and
pressure plates; `#$012D`/`#$012E` actor-position puzzle; `#$012F` west-side gate

### 4.4 Unique Characteristics

- **Largest single actor:** `dc2F_adrift` at 4,957 bytes — nearly 4× the next
  largest. It contains a full 7-phase gameplay loop over 21 in-game days with
  enemy fish combat, item discovery (Sam's letter in a jar), emotional character
  development (Will and Kara's evolving relationship), stargazing, shark encounters,
  and Will's collapse. Each phase reloads the same scene map with incremented
  `$0AA6` state.

- **Invention tracking system:** `na49_neil`'s four inventions use `$0AA6` as a
  4-bit bitmask (OR #1/#2/#4/#8). Neil's interact handler checks for `#$0F`
  (all four visited) to advance the plot. This is a compact state machine
  without individual flag bytes.

- **SPC audio handshake:** `dm47_sam` reads `APUIO1` ($2141) to detect when the
  Memory Melody music has finished loading/playing before proceeding with the
  item exchange. This is one of the few actors that directly polls an APU I/O port.

- **PPU register manipulation:** Several Gold Ship actors directly write PPU registers
  (`TM`, `CGADSUB`, `COLDATA`, `W12SEL`, `WOBJSEL`) for color math whitewash,
  subtractive blending, and window masking effects rather than using COP commands.

- **Cross-group placement:** `dialogstring_05F8F7` belongs to `inca_ruins`
  (Larai Cliff monologue) but physically sits in bank $05; `dm3E_intro` handles
  both mine and Sky Garden scenes via `sceneCurrent` check.

### 4.5 Narrative Flow

```
Gold Ship Deck (gs2C)           ← crew mistakes Will for ancient King
  ├─ Gold Ship Interior (gs2E)  ← Queen guards Mystic Statue; crew lore
  ├─ Shira Dream (gs2A)        ← Will's mother; lucky/unlucky star choice
  └─ Descent (gs2C_descent)    ← PPU whitewash → below-deck transition

Shipwreck (gs2B/gs2D)          ← storm aftermath
  ├─ Wreck Interior (gs2D)     ← Lily reunion, Kara/ring argument, Lance hears Seth
  ├─ Wreck Deck (gs2B)         ← Erik's panic, Seth's Red Jewel gift
  └─ Storm (gs2B_erik)         ← gravity physics, camera shake → adrift transition

Adrift (dc2F)                   ← 21-day ocean survival (15.2% of bank!)
  Day 1: Kara wake-up            Day 12: stargazing, Kara/Cygnus wish
  Day 2: fishing, Kara protests  Day 18: shark encounter, Kara's insight
  Day 4: Sam's jar letter        Day 21: Will collapses → Oakton
  Day 7: starvation, reconciliation

Oakton (dc30/dc31)              ← Turbo the rescue dog, scurvy diagnosis → Freejia

Freejia (fr32–fr3C)            ← slave-trade town (25% of bank)
  ├─ Town Square (fr32)         ← guide escort, kidnapper ambush, creep Red Jewel
  ├─ Houses (fr36–fr3B)        ← mother, harborer, messy house, adequacy manor
  ├─ Slave Market (fr3C)       ← Imas/Remus/Sam tell their stories, slaver boss
  ├─ Hotel (fr39)              ← party reunion; Lance's Memory Melody cure
  └─ Erik's Captivity (fr33)   ← Erik rescued → mine location learned

Diamond Mine (dm3E–dm47)       ← puzzle switches, slave chain rescue
  ├─ Main (dm3F)               ← 4-hit orb switch, elevator door, signage
  ├─ Inner (dm47)              ← Imas/Remus/Sam chain-cutting, Memory Melody
  ├─ Foyer (dm44)              ← double-locked cell door
  ├─ Collapsed Tunnel (dm40)   ← enemy slave breakout → 3 Red Jewels to Jeweler
  └─ Zigzag (dm41)             ← dripping ceiling hazard

Nazca (na49/na4B)              ← Neil's expedition (20.9% of bank)
  ├─ Neil's Cottage (na49)     ← 4 inventions (tank/wings/telescope/camera)
  │                             ← sock comedy, Cygnus constellation discussion
  └─ Nazca Plains (na4B)       ← Condor ground painting, 4-option Cygnus puzzle
                                ← buried tile → Sky Garden descent

Sky Garden (sg4C–sg54)          ← first Sky Garden puzzles
  ├─ Main (sg4C)               ← 3 Moon Tribe spirits, 4 moving platforms
  ├─ Underside (sg52/54)       ← toggle orb switches, pressure plates
  ├─ Southwest (sg51)           ← pushable/breakable enemy statue
  └─ Jump handler (sg4D)       ← table-driven inter-platform jump dispatcher
```

### 4.6 Extracted File Locations

| Directory | Scenes |
|-----------|--------|
| `extracted/gold_ship/ship_wreck/` | gs2B wreck deck actors |
| `extracted/gold_ship/ship_gold/` | gs2C intact deck actors |
| `extracted/gold_ship/ship_gold_interior/` | gs2E below-deck actors |
| `extracted/gold_ship/ship_wreck_interior/` | gs2D wreck interior actors |
| `extracted/gold_ship/dream/` | gs2A Shira dream sequence |
| `extracted/gold_ship/adrift/` | dc2F ocean adrift sequence |
| `extracted/gold_ship/` | dialogstring_058000 (root-level) |
| `extracted/freejia/oakton/` | dc30 Oakton town actors |
| `extracted/freejia/oakton_interior/` | dc31 rescuer house actors |
| `extracted/freejia/freejia/` | fr32 town square actors |
| `extracted/freejia/adequacy_manor/` | fr38 manor actors |
| `extracted/freejia/mothers_house/` | fr36 |
| `extracted/freejia/messy_house/` | fr3B |
| `extracted/freejia/harborer_house/` | fr3A |
| `extracted/freejia/thorn_tower/` | fr37 |
| `extracted/freejia/slave_market/` | fr3C market actors |
| `extracted/freejia/` | fr35 labor camp actors (root-level) |
| `extracted/freejia/freejia_hotel/` | fr39 hotel actors |
| `extracted/freejia/eriks_captivity/` | fr33 |
| `extracted/diamond_mine/mine_main/` | dm3F main mine actors |
| `extracted/diamond_mine/mine_inner/` | dm47 inner mine actors |
| `extracted/diamond_mine/mine_morgue/` | dm45 |
| `extracted/diamond_mine/mine_foyer/` | dm44 |
| `extracted/diamond_mine/mine_collapsed_tunnel/` | dm40 |
| `extracted/diamond_mine/mine_zigzag/` | dm41 |
| `extracted/diamond_mine/mine_entrance/` | dm3E intro |
| `extracted/nazca/neils_cottage/` | na49 cottage actors |
| `extracted/nazca/nazca/` | na4B plains actors |
| `extracted/sky_garden/garden_main/` | sg4C spirits + platforms |
| `extracted/sky_garden/garden_southwest_underside/` | sg52 |
| `extracted/sky_garden/garden_west_underside/` | sg54 |
| `extracted/sky_garden/garden_southwest/` | sg51 |
| `extracted/sky_garden/` | sg4D jump handler, sg___hint_spirit (root-level) |
| `extracted/thinkers/` | thinkers_05FB16 |
