; Music playback lifecycle management actors (172096–172315, Bank 02).
; 
; Manages the multi-frame process of loading and starting music during scene transitions. Music loading is asynchronous — the SPC data transfer takes multiple frames, during which the game must continue processing (joypad input is suppressed, but rendering continues).
; 
; === PLAYBACK LIFECYCLE ===
; 
; 1. MusicPlaybackActor is spawned by the scene transition system when new music needs loading
; 2. Stores musicParentActor to orbitAngle for tracking, spawns SpcTransferMusicData child actor for the actual SPC data transfer
; 3. Suppresses joypad input (TSB $FFF0 to joypadMaskStd — masks D-pad during load)
; 4. Yields each frame until musicTransitionState reaches $FFFF (transfer complete)
; 5. Spawns MusicRenderSync to handle a single post-load rendering update
; 6. Polls APUIO1 for $FF — the SPC700 signals readiness after processing the uploaded data
; 7. Unmasks joypad (TRB $FFF0 from joypadMaskStd), spawns a second SpcTransferMusicData for any follow-up data block
; 8. Waits again for musicTransitionState == $FFFF, then WaitByte(1) for final sync
; 
; === RENDER SYNC ===
; 
; MusicRenderSync is a one-shot actor spawned mid-transfer: waits 72 frames ($48), clears the $1000 actor flag, zeros joypadMaskStd, calls UpdateFrameRender + DialogStringRenderer, then dies. This ensures the screen gets at least one rendering update during the music loading pause.
; 
; === ACTOR POOL GUARD ===
; 
; Both SpawnAfterFlags calls check for $1FC0 return (actor pool exhausted). On failure, code_02A0DD clears displayModeFlags bit 7 ($0080, music loading active) and kills the actor — the music load is abandoned gracefully.
; 
; === QUERY INTERFACE ===
; 
; IsMusicPlaying: Returns carry set if music is actively loading/playing (musicTransitionState nonzero OR displayModeFlags bit 7 set), carry clear otherwise. Used by other systems to gate operations that conflict with music loading.
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

; Music playback lifecycle manager actor. Spawned during scene transitions when new music needs loading. Stores musicParentActor, spawns SpcTransferMusicData child for the actual SPC data transfer, suppresses joypad input ($FFF0 → joypadMaskStd to mask D-pad during load), and yields each frame until musicTransitionState == $FFFF.
; 
; After the first transfer: spawns MusicRenderSync for a post-load screen update, copies render state ($20/$22) to the child actor, then polls APUIO1 for $FF (SPC700 readiness signal). On ready: unmasks joypad, spawns a second SpcTransferMusicData for follow-up data, waits again for $FFFF transition state, then WaitByte(1) for final sync.
; 
; Actor pool exhaustion ($1FC0 from SpawnAfterFlags) branches to code_02A0DD for graceful cleanup.

MusicPlaybackActor {
    LDA $musicParentActor ; Store musicParentActor to per-actor scratch (orbitAngle,X)
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn SpcTransferMusicData child actor for SPC data upload
    CPY #$1FC0            ; $1FC0 = actor pool exhausted — check spawn success
    BNE loc_02A056
    JMP $&code_02A0DD     ; Spawn failed: jump to cleanup (clear flags, die)

  loc_02A056:
    TXA                   ; Swap X/Y to access spawned child actor's slot
    TYX 
    TAY 
    LDA $26               ; Copy music block index ($26+1) to child's chatPtr for data lookup
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000            ; Set bit 12 ($1000) on child actor flags — marks as music transfer actor
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$FFF0            ; Suppress D-pad input during music loading ($FFF0 = all D-pad + shoulder)
    TSB $joypadMaskStd
    COP [SetEntryContinue] ; Yield — resume next frame to poll transfer state
    LDA $musicTransitionState ; Check if music transfer has completed ($FFFF = done)
    CMP #$FFFF
    BEQ loc_02A07D        ; Transfer complete: proceed to render sync phase
    RTL 

  loc_02A07D:
    COP [SpawnAfterFlags] ( @MusicRenderSync, #$2000 ) ; Spawn MusicRenderSync for post-load screen update
    LDA $20               ; Copy render context pointer ($20/$22) to child actor
    STA $0020, Y
    LDA $22
    STA $0022, Y
    LDA $0012, Y
    ORA #$1000            ; Set bit 12 ($1000) on render sync actor flags
    STA $0012, Y
    COP [SetEntryContinue] ; Yield — resume to poll SPC readiness
    SEP #$20
    LDA $APUIO1           ; Read SPC status from APUIO1 — $FF means sound engine is ready
    REP #$20
    AND #$00FF
    CMP #$00FF            ; Check for $FF (SPC700 music engine ready signal)
    BEQ loc_02A0A9
    RTL 

  loc_02A0A9:
    LDA #$FFF0            ; Music engine ready: unmask D-pad input
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn second SpcTransferMusicData for follow-up data block
    CPY #$1FC0            ; Check spawn success ($1FC0 = pool exhausted)
    BEQ code_02A0DD
    PHX 
    LDA $orbitAngle, X    ; Copy parent actor reference to child's chatPtr
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryContinue] ; Yield — resume to poll second transfer completion
    LDA $musicTransitionState ; Poll musicTransitionState for second transfer completion
    CMP #$FFFF
    BEQ loc_02A0DA
    RTL 

  loc_02A0DA:
    COP [WaitByte] ( #01 ) ; Final sync: wait 1 frame before cleanup
}

---------------------------------------------
; Music actor cleanup on failure or completion. Clears displayModeFlags bit 7 ($0080 = music loading active flag) and kills the actor via COP [Die]. Reached when SpawnAfterFlags returns $1FC0 (actor pool exhausted) or as the normal exit path after all transfers complete.

code_02A0DD {
    LDA #$0080            ; Clear music loading flag (displayModeFlags bit 7 = $0080)
    TRB $displayModeFlags
    COP [Die]             ; Kill this actor — music load complete or abandoned
}

---------------------------------------------
; One-shot post-music-load rendering actor. Waits 72 frames ($48) via COP [WaitByte] for the SPC to finish processing uploaded data, then clears bit 12 ($1000) from its own actor flags. Zeros joypadMaskStd to fully re-enable input, sets data bank to the render context ($22 → DBR), and calls UpdateFrameRender + DialogStringRenderer to process one complete rendering cycle. Dies after execution — ensures the screen updates at least once during the music loading pause.

MusicRenderSync {
    COP [WaitByte] ( #48 ) ; Wait 72 frames ($48) for SPC to process uploaded data
    LDA #$1000            ; Clear bit 12 ($1000) from own actor flags after wait
    TRB $12
    PHP 
    PHB 
    REP #$20              ; Zero joypadMaskStd — fully re-enable all input
    STZ $joypadMaskStd
    SEP #$20
    LDA $22               ; Set data bank to render context bank ($22 → DBR via PHA+PLB)
    PHA 
    PLB 
    LDY $20               ; Load render context Y offset from $20
    JSL $@system_core.UpdateFrameRender ; Call UpdateFrameRender for one complete rendering cycle
    REP #$20
    JSL $@DialogStringRenderer ; Call DialogStringRenderer to process any pending text
    PLB 
    PLP 
    COP [Die]             ; Die — one-shot rendering actor has completed
}

---------------------------------------------
; Query routine — returns carry flag indicating music loading/playback state. Checks musicTransitionState (nonzero = transition in progress) and displayModeFlags bit 7 ($0080 = music loading active). Returns CLC (carry clear) if no music activity, SEC (carry set) if music is loading or playing. Called by other game systems to gate operations that conflict with music loading.

IsMusicPlaying {
    LDA $musicTransitionState ; Check musicTransitionState — nonzero means transition in progress
    BNE loc_02A119
    LDA $displayModeFlags ; Check displayModeFlags bit 7 ($0080) — music loading active
    BIT #$0080
    BNE loc_02A119
    CLC                   ; Neither active: CLC (carry clear = no music activity)
    RTL 

  loc_02A119:
    SEC                   ; Music active: SEC (carry set = music loading or playing)
    RTL 
}