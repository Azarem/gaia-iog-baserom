# Bank $00 — Functions: Game Over & Death Sequence

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B5B3`, `$00D62F`–`$00D796`, `$00F3B3`  
**Source files:** [`extracted/functions/game_over_sequence.asm`](../../../extracted/functions/game_over_sequence.asm) (contains `GameOverSequence`, `GameOverCutsceneSprites`, `DeathWakeupMessage`), [`DeathPaletteFadeThinker.asm`](../../../extracted/functions/DeathPaletteFadeThinker.asm), [`StopPlayerOnDeath.asm`](../../../extracted/functions/StopPlayerOnDeath.asm)  
**Block:** `game_over_sequence` + standalone utilities

These functions implement the full player death flow: halting movement, fading the palette, reloading the saved scene, displaying post-death cutscene sprites, and presenting the character-specific wake-up monologue.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (`ApplyPlayerHitstun` precedes death) · [`README.md`](README.md)

---

## Sequence Overview

```
Player HP → 0
    └─► StopPlayerOnDeath ($F3B3)     [JSL — zeros speed/wait; sets actor $10 bit $0200]
            └─► GameOverSequence ($D62F)    [$& pointer from ComposeDigitSprites_AtCursor]
                    ├─► Fade screen / palette teardown
                    ├─► COP [SpawnThinker] @DeathPaletteFadeThinker ($B5B3)
                    ├─► Reload saved scene ($0AF0/$0AF2 save point on a real game over, $0AF4/$0AF6 last warp on a revive)
                    ├─► COP [SpawnAfter] @GameOverCutsceneSprites ($D718)
                    └─► (later) DeathWakeupMessage ($D796) via player_character.asm
```

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `StopPlayerOnDeath` | `$F3B3` | 22 B | ✓ | JSL | Medium |
| `GameOverSequence` | `$D62F` | 233 B | **No** | `$&` pointer assignment | **High** |
| `DeathPaletteFadeThinker` | `$B5B3` | 13 B | ✓ | COP `SpawnThinker` | Medium |
| `GameOverCutsceneSprites` | `$D718` | 126 B | ✓ | COP `SpawnAfter` | Medium |
| `DeathWakeupMessage` | `$D796` | 225 B | ✓ | COP `SpawnAfterFlags` | Medium |

---

## StopPlayerOnDeath

**Address:** `$F3B3` · **Size:** 22 bytes

### Description

Helper called from `CheckPlayerDeath` after **`playerFlags` bit 9 (`$0200`)** is already set (game over) and the player actor entry point is repointed to `GameOverSequence`. Zeros `playerSpeedEw` / `playerSpeedNs` (`$09B2` / `$09B4`), zeros the actor wait counter (`$0008`), and ORs **`$0200` into the player actor's `$10` flags** — a different word from `playerFlags`. Does not run the fade/reload sequence (`GameOverSequence` owns that via the entry-point chain).

### Algorithm

```
1. LDY player actor address (from caller)
2. STZ playerSpeedEw / playerSpeedNs
3. STZ $0008,Y  ; wait counter — so GameOverSequence runs next tick
4. ORA #$0200 into $0010,Y
5. RTL
```

### Variables

| Symbol | Role |
|--------|------|
| `playerSpeedEw` / `playerSpeedNs` | Movement speeds (zeroed) |
| `$0008,Y` | Actor wait counter (zeroed) |
| `$0010,Y` bit `$0200` | Actor flag bit (set here; not the `playerFlags` game-over bit) |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Precedes | `GameOverSequence` | Death callback chain |

---

## GameOverSequence

**Address:** `$D62F` · **Size:** 233 bytes · **Movable:** No (inbound `$&GameOverSequence` from `ComposeDigitSprites_AtCursor`)

### Description

Full player death flow executed after `StopPlayerOnDeath`. Assigned as the player OnDeath callback via `SetOnDeath` COP in `ComposeDigitSprites_AtCursor` (`#$&GameOverSequence`). Handles screen fade, palette teardown, scene state restoration, and spawning of post-death visual elements.

The sequence saves and restores scene persistence data from `$0AF0`–`$0AF8` (last visited scene, player position, party state) so the player respawns at the most recent save point rather than the death location.

### Algorithm

```
1. Mask all joypad input ($FFFF → $joypad_mask_std)
2. Zero player velocity / animation state
3. COP [FadeScreen] — begin death fade to black
4. COP [SpawnThinker] @DeathPaletteFadeThinker ($B5B3)
5. Wait for fade completion
6. Restore scene state from $0AF0–$0AF8:
     - $0AF0: saved scene index
     - $0AF2: saved X position
     - $0AF4: saved Y position
     - $0AF6–$0AF8: party / form state
7. Trigger scene reload via scene script engine
8. COP [SpawnAfter] @GameOverCutsceneSprites ($D718)
9. RestoreSavedPtr / SetEntryHere for wake-up phase
```

### Variables

| Symbol | Role |
|--------|------|
| `$0AF0` | Saved scene index (respawn target) |
| `$0AF2` | Saved player X position |
| `$0AF4` | Saved player Y position |
| `$0AF6`–`$0AF8` | Saved party/form state |
| `$joypad_mask_std` | Joypad input mask (blocked during sequence) |
| `$player_flags` | Cleared/set for respawn state |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Assigned by | `ComposeDigitSprites_AtCursor` | Player OnDeath: `#$&GameOverSequence` |
| Spawns | `DeathPaletteFadeThinker` | `COP [SpawnThinker]` |
| Spawns | `GameOverCutsceneSprites` | `COP [SpawnAfter]` |
| Followed by | `DeathWakeupMessage` | Spawned from `player_character.asm` |

---

## DeathPaletteFadeThinker

**Address:** `$B5B3` · **Size:** 13 bytes

### Description

Death palette fade thinker spawned by `GameOverSequence` via `COP [SpawnThinker]`. Each frame it decrements the global palette brightness via `COP [PaletteStep]` until the screen reaches black, then kills itself with `COP [KillThinker]`. Provides the gradual desaturation effect during the death transition rather than an instant cut to black.

Self-contained with no `?INCLUDE` dependencies — can be relocated independently of the game-over sequence block.

### Algorithm

```
1. COP [PaletteStep] — decrement brightness one step
2. If palette not fully faded: RTL (continue next frame)
3. COP [KillThinker]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `GameOverSequence` | `COP [SpawnThinker]` |

---

## GameOverCutsceneSprites

**Address:** `$D718` · **Size:** 126 bytes

### Description

Post-death visual sequence displaying three marked sprite actors around the respawned player. Spawns child actors with the `$2000` marked flag (linked to parent) that perform a brief awakening animation — typically showing Will/Freedan/Shadow rising or the party gathering at the save point.

Uses `COP [SpawnAfter]` to create the child sprites relative to the player's position, with staggered timing for a layered visual effect. The sprites are cosmetic only and do not affect gameplay state.

### Algorithm

```
1. Read player position ($14/$16)
2. COP [SpawnAfter] child sprite 1 — offset (-16, -8), marked flag
3. Wait frames
4. COP [SpawnAfter] child sprite 2 — offset (+16, -8), marked flag
5. Wait frames
6. COP [SpawnAfter] child sprite 3 — offset (0, -16), marked flag
7. Animate children (COP [AnimOnce] each)
8. COP [Die] or SetEntryHere for message phase
```

### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Player respawn position |
| `$12` bit `$2000` | Marked child flag on spawned sprites |
| `$7F001C,X` | Parent actor link for marked children |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `GameOverSequence` | `COP [SpawnAfter]` |
| Precedes | `DeathWakeupMessage` | Visual then text phase |

---

## DeathWakeupMessage

**Address:** `$D796` · **Size:** 225 bytes

### Description

Post-death wake-up monologue displayed after the player respawns at the save point. Branches on `$0AD4` (current character/form index) to select character-specific text from three embedded dialogstring parts:

| `$0AD4` | Character | Text Theme |
|---------|-----------|------------|
| `0` | Will | Will's reflection on failure |
| `1` | Freedan | Freedan's warrior perspective |
| `2` | Shadow | Shadow's cryptic commentary |

Spawned from `player_character.asm` via `COP [SpawnAfterFlags]` after the cutscene sprites complete. Uses `COP [SwitchCase]` on `$0AD4` to dispatch to the correct dialogstring, then `COP [PrintDialogString]` for display. After the message, restores normal player control and clears death flags.

### Algorithm

```
1. COP [SwitchCase] $0AD4:
     0 → PrintDialogString dialogstring_will
     1 → PrintDialogString dialogstring_freedan
     2 → PrintDialogString dialogstring_shadow
2. Wait for text advance (button press)
3. Clear $10 bit $0200 (death flag)
4. RestoreSavedPtr → normal player script
5. Unmask joypad ($CFF0 TRB $joypad_mask_std)
6. COP [Die]
```

### Variables

| Symbol | Role |
|--------|------|
| `$0AD4` | Current body index (0=Will, 1=Freedan, 2=Shadow) |
| `$10` bit `$0200` | Death flag (cleared on wake-up) |
| `$joypad_mask_std` | Restored after message |
| Embedded dialogstrings | 3 character-specific death monologues |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned from | `player_character.asm` | `COP [SpawnAfterFlags]` |
| Follows | `GameOverCutsceneSprites` | Text after visual |
| Character index | `$0AD4` | Same as body swap / palette dispatch |

---

## Call Reference Matrix

### Internal Flow

| Step | Caller | Callee | Mechanism |
|------|--------|--------|-----------|
| 1 | Combat / HP check | `StopPlayerOnDeath` | JSL |
| 2 | Death callback | `GameOverSequence` | `$&GameOverSequence` pointer |
| 3 | `GameOverSequence` | `DeathPaletteFadeThinker` | COP `SpawnThinker` |
| 4 | `GameOverSequence` | `GameOverCutsceneSprites` | COP `SpawnAfter` |
| 5 | `player_character.asm` | `DeathWakeupMessage` | COP `SpawnAfterFlags` |

### External Dependencies

| Target | Bank | Purpose |
|--------|------|---------|
| `ComposeDigitSprites_AtCursor` | `$03` | Death callback pointer assignment |
| Scene script engine | `$02`/`$03` | Scene reload from save data |
| `$0AF0`–`$0AF8` | `$00` WRAM | Save/restore scene state |

---

## Statistics

| Metric | Value |
|--------|-------|
| Functions documented | 5 |
| Total span | `$B5B3`–`$B5C0` + `$D62F`–`$D877` + `$F3B3`–`$F3C9` |
| Combined game-over block size | 584 bytes (`$D62F`–`$D877`) |
| Immovable entries | 1 (`GameOverSequence`) |
| Character-specific text variants | 3 (Will / Freedan / Shadow) |

---

*Source: `extracted/functions/game_over_sequence.asm`, `extracted/functions/DeathPaletteFadeThinker.asm`, `extracted/functions/StopPlayerOnDeath.asm`.*
