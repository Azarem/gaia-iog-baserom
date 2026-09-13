; VBlank synchronization, Mode 7 register upload, and joypad processing with button remapping (163899–164305, Bank 02).
; 
; Two entry points share the Mode 7 and joypad pipeline:
; - VBlankPartial: skips NMI wait (for callers already in VBlank)
; - VBlankWaitAndJoypad: polls RDNMI until VBlank begins, then falls through
; 
; === MODE 7 UPLOAD ===
; When scrollModeFlags bit 3 is set, uploads the Mode 7 affine transformation matrix (M7A–M7D) and rotation center (M7X, M7Y) from WRAM shadow registers ($C2–$CD) to PPU write-twice registers ($211B–$2120). Each register requires two consecutive 8-bit writes (low byte, then high byte). Center point high bytes are masked to 5 bits (AND #$1F) for the 13-bit signed coordinate range. Also snapshots BG scroll positions ($BE/$C0 → $CE/$D0).
; 
; === JOYPAD INJECT ===
; If joypadInject ($09AC) is nonzero, it overrides the entire input pipeline — the injected value becomes joypadCurrent and the routine returns immediately. Used by cutscene scripts and automated sequences.
; 
; === BUTTON REMAPPING ===
; The D-pad (bits 8–11, $0F00) always passes through directly. Then each physical button is checked against its remap entry: if pressed in joypadRaw and the remap value is nonzero, those bits are TSB'd into joypadRemapped.
; 
; Remap variable → physical button checked:
;   remapL→Start($1000)  remapR→Select($2000)  remapB→B($8000)  remapY→Y($4000)
;   remapA→A($0080)  remapStart→X($0040)  remapX→L($0020)  remapSelect→R($0010)
; 
; SNES joypad bit layout (16-bit auto-read from $4218/$4219):
;   $8000=B  $4000=Y  $2000=Sel  $1000=Start  $0800=Up  $0400=Dn
;   $0200=Left  $0100=Right  $0080=A  $0040=X  $0020=L  $0010=R
; 
; === CONSUMPTION MASK + EDGE DETECTION ===
; joypadHeld serves as a cooperative consumption mask. Game code marks buttons as consumed via TSB $joypadHeld when processing input events. This routine then:
; 1. Copies remapped → joypadCurrent and joypadRaw
; 2. ANDs joypadHeld with current buttons — retains only consumed buttons still physically pressed
; 3. At the end, TRBs joypadHeld from joypadCurrent — removes consumed buttons from current
; Result: joypadCurrent = newly pressed buttons + auto-repeat triggers. Buttons consumed by game code via TSB don't reappear until released and re-pressed.
; 
; === AUTO-REPEAT ===
; When consumed+held buttons match joypadMaskInv (repeat-eligible):
; - joypadRepeatCounter increments each frame
; - At 12 frames: TRB repeat-eligible bits from joypadHeld → those buttons reappear in joypadCurrent next frame
; - Counter resets when no repeat-eligible buttons are held or when repeat fires
; 
; joypadMaskStd is TRB'd from joypadCurrent at the end to unconditionally suppress certain buttons.
; 
; === UTILITY ROUTINES ===
; EnableNmiAndJoypad: $81 → NMITIMEN (NMI + auto-read).
; EnableNmiOnly: $01 → NMITIMEN (NMI only).
; ForceBlank: $00 → INIDISP (brightness 0, forced blank off — screen dark but PPU active).
; EnableDisplay: $80 → INIDISP (forced blank on — VRAM/OAM/CGRAM accessible).
; WaitFrames: loop VBlankWaitAndJoypad for A frames.
---------------------------------------------

?BANK 02

!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!scrollModeFlags                06EF
!joypadInject                   09AC
!remapSelect                    0DA6
!remapX                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapStart                     0DB0
!remapL                         0DB2
!remapR                         0DB4
!M7A                            211B
!M7B                            211C
!M7C                            211D
!M7D                            211E
!M7X                            211F
!M7Y                            2120
!L_INIDISP                      802100
!L_NMITIMEN                     804200
!L_RDNMI                        804210

---------------------------------------------

; Partial VBlank handler — skips NMI wait, performs Mode 7 upload and joypad processing only.
; 
; Entry point for callers already inside VBlank (e.g., NMI handler). Saves processor state and accumulator (16-bit PHA under REP #$20), switches to 8-bit A, then branches directly to the Mode 7 and joypad processing section shared with VBlankWaitAndJoypad.

VBlankPartial {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    BRA loc_028057        ; Skip NMI wait — enter Mode 7 upload and joypad processing directly
}

---------------------------------------------
; Full VBlank synchronization with Mode 7 register upload and joypad input processing.
; 
; Polls RDNMI ($4210) until bit 7 is set (VBlank started), then falls through to Mode 7 upload and the complete joypad pipeline: inject check, button remapping, consumption mask update, auto-repeat, and edge detection.
; 
; The RDNMI register is read three times: once before the loop to clear any stale NMI flag, repeatedly in the loop to detect VBlank start, and once after loop exit to acknowledge and clear the flag.
; 
; See the vblank_joypad block note for detailed descriptions of each pipeline stage.

VBlankWaitAndJoypad {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI          ; Clear any stale NMI flag before entering the poll loop

  loc_02804D:
    LDA $L_RDNMI          ; Poll RDNMI bit 7 — set at the start of VBlank
    BPL loc_02804D
    LDA $L_RDNMI          ; Acknowledge read: clear the NMI flag after detection

  loc_028057:
    LDA $scrollModeFlags  ; Check scrollModeFlags bit 3 for active Mode 7 scene
    BIT #$08
    BEQ loc_0280A6
    LDA $C2               ; Upload Mode 7 matrix A: $C2 low byte, $C3 high byte via write-twice register
    STA $M7A
    LDA $C3
    STA $M7A
    LDA $C4
    STA $M7B
    LDA $C5
    STA $M7B
    LDA $C6               ; Matrix C (M7C) — same write-twice pattern as A and B
    STA $M7C
    LDA $C7
    STA $M7C
    LDA $C8
    STA $M7D
    LDA $C9
    STA $M7D
    LDA $CA               ; Center X (M7X): high byte masked to 5 bits for 13-bit signed coordinate
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC               ; Center Y (M7Y): same 5-bit mask as M7X
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE               ; Snapshot BG scroll positions for the Mode 7 frame ($BE→$CE, $C0→$D0)
    STX $CE
    LDX $C0
    STX $D0

  loc_0280A6:
    REP #$20
    LDA $joypadInject     ; Check joypadInject — nonzero overrides entire input pipeline with scripted input
    BEQ loc_0280B6
    STA $joypadCurrent    ; Use injected value as joypadCurrent, clear injection, return immediately
    STZ $joypadInject
    PLA 
    PLP 
    RTL 

  loc_0280B6:
    LDA $joypadRaw        ; Begin remapping: extract D-pad ($0F00) from raw input as base remapped state
    AND #$0F00
    STA $joypadRemapped
    LDA $remapL           ; L remap: if target defined and physical Start ($1000) pressed, TSB into remapped
    BEQ loc_0280D2
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0280D2
    LDA $remapL
    TSB $joypadRemapped

  loc_0280D2:
    LDA $remapR           ; R remap: physical Select ($2000) — same check-and-merge pattern
    BEQ loc_0280E5
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0280E5
    LDA $remapR
    TSB $joypadRemapped

  loc_0280E5:
    LDA $remapB           ; B remap: physical B ($8000)
    BEQ loc_0280F8
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_0280F8
    LDA $remapB
    TSB $joypadRemapped

  loc_0280F8:
    LDA $remapY           ; Y remap: physical Y ($4000)
    BEQ loc_02810B
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_02810B
    LDA $remapY
    TSB $joypadRemapped

  loc_02810B:
    LDA $remapA           ; A remap: physical A ($0080)
    BEQ loc_02811E
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_02811E
    LDA $remapA
    TSB $joypadRemapped

  loc_02811E:
    LDA $remapStart       ; Start remap: physical X ($0040)
    BEQ loc_028131
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_028131
    LDA $remapStart
    TSB $joypadRemapped

  loc_028131:
    LDA $remapX           ; X remap: physical L ($0020)
    BEQ loc_028144
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_028144
    LDA $remapX
    TSB $joypadRemapped

  loc_028144:
    LDA $remapSelect      ; Select remap: physical R ($0010)
    BEQ loc_028157
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_028157
    LDA $remapSelect
    TSB $joypadRemapped

  loc_028157:
    LDA $joypadRemapped   ; Finalize: remapped state → joypadCurrent and joypadRaw for this frame
    STA $joypadCurrent
    STA $joypadRaw
    AND $joypadHeld       ; Retain consumed buttons (set by game code via TSB) that are still physically pressed
    STA $joypadHeld
    BEQ loc_02817F
    AND $joypadMaskInv    ; Check if consumed-held buttons are eligible for auto-repeat (joypadMaskInv)
    BEQ loc_02817F
    LDA $joypadRepeatCounter ; Increment repeat counter — tracks consecutive held frames for repeat-eligible buttons
    INC 
    STA $joypadRepeatCounter
    CMP #$000C            ; 12-frame threshold: auto-repeat fires by clearing eligible bits from joypadHeld
    BNE loc_028182
    LDA $joypadMaskInv    ; Clear repeat-eligible from held → those buttons reappear as new presses next frame
    TRB $joypadHeld

  loc_02817F:
    STZ $joypadRepeatCounter ; Reset repeat counter (no eligible held buttons, or auto-repeat just fired)

  loc_028182:
    LDA $joypadHeld       ; Remove consumed-held from current → joypadCurrent = unconsumed presses only
    TRB $joypadCurrent
    LDA $joypadMaskStd    ; Suppress standard-masked buttons from joypadCurrent (joypadMaskStd)
    TRB $joypadCurrent
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Enable NMI and joypad auto-read by writing $81 to NMITIMEN ($4200).
; 
; Bit 7 = enable joypad auto-read (hardware reads controller data during V-Blank into $4218–$421F).
; Bit 0 = enable NMI on V-Blank.
; 
; Reads RDNMI first to clear any pending NMI flag, preventing an immediate spurious interrupt.

EnableNmiAndJoypad {
    PHP 
    SEP #$20
    PHA 
    LDA $L_RDNMI          ; Clear pending NMI flag before writing NMITIMEN
    LDA #$81              ; $81: NMI enable (bit 0) + joypad auto-read (bit 7)
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Enable NMI only (no joypad auto-read) by writing $01 to NMITIMEN ($4200).
; 
; Bit 0 = enable NMI. Joypad auto-read disabled — used during initialization or special rendering modes where the engine handles input manually.

EnableNmiOnly {
    PHP 
    SEP #$20
    PHA 
    LDA #$01              ; $01: NMI enable only — joypad auto-read disabled
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Set INIDISP ($2100) to $00 — brightness 0, forced blank released.
; 
; Clears bit 7 (forced blank off) and sets brightness to $0. The screen appears completely black but the PPU continues processing internally. Used to darken the display while keeping the PPU active.

ForceBlank {
    PHP 
    SEP #$20
    PHA 
    LDA #$00              ; $00: brightness 0, forced blank off (screen dark, PPU still active)
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Set INIDISP ($2100) to $80 — enable forced blank for VRAM access.
; 
; Sets bit 7 (forced blank on) with brightness 0. The PPU stops rendering, making VRAM, OAM, and CGRAM freely accessible for DMA transfers. Despite the name, this enters the hardware blank state — typically called before bulk VRAM operations.

EnableDisplay {
    PHP 
    SEP #$20
    PHA 
    LDA #$80              ; $80: forced blank on (bit 7) — VRAM/OAM/CGRAM accessible for DMA
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Wait for A frames by calling VBlankWaitAndJoypad in a loop.
; 
; Entry: A = number of frames to wait (must be > 0).
; Each iteration: processes one complete VBlank cycle (Mode 7 upload + joypad), then decrements A. Returns when A reaches zero. Joypad state is updated every frame during the wait.

WaitFrames {
    JSL $@VBlankWaitAndJoypad ; Process one VBlank cycle (Mode 7 + joypad), decrement frame counter
    DEC 
    BNE WaitFrames
    RTL 
}