# COP family: Dialog

_Deep-audited ops: `[6B]`, `[BD]`, `[BE]`, `[BF]`_

[← COP index](../index.md)

## Overview

Text output and branching choice menus. **`PrintDialogString` (`$BF`)** is the default wide-string dialogue box (via `DialogStringRenderer`). **`DialogueOptions` (`$BE`)** runs `MenuSelectionHandler` and **`RTI`s into a jump table** keyed by the player’s selection. **`PrintDialogStringAlt` (`$6B`)** renders the same string format but skips dialogue-mode setup and the pre-text **`UpdateFrameRender`** — suited to menu overlays that refresh often. **`RunBg3Script` (`$BD`)** executes **ASCII / console command streams** through `ConsoleStringRenderer` on BG3 (title text, diary chrome, credits).

## Shared state

- `$0654` (`worldReadyFlag`) — `$BE` retries until **`$000F`** (all subsystems ready)
- `$0656` / `$0658` — `joypadCurrent` / `joypadHeld`; cleared after `$BF` to prevent input bleed
- `$065A` (`joypadMaskStd`) — zeroed during text/menu; restored on exit
- `$065C` (`joypadMaskInv`) — `$BE` sets **`$0F00`** to block inventory toggles during choices
- `$10` bit `$0800` — status bar visibility; hidden during `$BF`/`$6B`/`$BE`
- `$09EC` (`displayModeFlags`) — `$2000` dialogue mode for `$BF`/`$BE`; `$BD` sets bit **`$0001`** (BG3 console active)
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
- **Handler:** `PrintDialogString` @ `extracted/system/engine/cop_handlers_input.asm`
- **Usage count:** 1383

##### What it does

1. Sets **`displayModeFlags` bit `$2000`** (dialogue mode).
2. Saves script bank/PC, runs **`UpdateFrameRender`** once to sync the framebuffer.
3. Hides the **status bar** (`$10` bit `$0800`).
4. Clears **`joypadMaskStd`**, switches **DBR** to the script bank, and **`JSL DialogStringRenderer`** with the **`&DialogString`** pointer.
5. On return: restores joypad mask, clears **D-pad** bits in `$0656`/`$0658`, clears dialogue mode, restores status bar, **`RTI`**.

```asm
PrintDialogString {
    TYX 
    LDA #$2000
    TSB $displayModeFlags
    ; … save $0A, UpdateFrameRender …
    LDA #$0800
    TRB $10               ; hide status bar
    STZ $joypadMaskStd
    ; … PLB from script bank …
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@DialogStringRenderer
    ; … restore joypad, TRB joypadCurrent/joypadHeld directions …
    TRB $displayModeFlags ; clear $2000
    RTI 
}
```

The renderer processes wide-string bytecode (`[DEF]`, `[N]`, `[END]`, etc.) and may **yield internally** while waiting for button presses at `[END]` / `$CF` commands — from the actor’s perspective the COP **blocks until the line completes**.

##### How it is used

Every standard NPC line, sign, and cutscene subtitle.

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )  ; actors/debug_man.asm:45
COP [PrintDialogString] ( &dialogstring_09CF19 )  ; incan_ruins/incan_ruins_entrance/ir1C_kara.asm:37
COP [PrintDialogString] ( &dialogstring_08ACE0 )  ; dao/dao/daC3_jackal_girl.asm:23
```

With choices:

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )
COP [DialogueOptions] ( #04, #00, &code_list_0BEE4E )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `&DialogString` — 2-byte pointer in **script bank** (`$0C`) |
| Side effects | Dialogue mode, status bar hidden, joypad masked during render |
| Follow-up | `[BE]` when the rendered text ends with a question / option rows |
| Outcome | Halt until renderer finishes (including in-string waits) |

---

#### COP [BE] — `DialogueOptions` (choice menu → branch table)

- **Preferred name:** `DialogueOptions`
- **Handler:** `DialogueOptions` @ `extracted/system/engine/cop_handlers_input.asm`
- **Usage count:** 92

##### What it does

1. If **`worldReadyFlag ≠ $000F`**, rewinds script PC and **`RTL`** (retry next frame).
2. Sets dialogue mode **`$2000`**, masks inventory input **`$0F00`**, saves/restores status bar bit **`$0800`**.
3. Clears **`joypadMaskStd`** so the menu handler owns input.
4. Reads layout **`Word`** from script → **`JSL MenuSelectionHandler`** → **`ASL A`** (index × 2).
5. Reads branch table base **`Word`**, adds index, loads **`&Code`** from table entry, clears modes, **`RTI`** to chosen handler.

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
    ; … hide status bar, clear joypadMaskStd …
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

Debug menus, yes/no prompts, and multi-branch NPC trees.

```asm
COP [PrintDialogString] ( &dialogstring_0BF010 )
COP [DialogueOptions] ( #04, #00, &code_list_0BEE4E )  ; actors/debug_man.asm:45-46

code_list_0BEE4E [
  &DebugManQuit   ;00 — cancel
  &code_0BEE58   ;01
  &code_0BEED5   ;02
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
- **Handler:** `PrintDialogStringAlt` @ `extracted/system/engine/cop_handlers_input.asm`
- **Usage count:** 24

##### What it does

Same core **`DialogStringRenderer`** call as **`[BF]`**, but:

- **No** `displayModeFlags` `$2000` setup/teardown
- **No** **`UpdateFrameRender`** before text
- Still hides status bar **`$0800`**, masks **`joypadMaskStd`**, clears **`joypadHeld`** D-pad bits **`$0F00`** after render

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

#### COP [BD] — `RunBg3Script` (BG3 console / ASCII overlay)

- **Preferred name:** `RunBg3Script`
- **Handler:** `RunBg3Script` @ `extracted/system/engine/cop_handlers_input.asm`
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
| Sets | `displayModeFlags` bit 0 (BG3 overlay active) |
| Pairs with | `[6B]` for wide-string menu rows on top of the same BG3 frame |
| Outcome | Continue (renderer runs synchronously before `RTI`) |

##### Family summary

| Op | Renderer | Typical surface |
|----|----------|-----------------|
| `[BF]` | `DialogStringRenderer` | NPC dialogue box |
| `[6B]` | `DialogStringRenderer` | Diary / rapid menu text |
| `[BD]` | `ConsoleStringRenderer` | Title, credits, BG3 chrome |
| `[BE]` | `MenuSelectionHandler` | Branch after `[BF]`/`[6B]` text |
