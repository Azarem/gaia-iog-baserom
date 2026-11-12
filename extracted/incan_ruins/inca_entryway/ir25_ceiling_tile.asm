; Falling ceiling tile of the Incan Ruins entryway (scene $25). Six copies at tiles (08,1A), (08,1C), (08,1E), (0A,1A), (0A,1C), (0A,1E).
; 
; Spawns hidden (the third actor-def byte #23 sets $2000 in $10) and nudges its position by (08,00). With flag $2F (the Blue Block was fitted into the slot by UseItem_DiamondBlock_Place) set at spawn it runs code_09C38D at once: it shows the tile, sets sprite priority to the minimum, clears collision on its tile, releases the joypad bits $CFFC and idles. With $2F clear it waits with WaitOnFlagByte(#2F, #01). When the flag turns on it locks the joypad ($CFFC), waits 60 ticks (WaitByte #3B), plays sound $1515, spawns camera_drift.CameraDriftLoopSimple for screen shake, waits 180 ticks (WaitByte #B3), stores a random byte in $08, yields once, subtracts $100 from its Y, shows the tile, sets the priority to the maximum and falls (StageSpriteLoopMoveY #18, #02, #0F). On landing it plays sound $1515, ends on frame #35 and runs code_09C38D.
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
    LDA #$CFFC
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
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}