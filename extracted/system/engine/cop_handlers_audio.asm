; COP handlers for SPC700 audio communication and music playback (Bank $00, 8 handlers).
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
    PHX 
    JSR $&actor_pool.AllocateActorAfter ; Allocate pooled thinker actor slot after current in list
    TYX 
    LDA #$&hdma_dma_spc.SpcTransferMusicData
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcTransferMusicData
    STA $0002, X
    LDA $0012, X
    ORA #$1000            ; ORA #$1000: thinker flag — SPC music transfer in progress
    STA $0012, X
    LDA $0010, X
    AND #$EFFF            ; AND #$EFFF: suppress actor render until music thinker ready
    STA $0010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X       ; Music track ID stored in thinker chatPtr ($7F000A)
    PLX 
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
    LDA #$&hdma_dma_spc.SpcCheckMusicReady
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh2
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #07 with one byte operand (SFX ID). Writes the byte directly to sfxQueueCh1 ($06F8) for channel-1 sound effect playback.

PlaySoundCh1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #08 with one word operand (two SFX bytes packed). Stores the entire 16-bit value to sfxQueueCh1 as a word, filling both $06F8 and $06F9 in one write.

PlaySoundBoth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $sfxQueueCh1      ; PlaySoundBoth: write second SFX byte without reading operand
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #09 with one byte operand. Writes the byte directly to APU I/O port APUIO1 ($2141) for SPC700 communication.

WriteApuIo1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0A with one byte operand. Writes the byte directly to APU I/O port APUIO0 ($2140) for SPC700 communication.

WriteApuIo0 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO0           ; Direct write to APUIO0 ($2140) SPC700 communication port
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #19 with one byte (track ID), one word (text pointer), and one byte (data bank). On pool success, allocates via ActorPoolAllocator, copies actor state, sets MusicPlaybackActor, and stores operands in $0026/$0020/$0022. On pool exhaustion, falls back to inline DialogStringRenderer with temporary data bank, joypad input suppressed, and displayModeFlags bit $80 cleared.

MusicAndText {
    TYX 
    PHD 
    LDA #$0000
    TCD 
    JSL $@actor_pool.ActorPoolAllocator ; ActorPoolAllocator — get free slot for music+text thinker
    BCS loc_008836
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&actor_pool.CopyActorState
    LDA #$&music_actors.MusicPlaybackActor
    STA $0000, Y
    LDA #$*music_actors.MusicPlaybackActor
    STA $0002, Y
    LDA #$1000
    STA $0012, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0026, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0020, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0022, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_008836:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    PHP 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA $joypadMaskStd
    STZ $joypadMaskStd    ; STZ joypadMaskStd: block player input during dialogue render
    PHA 
    LDA [$0A]
    INC $0A               ; DialogStringRenderer with temporary data bank from script
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    JSL $@system_core.UpdateFrameRender
    REP #$20
    JSL $@DialogStringRenderer
    PLA 
    STA $joypadMaskStd
    PLB 
    PLP 
    LDA #$0080
    TRB $displayModeFlags
    LDA $0A
    STA $02, S
    RTI 
}