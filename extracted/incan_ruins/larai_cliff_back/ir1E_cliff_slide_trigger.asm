; Cliff slide event of the Larai Cliff back scene ($1E).
; 
; Until flags $30 and $31 (both Incan statues on their mantels) are set, it runs every frame: SetFlagByte #00 while playerYPos is below $0110 and ClearFlagByte #00 otherwise (scratch flag $00, read by the player's idle sprite code). When both flags are set it sets scratch $00 for good, plays sound $1616 and polls BranchIfPlayerAt for the exact pixels (01E8,0120) and (01E7,0120). On a match it locks the joypad ($EFFC), plays sound $1616, spawns 40 debris helpers (LoopStart #28 passes, one every 9 ticks (JumpAfterDelay #$0008); code_09C51B starts each at X $02A0, Y $0090 plus a random byte and moves it along X, then dies), writes $FFF8 to playerSpeedEw, unlocks the joypad, waits 60 ticks (WaitByte #3B) and polls again.
---------------------------------------------

!joypadMaskStd                  065A
!playerYPos                     09A4
!playerSpeedEw                  09B2

---------------------------------------------

ir1E_cliff_slide_trigger [
  actor-def < #00, #00, #30, {

  code_09C4B5:
    COP [SetEntryHereAndYield]
    LDA $playerYPos
    CMP #$0110
    BCS loc_09C4C4
    COP [SetFlagByte] ( #00 )
    BRA loc_09C4C7

  loc_09C4C4:
    COP [ClearFlagByte] ( #00 )

  loc_09C4C7:
    COP [BranchOnFlagByte] ( #30, #00, &code_09C4B5 )
    COP [BranchOnFlagByte] ( #31, #00, &code_09C4B5 )
    COP [SetFlagByte] ( #00 )
    COP [PlaySoundBoth] ( #$1616 )

  loc_09C4DA:
    COP [SetEntryHere]
    COP [BranchIfPlayerAt] ( #$01E8, #$0120, &code_09C4ED )
    COP [BranchIfPlayerAt] ( #$01E7, #$0120, &code_09C4ED )
    RTL 
} >
]

code_09C4ED {
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [PlaySoundBoth] ( #$1616 )
    COP [LoopStart] ( #28 )
    COP [SpawnAfterFlags] ( @code_09C51B, #$1000 )
    COP [JumpAfterDelay] ( @code_09C508, #$0008 )
}

code_09C508 {
    COP [LoopEnd]
    LDA #$FFF8
    STA $playerSpeedEw
    LDA #$EFFC
    TRB $joypadMaskStd
    COP [WaitByte] ( #3B )
    BRA loc_09C4DA
}

code_09C51B {
    LDA #$02A0
    STA $14
    COP [RngByte]
    CLC 
    ADC #$0090
    STA $16
    COP [RngByte]
    AND #$0003
    BEQ loc_09C53B
    DEC 
    BEQ loc_09C544
    COP [StageSpriteLoopMoveX] ( #1A, #40, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_09C53B:
    COP [StageSpriteLoopMoveX] ( #1B, #40, #0E )
    COP [AnimLoop]
    COP [Die]

  loc_09C544:
    COP [StageSpriteLoopMoveX] ( #1C, #40, #10 )
    COP [AnimLoop]
    COP [Die]
}