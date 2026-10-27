; Event-block background-change COP handlers (37655–37728, Bank 00).
; 
; - StageBgChange (COP #32): loads the event block named by a script byte into the event-block work variables; nothing is drawn yet.
; - ApplyBgChange (COP #33): animates the staged tile swap to completion, one VRAM-queue batch per frame.
; - StageBgChangeFromDeathIdx (COP #34): like StageBgChange but takes the index from the actor's deathActionIdx field (the event-block byte of the scene actor record) and queues SFX $0F first.
; 
; Scripts use them as a StageBgChange + ApplyBgChange pair (102 StageBgChange sites: switches, doors, breakable walls, statues, boss rooms, the ending) or via SpawnFieldRevealEffect (COP #34). Handlers return by writing the next script address into the COP stack frame ($02,S) and RTI.
---------------------------------------------

?BANK 00

?INCLUDE 'event_blocks'
?INCLUDE 'system_core'

!sfxQueueCh1                    06F8
!deathActionIdx                 7F0024

---------------------------------------------

; COP #32 with one byte operand: an event-block index. Calls event_blocks.LookupEventBlock, which matches the entry against sceneCurrent and loads its source/destination tile rectangles into the event-block work variables; nothing is drawn yet (the paired ApplyBgChange animates it). LookupEventBlock's carry result (set = no entry for this scene) is ignored.

StageBgChange {
    TYX 
    LDA [$0A]             ; Read event-block index byte from script ($0A = argument pointer)
    INC $0A
    AND #$00FF

  loc_00931F:
    JSL $@event_blocks.LookupEventBlock ; Match the event block to this scene and stage its tile rectangles (shared with StageBgChangeFromDeathIdx)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #33 with no operands. Renders one frame (UpdateFrameRender + UpdateFrameDialogue), then loops AnimateEventBlock — each call swaps tiles and queues the on-screen ones for VRAM until the queue is full or all tiles are done — with an UpdateFrameDialogue frame between calls to flush the queue. Carry set from AnimateEventBlock = all tiles processed. Ends with one more frame.

ApplyBgChange {
    TYX 
    SEP #$20              ; Switch to 8-bit for UpdateFrameRender (expects SEP #$20)
    JSL $@system_core.UpdateFrameRender ; Render one complete frame before starting transition
    JSL $@system_core.UpdateFrameDialogue ; Run dialogue-mode frame update
    REP #$20

  loc_009335:
    JSL $@event_blocks.AnimateEventBlock ; Animate one step of the event block tile swap
    BCS loc_009345        ; Carry set = all tiles processed; clear = VRAM queue full, flush it with a frame and call again
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
; COP #34 with no operands. Uses the actor's deathActionIdx ($7F0024, the event-block byte of its scene record) as the event-block index, queues SFX $0F on both sound channels, then jumps into StageBgChange's LookupEventBlock tail to stage the swap. Only SpawnFieldRevealEffect uses it.

StageBgChangeFromDeathIdx {
    TYX 
    LDA $deathActionIdx, X ; Read event-block index from actor's deathActionIdx field
    PHA 
    LDA #$0F0F            ; Word store fills sfxQueueCh1/Ch2 ($06F8/$06F9) with SFX $0F
    STA $sfxQueueCh1
    PLA 
    BRA loc_00931F
}