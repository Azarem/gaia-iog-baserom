# COP family: Map transition

_Deep-audited ops: `[26]`, `[65]`, `[66]`, `[67]`_

[← COP index](../index.md)

## Overview

Queue field scene changes and stage world-map cursor / party metadata consumed by the overworld engine. `[26]` writes the global scene-transition packet; `[65]`–`[67]` fill `$0D52`–`$0D5E` before a map change or world-map UI flow runs.

## Shared state

| Symbol | Role |
|--------|------|
| `$0642` (`sceneNext`) | Destination scene ID |
| `$064C`–`$0652` | Spawn X/Y, flags, extra word |
| `$0AF0`–`$0AF6` (`sceneSaveData`) | Saved script PC/bank when flag bit 7 set |
| `$0D52` / `$0D56` | World-map destination X/Y |
| `$0D58` | World-map choice ID |
| `$0D5A` / `$0D5E` | Companion / area move IDs |

## Family notes

- `[26]` flag byte bit **7** (`$80`): save rewind PC (8 bytes before end of operands) into `$0AF0+` for resume after load — bit cleared in `$0650` after capture.
- World-map staging ops **do not** change scenes by themselves; they pair with `[26]`, world-map controller scripts, or boot/title flows.
- Debug warp menu (`actors/debug_man.asm`) is a concentrated source of `[26]` call sites.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `26` | `QueueMapChange` | 138 | Byte map, Word X, Word Y, Byte flags, Word extra | `QueueMapChange` | Continue |
| `65` | `StageWorldMapMove` | 13 | Word X, Word Y, Byte area, Byte companion | `StageWorldMapMove` | Continue |
| `66` | `StageWorldMapChoice` | 27 | Word X, Word Y, Byte choiceId | `StageWorldMapChoice` | Continue |
| `67` | `StageWorldMapMoveIds` | 24 | Byte area, Byte companion | `StageWorldMapMoveIds` | Continue |

**Family call-site total:** 202

## Opcodes

#### COP [26] — `QueueMapChange`

- **Handler:** `QueueMapChange` @ `extracted/system/engine/cop_handlers_spatial.asm`
- **Parameters:** `Byte` scene, `Word` pos X, `Word` pos Y, `Byte` dirAndSave flags, `Word` cam/extra

##### What it does

Writes operands into `$0642`, `$064C`–`$0652`. If flags bit 7 set: rewind `$0A` by 8, store PC at `$0AF0`/`$0AF4`, bank at `$0AF2`/`$0AF6`, clear bit 7 in stored flags. RTI — actual warp handled by engine main loop reading staging fields.

```asm
QueueMapChange {
    ; store sceneNext, spawn X/Y, flags, extra
    BIT #$0080 on $0650 → save PC/bank to sceneSaveData
    RTI
}
```

##### How it is used

**Overworld exits**, prologue/title, cutscene hard cuts, debug warps:

```asm
; actors/debug_man.asm
COP [QueueMapChange] ( #82, #$0020, #$0090, #07, #$1800 )

; babel_tower/comet_lair/sE8_dark_gaia.asm
COP [QueueMapChange] ( #E5, #$0000, #$0000, #00, #$1100 )
```

`overworld_exit.asm` and `[45]` rectangles often precede handlers that emit `[26]`.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Positions | **Pixel** spawn coordinates |
| Flag `$80` | Save script return for post-transition resume |
| Source examples | `debug_man.asm:145+`, `overworld_exit.asm`, `sFC_title_start_handler.asm` |

---

#### COP [65] — `StageWorldMapMove`

- **Handler:** `StageWorldMapMove` @ `extracted/system/engine/cop_handlers_input.asm`
- **Parameters:** `Word` dest X, `Word` dest Y, `Byte` area/scene id, `Byte` companion id

##### What it does

Stores X→`$0D52`, Y→`$0D56`, area→`$0D5E`, companion→`$0D5A`, clears `$0D58` (no choice menu). RTI.

##### How it is used

Full world-map relocation staging before `[26]` or world-map animation — e.g. flying to a new continent with party layout preset (13 sites).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Typical sequence | `[65]` … then `[26]` or world-map driver |
| Source examples | `WorldMapController.asm`, cutscene travel spirits |

---

#### COP [66] — `StageWorldMapChoice`

- **Handler:** `StageWorldMapChoice` @ `cop_handlers_input.asm`
- **Parameters:** `Word` X, `Word` Y, `Byte` choiceId → `$0D58`

##### What it does

Same coordinate staging as `[65]` but sets **choice** id instead of clearing it — used when the world-map UI presents branch text (27 sites, heavily in `world_map_options.asm`).

##### Parameters & return contract

| Item | Value |
|------|-------|
| `$0D58` | Indexes choice text / handler tables |
| Source examples | `system/world_map/world_map_options.asm` |

---

#### COP [67] — `StageWorldMapMoveIds`

- **Handler:** `StageWorldMapMoveIds` @ `cop_handlers_input.asm`
- **Parameters:** `Byte` area id, `Byte` companion id

##### What it does

Updates only `$0D5E` and `$0D5A` — **no** coordinate rewrite. Used when the cursor is already positioned on the world map (24 sites in `world_map_options.asm` companion/party toggles).

```asm
; system/world_map/world_map_options.asm
COP [StageWorldMapMoveIds] ( #00, #02 )
COP [StageWorldMapMoveIds] ( #00, #01 )
```

##### Parameters & return contract

| Item | Value |
|------|-------|
| Use when | On world map; only IDs change |
| Source examples | `world_map_options.asm` (party member select rows) |
