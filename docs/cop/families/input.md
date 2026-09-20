# COP family: Input (button wait + branch)

_Deep-audited ops: `[3E]`, `[3F]`, `[40]`, `[41]`_ · _Source: [`cop_handlers_input.asm`](../../../extracted/system/engine/cop_handlers_input.asm)_

[← COP index](../index.md)

## Overview

Script-level joypad **wait** and **branch** primitives. Mask **bit 0** of the operand word selects the pad source: **clear → `$0656` (`joypadCurrent`, filtered / latched presses)**; **set → `$0660` (`joypadRaw`, includes held / raw state)**. Wait ops **rewind the script PC by 4 bytes** and **`RTL`** until the condition holds; branch ops **consume or skip** the trailing **`&Code`** in one frame.

## Shared state

- `$0656` — `joypadCurrent` (filtered — “new press” style bits)
- `$0660` — `joypadRaw` (raw / held-inclusive read)
- `$0658` — `joypadHeld` (cleared by dialogue ops; relevant when chaining with `$BF`)
- `$065A` — `joypadMaskStd` (global input mask — title screen sets `$FFF0` before polling Start)

### Common button masks (16-bit)

| Mask | Button |
|------|--------|
| `$0080` | A |
| `$8000` | B |
| `$0040` | X |
| `$4000` | Y |
| `$0010` | Start |
| `$0020` | Select |
| `$0100` / `$0200` / `$0400` / `$0800` | Right / Left / Down / Up |
| `$0001` | R (used with `$1000` Start on title screen) |
| **`$xx01`** | Same direction/button tests against **`joypadRaw`** (bit 0 set) |

## Family notes

- **Wait** ops (`$3E`/`$3F`): “exit if not met” in legacy docs means the **actor yields** (`RTL`) and re-enters the COP next frame — not a script branch.
- **Branch** ops (`$40`/`$41`): one-shot; use inside **`SetEntryHere` + `RTL`** poll loops (title screen, inventory, player movement) for menu navigation without halting the whole actor forever.
- **`BranchIfPressed` with `$1001`** on title: Start **`$1000`** OR R **`$0001`**, raw source — see `sFC_title_start_handler.asm`.
- Player **`BranchIfNotPressed` with `$8001`**: B held on **raw** pad — attack charge / release detection in `attack_ability_system.asm`.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `3E` | `WaitForButton` | 0 | `Word` | `WaitForButton` | Halt (yield until press) |
| `3F` | `WaitForRelease` | 0 | `Word` | `WaitForRelease` | Halt (yield until release) |
| `40` | `BranchIfPressed` | 170 | `Word`, `&Code` | `BranchIfPressed` | Branch or Continue |
| `41` | `BranchIfNotPressed` | 22 | `Word`, `&Code` | `BranchIfNotPressed` | Branch or Continue |

**Family call-site total:** 192

## Opcodes

#### COP [3E] — `WaitForButton` (halt until button pressed)

- **Preferred name:** `WaitForButton`
- **Aliases:** `WaitUntilButton` (legacy script / wiki name)
- **Handler:** `WaitForButton` @ [`cop_handlers_input.asm`](../../../extracted/system/engine/cop_handlers_input.asm)
- **Usage count:** 0

##### What it does

Loads a **`Word` mask**, tests **`joypadCurrent`** or **`joypadRaw`** (per bit 0). If **any masked bit is set**, advances script (`RTI`). Otherwise **rewinds `$0A` by 4** and **`RTL`** so the same COP runs again next frame.

```asm
WaitForButton {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009498
    BIT $joypadCurrent
    BNE loc_00949D        ; pressed → RTI
    BRA loc_0094A2

  loc_009498:
    BIT $joypadRaw
    BEQ loc_0094A2

  loc_00949D:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094A2:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}
```

Distinct from **dialogue string `$CF WaitForButton`** (`DialogStringRenderer.asm`) — that command waits **inside** an active `[BF]` render; **`[3E]`** is a **COP-level** wait usable anywhere in actor code.

##### How it is used

Corpus audit: **0** ROM call sites. The handler exists in the dispatch table but no extracted script references it. Prefer **`BranchIfPressed` + `SetEntryHere` poll loops** for UI (title screen). Authoring shape when a hard block is needed:

```asm
COP [WaitForButton] ( #$0080 )    ; wait until A on joypadCurrent
COP [WaitForButton] ( #$8001 )    ; wait until B on joypadRaw
```

For “press A to continue” during dialogue, scripts usually rely on **`[BF]`** string **`[END]`** / `$CF` instead of `[3E]`.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Word Mask` — bit 0 → `$0660`; else `$0656` |
| Behavior | Rewind + yield until **(pad & mask) ≠ 0** |
| Outcome | Halt (retry each frame) → Continue when satisfied |

---

#### COP [3F] — `WaitForRelease` (halt until buttons released)

- **Preferred name:** `WaitForRelease`
- **Aliases:** `WaitUntilNoButton` (legacy)
- **Handler:** `WaitForRelease` @ [`cop_handlers_input.asm`](../../../extracted/system/engine/cop_handlers_input.asm)
- **Usage count:** 0

##### What it does

Same pad source rule as **`[3E]`**, but **`RTI` when `(pad & mask) == 0`** (all masked buttons released). Otherwise rewind + **`RTL`**.

```asm
WaitForRelease {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094C0
    BIT $joypadCurrent
    BEQ loc_0094C5        ; all released → RTI
    BRA loc_0094CA

  loc_0094C0:
    BIT $joypadRaw
    BNE loc_0094CA

  loc_0094C5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094CA:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}
```

Useful after detecting a press with **`[40]`** to **debounce** before accepting another action, or to wait out held directions.

##### How it is used

**0** ROM call sites — same as `[3E]`. Handler exists in the dispatch table but unused in shipped scripts. Typical paired pattern:

```asm
COP [WaitForButton] ( #$0080 )
; … one-shot action …
COP [WaitForRelease] ( #$0080 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Word Mask` |
| Behavior | Yield until **(pad & mask) == 0** |
| Outcome | Halt → Continue |

---

#### COP [40] — `BranchIfPressed` (branch if any masked button down)

- **Preferred name:** `BranchIfPressed`
- **Aliases:** `BranchIfButton`, `BranchIfPressed` (copdef)
- **Handler:** `BranchIfPressed` @ [`cop_handlers_input.asm`](../../../extracted/system/engine/cop_handlers_input.asm)
- **Usage count:** 170

##### What it does

If **(pad & mask) ≠ 0**, load **`&Code`** and **`RTI`** into that offset. Else skip the branch word and continue sequentially.

```asm
BranchIfPressed {
    TYX 
    LDA [$0A]             ; mask
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0094E8
    BIT $joypadCurrent
    BNE loc_0094F8
    BRA loc_0094ED

  loc_0094E8:
    BIT $joypadRaw
    BNE loc_0094F8

  loc_0094ED:
    INC $0A               ; skip &Code
    INC $0A
    RTI 

  loc_0094F8:
    LDA [$0A]             ; take branch
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}
```

##### How it is used

**Poll-loop menus** (diary, inventory), **title Start**, **elevator** direction picks, and **combat / archer** minigame input.

```asm
COP [SetEntryHere]
COP [BranchIfPressed] ( #$1001, &TitleToDiaryTransition )  ; system/title_screen/sFC_title_start_handler.asm:41
RTL 

COP [BranchIfPressed] ( #$0800, &DiaryTabCursorUp )       ; system/diary_menu/sFA_diary_menu.asm:184
COP [BranchIfPressed] ( #$0400, &DiaryTabCursorDown )
COP [BranchIfPressed] ( #$0080, &DiaryTabConfirm )

COP [BranchIfPressed] ( #$0801, &code_0AA661 )             ; diamond_mine/mine_elevator/dm43_elevator.asm:110 — D-pad + raw
COP [BranchIfPressed] ( #$0031, &code_0B901D )              ; great_wall/gw82_archer.asm:184

COP [BranchIfPressed] ( #$0080, &code_09BBD6 )              ; unused/unused_kara_dialog.asm:38 — loop test
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | `Word Mask`, `&Code` branch target (same bank) |
| Pattern | `SetEntryHere` → several `[40]` → `RTL` for frame poll |
| Outcome | **Branch** if pressed; else **Continue** |

---

#### COP [41] — `BranchIfNotPressed` (branch if buttons up)

- **Preferred name:** `BranchIfNotPressed`
- **Aliases:** `BranchIfNoButton`, `BranchIfNotPressed` (copdef)
- **Handler:** `BranchIfNotPressed` @ [`cop_handlers_input.asm`](../../../extracted/system/engine/cop_handlers_input.asm)
- **Usage count:** 22

##### What it does

If **(pad & mask) == 0**, take **`&Code`**. If any masked button is held, skip branch and fall through.

```asm
BranchIfNotPressed {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009514
    BIT $joypadCurrent
    BEQ loc_00951B        ; not pressed → branch
    BRA loc_009524

  loc_009514:
    BIT $joypadRaw
    BEQ loc_00951B
    BRA loc_009524

  loc_00951B:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009524:
    INC $0A
    INC $0A
    RTI 
}
```

##### How it is used

**Movement** (release direction to stop walk animation), **ladder / shimmy** detach, **attack** release after charging.

```asm
COP [BranchIfNotPressed] ( #$0400, &WalkRestoreSaved )     ; actors/player/player_character.asm:315 — left released
COP [BranchIfNotPressed] ( #$8001, &AttackCleanup )        ; actors/player/attack_ability_system.asm:160 — B released (raw)
COP [BranchIfNotPressed] ( #$8001, &LaunchPsychoDash )      ; actors/player/attack_ability_system.asm:171
COP [BranchIfNotPressed] ( #$0030, &RunStopToIdle )         ; actors/player/player_character.asm:1098 — L/R released
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | `Word Mask`, `&Code` |
| `$8001` | Common for **B-button** hold/release on **`joypadRaw`** |
| Outcome | **Branch** if not pressed; else **Continue** |

##### Family summary

| Op | Sync? | Condition for progress |
|----|-------|-------------------------|
| `[3E]` | Yields | Any masked button **down** |
| `[3F]` | Yields | All masked buttons **up** |
| `[40]` | Instant | Branch if **down** |
| `[41]` | Instant | Branch if **up** |
