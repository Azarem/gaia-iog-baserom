# Bank $00 — Functions: Game Over & Death Sequence

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B5B3`, `$00D62F`–`$00D877`, `$00F3B3`  
**Source files:** [`extracted/functions/game_over_sequence.asm`](../../../extracted/functions/game_over_sequence.asm), [`DeathPaletteFadeThinker.asm`](../../../extracted/functions/DeathPaletteFadeThinker.asm), [`StopPlayerOnDeath.asm`](../../../extracted/functions/StopPlayerOnDeath.asm), [`extracted/system/engine/combat_collision.asm`](../../../extracted/system/engine/combat_collision.asm) (`CheckPlayerDeath`), [`extracted/actors/player/player_character.asm`](../../../extracted/actors/player/player_character.asm), [`extracted/system/engine/warps_interaction.asm`](../../../extracted/system/engine/warps_interaction.asm) (`ExecuteWarp` record writes)

These routines implement the player death flow: halt movement, death presentation (palette bundles, sparkles, brightness fade), revive vs. real game-over respawn selection, scene transition from a warp record, and the post-respawn wake-up dialog.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (`ApplyPlayerHitstun` precedes lethal HP) · [`README.md`](README.md)

## Source of truth

| Topic | `extracted/...` |
|--------|------------------|
| Death sequence + cutscene actors | `functions/game_over_sequence.asm` |
| Palette bundle thinker | `functions/DeathPaletteFadeThinker.asm` |
| Movement halt helper | `functions/StopPlayerOnDeath.asm` |
| Entry-point assignment | `system/engine/combat_collision.asm` (`CheckPlayerDeath`) |
| Wake-up spawn | `actors/player/player_character.asm` (player init) |
| Warp record pointers | `system/engine/warps_interaction.asm`, `tables/scene_warps.asm` |

**Naming:** All labels in the table above are extracted symbols. `SetPlayerGameOverFlag` (boss-defeat hit immunity) is a **different** routine in `functions/SetPlayerGameOverFlag.asm` — not part of this death pipeline.

**Counts:** `CheckPlayerDeath` → `StopPlayerOnDeath`: **1** JSL call site. `GameOverSequence` assignment: **1** site (`CheckPlayerDeath` writes `$0000`/`$0002` on the player actor). `DeathWakeupMessage` spawn: **1** COP site (`player_character` init). Post-death sparkle children: **3** `SpawnAfterOffsetMarked` sites in `GameOverCutsceneSprites`.

---

## State transition (runtime)

```text
playerHp == 0  (and playerFlags: not $0020 boss latch, not $0200 already active)
    │
    ▼
CheckPlayerDeath (combat_collision, each frame after collision)
    ├─ playerFlags |= $0200  (game over — WRAM $09AE bit 9)
    ├─ player actor $0000/$0002 := GameOverSequence
    └─ JSL StopPlayerOnDeath
            │
            ▼  (next player actor tick)
GameOverSequence  [LIVE — player script entry]
    ├─ player $10 |= $0040  (dead / orb draw path; shadow_shimmer reads this)
    ├─ joypadMaskStd |= $FFFC  (full input mask; see transforms note in asm)
    ├─ wait → SpawnThinker DeathPaletteFadeThinker + SpawnAfter GameOverCutsceneSprites
    ├─ wait → metasprite pickups_effects anim $1C + INIDISP brightness fade (15→0)
    ├─ palette reset thinkers (bundles $0B, $0D)
    └─ GameOverChooseRespawn
            ├─ gemCount >= 100  [REVIVE]
            │     gemCount -= 100; playerHp = playerMaxHp/2
            │     warp record ← reviveWarpPtr / reviveWarpBank ($0AF4 / $0AF6)
            └─ gemCount < 100   [REAL GAME OVER]
                  gemCount := 0; playerHp := playerMaxHp; wramFlags ($0A80–$0A9F) cleared
                  characterForm := 0 (Will), or 2 (Shadow) if sceneCurrent == $E8
                  warp record ← sceneSaveData / sceneSaveDataBank ($0AF0 / $0AF2)
            │
            ▼  (shared tail — both paths)
    Copy warp record → sceneNext, warpDestX/Y, warpFacing, warpScrollParams
    gfxCacheIdxB := $0404; INC gameOverWakeupFlag ($0AF8); worldReadyFlag := 0
    SetEntryHere + RTL  →  scene transition (enter only; screen already black)

Next scene — PlayerCharacter init  [LIVE]
    └─ if gameOverWakeupFlag != 0 → SpawnAfterFlags DeathWakeupMessage ($2000)

DeathWakeupMessage  [LIVE — cutscene script only; cosmetic text]
    mask joypad ($CFFC); clear gameOverWakeupFlag; PrintDialogString by characterForm; Die
```

Parts marked **cutscene script only** (`GameOverCutsceneSprites`, `GameOverSparkleOrbitA/B`, `DeathWakeupMessage`) do not choose the respawn target; they only affect presentation after `GameOverSequence` has already queued the warp transition.

---

## WRAM fields: game over vs. revive

| Address | Symbol | Written by | Real game over (< 100 gems) | Revive (≥ 100 gems) | Wake-up message |
|---------|--------|------------|------------------------------|---------------------|-----------------|
| `$0ACE` | `playerHp` | Both paths | `:= playerMaxHp` | `:= playerMaxHp >> 1` | — |
| `$0AD6` | `gemCount` | Both paths | `:= 0` | `-= 100` | — |
| `$0AD4` | `characterForm` | Real death only | `0` or `2` if scene `$E8` | unchanged | selects dialog (0 Will / 1 Freedan / 2 Shadow) |
| `$0A80`–`0A9F` | `wramFlags` | Real death only | 16 words cleared | unchanged | — |
| `$0AF0` / `$0AF2` | `sceneSaveData` / bank | `ExecuteWarp` (save warps) | **record pointer** used for respawn | not used for respawn | — |
| `$0AF4` / `$0AF6` | `reviveWarpPtr` / bank | `ExecuteWarp` (every warp) | not used for respawn | **record pointer** used for respawn | — |
| `$0AF8` | `gameOverWakeupFlag` | `GameOverSequence` tail | incremented | incremented | read/cleared by `DeathWakeupMessage` |
| `$09AE` bit `$0200` | `playerFlags` | `CheckPlayerDeath` | set at death start | same | — |
| `$0642`–`0654` | transition words | `GameOverRespawnTail` | from warp record bytes | same | — |

Warp **records** (not raw X/Y in `$0AF0`–`$0AF6`): pointer at `$0AF0` or `$0AF4` points into `scene_warps` data; `GameOverSequence` reads byte 0 = scene, +1/+3 = spawn X/Y, +5 = facing, +6 = camera window.

---

## Sequence overview (labels)

| Function | Address | Est. size | Movable | Call type | Role |
|----------|---------|-----------|---------|-----------|------|
| `StopPlayerOnDeath` | `$F3B3` | 22 B | ✓ | JSL | Zero speed/wait; actor `$10` \|= `$0200` |
| `GameOverSequence` | `$D62F` | 233 B | **No** | Player entry pointer from `CheckPlayerDeath` | Full death + respawn choice |
| `DeathPaletteFadeThinker` | `$B5B3` | 13 B | ✓ | COP `SpawnThinker` | Bundles `$10` then `$0E` |
| `GameOverCutsceneSprites` | `$D718` | 126 B | ✓ | COP `SpawnAfter` | Sparkle spawner |
| `GameOverSparkleOrbitA` / `B` | (in block) | — | ✓ | COP `SpawnAfterOffsetMarked` | Orbiting sparkle loops |
| `DeathWakeupMessage` | `$D796` | 225 B | ✓ | COP `SpawnAfterFlags` | Post-scene dialog |

---

## StopPlayerOnDeath

**Address:** `$F3B3` · **Size:** 22 bytes · **Live**

### Description

Called once from `CheckPlayerDeath` when `playerHp` is zero. **Y** = player actor address. The caller has already set **`playerFlags` bit 9 (`$0200`)** and replaced the player entry with `GameOverSequence`.

Zeros `playerSpeedEw` / `playerSpeedNs` (`$09B2` / `$09B4`), zeros the actor wait counter `$0008,Y`, and ORs **`$0200` into the player actor's `$0010,Y`** — a different word from `playerFlags`. Does not run fade or scene logic.

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `CheckPlayerDeath` | Sole JSL site |
| Precedes | `GameOverSequence` | Player runs it on the next actor tick |

---

## GameOverSequence

**Address:** `$D62F` · **Size:** 233 bytes · **Movable:** No · **Live**

### Description

Player actor script after death. **Assigned only in `CheckPlayerDeath`** (`#$&game_over_sequence.GameOverSequence` / bank byte into `$0000`/`$0002,Y`). It is **not** assigned from `ComposeDigitSprites_AtCursor` (that file only renders debug digits).

Timeline (from block note + instructions): mask input → palette thinker + cutscene spawner → Dark-Space-style SFX `$0C0C` and metasprite anim `$1C` → **INIDISP** brightness fade using actor extended field `orbitAngle` as counter → palette reset thinkers → **revive vs. real death** → shared warp-record copy → `gameOverWakeupFlag++`, `worldReadyFlag := 0`, scene transition.

### Revive vs. real game over

Both paths share `GameOverRespawnTail` (read warp record at DBR:Y into `sceneNext`, `warpDestX/Y`, `warpFacing`, `warpScrollParams`).

| Branch | Condition | Record source | HP / gems / form / flags |
|--------|-----------|---------------|---------------------------|
| Revive | `gemCount >= $64` | `$0AF4` / `$0AF6` (last warp) | −100 gems; HP = max/2; form unchanged; `wramFlags` unchanged |
| Real game over | `gemCount < $64` | `$0AF0` / `$0AF2` (save-point warps only) | gems 0; full HP; form Will (Shadow if current scene `$E8`); clear `$0A80`–`0A9F` |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Assigned by | `CheckPlayerDeath` | Player `$0000`/`$0002` |
| Spawns | `DeathPaletteFadeThinker`, `GameOverCutsceneSprites` | COP |
| Sets | `gameOverWakeupFlag` | Consumed in next scene by `player_character` |

---

## DeathPaletteFadeThinker

**Address:** `$B5B3` · **Size:** 13 bytes · **Live**

### Description

One-shot thinker: `PaletteStart` bundle **`$10`**, `PaletteStep` until complete; then bundle **`$0E`**, `PaletteStep`; `KillThinker`. This is **not** the same mechanism as the **INIDISP** brightness loop inside `GameOverSequence` (those run in parallel during the death beat).

---

## GameOverCutsceneSprites and sparkle actors

**Address:** `$D718` · **Live**

### Description

Invisible spawner at the player: `SetMetasprite` `spriteset_pickups_effects`, palette `$00`, then three **`SpawnAfterOffsetMarked`** children:

| Delay (WaitByte) | Target | Offset from player | Flags |
|------------------|--------|------------------|-------|
| `#0B` then `#02` | `GameOverSparkleOrbitA` | (−25, −40) | `$0700` |
| `#02` | `GameOverSparkleOrbitB` | (+25, −24) | `$0700` |
| `#04` | `GameOverSparkleOrbitA` | (−25, −8) | `$0700` |

Waits `#62` (99 ticks), then `Die` (marked children end with it).

`GameOverSparkleOrbitA` / `B` loop **`StageSpriteMoveXY`** with animation **`$15`** and move-chain ramps `$2D`–`$30`, toggling actor `$10` bits **`$0001`** (draw behind) and **`$0002`** (draw in front) for a back/front orbit effect. Cosmetic only.

---

## DeathWakeupMessage

**Address:** `$D796` · **Live** (spawn); **cutscene-only** effect

### Description

Spawned from **`player_character` init** when **`gameOverWakeupFlag` (`$0AF8`)** is nonzero — after **both** revive and real game over. Not chained directly from `GameOverCutsceneSprites`.

Uses **`characterForm` (`$0AD4`)**: 0 → Will string; 1 → Freedan; 2 → Shadow (Freedan and Shadow share the same line text in ROM). Masks joypad with **`$CFFC`** (Select/Start stay live), clears **`gameOverWakeupFlag`**, waits, prints, unmasks with **`$CFFC` TRB**, `Die`.

After a **real** game over, form is forced to Will (or Shadow in scene `$E8`), so the **Freedan** line appears only when the player **revived** while still Freedan (`characterForm == 1`).

Does **not** clear `playerFlags` `$0200` or actor `$10` death bits; those are handled elsewhere in the death/respawn pipeline.

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned from | `player_character.asm` | `SpawnAfterFlags` `@game_over_sequence.DeathWakeupMessage` |
| Index | `characterForm` | `$0AD4`, not a separate “body index” |

---

## Call reference matrix

| Step | Caller | Callee | Mechanism |
|------|--------|--------|-----------|
| 1 | `CheckPlayerDeath` | `StopPlayerOnDeath` | JSL |
| 1 | `CheckPlayerDeath` | `GameOverSequence` | Store player entry `$0000`/`$0002` |
| 2 | Player actor runner | `GameOverSequence` | Saved entry pointer |
| 3 | `GameOverSequence` | `DeathPaletteFadeThinker` | COP `SpawnThinker` |
| 4 | `GameOverSequence` | `GameOverCutsceneSprites` | COP `SpawnAfter` |
| 5 | `player_character` init | `DeathWakeupMessage` | COP `SpawnAfterFlags` if `$0AF8` set |

### External dependencies

| Target | Role |
|--------|------|
| `ExecuteWarp` | Fills `$0AF4`/`$0AF6` every warp; `$0AF0`/`$0AF2` when warp entry byte 9 bit 7 set |
| Scene transition engine | Reads `sceneNext`, `worldReadyFlag`, warp dest words |
| `shadow_shimmer` | Reads player `$10` bit `$0040` set here |

---

## Statistics

| Metric | Value |
|--------|-------|
| Documented entry points | 6 (`GameOverSequence` + 5 helpers/children) |
| Combined block span | `$D62F`–`$D877` (game_over_sequence.asm) |
| Immovable (inbound pointer) | `GameOverSequence` (`CheckPlayerDeath`) |
| Wake-up dialog variants | 3 (`characterForm` 0–2) |

---

## Source validation

**Files checked:** `extracted/functions/game_over_sequence.asm`, `DeathPaletteFadeThinker.asm`, `StopPlayerOnDeath.asm`, `system/engine/combat_collision.asm`, `actors/player/player_character.asm`, `system/engine/warps_interaction.asm` (block notes), `system/engine/oam_digit_compose.asm` (confirmed no `GameOverSequence` reference).

**Verified:** Death entry assignment and JSL in `CheckPlayerDeath`; `$0AF0`–`0AF8` roles and revive vs. real-death branches in `GameOverSequence`; sparkle spawn offsets/timing; `DeathWakeupMessage` spawn condition and `characterForm` dispatch; `DeathPaletteFadeThinker` bundle IDs.

**Notes:** `ComposeDigitSprites_AtCursor` is unrelated to player death (diary debug digits only). `SetPlayerGameOverFlag` sets actor `$10` `$0200` for boss sequences — same bit as `StopPlayerOnDeath` but different purpose. INIDISP fade and palette-bundle thinker run concurrently; doc separates them. Sparkle orbit ramp semantics marked inferred in source block note.
