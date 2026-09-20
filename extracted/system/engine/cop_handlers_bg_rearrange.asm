?BANK 00

?INCLUDE 'event_blocks'
?INCLUDE 'system_core'

!sfxQueueCh1                    06F8
!deathActionIdx                 7F0024

---------------------------------------------

; COP #32 background-change stager taking one byte operand: an event-block index. Calls event_blocks.LookupEventBlock to queue a BG tilemap/palette swap without applying it immediately; the paired ApplyBgChange COP performs the animated transition. Used in ending sequences and Babel Tower cutscenes.

StageBgChange {
    TYX 
    LDA [$0A]             ; Read event-block index byte from script
    INC $0A
    AND #$00FF

  loc_00931F:
    JSL $@event_blocks.LookupEventBlock ; Look up event block and queue BG tilemap/palette swap
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #33 with no operands. Runs one UpdateFrameRender then loops AnimateEventBlock until carry set, calling UpdateFrameDialogue each iteration to drive the animated BG tilemap/palette transition to completion.

ApplyBgChange {
    TYX 
    SEP #$20              ; Switch to 8-bit for UpdateFrameRender (expects SEP #$20)
    JSL $@system_core.UpdateFrameRender ; Render one complete frame before starting transition
    JSL $@system_core.UpdateFrameDialogue ; Run dialogue-mode frame update
    REP #$20

  loc_009335:
    JSL $@event_blocks.AnimateEventBlock ; Animate one step of the event block tile swap
    BCS loc_009345        ; Carry set = animation complete, all tiles swapped
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue ; Render a frame between animation steps for visible transition
    REP #$20
    BRA loc_009335

  loc_009345:
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #34 with no operands. Uses the actor's deathActionIdx ($7F0024) as the event-block index, queues SFX $0F0F to both channels, then calls LookupEventBlock to stage the same BG swap as StageBgChange.

StageBgChangeFromDeathIdx {
    TYX 
    LDA $deathActionIdx, X ; Read event-block index from actor's deathActionIdx field
    PHA 
    LDA #$0F0F            ; Queue SFX $0F to both sound channels (tile-change sound effect)
    STA $sfxQueueCh1
    PLA 
    BRA loc_00931F
}