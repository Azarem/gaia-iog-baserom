; Title screen Start button handler — polls for Start or R input and transitions to the diary/save menu.
; 
; Two actor-defs share a common button-check loop. sFC_actor_0BC9AE adds a $021B-frame (~9 second)
; delay before accepting input, preventing accidental skips during the intro sequence.
; sFC_actor_0BC9BD enters the poll loop immediately for respawned or quick-entry cases.
; 
; When Start or R is detected, TitleToDiaryTransition clears GFX cache state, queues a map change to
; scene $FA (diary menu) at position ($100, $370), performs one manual VBlank sync, and fades
; to black (INIDISP = $00) before the transition completes.
---------------------------------------------

?INCLUDE 'vblank_joypad'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!INIDISP                        2100

---------------------------------------------

sFC_title_start_handler [
  actor-def < #00, #00, #38, {

  TitleStartDelayedInit:
    LDA #$FFF0            ; Mask all joypad input except Start/Select/L/R
    TSB $joypadMaskStd
    COP [WaitWord] ( #$021B ) ; Wait 539 frames (~9 sec) before accepting input
    BRA loc_0BC9C6        ; Fall through to shared button poll
} >
]

sFC_actor_0BC9BD [
  actor-def < #00, #00, #38, {

  TitleStartPollInit:
    LDA #$FFF0            ; Mask all joypad input except Start/Select/L/R
    TSB $joypadMaskStd

  loc_0BC9C6:
    COP [SetEntryHere]    ; Re-enter each frame to poll input
    COP [BranchIfPressed] ( #$1001, &TitleToDiaryTransition ) ; Start ($1000) or R ($0001) → begin game
    RTL                   ; No button → loop
} >
]

---------------------------------------------
; Transition to diary menu — clears GFX state, queues scene $FA, syncs VBlank, and fades to black.
; Manually sets DP = $0000 for the VBlank call since actor DP points to the actor slot.

TitleToDiaryTransition {
    STZ $0DB6             ; Clear dialogue/state scratch
    LDA #$0000            ; Reset transition effect to none
    STA $gfxCacheIdxB
    LDA #$0001            ; Instant blank transition type
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #FA, #$0100, #$0370, #00, #$4400 ) ; Scene $FA (diary menu), pos ($100,$370)
    COP [SetEntryHereAndYield] ; Mark actor for cleanup after transition
    PHD                   ; Save actor DP
    PHX                   ; Save actor slot index
    LDA #$0000            ; Set DP to system page for VBlank routine
    TCD 
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; One VBlank sync before fade
    PLX 
    PLD 
    COP [SetEntryHere]
    SEP #$20
    LDA #$00              ; Force blank — screen off
    STA $INIDISP
    REP #$20
    RTL 
}