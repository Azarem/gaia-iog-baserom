; Boot logo sequence actor — scene $FB master controller for publisher/developer splash screens.
; 
; Orchestrates the two-phase logo sequence during power-on. Uses flag byte #10 to track progress:
; first visit plays sprite loop #01 (first logo), sets the flag, and reloads scene $FB.
; Second visit plays sprite loop #00 (second logo), clears the flag, and transitions to scene $FC (title screen).
; 
; Detects PAL/NTSC via STAT78 bit 4. PAL consoles skip the sprite-based logos entirely and
; display a text-only boot screen via BG3 strings (BootLogoPalTextFallback).
; 
; === HARDWARE SETUP ===
; 
; Sets displayModeFlags bit 14 ($4000) for boot display mode. Enables FastROM via MEMSEL = $01.
; TM = $10 puts BG1 on the main screen for logo rendering. Joypad mask $FFF0 blocks all D-pad
; and face button input during the sequence.
---------------------------------------------

?INCLUDE 'system_strings'

!joypadMaskStd                  065A
!displayModeFlags               09EC
!TM                             212C
!STAT78                         213F
!MEMSEL                         420D
!cgramPalette                   7F0A00

---------------------------------------------

sFB_boot_logo [
  actor-def < #00, #00, #18, {

  BootLogoInit:
    LDA #$4000            ; Bit 14: boot display mode
    TSB $displayModeFlags
    LDA #$0000            ; Clear CGRAM palette base
    STA $cgramPalette
    SEP #$20
    LDA #$01              ; Enable FastROM (3.58 MHz bus)
    STA $MEMSEL
    LDA #$10              ; BG1 on main screen for logo sprites
    STA $TM
    REP #$20
    LDA #$FFF0            ; Mask all joypad input during logos
    TSB $joypadMaskStd
    SEP #$20
    LDA $STAT78           ; PPU status register
    BIT #$10              ; Bit 4: PAL/NTSC detection (1=PAL)
    BEQ loc_0BC8EA        ; NTSC → normal sprite logo sequence
    JMP $&BootLogoPalTextFallback ; PAL → text-only boot screen

  loc_0BC8EA:
    REP #$20
    COP [NudgePosition] ( #08, #00 ) ; Nudge X +8px for sprite centering
    COP [BranchOnFlagByte] ( #10, #01, &BootLogoSecondPhase ) ; Flag #10 set? → second logo phase
    COP [NudgePosition] ( #00, #F0 ) ; Nudge Y −16px ($F0 signed)
    COP [StageSpriteLoop] ( #01, #02 ) ; First logo: sprite loop #01, 2 ticks
    COP [AnimLoop]
    COP [SetFlagByte] ( #10 ) ; Mark first logo as shown
    COP [QueueMapChange] ( #FB, #$0000, #$0000, #00, #$1100 ) ; Reload scene $FB for second logo
    COP [Die]
} >
]

---------------------------------------------
; Second logo phase — plays sprite loop #00, clears the tracking flag, and transitions to the title screen.

BootLogoSecondPhase {
    COP [StageSpriteLoop] ( #00, #02 ) ; Second logo: sprite loop #00, 2 ticks
    COP [AnimLoop]
    COP [ClearFlagByte] ( #10 ) ; Reset flag for next power cycle
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 ) ; Transition to title screen (scene $FC)
    COP [Die]
}
---------------------------------------------

; PAL region fallback — loads a palette and displays text-only boot screen via BG3 strings.
; Skips sprite logos entirely. TM = $04 enables BG3 only (text layer, no sprite BGs).

BootLogoPalTextFallback {
    REP #$20
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 ) ; Load boot screen palette
    LDA #$0000
    STA $cgramPalette
    COP [RunBg3Script] ( @system_strings.boot_screen_strings ) ; Render text-only boot screen
    SEP #$20
    LDA #$04              ; BG3 only — text layer for PAL boot
    STA $TM
    REP #$20
    COP [SetEntryHere]    ; Loop indefinitely (PAL has no logo exit)
    RTL 
}