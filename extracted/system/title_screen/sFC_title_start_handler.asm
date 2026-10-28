; Title / prologue Start handler (Bank 0B, 772529-772609): waits for Start, then sends the game to the diary menu (scene $FA).
; 
; Two actor-defs share one poll loop. sFC_title_start_handler is spawned with sFC_title_intro by scene_FC_actors (the title scene $FC list) and first waits WaitWord $021B = 540 ticks (~9 s) so the intro's opening seconds cannot be skipped. sFC_title_start_poll polls at once; it is spawned in the actor lists of the four prologue scenes ($8C-$8F, next to pr8C_prologue1/5, pr8D_prologue2, pr8E_prologue3 and pr8F_prologue4), so Start skips the prologue slides as well.
; 
; Both variants first mask nearly every button out of joypadCurrent (joypadMaskStd |= $FFFC; vanilla $FFF0, widened by transforms.json) and then poll with COP BranchIfPressed #$1001. In that mask word bit 0 is not a button: it makes the handler test joypadRaw instead of joypadCurrent (see docs/cop/families/input.md, BranchIfPressed), which is how Start ($1000) still gets through the mask. R is not tested.
; 
; On Start, TitleToDiaryTransition sets transitionBrightness = 0 and the transition parameters (gfxCacheIdxB = 0: speed 0; gfxCacheIdxA = 1: exit type 1 = instant blank, enter type 0 = graduated fade), queues scene $FA at ($0100,$0370) with COP QueueMapChange, yields one frame, runs one VBlankWaitAndJoypad with DP forced to $0000, and then holds INIDISP = $00 (force blank) every frame until the scene change replaces the actor.
---------------------------------------------

?INCLUDE 'vblank_joypad'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!transitionBrightness           0DB6
!INIDISP                        2100

---------------------------------------------

sFC_title_start_handler [
  actor-def < #00, #00, #38, {

; Title-scene variant: suppress the buttons, wait 540 ticks (WaitWord #$021B), then join the shared poll loop.

  TitleStartDelayedInit:
    LDA #$FFFC            ; Suppress nearly all buttons in joypadCurrent (Start is polled from joypadRaw)
    TSB $joypadMaskStd
    COP [WaitWord] ( #$021B ) ; WaitWord #$021B = 540 ticks (~9 sec) before accepting input
    BRA TitleStartPollLoop ; Join the shared poll loop
} >
]

sFC_title_start_poll [
  actor-def < #00, #00, #38, {

; Prologue-scene variant (spawned as sFC_title_start_poll): suppress the buttons and poll immediately.

  TitleStartPollInit:
    LDA #$FFFC            ; Suppress nearly all buttons in joypadCurrent (Start is polled from joypadRaw)
    TSB $joypadMaskStd

; Shared poll loop: re-enter every frame; Start (read from joypadRaw) -> TitleToDiaryTransition, otherwise RTL.

  TitleStartPollLoop:
    COP [SetEntryHere]    ; Re-enter each frame to poll input
    COP [BranchIfPressed] ( #$1001, &TitleToDiaryTransition ) ; Start ($1000), tested against joypadRaw (mask bit 0 = raw source) -> diary menu
    RTL                   ; No button → loop
} >
]

---------------------------------------------
; Start pressed: reset the transition parameters, queue the change to scene $FA (diary menu) at ($0100,$0370), yield one frame, run one VBlank sync with DP = $0000 (the actor's DP points at its slot, so it is swapped around the call), then keep the screen in force blank until the scene change takes over.

TitleToDiaryTransition {
    STZ $transitionBrightness ; transitionBrightness := 0
    LDA #$0000            ; Transition speed bytes := 0 (exit and enter)
    STA $gfxCacheIdxB
    LDA #$0001            ; Exit type 1 (instant blank), enter type 0 (graduated fade)
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #FA, #$0100, #$0370, #00, #$4400 ) ; Scene $FA (diary menu), pos ($100,$370)
    COP [SetEntryHereAndYield] ; Save the re-entry point and yield one frame
    PHD                   ; Save actor DP
    PHX                   ; Save actor slot index
    LDA #$0000            ; Set DP to system page for VBlank routine
    TCD 
    JSL $@vblank_joypad.VBlankWaitAndJoypad ; One VBlank sync before fade
    PLX 
    PLD 
    COP [SetEntryHere]    ; Re-enter below every frame (force blank stays on)
    SEP #$20
    LDA #$00              ; Force blank — screen off
    STA $INIDISP
    REP #$20
    RTL 
}