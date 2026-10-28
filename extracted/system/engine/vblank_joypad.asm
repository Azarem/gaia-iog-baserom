; VBlank synchronization, Mode 7 register upload, and joypad processing with button remapping (163899–164305, Bank 02).
; 
; Two entry points share the Mode 7 and joypad pipeline:
; - VBlankPartial: skips the NMI wait; its only caller is UpdateFrameFull (system_core), which runs inside the NMI handler
; - VBlankWaitAndJoypad: polls RDNMI until VBlank begins, then falls through
; 
; === NMI COOPERATION ===
; The hardware joypad value is NOT read here. The NMI handler (step 11) waits for the auto-read to finish and stores JOY1L in joypadRaw; this routine then replaces joypadRaw with the REMAPPED value. It therefore only sees fresh hardware data when the NMI has run since the previous call (NMI enabled while waiting, or called from inside the NMI as VBlankPartial). Called with NMI disabled it would remap an already remapped joypadRaw again, which is not idempotent for swapped or software-only mappings.
; 
; === MODE 7 UPLOAD ===
; When scrollModeFlags bit 3 is set, uploads the Mode 7 affine transformation matrix (M7A–M7D) and rotation center (M7X, M7Y) from WRAM shadow registers ($C2–$CD) to PPU write-twice registers ($211B–$2120). Each register requires two consecutive 8-bit writes (low byte, then high byte). Center point high bytes are masked to 5 bits (AND #$1F) for the 13-bit signed coordinate range. Also snapshots BG scroll positions ($BE/$C0 → $CE/$D0) with LDX/STX: X is not saved by this routine, so X is clobbered in Mode 7 scenes (A and P are preserved).
; 
; === JOYPAD INJECT ===
; If joypadInject ($09AC) is nonzero, the value becomes joypadCurrent, joypadInject is cleared and the routine returns at once. The injection is one-shot (a script must rewrite it every frame to hold buttons, as sc06_bill does; sg4C_auto_advance writes $FFFF once) and it bypasses everything below: no remapping, no consumption mask, no auto-repeat and no joypadMaskStd, and joypadRaw is left as the hardware value. Writers in extracted/: sg4C_auto_advance, sc06_bill; scene_lifecycle clears it on scene change.
; 
; === BUTTON REMAPPING ===
; The D-pad (bits 8–11, $0F00) always passes through directly. Then each physical button is checked against its remap entry: if the button is pressed in joypadRaw and the remap value is nonzero, the remap value (an arbitrary 16-bit logical mask) is TSB'd into joypadRemapped. A button whose remap value is zero never appears. The remap values live in $0DA6–$0DB4 (the diary menu edits them); db-us/transforms.json rewrites some of their defaults. The low nibble of a hardware read is always 0 ($0008/$0004 are not hardware buttons), so a remap target may use those bits as software-only logical buttons.
; 
; Remap variable → physical button checked (the names refer to the physical button):
;   remapStart→Start($1000)  remapSelect→Select($2000)  remapB→B($8000)  remapY→Y($4000)
;   remapA→A($0080)  remapX→X($0040)  remapL→L($0020)  remapR→R($0010)
; 
; SNES joypad bit layout (16-bit auto-read from $4218/$4219):
;   $8000=B  $4000=Y  $2000=Sel  $1000=Start  $0800=Up  $0400=Dn
;   $0200=Left  $0100=Right  $0080=A  $0040=X  $0020=L  $0010=R
; 
; === CONSUMPTION MASK + EDGE DETECTION ===
; joypadHeld serves as a cooperative consumption mask. Game code marks buttons as consumed via TSB $joypadHeld when processing input events. This routine then:
; 1. Copies remapped → joypadCurrent and joypadRaw
; 2. ANDs joypadHeld with the remapped buttons — retains only consumed buttons still physically pressed
; 3. Applies the auto-repeat rule below (which may drop repeat-eligible bits from joypadHeld)
; 4. TRBs joypadHeld from joypadCurrent — removes consumed buttons — and then joypadMaskStd
; Result: joypadCurrent = newly pressed buttons + auto-repeat triggers. A consumed button does not reappear until it is released and pressed again (or auto-repeat fires).
; 
; === AUTO-REPEAT ===
; Buttons in joypadMaskInv (the repeat mask; the dialog handler and the diary menu set it to $0F00, the D-pad) that are consumed and still held are repeat-eligible:
; - joypadRepeatCounter increments on each call while at least one is held
; - on the 12th call the eligible bits are cleared from joypadHeld BEFORE it is subtracted from joypadCurrent, so the repeat shows up in joypadCurrent in the same call; the counter is reset, so the first repeat comes 12 calls after the press was consumed and the following ones every 12 calls while the game code keeps consuming them
; - the counter is also reset whenever no consumed button in the mask is held
; 
; joypadMaskStd is TRB'd from joypadCurrent at the end to unconditionally suppress certain buttons (never from the injected value).
; 
; === UTILITY ROUTINES ===
; EnableNmiAndJoypad: $81 → NMITIMEN (NMI + joypad auto-read).
; DisableNmiKeepJoypad: $01 → NMITIMEN: turns the NMI OFF and leaves only joypad auto-read on.
; ScreenBlackout: $00 → INIDISP (forced blank OFF, brightness 0 — screen appears black but PPU remains active; does NOT set the SNES forced blank bit).
; EnterForcedBlank: $80 → INIDISP (forced blank ON — PPU halted, VRAM/OAM/CGRAM accessible for DMA transfers).
; WaitFrames: loop VBlankWaitAndJoypad for A frames (A = 0 would wait 256 frames, or 65,536 with a 16-bit A).
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
!remapR                         0DA6
!remapL                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapX                         0DB0
!remapStart                     0DB2
!remapSelect                    0DB4
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

; Partial VBlank handler — skips the NMI wait and performs the Mode 7 upload and joypad processing only. Its only caller is UpdateFrameFull (system_core), which the NMI handler runs while a music upload is in progress; the NMI has already stored a fresh joypadRaw by then. Saves P and the 16-bit accumulator (PHA under REP #$20), switches to 8-bit A and branches into the section shared with VBlankWaitAndJoypad.

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
; Polls RDNMI ($4210) until bit 7 is set (VBlank started), then falls through to the Mode 7 upload and the complete joypad pipeline: inject check, button remapping, consumption mask update, auto-repeat, and edge detection.
; 
; RDNMI is read before the loop (clears a stale flag), in the loop, and once more after it; reading the register clears the flag, so the extra read after the loop changes nothing. The caller normally has NMI enabled while it waits, so the NMI handler runs inside the poll loop and refreshes joypadRaw before the remap below. Saves and restores A and P only (see the block note for the X clobber in Mode 7).
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
    LDA $L_RDNMI          ; Extra read: the poll read above already cleared the flag, so this changes nothing

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
    LDA $CA               ; Center X (M7X): low byte $CA here; the high byte $CB is masked to 5 bits (13-bit signed) below
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC               ; Center Y (M7Y): low byte $CC here; the high byte $CD is masked to 5 bits below
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE               ; X is not saved by this routine: Mode 7 scenes lose X here. Snapshot BG scroll ($BE/$C0 to $CE/$D0)
    STX $CE
    LDX $C0
    STX $D0

  loc_0280A6:
    REP #$20
    LDA $joypadInject     ; Check joypadInject — nonzero overrides entire input pipeline with scripted input
    BEQ loc_0280B6
    STA $joypadCurrent    ; Injected bits go straight to joypadCurrent: no remap, consumption mask, repeat or joypadMaskStd; joypadRaw untouched
    STZ $joypadInject     ; One-shot: a script must rewrite joypadInject every frame to hold a button
    PLA 
    PLP 
    RTL 

  loc_0280B6:
    LDA $joypadRaw        ; joypadRaw = the hardware read stored by the NMI handler (JOY1L); D-pad passes through unchanged
    AND #$0F00
    STA $joypadRemapped
    LDA $remapStart       ; Start remap: if target defined and physical Start ($1000) pressed, TSB into remapped
    BEQ loc_0280D2
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0280D2
    LDA $remapStart
    TSB $joypadRemapped

  loc_0280D2:
    LDA $remapSelect      ; Select remap: physical Select ($2000) — same check-and-merge pattern
    BEQ loc_0280E5
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0280E5
    LDA $remapSelect
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
    LDA $remapX           ; X remap: physical X ($0040)
    BEQ loc_028131
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_028131
    LDA $remapX
    TSB $joypadRemapped

  loc_028131:
    LDA $remapL           ; L remap: physical L ($0020)
    BEQ loc_028144
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_028144
    LDA $remapL
    TSB $joypadRemapped

  loc_028144:
    LDA $remapR           ; R remap: physical R ($0010)
    BEQ loc_028157
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_028157
    LDA $remapR
    TSB $joypadRemapped

  loc_028157:
    LDA $joypadRemapped   ; Finalize: remapped state → joypadCurrent and joypadRaw for this frame
    STA $joypadCurrent
    STA $joypadRaw        ; joypadRaw now holds the remapped (logical) mask until the next NMI stores JOY1L again
    AND $joypadHeld       ; joypadHeld = consumed buttons that are still pressed (game code adds bits with TSB)
    STA $joypadHeld
    BEQ loc_02817F
    AND $joypadMaskInv    ; Check if consumed-held buttons are eligible for auto-repeat (joypadMaskInv)
    BEQ loc_02817F
    LDA $joypadRepeatCounter ; Increment repeat counter — tracks consecutive held frames for repeat-eligible buttons
    INC 
    STA $joypadRepeatCounter
    CMP #$000C            ; 12-frame threshold: auto-repeat fires by clearing eligible bits from joypadHeld
    BNE loc_028182
    LDA $joypadMaskInv    ; Fire the repeat: drop the eligible bits from joypadHeld so they stay in joypadCurrent in THIS call
    TRB $joypadHeld

  loc_02817F:
    STZ $joypadRepeatCounter ; Reset counter (nothing eligible held, or the repeat just fired)

  loc_028182:
    LDA $joypadHeld       ; joypadCurrent = pressed buttons minus the still-consumed ones (a fired repeat is no longer in joypadHeld)
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
; Bit 7 = enable NMI on V-Blank.
; Bit 0 = enable joypad auto-read (hardware reads controller data during V-Blank into $4218–$421F).
; 
; Reads RDNMI first to clear any pending NMI flag, preventing an immediate spurious interrupt.

EnableNmiAndJoypad {
    PHP 
    SEP #$20
    PHA 
    LDA $L_RDNMI          ; Clear pending NMI flag before writing NMITIMEN
    LDA #$81              ; $81: NMI enable (bit 7) + joypad auto-read (bit 0)
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Write $01 to NMITIMEN ($4200): joypad auto-read ON, NMI OFF.
; 
; Bit 7 clear disables the NMI; bit 0 keeps the joypad auto-read enabled. The routine is called after the main loop's VBlank sync so that the frame's logic runs without NMI interruption, and by the SPC transfer routines around the port handshakes. EnableNmiAndJoypad turns the NMI back on.

DisableNmiKeepJoypad {
    PHP                   ; NMITIMEN = $01 below: NMI off, joypad auto-read on (DisableNmiKeepJoypad)
    SEP #$20
    PHA 
    LDA #$01              ; $01: joypad auto-read only (bit 0); bit 7 clear = NMI DISABLED
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Set INIDISP ($2100) to $00 — brightness 0, forced blank released.
; 
; Clears bit 7 (forced blank off) and sets brightness to $0. The screen appears completely black but the PPU continues processing internally. Used to darken the display while keeping the PPU active.

ScreenBlackout {
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
; Set INIDISP ($2100) to $80 — enter forced blank for VRAM access.
; 
; Sets bit 7 (forced blank on) with brightness 0. The PPU stops rendering, making VRAM, OAM, and CGRAM freely accessible for DMA transfers. Called before bulk VRAM operations.

EnterForcedBlank {
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
; Entry: A = number of frames to wait (A = 0 would wait 256 frames with an 8-bit A, 65,536 with a 16-bit A). VBlankWaitAndJoypad preserves A, so the DEC counts the frames. Joypad state is updated every frame during the wait only if the NMI runs (see the block note).

WaitFrames {
    JSL $@VBlankWaitAndJoypad ; Process one VBlank cycle (Mode 7 + joypad), decrement frame counter
    DEC 
    BNE WaitFrames
    RTL 
}