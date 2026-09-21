# Unused Mode 7 Boss — Full Analysis & Patch Comparison

## Overview

The file `extracted/unused/unused_mode7_boss.asm` contains the **largest unused code block in the IOG ROM** — approximately 1,900 lines of 65C816 assembly at ROM address `$09AA6E`. It implements a complete multi-phase boss fight with orbital attack patterns, HP tracking, phase transitions, projectile spawning, camera control, and palette effects.

The patch `IOG_ApocalypseGaia_12.asr` (written by the author of the IOG retranslation project) claims to restore this unused boss as "Apocalypse Gaia." This document analyzes the unused boss in full, catalogs what appears unfinished, and then compares it against the patch to determine whether this is a true restoration.

---

## Part 1: The Unused Boss — Complete Documentation

### Actor Hierarchy

The boss spawns from a single entry point and creates a complex tree of child actors:

```
Core (actor_09AA6E) — the main boss entity
├── Background Palette Cycler (code_09B719) — "Colors of the End"
├── Sprite Palette Cycler (code_09B6FC) — "Bubbles turn freaky colors"
├── Floor Beam Spawner (code_09B747) — harassing beam attacks from below
├── Brain (code_09B5C7) — camera control, sine-wave hover
├── Left Bit (code_09B30E) — side minion, offset ($C8,$33)
├── Right Bit (code_09B36A) — side minion, offset ($38,$33), H-mirrored
├── Left Launcher (code_09B586) — bubble spawner, offset ($BF,$0B)
└── Right Launcher (code_09B57F) — bubble spawner, offset ($41,$0B), H-mirrored
```

### Phase 1: Core with Bits and Launchers

**Entry (`actor_09AA6E` → `code_09AA71`):**
1. Sets flag `$8011` in `$12` (physics properties)
2. Adjusts initial position: X-8, Y+256 (one full screen below)
3. Zeros all camera targets and deltas
4. Spawns all 7 child actors
5. Zeroes `$24` (internal state variable), plays idle animation, enters sleep loop

**Phase 1 Main Loop (`loc_09AB02`):**
1. Sets both Launcher event pointers to `code_09B58E` (fire mode)
2. Starts a countdown timer of `$021C` (540) frames stored in `animScratch`
3. Each frame: checks `$24` — if zero, transitions to Phase 2; otherwise decrements timer
4. When timer reaches zero: walks the actor chain to find the Bits and sets their pointers to attack mode (`code_09B37A` for right Bit, `code_09B31E` for left Bit)
5. Resets timer to `$00B4` (180) frames and loops

**Bit Attack Behavior:**
- Each Bit checks `$24` of Core to determine if one Bit has already died (`$24 == 1` forces the surviving Bit to attack)
- If both alive, frame parity determines which attacks
- Attack sequence: sound → animate sprites $06, $07 → become vulnerable (`TRB $10` clears invuln bit) → animate $16 → spawn beam projectiles → wait $77 (119) frames → restore invulnerability → return to idle
- **Death pointer** (`code_09B3C6`): Sets `$26 = 1`, LSR's Core's `$24` (halving it — this is how the Core knows a Bit died), spawns a falling death animation actor, enters idle sprite $0B loop

**Launcher Behavior (`code_09B58E`):**
- 5-iteration loop: animate sprites $09, $0A, spawn a Bubble (`code_09B7A8`), animate $1A
- After 5 volleys, returns to idle sprite $08 and sleeps until Core resets its pointer

### Phase 2: Core Becomes Vulnerable

**Transition (`loc_09AB6C`):**
- When `$24` reaches zero (both Bits dead), the Core enters Phase 2
- Sets death callback to `code_09ABF5`
- Loads its own HP from `enemy_stats_table+$15C`
- Spawns intro palette shift, clears the "invisible" flag
- Waits $1D (29) frames, enables hit callback

**Phase 2 Main Loop (`loc_09AB8B`):**
1. Animate sprites $01, $02
2. Play sound $29
3. Spawn a Nuke (`code_09B8B6`)
4. Animate sprite $19
5. Spawn flame palette shift
6. Clear hit callback
7. Wait $00B3 (179) frames
8. Reenable Launchers and Bits (sets Launcher pointers to `loc_09B5AD`, Bit pointers to `code_09B3EA`)
9. Wait $01DF (479) frames
10. Loop back to start

**Phase 2 Hit Callback (`code_09ABEE`):**
- Animate damage sprite $03, then resume animation sequence at `loc_09AB8B`

**Phase 2 Bit Behavior (Dead Bits, now in P2 mode):**
- `code_09B3EA`: Animate sprite $1C, play sound $20, spawn fire object (`code_09B3FD`)
- Fire objects converge to center screen, one dies, the other flies up and spawns a rain of fire from above

### Phase 2 → Phase 3 Transition

**Core P2 Death (`code_09ABF5`):**
1. Spawns flame palette shift
2. Animates death sprite $04
3. Sets Brain's event pointer to `code_09B6A6` (scroll-off routine)
4. Sets `$26 = 1`, sleeps until Brain clears it to zero
5. Locks joypad mask `$FFF0`
6. Sets flag byte $F5
7. **Performs four VRAM DMA transfers** — copies $800 bytes each from `$7EE000`, `$7EE800`, `$7EF000`, `$7EF800` to VRAM at $5000–$5FFF. This is the "Mode 7 tilemap" referenced in the header — it modifies the background graphics for Phase 3
8. Unlocks joypad
9. Spawns Final Core (`code_09AC55`)
10. Dies (along with remaining Launchers/Bits/palette events via `COP [Die]`)

### Phase 3: The Final Core

**Entry (`code_09AC55`):**
1. Sets death callback to `code_09B1D5`
2. Loads HP from `enemy_stats_table+$15C`
3. Sets sprite priority above both BGs
4. Spawns Left Helper chain (`code_09ADB3`) and Right Helper chain (`code_09ADEB`)
5. Plays initial animation, sets initial position to ($80, $80) — center of screen
6. Starts movement with sprite $1E at max speed
7. Clears invulnerability flags

**Final Core Movement AI (`code_09ACA2`):**
- Each frame, uses frame parity (`$0036 LSR`) to choose between:
  - **Even frames**: Target = player position (loads from `$playerActor`)
  - **Odd frames**: Target = random position (RNG for X, low byte of $0411 for Y)
- Adds random jitter ±$1F to the target
- Boundary checks: rejects targets within $20 of screen edges (both X and Y must be in $20–$E0)
- Moves toward valid target with sprite $1E at speed ($FF, $FF)
- After reaching target, resets hit callback and repeats

**Final Core Hit Callback (`code_09AD11`):**
1. Sets `$26 = 1` (marks damage state)
2. Animates damage sprites $42, $1F, $20
3. Spawns Mini-boss (`code_09AD3F`) at offset (0, $EC)
4. Animates sprite $21
5. Clears `$26`, returns to movement loop

**Mini-Boss (`code_09AD3F`):**
- Sets death callback to `code_09ADA7`
- Enables death/damage pointers flag `$0080`
- Falls down with sprite $22, vertical movement
- Waits $13 (19) frames, animates idle sprite $23
- Loads own HP from `enemy_stats_table+$158`
- **Movement loop**: Seeks random positions within ($14–$E0) for both X and Y, moves with sprite $24 at speed 2
- **Hit callback** (`code_09ADA0`): animate damage sprite $25, return to movement loop
- **Death** (`code_09ADA7`): animate sprites $26, $27, die

### Helpers and Orbital Cannons

**Helper Init (Left: `code_09ADB3`, Right: `code_09ADEB`):**
Each Helper spawns a chain of child actors:
```
Helper
├── Cannon (code_09AE52 / code_09B147) — orbital attack system
├── Tendon (code_09B2AE) — body segment (midpoint calc)
├── Joint ×3 (code_09B28D) — body segments (position interpolation)
└── Root (code_09B29B) — body segment (base anchor)
```

After spawning, the Helper stores its offset from the Final Core and runs a loop to maintain that fixed displacement each frame.

**Left Cannon (`code_09AE52`):**
1. Initializes orbit angle to 0, diameter to $70
2. Main loop: checks if Final Core is invulnerable (bit $0010 of flags)
   - If invulnerable: just orbit around Helper
   - If vulnerable: use `DirToPlayer` to find target angle
3. Orbits toward the player-facing angle at 2 units/frame
4. When close to target angle (within 3 units), branches to directional fire logic

**Directional Fire (`code_09AF02`):**
- Converts orbit angle to an 8-direction index (0–7) using lookup table `byte_09B26C`
- Adds frame parity adjustment
- Uses `SwitchCase` to select one of 8 firing routines

**Each directional fire routine (e.g., `code_09AF42`):**
1. Change cannon sprite to match direction (sprites $29–$30)
2. Call `code_09B084` to set Final Core to a frozen idle animation
3. Loop $10 (16) frames: orbit around Helper
4. Spawn directional bullet
5. Loop $0A (10) more frames: orbit
6. Call `code_09B062` to restore Final Core to normal loop
7. Restore saved pointer (back to main orbit logic)

**Right Cannon (`code_09B147`):**
- Similar to Left Cannon but with different behavior:
  - On even $0410: uses the same 8-directional fire logic as Left
  - On odd $0410: random orbit — picks a random count, orbits CW or CCW for that many steps
- Has a separate entry for directional sprite (`code_09B178`)

**Bullets (8 variants, `code_09B0A6` through `code_09B121`):**
Each plays sound $23, animates a unique start sprite, sets a unique hitbox sprite, stages directional movement (X,Y velocity pairs):

| Direction | Start Sprite | Hitbox Sprite | Velocity (X,Y) |
|-----------|-------------|---------------|-----------------|
| 0 (North) | $33 | $3B | (0, 8) |
| 1 (NE) | $38 | $40 | (5, 6) |
| 2 (East) | $35 | $3D | (7, 0) |
| 3 (SE) | $39 | $41 | (5, 5) |
| 4 (South) | $32 | $3A | (0, 7) |
| 5 (SW) | $36 | $3E | (6, 5) |
| 6 (West) | $34 | $3C | (8, 0) |
| 7 (NW) | $37 | $3F | (6, 6) |

All bullets converge at `code_09B134`: animate until off-screen, then die.

### Body Segments

**Joint (`code_09B28D`):** Positions itself between parent and sibling using averaged coordinates with carry-rotation for negative handling. Maintains offset history in `orbitAngle`/`orbitDiameter` scratch.

**Root (`code_09B29B`):** Same as Joint but also snaps its X to parent's X each frame (an anchor behavior).

**Tendon (`code_09B2AE`):** Calls `ActorMidpointCalc` — places itself at the exact midpoint of its prev/next neighbors.

### Nuke System (`code_09B8B6`)

1. Spawned by Core P2 during its main loop
2. Falls downward with sprite $12
3. Plays sound $1E
4. Generates random initial angle, spawns three Nuke Pieces at 120° offsets ($55 apart)

**Nuke Piece (`code_09B8F3`):**
- Spiral outward from nuke impact point using orbital math
- Angle increments by 2 per wait-frame, radius by 4 per wait-frame
- When radius overflows $FF: reverses velocity to linear movement
- Linear phase continues until off-screen, then dies

### Bubble System (`code_09B7A8`)

1. Spawned by Launchers
2. Plays sound $1E
3. Direction-dependent offset and movement (uses H-mirror to determine side)
4. Zero HP, death callback to `code_09B84F`
5. Moves toward random position near player (PlayerX ± rand($7F) - $3F)
6. On death: changes spriteset, spawns 4 debris actors, plays sound $1D, animates explosion

### Brain / Camera System (`code_09B5C7`)

**Initial scroll-on:**
1. Stores Core's X/Y as reference points
2. Moves upward 2 pixels/frame, shifting Core and all children via `code_09B9CC`
3. Adjusts camera deltas to compensate
4. Continues until Y reaches 0 (one full screen of scrolling)

**Post-scroll sine hover:**
1. Increments angle by 2 per frame (mod $100)
2. At angle $40 and $C0 (peaks/troughs): hovers for random duration ($28 + rand($3F) frames)
3. Uses `code_09BA59` — sine function with scale factor:
   - Loads 8-bit sine table, multiplies by orbit diameter via hardware multiply ($4202/$4203)
   - Result = sin(angle) × scale / 256
4. Applies sine offset to Y position, updates Core and all children

### End-of-Fight (`code_09BA38`)

- Locks joypad ($8000)
- Waits $EF (239) frames
- Resets character form to 0
- Sets GFX cache to $0404
- Queues map change to **$E5** (Kara/credits ending map)
- Dies

### Palette Effects

- `code_09B719`: Background colors — runs palette bundle $62, randomly triggers bundle $66 (lightning flash), random timing
- `code_09B6FC`: Sprite colors — runs palette bundle $63 in a loop, dies when Core signals `$26 == 2`
- `code_09B9BE`: P2 intro — palette bundle $6A, single-shot
- `code_09B9C5`: Nuke/death — palette bundle $69, single-shot

### Lookup Tables

**`byte_09B25C` (Direction → Angle):** Maps 8 directions to orbit angles:
```
Dir 0(S)→$80, 1(SW)→$60, 2(W)→$28, 3(NW)→$20,
4(N)→$00, 5(NE)→$E0, 6(E)→$C0, 7(SE)→$A0
```

**`byte_09B264` (Angle → Sprite):** Maps orbit angle sectors to directional sprites:
```
$29, $30, $2C, $2F, $2A, $2E, $2B, $2D
```

**`byte_09B26C` (Angle → Case Index):** Maps orbit angle sectors to SwitchCase branches:
```
4, 3, 2, 1, 0, 7, 6, 5
```

**`byte_09B57A` (Beam Moves):** Y-velocity table for Bit beam projectiles:
```
3, 1, 0, 2, 4
```

---

## Part 2: What Appears Unfinished

### 1. Mode 7 Setup Without Full Mode 7 Usage
The `!mode7Tilemap` variable is defined at `$7EE000`, and the P2→P3 transition copies data from `$7EE000–$7EF7FF` to VRAM. However, there is **no Mode 7 matrix rotation/scaling during gameplay**. The data appears to be background tile changes only. The "Mode 7" label in the header may refer to the VRAM layout being a Mode 7-compatible tilemap, but the boss never actually activates Mode 7 rendering mode ($2105).

### 2. No Map/Room Integration
The boss has no link to any map or room in the game. It initializes its own camera, spawns from an actor definition, and exits to map $E5 on victory. There is no evidence of a map spawn table entry, trigger event, or cutscene leading into this fight.

### 3. Floor Beam Spawner is Minimal
`code_09B747` only spawns horizontally-moving sprite $15 beams at fixed position ($A0, $C0). It has no target tracking, no variation in timing beyond a random 5–8 frame delay, and is killed when Core becomes invulnerable. This seems like placeholder harassment.

### 4. Body Segments Are Visually Simple
The 5 Joints + Tendon + Root chain between each Cannon and the Core all use sprite $28 and do nothing but interpolate positions. They have no animation, no interaction, no collision. They appear to be visual connectors ("tentacle arms") that were never finalized.

### 5. Core P2 Has Rigid Animation Timing
The P2 loop uses fixed frame counts ($B3 = 179 frames vulnerable, $1DF = 479 frames for the full cycle). There's no difficulty scaling, no reaction to player behavior, and the damage callback simply replays the animation from the top.

### 6. Mini-Boss Lacks Strategic Depth
The Mini spawned by the Final Core has random movement with no player tracking. It seeks random positions and has no attack of its own — it's purely a damage sponge. A finished version would likely chase the player or have projectile attacks.

### 7. Sprite Count is Extremely High
The boss defines sprites up to $42 (66 unique sprite frames/hitboxes). Combined with multiple simultaneously active actors (Core + Brain + 2 Bits + 2 Launchers + 2 Helpers + 2 Cannons + 5 Joints + 1 Tendon + 1 Root + dynamic Bubbles/Bullets/Nukes/Minis), this would cause severe sprite flickering and slowdown on real SNES hardware.

### 8. No Invincibility Frames Between Phases
Transitions from P1→P2 and P2→P3 don't disable player input or grant immunity. A player could theoretically take damage during the VRAM DMA transitions.

### 9. Palette Bundle References Are Unverified
The boss references palette bundles $62, $63, $66, $69, $6A — whether these exist in the vanilla ROM and produce appropriate visual effects is unconfirmed. They could be placeholders.

### 10. Sound Effect Choices May Be Borrowed
Sound IDs ($06, $15, $1D, $1E, $20, $21, $23, $29) are used throughout but may be shared with other game contexts. No unique boss music trigger is present.

---

## Part 3: Comparison with IOG_ApocalypseGaia_12.asr

### Identification: Same Boss

**The patch targets the exact same ROM address.** The patch writes at `org $89aa6e`, which in HiROM mapping corresponds to the same physical ROM offset as the extracted code at `$09AA6E`. This is not a coincidence — the patch is directly overwriting the unused boss code.

**The enemy stat table references match exactly:**

| Vanilla Reference | Hex Address | Patch Reference | Used By |
|-------------------|-------------|-----------------|---------|
| `enemy_stats_table+$154` | `$AD44` | `lda #$AD44 : jsr SR_InitVitals` | Bits, Core P2 |
| `enemy_stats_table+$158` | `$AD48` | `lda #$AD48 : jsr SR_InitVitals` | Minis, Shields |
| `enemy_stats_table+$15C` | `$AD4C` | `lda #$AD4C : jsr SR_InitVitals` | Final Core |

The patch even notes: *"HP/STR/DEF/DP entry for the Final Core. Unused (and nonfunctional) in the vanilla code"* and writes new values to `$81AD4C`: `db $14,$24,$7F,$00` (HP=20, STR=36, DEF=127, DP=0).

**The phase structure matches:**
- Vanilla: Core P1 → Bits die → Core P2 → VRAM transition → Final Core P3
- Patch: Identical progression, same label addresses

### Assessment: NOT a True Restoration

Despite being based on the same code, the patch is a **heavily modified creative reimagining**, not a faithful restoration. Here is the evidence:

#### A. Disabled Vanilla Code

The patch uses `if 0` blocks to explicitly disable vanilla code and replace it. Examples:

1. **Brain scroll-on** (lines 3116–3139): The entire initial camera scroll sequence is wrapped in `if 0`. The patch instead jumps directly to the hover phase because it integrates the boss into the existing Dark Gaia fight sequence — the camera is already positioned.

2. **Core P1 collision enabling** (lines 1523–1537): The vanilla code that enables collision on Launchers and Bits is commented out. The patch author writes: *"I'm disabling that, to save badly needed processing time."*

3. **Final Core movement AI** (lines 1740–1778): The vanilla random-walk targeting is wrapped in `if 0` and replaced with a custom `SR_FindPlayerAvoidanceCoordinates` subroutine.

4. **Bubble debris** (lines 3357–3370): The 4-directional debris spawned on Bubble death is entirely disabled.

#### B. New Code Not Present in Vanilla

The patch adds substantial new systems with no basis in the original ROM:

1. **Shield Minis** (`..Shield:` at line 1985): An entirely new actor type that orbits the damaged Final Core using trigonometry. The vanilla code only has damage Minis — shields don't exist.

2. **Game State Tracking** (`$00F0`): A new global state variable that tracks boss damage level, affects cannon fire timing, and controls music tempo via `$2141`.

3. **VRAM Tile Pushes** (`LR_PushAndUpdateAGBody`, `LR_UpdateFlameSpriteset`): Elaborate DMA routines that dynamically update boss body graphics and the "flame" spriteset. None of this exists in vanilla.

4. **BG Layer Composition**: Multiple screen-mode thinkers (`ECometBG.AGP1`, `.AGP3`, `.DGOnScreen`, `.DGDead`) that manage BG1/BG2 priorities, color math, window effects, and HDMA — entirely new.

5. **Player Herb Preservation** (`LR_SetupPlayerForComet`): Logic to save and restore the player's herb count across respawns during the fight — a gameplay polish feature.

6. **Music Tempo Control**: Direct writes to `$2141` (SPC700 IO port) to dynamically speed up music as the boss takes more damage.

7. **Dark Gaia Integration**: The boss is wired into the Comet map ($8CE212), shares the Dark Gaia spriteset, and transitions seamlessly from the existing Dark Gaia fight. The vanilla boss was standalone.

8. **Chaser Projectiles** (`EChaser` at line 3017): Bit beam pieces now home in on the player using a chaser system — vanilla beams just fly in a straight line.

#### C. Removed Vanilla Features

1. **Body Segments Disabled**: All Joint, Tendon, and Root spawn calls are commented out:
   ```
   ;cop #$A4 : dl EAGCoreP3_Joint : db $D0,$00,$02,$23
   ;cop #$A4 : dl EAGCoreP3_Joint : db $E0,$00,$02,$23
   ;cop #$A4 : dl EAGCoreP3_Joint : db $F0,$00,$02,$23
   ;cop #$A4 : dl EAGCoreP3_Root : db $00,$00,$02,$23
   ```
   The patch author notes these "cause lag."

2. **Helper Anchors Disabled**: The Helper init routines (`code_09ADB3`/`code_09ADEB`) that spawn the body chain are cut. The Cannons are spawned directly by the Core instead.

3. **Floor Beam Spawner**: Not referenced in the patch's active code.

4. **Cannon Freeze/Restore**: The `code_09B084` (freeze Final Core during cannon attack) and `code_09B062` (restore) subroutines are present in `if 0` blocks but not used in the active code path.

#### D. Modified Vanilla Behavior

1. **Cannon Spawn Offsets Changed**:
   - Vanilla Left Gun: offset ($B0, $00), Right Gun: ($50, $E0)  
   - Patch Left Gun: offset ($B0, $F8), Right Gun: ($50, $F8)
   - The patch author marks this: `!!! different from vanilla...`

2. **P1 Timer Shortened**: Vanilla uses $021C (540 frames); patch uses $0130 (304 frames).

3. **Nuke System Rewritten**: The vanilla Nuke (`code_09B8B6`) falls straight down; the patch's `EAGNuke` has three fall directions (center, left, right) with different trajectories.

4. **Bit Attack Timing**: Vanilla Bits attack on frame parity; the patch adds a $28-frame delay (`cop #$DA : db $28`) when both Bits are alive.

5. **P2 Launcher Sequence**: Vanilla has simple pointer swaps; the patch adds a complete `P2WaitThenFireAll` / `P2FireAll` system with coordinated Bit+Launcher attacks.

6. **Final Core Movement**: Vanilla picks random positions or tracks the player with simple jitter. The patch uses a sophisticated avoidance algorithm that places the Core away from the player based on signed distance calculations.

### Summary Table

| Feature | Vanilla Unused Boss | Patch (Apocalypse Gaia) | Verdict |
|---------|-------------------|------------------------|---------|
| ROM Address | $09AA6E | $89AA6E (same offset) | ✅ Match |
| Phase Structure | P1→P2→P3 | P1→P2→P3 | ✅ Match |
| Stat Table Entries | +$154, +$158, +$15C | $AD44, $AD48, $AD4C | ✅ Match (same addresses) |
| Actor Spawn Tree | Core→Brain→Bits→Launchers→Helpers→Cannons→Joints | Same minus Joints/Tendon/Root | ⚠️ Modified |
| Brain Scroll-On | 2px/frame upward scroll | Disabled (integrated into DG) | ❌ Removed |
| Body Segments | 5 Joints + Tendon + Root per side | Entirely disabled | ❌ Removed |
| Shield Minis | Not present | New orbiting shield system | ❌ New addition |
| Cannon AI | Angular tracking with DirToPlayer | Timer-based with game state | ⚠️ Rewritten |
| Final Core Movement | Random walk + player tracking | Player avoidance algorithm | ⚠️ Rewritten |
| Nuke Trajectory | Straight down | Three-way branching | ⚠️ Rewritten |
| BG/VRAM Management | 4× DMA at transition | Elaborate multi-thinker system | ❌ Entirely new |
| Music Integration | None | Dynamic tempo via $2141 | ❌ New addition |
| Dark Gaia Integration | Standalone fight | Continuation of DG sequence | ❌ New addition |
| Map Exit | Direct to $E5 | Complex with herb preservation | ⚠️ Enhanced |
| Palette Bundles | $62, $63, $66, $69, $6A | Same IDs referenced | ✅ Match |

---

## Conclusion

**Is this the same boss?** Yes, definitively. The ROM addresses, enemy stat references, phase structure, actor hierarchy, and many individual code sequences match between the vanilla unused code and the patch.

**Is this a true restoration?** No. The patch author clearly studied the vanilla unused code in detail (evidenced by the `if 0` blocks preserving original code, the `!!! different from vanilla...` annotations, and the matching stat table references). However, they made extensive creative decisions:

- Removed features deemed too laggy (body segments)
- Added entirely new systems (shields, game state, BG management, music tempo)
- Rewrote AI systems for better gameplay (avoidance movement, coordinated attacks)
- Integrated the fight into the existing Dark Gaia sequence rather than keeping it standalone

**The patch is best described as a "completion and integration" of an unfinished boss**, not a restoration. The author took the original framework — which was structurally complete but unpolished — and made it into a playable, balanced, visually polished boss fight that fits within the game's existing final boss sequence. Roughly 40–50% of the patch's code has direct correspondence to the vanilla unused code, while the rest is new.
