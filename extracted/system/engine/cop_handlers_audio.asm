; COP handlers for SPC700 audio communication and music playback (Bank $00, 8 COP handlers).
; 
; StartMusic (#04) allocates a thinker with AllocateActorAfter and sets its entry to SpcTransferMusicData for the asynchronous SPC upload. FadeThenStartMusic (#05) does the same but enters at SpcFadeOutHandshake, which first sends $F1 on APUIO0: the SPC engine's CmdFadeOut command (fade counters $30/$31 = $FF; docs/audio/spc-disassembly.md), so the 'fade' in the name is real but happens inside the SPC engine, not in 65816 code (not traced: whether it is audible before the following $01/$F0 commands). Both OR $1000 into the thinker's $12 (it keeps running while the world is frozen, as in MusicJingleActor), clear $1000 in its $10 and store the track in chatPtr.
; 
; PlaySoundCh2 (#06), PlaySoundCh1 (#07) and PlaySoundBoth (#08) write the sfx queue bytes sfxQueueCh1/Ch2 ($06F8/$06F9); WriteApuIo1 (#09) and WriteApuIo0 (#0A) write APUIO1/APUIO0 ($2141/$2140) directly.
; 
; MusicAndText (#19) allocates a pooled actor with ActorPoolAllocator, appends it to the list tail, CopyActorState, sets it to MusicJingleActor and stores the three operands ($0026 track, $0020 text pointer, $0022 text bank). On pool exhaustion the track is dropped and only the text is shown inline through DialogStringRenderer, then displayModeFlags bit 7 is cleared.
; 
; Uses in extracted/: PlaySoundCh1 244, PlaySoundCh2 92, PlaySoundBoth 72, StartMusic 57, MusicAndText 22, FadeThenStartMusic 14, WriteApuIo0 7, WriteApuIo1 4.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'DialogStringRenderer'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'music_actors'
?INCLUDE 'system_core'

!actorListLast                  0058
!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!displayModeFlags               09EC
!APUIO0                         2140
!APUIO1                         2141
!chatPtr                        7F000A

---------------------------------------------

; COP #04 with one byte operand (music bundle ID). Allocates a thinker with AllocateActorAfter, sets its entry to SpcTransferMusicData, ORs $1000 into its $12 and clears $1000 in its $10 (the mask is $EFFF; it is not the $0800 render bit), and stores the music ID in chatPtr. The thinker runs the SPC handshake and upload asynchronously.

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
    ORA #$1000            ; Set $1000 in the child's $12 so it keeps running in display-filter mode (as MusicJingleActor does)
    STA $0012, X
    LDA $0010, X
    AND #$EFFF            ; Clear $1000 in the child's $10 (mask $EFFF clears bit 12, not $0800); meaning of that bit not traced
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
; COP #05 with one byte operand (music bundle ID). Same allocation, $12/$10 flag handling and chatPtr as StartMusic, but the thinker's entry is SpcFadeOutHandshake: it sends $F1 on APUIO0 (the SPC engine's CmdFadeOut, performed inside the SPC), waits for the echo, sends $01, and falls into SpcTransferMusicData when the SPC answers zero. Whether the fade is audible before the following $01/$F0 commands is not traced.

FadeThenStartMusic {
    TYX 
    PHX 
    JSR $&actor_pool.AllocateActorAfter
    TYX 
    LDA #$&hdma_dma_spc.SpcFadeOutHandshake ; Set thinker entry to SpcFadeOutHandshake (fade-before-play path)
    STA $0000, X
    LDA #$*hdma_dma_spc.SpcFadeOutHandshake
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
    SEP #$20              ; 8-bit store: sfxQueueCh2 is a one-byte WRAM queue slot, not an I/O register
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
    SEP #$20              ; 8-bit store: sfxQueueCh1 is a one-byte WRAM queue slot
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
; COP #19 with one byte (track ID), one word (text pointer), and one byte (data bank). On pool success, allocates via ActorPoolAllocator, copies actor state, sets MusicJingleActor, and stores operands in $0026/$0020/$0022. On pool exhaustion, falls back to inline DialogStringRenderer with temporary data bank, joypad input suppressed, and displayModeFlags bit $80 cleared.

MusicAndText {
    TYX 
    PHD                   ; Save caller's direct page for later restoration
    LDA #$0000            ; Set DP=0 for WRAM direct-page access during allocation
    TCD 
    JSL $@actor_pool.ActorPoolAllocator ; ActorPoolAllocator — get free slot for music+text thinker
    BCS loc_008836        ; Pool exhausted → jump to inline fallback path
    TYX 
    LDY $actorListLast    ; Load thinker list tail pointer ($0058)
    TXA 
    STA $0006, Y          ; Link new actor as next of current tail
    STA $actorListLast    ; Update thinker list tail to new actor
    TYA 
    STA $0004, X          ; Set new actor's prev pointer to old tail
    STZ $0006, X          ; New actor is now tail: clear next pointer (null terminator)
    TXY 
    PLA                   ; Pop saved DP and restore caller's direct page
    TCD 
    TAX 
    JSR $&actor_pool.CopyActorState ; Copy actor state from parent to new music+text thinker
    LDA #$&music_actors.MusicJingleActor ; Set entry point to MusicJingleActor for async playback
    STA $0000, Y
    LDA #$*music_actors.MusicJingleActor
    STA $0002, Y
    LDA #$1000            ; $12 = $1000 (overwrites): keeps running in display-filter mode
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
    LDA #$0080            ; Leave display-filter mode (bit 7, set by the calling script); the track is not played on this path
    TRB $displayModeFlags
    LDA $0A
    STA $02, S
    RTI 
}