# COP Instruction Families

Deep-dive documentation for all **209 COP opcodes** organized into **39 families** by shared purpose. Each family document covers the opcodes' parameters, handler disassembly, WRAM usage, and behavioral details derived from the actual `cop_handlers_*.asm` source.

[← Back to COP System Overview](../README.md)

---

## How Families Are Organized

Families are grouped by **shared handler files and purpose**, not by opcode number order. Adjacent opcodes often belong to completely different families (e.g., `$0A` WriteApuIo0 is Audio, but `$0B` MarkSolidHere is Collision Paint). The [COP Overview](../README.md) documents these "false neighbors" in detail.

---

## Family Index

### Hardware & Graphics

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**HDMA / DMA**](hdma_dma.md) | `$00`–`$03` | Generate sine-wave HDMA tables, queue HDMA/DMA transfers, configure HDMA channels |
| [**Sine HDMA**](sine_hdma.md) | `$5F` `$60` `$61` | Initialize and tick sine-based scroll wobble effects on BG layers |
| [**VRAM / Memory**](vram_memory.md) | `$4F` `$50` `$51` `$54` | Ad-hoc VRAM DMA, palette copy, LZ decompression, scratch pointer |
| [**Palette**](palette.md) | `$36`–`$3A` | Start/restart/step/loop palette animation bundles |
| [**Metatile / World Map**](metatile.md) | `$4B`–`$4E` | Draw 2×2 metatiles at absolute/actor position, stream world map tile data |
| [**BG Rearrange**](bg_rearrange.md) | `$32` `$33` `$34` | Queue and apply background layer rearrangements |

### Audio

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Audio (Music + SFX)**](audio.md) | `$04`–`$0A`, `$19` | Start/fade music, play sound effects on APU channels, raw APU I/O writes |

### Collision & Spatial

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Collision Paint**](collision_paint.md) | `$0B`–`$12`, `$42` | Write solid/clear/type collision data at actor position, offsets, or absolute coords |
| [**Collision Branch**](collision_branch.md) | `$13`–`$18`, `$1A`–`$1E`, `$62` | Branch based on collision state — solid probes and type checks in all four cardinal directions |
| [**Proximity / Area**](proximity.md) | `$1F`–`$21`, `$44` `$45` | Grid alignment test, distance checks between actors, rectangular area containment tests |
| [**Position**](position.md) | `$25`, `$46` `$47`, `$BC` | Teleport actor to tile position, copy position between linked actors, nudge by signed delta |
| [**Offscreen**](offscreen.md) | `$27`, `$68` `$69` | Pause while off-camera, branch if offscreen, halt based on global frame counter |

### Movement & Physics

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Movement / Staged**](movement.md) | `$22`, `$43`, `$4A`, `$52` `$53` | Move toward target, snap to grid, staged timed movement with tick advancement |
| [**Force Move**](force_move.md) | `$AA`–`$B1` | Stage forced X/Y movement, set direction bits, apply movement to child actors, reload duration tables |
| [**Gravity**](gravity.md) | `$63` `$64` | Initialize and tick quadratic gravity simulation with ground-level detection |
| [**Spiral / Orbit**](spiral.md) | `$6C` `$6D` | Initialize circular/spiral motion with angle and diameter, advance per frame |
| [**Camera Pan**](camera.md) | `$DC`–`$DF` | Smoothly pan camera in four cardinal directions until settled |

### Player & Actor Queries

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Player Query**](player_query.md) | `$28`–`$31`, `$35`, `$48` `$49` | Branch by player position, distance, facing direction, axis proximity, and active body form |
| [**Player Sprite**](player_sprite.md) | `$8E`–`$98` | Set player sprite directly, stage player body sprites with movement, wall-type animation triggers |
| [**Map Transition**](map_transition.md) | `$26`, `$65`–`$67` | Queue scene/map changes with coordinates, stage world-map moves and branch-point choices |

### Sprite System

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Sprite Staging**](sprite_staging.md) | `$80`–`$87`, `$8D` | Stage sprite frames with optional X/Y movement and loop counts, attach hitboxes |
| [**Sprite Animation**](sprite_anim.md) | `$88`–`$8C` | Load metasprite sets, play animations once or looping, advance single frames, wait for frame |
| [**Sprite State**](sprite_state.md) | `$55` `$56` | Reset sprite index and control word, advance sprite animation one step |
| [**OAM Attributes**](oam_attribs.md) | `$B2`–`$BB` | Set/clear OAM priority, palette index, horizontal/vertical mirror flags |

### Actor Lifecycle

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Actor Spawn**](actor_spawn.md) | `$99`–`$A6` | Spawn actors before/after in linked list — with flags, offsets, absolute coords, death tracking, deferred list append |
| [**Actor Death**](actor_death.md) | `$A7`–`$A9`, `$E0` | Mark dungeon death flag, kill prev/next actor in list, remove self immediately |
| [**Actor Flags**](actor_flags.md) | `$5B` `$5C` `$5D` | Set/clear bits in actor extra-flags word, branch if behind wall overlay |
| [**Linked Actor**](linked_actor.md) | `$6A` | Set the entry pointer for a linked child actor |
| [**Callbacks**](callbacks.md) | `$57`–`$5A`, `$5E` | Register handlers for death, hit, dodge, collision, and custom events |
| [**Thinkers**](thinkers.md) | `$3B`–`$3D` | Spawn background thinker processes (with/without parameter), kill associated thinker |

### Script Flow & State

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Script Control**](script_control.md) | `$C0`–`$CB`, `$E1` `$E2` | Set interact handler, entry points, jumps (near/far/delayed), calls, counted loops, yield, signal |
| [**Scene Flags**](scene_flags.md) | `$CC`–`$D3` | Set/clear/branch/wait on scene progress flags by byte or word index |
| [**Input**](input.md) | `$3E`–`$41` | Wait for button press/release, branch on button state |
| [**Wait**](wait.md) | `$DA` `$DB` | Pause script for a byte-sized or word-sized number of frames |
| [**Dialog**](dialog.md) | `$6B`, `$BD`–`$BF` | Print dialog strings, run BG3 text scripts, present player choice menus |
| [**Inventory**](inventory.md) | `$D4`–`$D7` | Give/remove items, branch if missing item, branch if item equipped |
| [**Dungeon / Switch**](dungeon_switch.md) | `$D8` `$D9` | Set room-clear kill flag, switch-case dispatch via RAM byte and jump table |
| [**RNG**](rng.md) | `$23` `$24` | Generate random byte (0–255) or random value modulo N |

### Other

| Family | Opcodes | Description |
|--------|---------|-------------|
| [**Invalid Ops**](invalid_ops.md) | `$6E`–`$7F`, `$E3` | Garbage jump table entries in the invalid gap — not usable opcodes |

---

## Handler Source Files

All COP handlers are implemented in 30 ASM files under `extracted/system/engine/`:

| Source File | Families |
|-------------|----------|
| `cop_handlers_hdma_dma.asm` | HDMA/DMA |
| `cop_handlers_audio.asm` | Audio |
| `cop_handlers_collision.asm` | Collision Paint, Collision Branch, Proximity |
| `cop_handlers_movement.asm` | Movement, RNG, Proximity |
| `cop_handlers_player_query.asm` | Player Query, Position, Map Transition, Offscreen |
| `cop_handlers_actor_query.asm` | Player Query, Proximity, Position |
| `cop_handlers_bg_rearrange.asm` | BG Rearrange |
| `cop_handlers_palette.asm` | Palette |
| `cop_handlers_thinker.asm` | Thinkers |
| `cop_handlers_input.asm` | Input |
| `cop_handlers_metatile.asm` | Metatile |
| `cop_handlers_vram.asm` | VRAM/Memory |
| `cop_handlers_sprite.asm` | Sprite Staging, Sprite Animation, Sprite State |
| `cop_handlers_callbacks.asm` | Callbacks, Actor Flags |
| `cop_handlers_actor_flags.asm` | Actor Flags, Collision Branch |
| `cop_handlers_effects.asm` | Sine HDMA, Gravity, Spiral, Camera |
| `cop_handlers_world_map.asm` | Map Transition |
| `cop_handlers_offscreen.asm` | Offscreen |
| `cop_handlers_linked_actor.asm` | Linked Actor |
| `cop_handlers_player_sprite.asm` | Player Sprite |
| `cop_handlers_spawn.asm` | Actor Spawn |
| `cop_handlers_actor_death.asm` | Actor Death |
| `cop_handlers_force_move.asm` | Force Move |
| `cop_handlers_oam_attribs.asm` | OAM Attributes |
| `cop_handlers_dialog.asm` | Dialog |
| `cop_handlers_script_control.asm` | Script Control |
| `cop_handlers_scene_flags.asm` | Scene Flags |
| `cop_handlers_inventory.asm` | Inventory |
| `cop_handlers_dungeon_switch.asm` | Dungeon/Switch |
| `cop_handlers_wait.asm` | Wait |

---

## Related

- [COP System Overview](../README.md) — Dispatch architecture, full opcode roster, common script idioms
- [COP Dispatch Engine](../../code/bank00/cop-dispatch.md) — Bank $00 dispatch implementation details
- [Code Bank Documentation](../../code/) — Full ROM bank analysis
