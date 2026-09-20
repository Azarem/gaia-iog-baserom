; Mine elevator — moves player between upper and lower mine levels.
; 
; Checks player X position to determine which floor: X < $30 means
; upper floor (tile pos 4,8), otherwise lower floor (tile pos $5C,$34).
; Waits for player to step onto the platform at specific coordinates.
; During ride: locks joypad, animates cage sprite moving frame by frame,
; physically repositions the player actor each tick to match, plays
; ratchet SFX (#0C) every 16 frames. D-pad during ride triggers
; InitPlayerScriptVariant for facing direction. Two child actors
; (elevator_stop_y, elevator_stop_x) handle edge scrolling limits
; by ping-ponging between map bounds.
---------------------------------------------

?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A
!mapBoundsX                     0692
!mapBoundsY                     0696
!playerXPos                     09A2
!playerActor                    09AA
!COLDATA                        2132

---------------------------------------------

dm43_elevator [
  actor-def < #34, #01, #03, {

  code_0AA5A9:
    SEP #$20
    LDA #$23
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    LDA $playerXPos
    CMP #$0030
    BCS loc_0AA5FE
    COP [SetTilePos] ( #04, #08 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0048, #$0080, &code_0AA5CE )
    RTL 
} >
]

code_0AA5CE {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]

  loc_0AA5D6:
    COP [StageSpriteMoveXY] ( #34, #03, #01 )
    COP [AnimOnce]
    JSR $&code_0AA63D
    LDY $playerActor
    LDA $14
    INC 
    STA $0014, Y
    LDA $16
    STA $0016, Y
    CMP #$0340
    BEQ loc_0AA5F5
    BRA loc_0AA5D6

  loc_0AA5F5:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 

  loc_0AA5FE:
    COP [SetTilePos] ( #5C, #34 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$05C8, #$0340, &code_0AA60D )
    RTL 
}

code_0AA60D {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]

  loc_0AA615:
    COP [StageSpriteMoveXY] ( #34, #04, #02 )
    COP [AnimOnce]
    JSR $&code_0AA63D
    LDY $playerActor
    LDA $14
    DEC 
    STA $0014, Y
    LDA $16
    STA $0016, Y
    CMP #$0080
    BEQ loc_0AA634
    BRA loc_0AA615

  loc_0AA634:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_0AA63D {
    LDA $0036
    AND #$000F
    BNE loc_0AA648
    COP [PlaySoundCh2] ( #0C )

  loc_0AA648:
    COP [BranchIfButton] ( #$0801, &code_0AA661 )
    COP [BranchIfButton] ( #$0401, &code_0AA666 )
    COP [BranchIfButton] ( #$0201, &code_0AA66B )
    COP [BranchIfButton] ( #$0101, &code_0AA670 )
    RTS 
}

code_0AA661 {
    LDA #$0001
    BRA loc_0AA673
}

code_0AA666 {
    LDA #$0000
    BRA loc_0AA673
}

code_0AA66B {
    LDA #$0002
    BRA loc_0AA673
}

code_0AA670 {
    LDA #$0003

  loc_0AA673:
    JSL $@InitPlayerScriptVariant
    RTS 
}

dm43_elevator_stop_y [
  actor-def < #34, #01, #13, {

  code_0AA67B:
    COP [AddPosition] ( #05, #00 )

  loc_0AA67F:
    COP [SetEntryContinue]
    COP [StageForceMoveY] ( #01 )
    LDA $16
    CMP $mapBoundsY
    BEQ loc_0AA68C
    RTL 

  loc_0AA68C:
    COP [SetEntryContinue]
    COP [StageForceMoveY] ( #02 )
    LDA $16
    CMP #$0000
    BEQ loc_0AA67F
    RTL 
} >
]

dm43_elevator_stop_x [
  actor-def < #34, #01, #13, {

  loc_0AA69C:
    COP [SetEntryContinue]
    COP [StageForceMoveX] ( #01 )
    LDA $14
    CMP $mapBoundsX
    BEQ loc_0AA6A9
    RTL 

  loc_0AA6A9:
    COP [SetEntryContinue]
    COP [StageForceMoveX] ( #02 )
    LDA $14
    CMP #$0000
    BEQ loc_0AA69C
    RTL 
} >
]