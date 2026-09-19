; Directional ramp actors (ramp_east, ramp_west, ramp_north, ramp_south) that detect player speed ≥6 and alignment within pixel thresholds, then hijack the player into a ramp-climb animation.
; 
; Uses hdma_ramp_tables motion curves for vertical arc movement, disables normal input, and restores control through stair_climb.RestorePlayerControl on exit. Placed on ramp tiles throughout overworld and dungeon maps via scene_actors.
---------------------------------------------

?BANK 00

?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'stair_climb'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!retPtr2                        7F001E
!statsPtr                       7F0020

---------------------------------------------

ramp_east [
  actor-def < #00, #00, #20, {

  code_00D2D3:
    COP [SetEntryContinue]

  code_00D2D5:
    LDA $14
    CLC 
    ADC #$0008
    STA $0018
    LDA $playerSpeedEw
    JSR $&RampCheckPlayerSpeed
    BCC loc_00D2E7
    RTL 

  loc_00D2E7:
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00D2F6
    EOR #$FFFF
    INC 

  loc_00D2F6:
    CMP #$0019
    BMI loc_00D2FC
    RTL 

  loc_00D2FC:
    LDA $0014, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $0018
    BMI loc_00D30A
    RTL 

  loc_00D30A:
    BPL loc_00D310
    EOR #$FFFF
    INC 

  loc_00D310:
    CMP #$000F
    BCC loc_00D316
    RTL 

  loc_00D316:
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BEQ loc_00D334
    BPL loc_00D329
    EOR #$FFFF
    INC 

  loc_00D329:
    CMP #$0010
    BCS loc_00D32F
    RTL 

  loc_00D32F:
    COP [SetEntryExitNow] ( @code_00D2D5 )

  loc_00D334:
    LDA #$&RampPlayerClimbEast
    STA $0000, Y
    LDA #$*RampPlayerClimbEast
    STA $0002, Y
    JSR $&RampBeginPlayerControl
    COP [SetEntryExitNow] ( @code_00D2D5 )
} >
]

ramp_west [
  actor-def < #00, #00, #20, {

  code_00D34B:
    COP [SetEntryContinue]

  code_00D34D:
    LDA $14
    SEC 
    SBC #$0008
    STA $0018
    LDA $playerSpeedEw
    JSR $&RampCheckPlayerSpeed
    BCC loc_00D35F
    RTL 

  loc_00D35F:
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00D36E
    EOR #$FFFF
    INC 

  loc_00D36E:
    CMP #$0019
    BMI loc_00D374
    RTL 

  loc_00D374:
    LDA $0014, Y
    CLC 
    ADC #$0008
    SEC 
    SBC $0018
    BPL loc_00D382
    RTL 

  loc_00D382:
    CMP #$000F
    BCC loc_00D388
    RTL 

  loc_00D388:
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BEQ loc_00D3A6
    BPL loc_00D39B
    EOR #$FFFF
    INC 

  loc_00D39B:
    CMP #$0010
    BCS loc_00D3A1
    RTL 

  loc_00D3A1:
    COP [SetEntryExitNow] ( @code_00D34D )

  loc_00D3A6:
    LDA #$&loc_00D4F5
    STA $0000, Y
    LDA #$*loc_00D4F5
    STA $0002, Y
    JSR $&RampBeginPlayerControl
    COP [SetEntryExitNow] ( @code_00D34D )
} >
]

ramp_north [
  actor-def < #00, #00, #20, {

  code_00D3BD:
    COP [SetEntryContinue]

  code_00D3BF:
    LDA $playerSpeedNs
    JSR $&RampCheckPlayerSpeed
    BCC loc_00D3C8
    RTL 

  loc_00D3C8:
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00D3D7
    EOR #$FFFF
    INC 

  loc_00D3D7:
    CMP #$0011
    BMI loc_00D3DD
    RTL 

  loc_00D3DD:
    LDA $0016, Y
    SEC 
    SBC #$0010
    SEC 
    SBC $16
    BMI loc_00D3EA
    RTL 

  loc_00D3EA:
    BPL loc_00D3F0
    EOR #$FFFF
    INC 

  loc_00D3F0:
    CMP #$000F
    BCC loc_00D3F6
    RTL 

  loc_00D3F6:
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D414
    BPL loc_00D409
    EOR #$FFFF
    INC 

  loc_00D409:
    CMP #$0010
    BCS loc_00D40F
    RTL 

  loc_00D40F:
    COP [SetEntryExitNow] ( @code_00D3BF )

  loc_00D414:
    LDA #$&loc_00D518
    STA $0000, Y
    LDA #$*loc_00D518
    STA $0002, Y
    JSR $&RampBeginPlayerControl
    COP [SetEntryExitNow] ( @code_00D3BF )
} >
]

ramp_south [
  actor-def < #00, #00, #20, {

  code_00D42B:
    COP [SetEntryContinue]

  code_00D42D:
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    LDA $playerSpeedNs
    JSR $&RampCheckPlayerSpeed
    BCC loc_00D43F
    RTL 

  loc_00D43F:
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00D44E
    EOR #$FFFF
    INC 

  loc_00D44E:
    CMP #$0011
    BMI loc_00D454
    RTL 

  loc_00D454:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_00D45E
    RTL 

  loc_00D45E:
    CMP #$000F
    BCC loc_00D464
    RTL 

  loc_00D464:
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D482
    BPL loc_00D477
    EOR #$FFFF
    INC 

  loc_00D477:
    CMP #$0010
    BCS loc_00D47D
    RTL 

  loc_00D47D:
    COP [SetEntryExitNow] ( @code_00D42D )

  loc_00D482:
    LDA #$&RampPlayerClimbSouth
    STA $0000, Y
    LDA #$*RampPlayerClimbSouth
    STA $0002, Y
    JSR $&RampBeginPlayerControl
    COP [SetEntryExitNow] ( @code_00D42D )
} >
]

RampBeginPlayerControl {
    STZ $playerSpeedEw
    STZ $playerSpeedNs
    LDA $0E
    PHX 
    TYX 
    STA $statsPtr, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags
    RTS 
}

RampCheckPlayerSpeed {
    BPL loc_00D4C1
    EOR #$FFFF
    INC 

  loc_00D4C1:
    CMP #$0006
    BCC loc_00D4D0
    LDA $playerFlags
    BIT #$0800
    BNE loc_00D4D0
    CLC 
    RTS 

  loc_00D4D0:
    SEC 
    RTS 
}

RampPlayerClimbEast {
    COP [SpawnAfter] ( @func_00D5C0 )
    PHX 
    LDX $06
    LDA #$FFF8
    STA $orbitDiameter, X
    PLX 
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  loc_00D4EC:
    COP [StagePlayerMoveXY] ( #21, #10, #00 )
    COP [AnimOnce]
    BRA loc_00D4EC

  loc_00D4F5:
    COP [SpawnAfter] ( @func_00D5C0 )
    PHX 
    LDX $06
    LDA #$0008
    STA $orbitDiameter, X
    PLX 
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  loc_00D50F:
    COP [StagePlayerMoveXY] ( #24, #0F, #00 )
    COP [AnimOnce]
    BRA loc_00D50F

  loc_00D518:
    LDA $statsPtr, X
    STA $loopCounter, X
    LDA #$&ramp_east_step
    STA $retPtr2, X
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  ramp_east_step:
    COP [StagePlayerMoveXY] ( #1E, #00, #10 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$FFF8
    STA $playerSpeedNs
    JSR $&stair_climb.RestorePlayerControl
    LDA #$0000
    STA $slopeStepCounter
    LDA #$0007
    STA $decelStepCounter
    RTL 
}

RampPlayerClimbSouth {
    LDA $statsPtr, X
    STA $loopCounter, X
    LDA #$&ramp_north_step
    STA $retPtr2, X
    COP [SetEntryContinue]
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  ramp_north_step:
    COP [StagePlayerMoveXY] ( #19, #00, #0F )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0008
    STA $playerSpeedNs
    JSR $&stair_climb.RestorePlayerControl
    LDA #$0000
    STA $slopeStepCounter
    LDA #$0007
    STA $decelStepCounter
    RTL 
}
---------------------------------------------

func_00D5C0 {
    PHX 
    LDX $04
    LDA $statsPtr, X
    ASL 
    CLC 
    ADC $statsPtr, X
    TAX 
    LDA $@hdma_ramp_tables.ramp_motion_curves+2, X
    AND #$00FF
    TAY 
    LDA $@hdma_ramp_tables.ramp_motion_curves, X
    SEC 
    SBC #$&hdma_ramp_tables.ramp_motion_curves
    PLX 
    STA $orbitAngle, X
    TYA 
    STA $loopCounter, X
    STZ $2A
    LDA #$&ramp_motion_curve_step
    STA $retPtr2, X

  ramp_motion_curve_step:
    PHX 
    LDA $orbitAngle, X
    CLC 
    ADC $2A
    INC $2A
    TAX 
    LDA $@hdma_ramp_tables.ramp_motion_curves, X
    AND #$00FF
    BIT #$0080
    BEQ loc_00D60B
    ORA #$FF00

  loc_00D60B:
    LDX $04
    CLC 
    ADC $0016, X
    STA $0016, X
    PLX 
    COP [LoopNext]
    LDA $orbitDiameter, X
    STA $playerSpeedEw
    JSR $&stair_climb.RestorePlayerControl
    LDA #$0000
    STA $slopeStepCounter
    LDA #$0007
    STA $decelStepCounter
    COP [Die]
}