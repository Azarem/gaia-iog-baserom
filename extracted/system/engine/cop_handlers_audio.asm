; COP handlers for SPC700 audio communication and music playback (Bank $00, 8 COP handlers).
; 
; StartMusic allocates a thinker actor via AllocateActorAfter and sets its entry to SpcTransferMusicData for asynchronous SPC handshake. FadeThenStartMusic uses SpcCheckMusicReady for fade-before-play. PlaySoundCh1/Ch2/Both queue sound effects to APU channels via sfxQueueCh1/Ch2. WriteApuIo0/1 write directly to SPC I/O ports $2140/$2141.
; 
; MusicAndText is the most complex handler: it allocates a pooled actor via ActorPoolAllocator, copies actor state, sets it to MusicPlaybackActor, and reads three operands (track ID, text pointer, bank byte). On pool exhaustion it falls back to inline DialogStringRenderer rendering with temporary data bank.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'DialogStringRenderer'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'music_actors'
?INCLUDE 'system_core'

!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!displayModeFlags               09EC
!APUIO0                         2140
!APUIO1                         2141
!chatPtr                        7F000A

---------------------------------------------

; COP #04 music-start handler taking one byte operand: the music bundle ID. Allocates a new actor slot via AllocateActorAfter, sets its entry point to SpcTransferMusicData, sets status bit $1000 and clears $0800, and stores the music ID in chatPtr. The spawned transfer actor handles the SPC handshake asynchronously. Used in cutscenes throughout the game.

StartMusic {
    TYX 
    PHX                   ; Save current actor X for restoration after allocation
    JSR $&actor_pool.AllocateActorAfter ; Allocate pooled thinker actor slot after current in list
    TYX 
    LDA #$&hdma_dma_spc.SpcTransferMusicData ; Set new thinker entry point to SpcTransferMusicData
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcTransferMusicData
    STA $0002, X
    LDA $0012, X
    ORA #$1000            ; Thinker flag — SPC music transfer in progress
    STA $0012, X
    LDA $0010, X
    AND #$EFFF            ; Clear $0800 on new thinker (suppress actor render)
    STA $0010, X
    LDA [$0A]             ; Read music bundle ID byte from script
    INC $0A
    AND #$00FF
    STA $chatPtr, X       ; Music track ID stored in thinker chatPtr ($7F000A)
    PLX                   ; Restore X = original calling actor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #05 with one byte operand (music bundle ID). Allocates a thinker actor after the current one via AllocateActorAfter, sets entry to SpcCheckMusicReady (fade-before-play path), sets thinker flag #$1000, clears render flag #$0800, and stores the music ID in chatPtr.

FadeThenStartMusic {
    TYX 
    PHX 
    JSR $&actor_pool.AllocateActorAfter
    TYX 
    LDA #$&hdma_dma_spc.SpcCheckMusicReady ; Set thinker entry to SpcCheckMusicReady (fade-before-play path)
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcCheckMusicReady
    STA $0002, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    LDA $0010, X
    AND #$EFFF
    STA $0010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #06 with one byte operand (SFX ID). Writes the byte directly to sfxQueueCh2 ($06F9) for channel-2 sound effect playback.

PlaySoundCh2 {
    TYX 
    LDA [$0A]             ; Read SFX ID byte for channel 2
    INC $0A
    AND #$00FF
    SEP #$20              ; Switch to 8-bit for byte-size I/O register write
    STA $sfxQueueCh2      ; Queue SFX byte to channel 2 ($06F9)
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #07 with one byte operand (SFX ID). Writes the byte directly to sfxQueueCh1 ($06F8) for channel-1 sound effect playback.

PlaySoundCh1 {
    TYX 
    LDA [$0A]             ; Read SFX ID byte for channel 1
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh1      ; Queue SFX byte to channel 1 ($06F8)
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #08 with one word operand (two SFX bytes packed). Stores the entire 16-bit value to sfxQueueCh1 as a word, filling both $06F8 and $06F9 in one write.

PlaySoundBoth {
    TYX 
    LDA [$0A]             ; Read packed word: low byte=ch1, high byte=ch2
    INC $0A
    INC $0A
    STA $sfxQueueCh1      ; Word write: fills both sfxQueueCh1 ($06F8) and sfxQueueCh2 ($06F9)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #09 with one byte operand. Writes the byte directly to APU I/O port APUIO1 ($2141) for SPC700 communication.

WriteApuIo1 {
    TYX 
    LDA [$0A]             ; Read byte for APU I/O port 1
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO1           ; Direct write to APUIO1 ($2141) for SPC700 command
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0A with one byte operand. Writes the byte directly to APU I/O port APUIO0 ($2140) for SPC700 communication.

WriteApuIo0 {
    TYX 
    LDA [$0A]             ; Read byte for APU I/O port 0
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO0           ; Direct write to APUIO0 ($2140) for SPC700 command
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #19 with one byte (track ID), one word (text pointer), and one byte (data bank). On pool success, allocates via ActorPoolAllocator, copies actor state, sets MusicPlaybackActor, and stores operands in $0026/$0020/$0022. On pool exhaustion, falls back to inline DialogStringRenderer with temporary data bank, joypad input suppressed, and displayModeFlags bit $80 cleared.

MusicAndText {
    TYX 
    PHD                   ; Save caller's direct page for later restoration
    LDA #$0000            ; Set DP=0 for WRAM direct-page access during allocation
    TCD 
    JSL $@actor_pool.ActorPoolAllocator ; ActorPoolAllocator — get free slot for music+text thinker
    BCS loc_008836        ; Pool exhausted → jump to inline fallback path
    TYX 
    LDY $0058             ; Load thinker list tail pointer ($0058)
    TXA 
    STA $0006, Y          ; Link new actor as next of current tail
    STA $0058             ; Update thinker list tail to new actor
    TYA 
    STA $0004, X          ; Set new actor's prev pointer to old tail
    STZ $0006, X          ; New actor is now tail: clear next pointer (null terminator)
    TXY 
    PLA                   ; Pop saved DP and restore caller's direct page
    TCD 
    TAX 
    JSR $&actor_pool.CopyActorState ; Copy actor state from parent to new music+text thinker
    LDA #$&music_actors.MusicPlaybackActor ; Set entry point to MusicPlaybackActor for async playback
    STA $0000, Y
    LDA #$*music_actors.MusicPlaybackActor
    STA $0002, Y
    LDA #$1000            ; Set thinker status $1000 (active music/text actor)
    STA $0012, Y
    LDA [$0A]             ; Read track ID byte → store in new actor $0026
    INC $0A
    AND #$00FF
    STA $0026, Y
    LDA [$0A]             ; Read text pointer word → store in new actor $0020
    INC $0A
    INC $0A
    STA $0020, Y
    LDA [$0A]             ; Read data bank byte → store in new actor $0022
    INC $0A
    AND #$00FF
    STA $0022, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_008836:
    PLA                   ; Pool exhaustion fallback: restore caller DP for inline rendering
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    PHP                   ; Save processor flags and data bank before inline dialogue
    PHB 
    LDA [$0A]             ; Read text pointer word from script
    INC $0A
    INC $0A
    TAY 
    LDA $joypadMaskStd    ; Load current joypad mask before suppressing input
    STZ $joypadMaskStd    ; Block all player input during inline dialogue render
    PHA 
    LDA [$0A]             ; Read data bank byte for DialogStringRenderer
    INC $0A               ; DialogStringRenderer with temporary data bank from script
    AND #$00FF
    SEP #$20
    PHA                   ; Push bank byte and PLB to set temporary DBR for text data
    PLB 
    JSL $@system_core.UpdateFrameRender ; Render one frame to sync screen before dialogue text
    REP #$20
    JSL $@DialogStringRenderer ; Run inline DialogStringRenderer with temporary data bank
    PLA                   ; Restore original joypad mask (re-enable player input)
    STA $joypadMaskStd
    PLB 
    PLP 
    LDA #$0080            ; Clear displayModeFlags bit $80 (dialogue overlay complete)
    TRB $displayModeFlags
    LDA $0A
    STA $02, S
    RTI 
}