; Falling ceiling tile trap in the Inca entryway — shakes then falls.
; 
; Waits for flag $2F to not yet be set. Locks joypad, waits $3B frames,
; plays rumble SFX ($1515), spawns camera_drift for screen shake,
; waits $B3 frames, then drops the tile: teleports Y position up by
; $100 pixels and falls with TRB $2000. Triggers on ceiling event.
---------------------------------------------

?INCLUDE 'camera_drift'

!joypadMaskStd                  065A

---------------------------------------------

ir25_ceiling_tile [
  actor-def < #18, #00, #23, {

  code_09C33E:
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_09C38D )
    COP [WaitOnFlagByte] ( #2F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftLoopSimple, #$2000 )
    COP [WaitByte] ( #B3 )
    COP [RngByte]
    STA $08
    COP [SetEntryHereAndYield]
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [SetPriorityMax]
    COP [StageSpriteLoopMoveY] ( #18, #02, #0F )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$1515 )
    COP [ClearPriorityMax]
    COP [StageSpriteMoveY] ( #18, #35 )
    COP [AnimOnce]
    BRA code_09C38D
} >
]

code_09C38D {
    LDA #$2000
    TRB $10
    COP [SetPriorityMin]
    COP [ClearCollisionHere]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}