# COP family: Dialog

_Deep-audited ops: `[6B]`, `[BD]`, `[BE]`, `[BF]`_ · _Source: [`cop_handlers_dialog.asm`](../../../extracted/system/engine/cop_handlers_dialog.asm)_

[← COP index](../README.md)

## Overview

Text output and branching choice menus. **`PrintDialogString` (`$BF`)** is the default wide-string dialogue box (via `DialogStringRenderer`). **`DialogueOptions` (`$BE`)** runs `MenuSelectionHandler` and **`RTI`s into a jump table** keyed by the player’s selection. **`PrintDialogStringAlt` (`$6B`)** renders the same string format but skips the `displayModeFlags` bit 13 (`$2000`) set/clear and the pre-text **`UpdateFrameRender`** — suited to menu overlays that refresh often. **`RunBg3Script` (`$BD`)** executes **Console / console command streams** through `ConsoleStringRenderer` on BG3 (title text, diary chrome, credits).

## Shared state

- `$0654` (`worldReadyFlag`) — `$BE` retries until **`$000F`** (all subsystems ready)
- `$0656` / `$0658` — `joypadCurrent` / `joypadHeld`; after `$BF` the restored `joypadMaskStd` is re-applied to `joypadCurrent` (`TRB`) and the D-pad bits (`$0F00`) are cleared in `joypadHeld`; after `$6B` only the `joypadHeld` D-pad bits are cleared
- `$065A` (`joypadMaskStd`) — zeroed during text/menu; restored on exit
- `$065C` (`joypadMaskInv`) — `$BE` sets **`$0F00`** (the D-pad buttons) as the auto-repeat buttons while the menu is open, and clears it on exit
- Actor `$10` bit `$0800` (cutscene-active) — saved and cleared during `$BF`/`$6B`/`$BE` so `RunActors_CutsceneOnly` does not re-run the actor while the renderer runs its frame updates, then restored (measured: with the bit forced back on while `displayModeFlags $2000` was set, the calling actor was re-run mid-COP and `PrintDialogString` ran 7 times in 12 frames instead of once; in the natural hideout cutscene the calling actor does not carry the bit, so the clear did nothing there); not a status bar flag
- `$09EC` (`displayModeFlags`) — bit 13 (`$2000`, dialogue mode) is set during `$BF`/`$BE` and cleared afterwards. Its **only reader** is the Mu bomb countdown actor (`mu67_bomb.asm:145-147`), which skips its decrement and tick sound while the bit is set (measured: timer frozen at `$0133` for the 360 frames the bit was forced, then one step per 60 frames; church dialogue: 4 sets, 4 clears). It does not suppress the HUD (that is `hudDisableFlag` bit 6) and does not mask input; `$BD` sets bit **`$0001`** (request a full BG3 staging-buffer upload)
- `MenuSelectionHandler` — choice UI; returns index in **A**
- `DialogStringRenderer` — wide-string bytecode interpreter (`extracted/system/engine/DialogStringRenderer.asm`)
- `ConsoleStringRenderer` — BG3 tilemap command interpreter

## Family notes

- Typical NPC flow: **`[BF]` … optional `[BE]`** — options read rows already rendered into the dialogue box.
- **`[6B]`** is common in **`sFA_diary_menu.asm`**: redraw menu labels without the full `$BF` preamble each frame.
- **`[BD]`** almost always precedes or accompanies diary **`[6B]`** lines so BG3 chrome and wide-string rows stay aligned.
- **`[BE]`** operand layout: copdef lists **`Byte`, `Byte`, `&&Code`** — the two bytes form the **`Word`** layout passed to `MenuSelectionHandler`; the table is a **`&&Code`** list of **`&Code`** handlers (index × 2 added to table base).
- Do not confuse **`$CF WaitForButton`** inside dialogue **strings** (renderer command table) with COP **`$3E WaitForButton`** — different layers.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `6B` | `PrintDialogStringAlt` | 24 | `&DialogString` | `PrintDialogStringAlt` | Halt (until string done) |
| `BD` | `RunBg3Script` | 61 | `Address` | `RunBg3Script` | Continue |
| `BE` | `DialogueOptions` | 92 | `Byte`, `Byte`, `&&Code` | `DialogueOptions` | Halt → branch |
| `BF` | `PrintDialogString` | 1383 | `&DialogString` | `PrintDialogString` | Halt (until string done) |

**Family call-site total:** 1560

## Opcodes

#### COP [BF] — `PrintDialogString` (show dialogue box)

- **Preferred name:** `PrintDialogString`
- **Aliases:** (primary NPC “talk” opcode)
- **Handler:** `PrintDialogString` @ [`cop_handlers_dialog.asm`](../../../extracted/system/engine/cop_handlers_dialog.asm)
- **Usage count:** 1383

##### What it does

1. Sets **`displayModeFlags` bit 13** (`$2000`; read only by the `mu67_bomb` countdown, which pauses while it is set).
2. Saves script bank/PC, runs **`UpdateFrameRender`** once to sync the framebuffer.
3. Saves and clears actor **`$10` bit `$0800`** (cutscene-active).
4. Clears **`joypadMaskStd`**, switches **DBR** to the script bank, and **`JSL DialogStringRenderer`** with the **`&DialogString`** pointer.
5. On return: restores `joypadMaskStd` and re-applies it to `joypadCurrent` (`TRB`), clears the **D-pad** bits (`$0F00`) in `joypadHeld`, clears bit 13 of `displayModeFlags`, restores actor `$10` bit `$0800`, **`RTI`**.

```asm
PrintDialogString {
    TYX 
    LDA #$2000
    TSB $displayModeFlags
    ; … save $0A, UpdateFrameRender …
    LDA #$0800
    TRB $10               ; clear actor $10 bit 11 (cutscene-active)
    STZ $joypadMaskStd
    ; … PLB from script bank …
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer
    ; … restore joypadMaskStd, TRB joypadCurrent, TRB joypadHeld D-pad bits …
    TRB $displayModeFlags ; clear $2000
    RTI 
}
```

The renderer processes wide-string bytecode (`[DEF]`, `[N]`, `[END]`, etc.) and may **yield internally** while waiting for button presses at `[END]` / `$CF` commands — from the actor’s perspective the COP **blocks until the line completes**.

##### How it is used

Every standard NPC line, sign, and cutscene subtitle.

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )  ; actors/debug_man.asm (DebugManInteract)
COP [PrintDialogString] ( &dialogstring_09CF19 )  ; incan_ruins/incan_ruins_entrance/ir1C_kara.asm:37
COP [PrintDialogString] ( &dialogstring_08ACE0 )  ; dao/dao/daC3_jackal_girl.asm:23
```

With choices:

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )
COP [DialogueOptions] ( #04, #00, &DebugMenuTable1 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `&DialogString` — 2-byte pointer in **script bank** (`$0C`) |
| Side effects | `displayModeFlags` bit 13 set, actor `$10` bit `$0800` cleared, `joypadMaskStd` cleared during render |
| Follow-up | `[BE]` when the rendered text ends with a question / option rows |
| Outcome | Halt until renderer finishes (including in-string waits) |

---

#### COP [BE] — `DialogueOptions` (choice menu → branch table)

- **Preferred name:** `DialogueOptions`
- **Handler:** `DialogueOptions` @ [`cop_handlers_dialog.asm`](../../../extracted/system/engine/cop_handlers_dialog.asm)
- **Usage count:** 92

##### What it does

1. If **`worldReadyFlag ≠ $000F`**, rewinds script PC and **`RTL`** (retry next frame).
2. Sets **`displayModeFlags` bit 13** (`$2000`; read only by the `mu67_bomb` countdown), sets **`joypadMaskInv = $0F00`** (the D-pad buttons are the auto-repeat buttons while the menu is open), saves and clears actor **`$10` bit `$0800`**.
3. Clears **`joypadMaskStd`** so the menu handler sees every button.
4. Reads layout **`Word`** from script → **`JSL MenuSelectionHandler`** → **`ASL`** (index × 2).
5. Reads branch table base **`Word`**, adds index, restores the saved bit and `joypadMaskStd`, clears `joypadMaskInv` and bit 13, loads **`&Code`** from the table entry, **`RTI`** to chosen handler.

```asm
DialogueOptions {
    TYX 
    LDA $worldReadyFlag
    CMP #$000F
    BNE /* rewind + RTL */
    LDA #$2000
    TSB $displayModeFlags
    LDA #$0F00
    STA $joypadMaskInv
    ; … clear actor $10 bit 11, clear joypadMaskStd …
    LDA [$0A]             ; layout word (from two byte operands in asm listing)
    INC $0A
    INC $0A
    JSL $@MenuSelectionHandler
    ASL 
    ; … add to table base, LDA $0000,Y → STA $02,S ; RTI …
}
```

Cancel / B-button behavior is implemented inside **`MenuSelectionHandler`** (table index 0 is often wired to a shared cancel path).

##### How it is used

Debug menus, yes/no prompts, and multi-branch NPC trees. The unused **`debug_man`** actor (`DebugManInteract`) chains seven menus of four rows each (21 warp destinations plus cancel); every table has five **`&Code`** entries because **`DialogueOptions`** returns row index + 1 and index 0 is cancel (`DebugManQuit`).

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )
COP [DialogueOptions] ( #04, #00, &DebugMenuTable1 )  ; debug_man.asm (DebugManInteract)

DebugMenuTable1 [
  &DebugManQuit   ;00 — cancel (B button)
  &DebugMenuLevel2   ;01 — "Others"
  &DebugWarpGreatWall   ;02
  …
]
```

Layout bytes **`#04, #00`** → word **`$0004`** (four options in a single row — typical debug menu grid).

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | `Byte` + `Byte` → **`Word` menu layout** for `MenuSelectionHandler`; `&&Code` branch table |
| Prerequisite | **`[BF]`** (or `[6B]`) must have rendered option text lines the menu cursor aligns to |
| `$0654` | Must be **`$000F`** or handler yields without consuming operands |
| Outcome | Halt during menu; **`RTI` branch** to selected `&Code` |

---

#### COP [6B] — `PrintDialogStringAlt` (lightweight dialogue render)

- **Preferred name:** `PrintDialogStringAlt`
- **Aliases:** (no `$2000` dialogue mode path)
- **Handler:** `PrintDialogStringAlt` @ [`cop_handlers_dialog.asm`](../../../extracted/system/engine/cop_handlers_dialog.asm)
- **Usage count:** 24

##### What it does

Same core **`DialogStringRenderer`** call as **`[BF]`**, but:

- **No** `displayModeFlags` `$2000` setup/teardown
- **No** **`UpdateFrameRender`** before text
- Still saves and clears actor **`$10` bit `$0800`**, clears **`joypadMaskStd`** while rendering, and clears the **`joypadHeld`** D-pad bits **`$0F00`** after render (it does not re-apply the mask to `joypadCurrent`)

```asm
PrintDialogStringAlt {
    TYX 
    LDA #$0800
    TRB $10
    STZ $joypadMaskStd
    ; … PLB, read &DialogString, JSL DialogStringRenderer …
    LDA #$0F00
    TRB $joypadHeld
    TSB $10
    RTI 
}
```

Use when the screen already shows the correct BG/layout and you only need to **swap the wide-string rows** (diary tabs, multi-line settings).

##### How it is used

Diary / save menu loops interleaved with **`RunBg3Script`**.

```asm
COP [RunBg3Script] ( @system_strings.consolestring_01EADC )
COP [PrintDialogStringAlt] ( &dialogstring_0BF3F4 )  ; system/diary_menu/sFA_diary_menu.asm:152-153
COP [PrintDialogStringAlt] ( &dialogstring_0BF437 )  ; system/diary_menu/sFA_diary_menu.asm:258
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `&DialogString` — same format as `[BF]` |
| Diff vs `[BF]` | Skips `$2000` mode + pre-render frame sync — faster for UI loops |
| Outcome | Halt until string completes |

---

#### COP [BD] — `RunBg3Script` (BG3 console / Console overlay)

- **Preferred name:** `RunBg3Script`
- **Handler:** `RunBg3Script` @ [`cop_handlers_dialog.asm`](../../../extracted/system/engine/cop_handlers_dialog.asm)
- **Usage count:** 61

##### What it does

Reads an **`Address`** operand (word + bank), sets **DBR**, zeroes **DP**, and **`JSL ConsoleStringRenderer`** — a **command-stream** format for BG3 tiles (not wide dialogue). Sets **`displayModeFlags` bit `$0001`** on success.

```asm
RunBg3Script {
    PHY 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    JSL $@ConsoleStringRenderer
    ; … restore banks/DP …
    LDA #$0001
    TSB $displayModeFlags
    RTI 
}
```

Distinct from **`[BF]`**: no dialogue box VRAM staging, no `$2000` dialogue flag — intended for **HUD labels, title subtitles, credits typography**.

##### How it is used

Title intro timing, diary menu chrome, and boot-adjacent UI.

```asm
COP [RunBg3Script] ( @system_strings.consolestring_01DA5E )  ; system/title_screen/sFC_title_intro.asm:46
COP [RunBg3Script] ( @system_strings.consolestring_01DA47 )  ; system/title_screen/sFC_title_intro.asm:48
COP [RunBg3Script] ( @system_strings.consolestring_01EADC )  ; system/diary_menu/sFA_diary_menu.asm (throughout)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Address` — `@label` far pointer to console command stream |
| Sets | `displayModeFlags` bit 0 (request a full BG3 staging-buffer upload) |
| Pairs with | `[6B]` for wide-string menu rows on top of the same BG3 frame |
| Outcome | Continue (renderer runs synchronously before `RTI`) |

##### Family summary

| Op | Renderer | Typical surface |
|----|----------|-----------------|
| `[BF]` | `DialogStringRenderer` | NPC dialogue box |
| `[6B]` | `DialogStringRenderer` | Diary / rapid menu text |
| `[BD]` | `ConsoleStringRenderer` | Title, credits, BG3 chrome |
| `[BE]` | `MenuSelectionHandler` | Branch after `[BF]`/`[6B]` text |
