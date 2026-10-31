; Jingle-with-text actors started by COP MusicAndText ($19): play a short music track, show a dialogue string, then restore the scene music (172096–172315, Bank 02).
; 
; MusicAndText (cop_handlers_audio) allocates a thinker, points it at MusicJingleActor, flags it $1000 in $12 and stores its operands: $26 = track ID (every observed call uses $17), $20/$22 = dialogue string pointer and bank. Callers set displayModeFlags bit 7 ($0080) first, so while the transfer runs only actors flagged $1000 execute (RunActors_DisplayFiltered) and the rest of the scene is frozen.
; 
; === PLAYBACK LIFECYCLE ===
; 
; 1. MusicJingleActor saves musicParentActor ($06F2: the BGM id stored by the scene's music record; StartMusic does not update it, and pyCD_jackal and the Memory Melody item overwrite it with $0F and $0E) in orbitAngle
; 2. Spawns SpcTransferMusicData with chatPtr = $26 + 1 (music data index of the jingle) and flags it $1000
; 3. Masks the joypad (TSB $FFFC into joypadMaskStd, every button and the D-pad) and yields until musicTransitionState reaches $FFFF (the NMI finished the SPC block transfer)
; 4. Spawns MusicRenderSync, handing it the string pointer ($20/$22), then polls APUIO1 for $FF (the SPC700 replied)
; 5. Unmasks the joypad (TRB $FFFC) and spawns a second SpcTransferMusicData with chatPtr = the saved scene music, so the scene track resumes
; 6. Waits again for $FFFF, WaitByte #01 (2 ticks), then falls through into MusicLoadCleanup, which clears displayModeFlags bit 7 and dies
; 
; === RENDER SYNC ===
; 
; MusicRenderSync does WaitByte #48 (73 ticks), clears its own $1000 flag, zeros joypadMaskStd, sets DBR to the string bank ($22), then calls UpdateFrameRender and DialogStringRenderer (Y = $20) once to show the string, and dies.
; 
; === ACTOR POOL GUARD ===
; 
; Both SpawnAfterFlags calls check for a $1FC0 return (actor pool exhausted). On failure MusicLoadCleanup clears displayModeFlags bit 7 and kills the actor, so the music load is abandoned gracefully.
; 
; === QUERY INTERFACE ===
; 
; IsMusicPlaying: returns carry set while musicTransitionState is nonzero or displayModeFlags bit 7 is set, carry clear otherwise. Used by melody items, the global input handler and several NPC scripts to avoid starting new music or input while a jingle sequence is active.
---------------------------------------------

?BANK 02

?INCLUDE 'DialogStringRenderer'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'system_core'

!joypadMaskStd                  065A
!musicParentActor               06F2
!musicTransitionState           06FA
!displayModeFlags               09EC
!APUIO1                         2141
!chatPtr                        7F000A
!orbitAngle                     7F0010

---------------------------------------------

; Jingle sequence actor started by COP MusicAndText. Saves musicParentActor (the BGM id stored by the scene's music record; StartMusic does not update it) in orbitAngle, spawns SpcTransferMusicData to upload the jingle (chatPtr = $26 + 1), masks the joypad ($FFFC into joypadMaskStd) and yields each frame until musicTransitionState == $FFFF.
; 
; Then spawns MusicRenderSync (receives the string pointer $20/$22) and polls APUIO1 for $FF (the SPC700 replied). On reply it unmasks the joypad, spawns a second SpcTransferMusicData whose chatPtr is the saved scene music (so the scene track resumes), waits again for $FFFF and WaitByte #01 (2 ticks), then falls through into MusicLoadCleanup.
; 
; Actor pool exhaustion ($1FC0 from SpawnAfterFlags) branches to MusicLoadCleanup.

MusicJingleActor {
    LDA $musicParentActor ; Save musicParentActor ($06F2: the BGM id the scene's music record stored) in orbitAngle for the restore at step 5
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn SpcTransferMusicData child actor for SPC data upload
    CPY #$1FC0            ; $1FC0 = actor pool exhausted — check spawn success
    BNE MusicJingleAfterSpawn
    JMP $&MusicLoadCleanup ; Spawn failed: jump to cleanup (clear flags, die)

; Continuation after the first SpcTransferMusicData spawn: gives the child the jingle's music data index ($26 + 1 as chatPtr), sets $1000 in its $12 so it still runs in display-filter mode, masks the joypad (joypadMaskStd bits 2-15) and yields with SetEntryHere. On resume it polls musicTransitionState and continues at MusicJingleRenderSync once the value is $FFFF (upload complete).

  MusicJingleAfterSpawn:
    TXA                   ; Rotate X/Y (TXA/TYX/TAY): X = child, Y = this actor, while the child is configured
    TYX 
    TAY 
    LDA $26               ; Child chatPtr = track ID from $26 (set by MusicAndText) + 1 = music data index of the jingle
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000            ; Set $1000 in the child's $12 so it still runs in display-filter mode (displayModeFlags $0080)
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$FFFC            ; Mask every button and the D-pad (bits 2-15) while the jingle loads
    TSB $joypadMaskStd
    COP [SetEntryHere]    ; Yield — resume next frame to poll transfer state
    LDA $musicTransitionState ; Check if music transfer has completed ($FFFF = done)
    CMP #$FFFF
    BEQ MusicJingleRenderSync ; Transfer complete: proceed to render sync phase
    RTL 

; Runs after the jingle upload finished: spawns MusicRenderSync (with $1000 set in its $12) and hands it the dialogue string pointer ($20) and bank ($22), then yields and polls APUIO1 every frame. The value $FF (the SPC700's reply that its sound engine is ready) continues at MusicJingleSpcReady.

  MusicJingleRenderSync:
    COP [SpawnAfterFlags] ( @MusicRenderSync, #$2000 ) ; Spawn MusicRenderSync for post-load screen update
    LDA $20               ; Hand the dialogue string pointer ($20) and bank ($22) to MusicRenderSync
    STA $0020, Y
    LDA $22
    STA $0022, Y
    LDA $0012, Y
    ORA #$1000            ; Set $1000 so MusicRenderSync also runs in display-filter mode
    STA $0012, Y
    COP [SetEntryHere]    ; Yield — resume to poll SPC readiness
    SEP #$20
    LDA $APUIO1           ; Read SPC status from APUIO1 — $FF means sound engine is ready
    REP #$20
    AND #$00FF
    CMP #$00FF            ; Check for $FF (SPC700 music engine ready signal)
    BEQ MusicJingleSpcReady
    RTL 

; After the SPC reply: unmasks the joypad again, spawns a second SpcTransferMusicData whose chatPtr is the scene music index saved in orbitAngle (so the scene track is reloaded) and polls musicTransitionState; at $FFFF it continues at MusicJingleWaitFinal. Pool exhaustion branches to MusicLoadCleanup.

  MusicJingleSpcReady:
    LDA #$FFFC            ; SPC replied $FF: unmask the buttons again
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn the second SpcTransferMusicData to reload the scene music
    CPY #$1FC0            ; Check spawn success ($1FC0 = pool exhausted)
    BEQ MusicLoadCleanup
    PHX 
    LDA $orbitAngle, X    ; Saved scene music index (orbitAngle) becomes the child's chatPtr: reload the scene track
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryHere]    ; Yield — resume to poll second transfer completion
    LDA $musicTransitionState ; Poll musicTransitionState for second transfer completion
    CMP #$FFFF
    BEQ MusicJingleWaitFinal
    RTL 

; Final step of the jingle sequence: waits 2 ticks (COP WaitByte #01), then falls through into MusicLoadCleanup, which leaves display-filter mode and kills the actor.

  MusicJingleWaitFinal:
    COP [WaitByte] ( #01 ) ; Final sync: WaitByte #01 = 2 ticks, then fall through into MusicLoadCleanup
}

---------------------------------------------
; Music actor cleanup on failure or completion. Clears displayModeFlags bit 7 ($0080: display-filter mode set by the MusicAndText caller, which froze all actors not flagged $1000) and kills the actor via COP [Die]. Reached when SpawnAfterFlags returns $1FC0 (actor pool exhausted) or by falling through from the end of MusicJingleActor.

MusicLoadCleanup {
    LDA #$0080            ; Clear displayModeFlags bit 7 ($0080): leave display-filter mode so the frozen actors run again
    TRB $displayModeFlags
    COP [Die]             ; Kill this actor — music load complete or abandoned
}

---------------------------------------------
; One-shot actor that shows the MusicAndText string. Waits 73 ticks via COP [WaitByte] ( #48 ), clears its own $1000 flag, zeros joypadMaskStd to unmask input, sets DBR to the string bank ($22), then calls UpdateFrameRender and DialogStringRenderer (Y = string pointer from $20) and dies. It was given $20/$22 by MusicJingleActor.

MusicRenderSync {
    COP [WaitByte] ( #48 ) ; WaitByte #48 = 73 ticks before showing the text (inferred: the jingle plays meanwhile)
    LDA #$1000            ; Clear $1000 from own actor flags after the wait
    TRB $12
    PHP 
    PHB 
    REP #$20              ; Zero joypadMaskStd: unmask all input for the dialogue
    STZ $joypadMaskStd
    SEP #$20
    LDA $22               ; DBR = $22, the bank of the dialogue string (PHA+PLB)
    PHA 
    PLB 
    LDY $20               ; Y = dialogue string pointer from $20
    JSL $@system_core.UpdateFrameRender ; UpdateFrameRender: render one frame
    REP #$20
    JSL $@DialogStringRenderer ; DialogStringRenderer: show the string (Y = pointer, bank in DBR)
    PLB 
    PLP 
    COP [Die]             ; Die: the one-shot actor is done
}

---------------------------------------------
; Query routine: carry set while a jingle/melody sequence is active, carry clear otherwise. Active means musicTransitionState is nonzero (SPC transfer in progress) or displayModeFlags bit 7 ($0080) is set (display-filter mode, set by the MusicAndText callers and melody items until MusicLoadCleanup clears it). Called by melody items, GlobalInputHandler and several NPC scripts to avoid overlapping music or input.

IsMusicPlaying {
    LDA $musicTransitionState ; musicTransitionState nonzero: an SPC transfer is in progress
    BNE IsMusicPlayingYes
    LDA $displayModeFlags ; displayModeFlags bit 7 ($0080): display-filter mode still set
    BIT #$0080
    BNE IsMusicPlayingYes
    CLC                   ; Neither active: CLC (carry clear = no music activity)
    RTL 

; Shared exit of IsMusicPlaying that returns carry set: a music transfer is in progress or the display-filter flag is still set.

  IsMusicPlayingYes:
    SEC                   ; Music active: SEC (carry set = music loading or playing)
    RTL 
}