# Mesen2 findings index

This page routes a runtime or static fact about the US ROM to the document that states it and to the series summary that holds the evidence. Each summary names the sessions, the result files and the evidence tags. A fact in a document under `docs/` is only as strong as the tag in the summary row it points to.

How to use it:

1. Find the fact in section 2.
2. Open the document column for the sentence a patch author reads.
3. Open the summary column for the measurement, the tag (VERIFIED-RUNTIME, VERIFIED-STATIC, CONTRADICTED, INCONCLUSIVE, SIMULATED) and the open halves.

Two build names appear in every button statement. **This build** (the rebuilt baserom with remapped buttons) maps physical A to `$8080` (interact `$8000` plus attack `$0080`), physical B to `$4008` (cancel `$4000` plus item use `$0008`), Y to `$0040` and X to `$0004`. The **vanilla US ROM** (O) uses its own map: the identity map on the title screen, the diary, Type 2 and the quick-warp states gives physical B `$8000`, A `$0080`, Y `$4000`; Type 1 after a new game gives A `$8000`, B `$4000`, Y `$0040`. The raw pad word is B `$8000`, Y `$4000`, Select `$2000`, Start `$1000`. State the build whenever a mask is written down.

---

## 1. Series summaries

| Series | Summary | Subject |
|--------|---------|---------|
| A | [mesen2-a-series-summary.md](mesen2-a-series-summary.md) | Actor `$10` / `$12` flag census and forced-bit experiments |
| B | [mesen2-b-series-summary.md](mesen2-b-series-summary.md) | Collision layer, special tiles, wall slides, ramps, glide |
| C | [mesen2-c-series-summary.md](mesen2-c-series-summary.md) | NMI, adhoc DMA, `displayModeFlags`, boot |
| D | [mesen2-d-series-summary.md](mesen2-d-series-summary.md) | Sound queue, music ids, SPC loader |
| E | [mesen2-e-series-summary.md](mesen2-e-series-summary.md) | Palette bundles, HDMA, Mode 7, world map display |
| F | [mesen2-f-series-summary.md](mesen2-f-series-summary.md) | Sprite sets, sprite groups, hidden groups, orbital hitboxes |
| G | [mesen2-g-series-summary.md](mesen2-g-series-summary.md) | Combat, defeat, drops, rewards, game over |
| M + N | [mesen2-m-n-series-summary.md](mesen2-m-n-series-summary.md) | Title, menus, world map, radar, interactions, revive |
| P + S | [mesen2-p-s-series-summary.md](mesen2-p-s-series-summary.md) | Run window, buttons, abilities, camera, static questions |
| R | [mesen2-r-series-summary.md](mesen2-r-series-summary.md) | Dead and live code, save warps, scene tables |
| V | [mesen2-v-series-summary.md](mesen2-v-series-summary.md) | Twelve claim confirmations |
| W1 | [mesen2-w1-series-summary.md](mesen2-w1-series-summary.md) | Movement gates, flagged idle, thinker pages, depth-sort buckets |
| FR | [mesen2-fr-series-summary.md](mesen2-fr-series-summary.md) | Event flags, scene load lifecycle, arrival locks, presets |

Related: [mesen2-exports.md](mesen2-exports.md) covers exports from the same campaign.

---

## 2. Fact, document, summary

### 2.1 Waits and timing

| Fact | Document | Summary |
|------|----------|---------|
| `WaitByte #n` (and the other wait stores) resume after n + 1 passes of the owning runner. A pass equals one NMI frame only when the main loop runs one runner pass per frame | [cop-commands-reference.md](cop-commands-reference.md) | [V](mesen2-v-series-summary.md) |
| The title `WaitByte #B3` is 180 passes but 313 NMI frames (about 5.2 s) because the 135-frame fade runs with no runner pass | [code/bank0B-late-bosses-system-cutscene-actors.md](code/bank0B-late-bosses-system-cutscene-actors.md), [code/bank03/scene-and-hardware.md](code/bank03/scene-and-hardware.md) | [V](mesen2-v-series-summary.md), [M + N](mesen2-m-n-series-summary.md) |
| A world-map route step of n frames applies n + 1 position deltas; the last delta of step k shares a frame with the first of step k + 1 | [code/bank03/radar-and-world-map.md](code/bank03/radar-and-world-map.md) | [M + N](mesen2-m-n-series-summary.md) |
| `LoopEnd` with count n yields n − 1 times; the last pass leaves without a yield | [cop/families/script_control.md](cop/families/script_control.md) | [M + N](mesen2-m-n-series-summary.md), [P + S](mesen2-p-s-series-summary.md) |
| The run window is the 13-frame down-counter `$040C` started by the first walk entry; a second press in the same direction inside it runs, a press 14 frames later does not, cross-direction never runs | [code/bank00/system-core.md](code/bank00/system-core.md) | [P + S](mesen2-p-s-series-summary.md) |

### 2.2 Input and buttons

| Fact | Document | Summary |
|------|----------|---------|
| Physical-to-logical map of this build and of the vanilla ROM | [wram-memory-map.md](wram-memory-map.md#29-input-remapping-0da00dc0) | [P + S](mesen2-p-s-series-summary.md), [V](mesen2-v-series-summary.md) |
| Closing the inventory with B and then holding B does not arm item use in this build | [code/bank02/inventory-overlay.md](code/bank02/inventory-overlay.md) | [M + N](mesen2-m-n-series-summary.md) |
| The inventory cancel `$4000` is physical Y on the vanilla ROM and physical B in this build | [code/bank02/inventory-overlay.md](code/bank02/inventory-overlay.md) | [C](mesen2-c-series-summary.md) |
| Logical Y (`$0040`) and X (`$0004`) have no effect found in free field scenes `$01` and `$0C` | [wram-memory-map.md](wram-memory-map.md#29-input-remapping-0da00dc0) | [P + S](mesen2-p-s-series-summary.md) |

### 2.3 Actor flags `$10` / `$12`

| Fact | Document | Summary |
|------|----------|---------|
| `$10` bit `$0200` means "ignore enemy contact" on the actor that carries it; `playerFlags` `$0200` is game over | [wram-memory-map.md](wram-memory-map.md#actor-flag-bits-flags10--flags12-verified-with-mesen2), [code/bank00/functions-game-over.md](code/bank00/functions-game-over.md) | [A](mesen2-a-series-summary.md), [P + S](mesen2-p-s-series-summary.md) |
| `$10` bit `$0200` readers are four sites with masks `$76E0`, `$36F0`, `$0280`; the friendly pass `$74E0` allows it | [code/bank03/movement-and-collision.md](code/bank03/movement-and-collision.md) | [P + S](mesen2-p-s-series-summary.md), [A](mesen2-a-series-summary.md) |
| `$10` bit `$0008` switches an actor to collision-aware movement | [code/bank03/movement-and-collision.md](code/bank03/movement-and-collision.md) | [A](mesen2-a-series-summary.md) |
| `$10` bit `$2000` drops the actor from the depth-sort buffer stores (measured on a live enemy) | [wram-memory-map.md](wram-memory-map.md#actor-flag-bits-flags10--flags12-verified-with-mesen2), [code/bank03/actor-thinker-runtime.md](code/bank03/actor-thinker-runtime.md) | [A](mesen2-a-series-summary.md), [V](mesen2-v-series-summary.md) |
| `$10` bit `$0400` on a victim is set only on the inline-lethal path; drops spawn with `$0420` | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) | [A](mesen2-a-series-summary.md) |
| `$10` bit `$0100` is the vulnerable stance; abilities clear it | [code/bank02/player-character.md](code/bank02/player-character.md) | [A](mesen2-a-series-summary.md) |
| `$12` bit 12 qualifies the display filter: with `displayModeFlags` bit 7 set only actors with that bit run | [code/bank03/actor-thinker-runtime.md](code/bank03/actor-thinker-runtime.md) | [P + S](mesen2-p-s-series-summary.md), [A](mesen2-a-series-summary.md) |
| Movement flag word `$AA` bits `$0400` / `$0800` are live gates | [wram-memory-map.md](wram-memory-map.md) | [W1](mesen2-w1-series-summary.md) |

### 2.4 Combat and rewards

| Fact | Document | Summary |
|------|----------|---------|
| Player attacks are evaluated in combat phase 2; the idle player `$0100` stays out of it | [code/bank03/movement-and-collision.md](code/bank03/movement-and-collision.md) | [G](mesen2-g-series-summary.md) |
| Ability damage follows the loaded record byte; Spin Dash flight uses the Slider record (5/8), not the charge-only record (4/7) | [code/bank02/attack-ability-system.md](code/bank02/attack-ability-system.md) | [P + S](mesen2-p-s-series-summary.md), [G](mesen2-g-series-summary.md) |
| A positive `iframeCounter` freezes a victim, a negative one is the recovery | [wram-memory-map.md](wram-memory-map.md), [code/bank02/player-character.md](code/bank02/player-character.md) | [V](mesen2-v-series-summary.md), [G](mesen2-g-series-summary.md) |
| Player hit stagger is 16 ticks after the hit tick (17 with it); 60 without a stagger child | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) | [V](mesen2-v-series-summary.md), [G](mesen2-g-series-summary.md) |
| A full actor pool returns the sentinel slot `$1FC0` and the hit stun stands 60 ticks | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) | [G](mesen2-g-series-summary.md) |
| Dungeon kill bits `$0A80`–`$0A9F` survive room changes and revive; real game over (under 100 gems) and world-map entry clear them | [wram-memory-map.md](wram-memory-map.md), [code/bank00/event-flags.md](code/bank00/event-flags.md) | [G](mesen2-g-series-summary.md), [FR](mesen2-fr-series-summary.md), [W1](mesen2-w1-series-summary.md) |
| Revive costs exactly 100 gems (`>= 100`) | [code/bank00/functions-game-over.md](code/bank00/functions-game-over.md) | [V](mesen2-v-series-summary.md), [M + N](mesen2-m-n-series-summary.md) |
| Stat-up `$55` is a reset at signed overflow, not a cap; the max-HP display clamp is `$28` | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) | [V](mesen2-v-series-summary.md), [M + N](mesen2-m-n-series-summary.md) |
| The jeweler's "Strength" page raises max HP | [code/bank08-native-dao-pyramid-actors.md](code/bank08-native-dao-pyramid-actors.md) | [V](mesen2-v-series-summary.md), [M + N](mesen2-m-n-series-summary.md) |
| Psycho Dash moves the player 52 px out and back; Dark Friar fragments keep their direction after the sign flip | [code/bank02/attack-ability-system.md](code/bank02/attack-ability-system.md) | [P + S](mesen2-p-s-series-summary.md) |
| Aura orbitals damage through the body box (header bytes 8–11) | [code/bank02/attack-ability-system.md](code/bank02/attack-ability-system.md) | [F](mesen2-f-series-summary.md) |
| Statues are pulled one tile, not pushed | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) | [M + N](mesen2-m-n-series-summary.md) |

### 2.5 Collision and movement

| Fact | Document | Summary |
|------|----------|---------|
| The low nibble of a collision cell is a quadrant mask; types `$06` and `$09` are diagonal-edge masks | [wram-memory-map.md](wram-memory-map.md) (§4.10 Collision Layer) | [B](mesen2-b-series-summary.md) |
| The collision layer is one merged map at `$7F:C000`, with a dual-layer overlay in nine scenes and post-load changes in five | [code/bank02/scene-script.md](code/bank02/scene-script.md), [code/bank02/tile-collision.md](code/bank02/tile-collision.md) | [B](mesen2-b-series-summary.md) |
| Wall slides, wall snaps and ramp corners are measured | [code/bank02/player-movement.md](code/bank02/player-movement.md), [code/bank02/slope-ramp-physics.md](code/bank02/slope-ramp-physics.md) | [B](mesen2-b-series-summary.md) |
| Ramp and glide distances are statistical, not fixed | [code/bank00/ramp-launchers.md](code/bank00/ramp-launchers.md), [code/bank00/slider-glide-system.md](code/bank00/slider-glide-system.md) | [B](mesen2-b-series-summary.md) |
| `NorthProbeRedirect` runs but its pair is dead | [code/bank02/player-movement.md](code/bank02/player-movement.md) | [R](mesen2-r-series-summary.md) |
| `$7F:0000`–`$01FF` is collision data; `$7F0E00` / `$7F3000` hold the thinker pages | [code/bank03/actor-thinker-runtime.md](code/bank03/actor-thinker-runtime.md) | [W1](mesen2-w1-series-summary.md) |

### 2.6 Camera

| Fact | Document | Summary |
|------|----------|---------|
| The camera target is the player Y minus `$80`; the sprite draws above the actor point | [code/bank02/camera-scrolling.md](code/bank02/camera-scrolling.md) | [P + S](mesen2-p-s-series-summary.md) |
| Camera shake and patterned drift add offsets after the controller store and do not accumulate | [code/bank00/functions-camera-motion.md](code/bank00/functions-camera-motion.md) | [P + S](mesen2-p-s-series-summary.md) |
| Packed parallax ratios give the same multiplier on both axes | [code/bank00/camera-scroll-system.md](code/bank00/camera-scroll-system.md) | [P + S](mesen2-p-s-series-summary.md) |
| The forced scroll override and its writers; only the first 8 words of `camera_drift_offsets` are live | [code/bank00/camera-scroll-system.md](code/bank00/camera-scroll-system.md), [code/bank00/data-tables-memory.md](code/bank00/data-tables-memory.md) | [W1](mesen2-w1-series-summary.md), [R](mesen2-r-series-summary.md) |

### 2.7 Display, NMI, HDMA, palette, Mode 7

| Fact | Document | Summary |
|------|----------|---------|
| `displayModeFlags` bit table: bit 14 hides the HUD, bit 0 requests a full BG3 upload, bits 4 and 5 the partial one; bit 5 has no setter; bit 13 is read only by the Mu bomb countdown | [wram-memory-map.md](wram-memory-map.md#display-mode-flags-reference-09ec) | [C](mesen2-c-series-summary.md), [V](mesen2-v-series-summary.md) |
| Adhoc VRAM DMA from an actor is safe; elsewhere store the size before the destination | [code/bank00/nmi-handler.md](code/bank00/nmi-handler.md) | [C](mesen2-c-series-summary.md) |
| NMITIMEN `$01` is not "NMI on"; wait for VBlank by polling RDNMI | [code/bank02/hardware-and-init.md](code/bank02/hardware-and-init.md) | [C](mesen2-c-series-summary.md) |
| Hooks before frame 84 run SlowROM | [code/bank00/system-core.md](code/bank00/system-core.md) | [C](mesen2-c-series-summary.md) |
| Backdrop ramps are bundle-driven tagged triplets; the palette step does not decompress bundles | [code/bank00/thinkers-palette.md](code/bank00/thinkers-palette.md) | [E](mesen2-e-series-summary.md) |
| Mode 7 HDMA tables are filled once; `M7SEL` `$80` makes the area outside the plane transparent (backdrop), not a tile-0 fill | [code/bank03/mode7-and-cutscenes.md](code/bank03/mode7-and-cutscenes.md) | [E](mesen2-e-series-summary.md), [V](mesen2-v-series-summary.md) |
| HDMA channels 1–5 are saturated; channel setup and sine thinkers | [code/bank03/scene-and-hardware.md](code/bank03/scene-and-hardware.md), [code/bank00/thinkers-hdma.md](code/bank00/thinkers-hdma.md) | [E](mesen2-e-series-summary.md) |
| `SceneCmd_LoadBgTiles` mode 3 is unreachable | [code/bank02/scene-script.md](code/bank02/scene-script.md) | [R](mesen2-r-series-summary.md) |

### 2.8 Sprites and animation

| Fact | Document | Summary |
|------|----------|---------|
| Reset the tick counter when forcing an animation frame | [code/bank03/sprite-rendering.md](code/bank03/sprite-rendering.md) | [F](mesen2-f-series-summary.md) |
| Body row 4 frame `$20` is a form-neutral lying hold pose | [code/bank00/actors-player-rewards.md](code/bank00/actors-player-rewards.md) | [F](mesen2-f-series-summary.md) |
| Sprite-set and sprite-group headers, embedded groups and the `$4B` index are real data | [structs-reference.md](structs-reference.md#sprite-set--sprite-group--sprite-part) | [F](mesen2-f-series-summary.md) |
| The facing tables selected by `$0AC8 − 4`; row 8 reads WRAM `$0100 + frame` | [code/bank03/field-input-and-items.md](code/bank03/field-input-and-items.md) | [P + S](mesen2-p-s-series-summary.md), [W1](mesen2-w1-series-summary.md) |
| Event flag `#00` switches the idle family; idle `*Flagged` handlers | [code/bank02/player-character.md](code/bank02/player-character.md), [cop/families/player_sprite.md](cop/families/player_sprite.md) | [W1](mesen2-w1-series-summary.md) |
| Depth-sort buckets must be cleared after decompress | [code/bank03/sprite-rendering.md](code/bank03/sprite-rendering.md) | [W1](mesen2-w1-series-summary.md) |

### 2.9 Scenes, flags and save

| Fact | Document | Summary |
|------|----------|---------|
| Scene scratch `$0A00`–`$0A01` is zeroed on every load; the inventory snapshots it; flag `$FF` is a setup latch | [wram-memory-map.md](wram-memory-map.md), [code/bank02/scene-script.md](code/bank02/scene-script.md) | [FR](mesen2-fr-series-summary.md) |
| Arrival is cutscene-gated, not flag-gated; the scene `$0A` lock is timed | [flags/README.md](flags/README.md), [flags/system.md](flags/system.md) | [FR](mesen2-fr-series-summary.md) |
| Edward Castle statues are solid push blocks in both flag states | [flags/edward_castle.md](flags/edward_castle.md) | [FR](mesen2-fr-series-summary.md) |
| Checkpoint presets are approximate | [flags/README.md](flags/README.md) | [FR](mesen2-fr-series-summary.md) |
| Save and revive warp pointers `$0AF0`–`$0AF6`; 23 save warps | [wram-memory-map.md](wram-memory-map.md), [code/bank02/game-systems.md](code/bank02/game-systems.md) | [R](mesen2-r-series-summary.md) |
| 25 `sceneNext` ids are bogus | [code/bank0D-scene-meta.md](code/bank0D-scene-meta.md) | [R](mesen2-r-series-summary.md) |
### 2.10 Title, menus, maps, text

| Fact | Document | Summary |
|------|----------|---------|
| The boot logos spell "Nintendo PRESENTS" and ENIX "PRODUCTION"; the title Earth is not a comet | [code/bank0B-late-bosses-system-cutscene-actors.md](code/bank0B-late-bosses-system-cutscene-actors.md) | [M + N](mesen2-m-n-series-summary.md) |
| Max HP never displays above `$28` | [code/bank02/inventory-menu.md](code/bank02/inventory-menu.md) | [M + N](mesen2-m-n-series-summary.md), [V](mesen2-v-series-summary.md) |
| The world-map Start toggles the overlay; the town Start opens PAUSE, not the radar | [code/bank03/radar-and-world-map.md](code/bank03/radar-and-world-map.md) | [M + N](mesen2-m-n-series-summary.md) |
| `PrintNumber` count 5 prints leading zeros after the first digit; font tile `$20` is a period | [code/bank03/text-and-menus.md](code/bank03/text-and-menus.md) | [M + N](mesen2-m-n-series-summary.md) |
| The scene title box interior is 20 tiles | [code/bank02/game-systems.md](code/bank02/game-systems.md) | [M + N](mesen2-m-n-series-summary.md) |

### 2.11 Audio

| Fact | Document | Summary |
|------|----------|---------|
| The sound word goes out on even frames, one per two frames; a second write to the same half replaces the first | [cop/families/audio.md](cop/families/audio.md), [code/bank00/nmi-handler.md](code/bank00/nmi-handler.md) | [D](mesen2-d-series-summary.md) |
| `$06F2` is the BGM id of the scene music record, not the track in use | [wram-memory-map.md](wram-memory-map.md), [code/bank02/spc-transfer.md](code/bank02/spc-transfer.md) | [D](mesen2-d-series-summary.md), [V](mesen2-v-series-summary.md) |
| `FadeThenStartMusic` fades for about 340 frames; `$F2` keys off and is not a mute; `$F0` stops | [audio/spc-engine.md](audio/spc-engine.md), [cop/families/audio.md](cop/families/audio.md) | [D](mesen2-d-series-summary.md) |
| A song stream must keep its terminator word | [audio/spc-engine.md](audio/spc-engine.md) | [D](mesen2-d-series-summary.md) |

---

## 3. Claim confirmation rules (CL-01 to CL-12)

Source for every row: the V1 result file `V1_20261110.md` and the V rows of `closures.md`. Summary: [mesen2-v-series-summary.md](mesen2-v-series-summary.md).

| Id | Rule | Tag | Document |
|----|------|-----|----------|
| CL-01 | `WaitByte #n` resumes after n + 1 passes of the owning runner. A wait is not a fixed time: `#B3` on the title is 180 passes and 313 NMI frames | VERIFIED-RUNTIME; CONTRADICTED ("~3 sec") | [cop-commands-reference.md](cop-commands-reference.md) |
| CL-02 | Positive `iframeCounter` freezes a victim (+17; 60 for the player), negative recovers (−12 / −17; −30 for the player) | VERIFIED-RUNTIME | [code/bank02/player-character.md](code/bank02/player-character.md) |
| CL-03 | `$10` bit `$0200` makes the actor not hittable | VERIFIED-RUNTIME | [wram-memory-map.md](wram-memory-map.md#actor-flag-bits-flags10--flags12-verified-with-mesen2) |
| CL-04 | `$10` bit `$2000` removes the actor from the depth sort | VERIFIED-RUNTIME | [wram-memory-map.md](wram-memory-map.md#actor-flag-bits-flags10--flags12-verified-with-mesen2) |
| CL-05 | `displayModeFlags` bit 14 = HUD off; bit 0 = full BG3 upload; bits 4 and 5 = partial upload; bit 5 has no setter | VERIFIED-RUNTIME | [wram-memory-map.md](wram-memory-map.md#display-mode-flags-reference-09ec) |
| CL-06 | This build: physical A → `$8080`, physical B → `$4008`; interact is `$8000`, not `$0080` | CONTRADICTED (plan wording) | [wram-memory-map.md](wram-memory-map.md#29-input-remapping-0da00dc0) |
| CL-07 | The jeweler's "Strength" page raises max HP (8 → 9), not Strength | VERIFIED-RUNTIME | [code/bank08-native-dao-pyramid-actors.md](code/bank08-native-dao-pyramid-actors.md) |
| CL-08 | Revive costs exactly 100 gems; 0 gems gives no revive; 99 gems is static only | VERIFIED-RUNTIME | [code/bank00/functions-game-over.md](code/bank00/functions-game-over.md) |
| CL-09 | Player hit stagger is 16 ticks after the hit tick (17 with it); 60 without a stagger child | VERIFIED-RUNTIME | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) |
| CL-10 | World-map `M7SEL` is `$80`; outside the plane it shows the backdrop, not a tile-0 fill | VERIFIED-RUNTIME | [code/bank03/mode7-and-cutscenes.md](code/bank03/mode7-and-cutscenes.md) |
| CL-11 | Stat-up `$55` is a reset at signed overflow, not a cap; the max-HP display clamp is `$28` | VERIFIED-RUNTIME | [code/bank00/actors-combat-interaction.md](code/bank00/actors-combat-interaction.md) |
| CL-12 | `$06F2` is the BGM id stored by `SpcMusicLoadCmd`, not an actor slot, and not always the track in use (`StartMusic` and `FadeThenStartMusic` never update it) | VERIFIED-RUNTIME; CONTRADICTED ("current music index") | [wram-memory-map.md](wram-memory-map.md), [code/bank02/spc-transfer.md](code/bank02/spc-transfer.md) |

---

## 4. Hazards that hold across the series

- Where a hand-written document disagrees with a summary row, the summary row and its evidence tag win. The Y and B lines of `code/bank03/field-input-and-items.md` predate the P series.
- DP `$80`–`$82` is the collision tile map pointer. Save and restore engine low DP around any overlay code that uses scratch there.
- X must equal the actor slot before every COP instruction; save and restore it around loops and scratch code.
- Name the build (this build or the vanilla ROM) with every button mask.
- A measurement that used a poke, a warp or a forced bit carries its tag (VERIFIED-RUNTIME with the poke disclosed, or SIMULATED); do not treat the poked path as the only natural route.
