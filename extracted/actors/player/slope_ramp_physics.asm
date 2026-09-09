?BANK 02

?INCLUDE 'tile_collision'

!joypadCurrent                  0656
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!slopeFracAccum                 09C6
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!iframeCounter                  7F0028

---------------------------------------------

SlopePhysicsEntry {
    COP [SetEntryContinue]
    PHX 
    LDX $playerActor
    LDA $0010, X
    BIT #$00C0
    BEQ loc_02B443
    LDA $iframeCounter, X
    BMI loc_02B443
    PLX 
    JMP $&SlopeFlatDecelerate

  loc_02B443:
    PLX 
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BEQ loc_02B4C0
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDY $playerActor
    LDA $0014, Y
    STA $1A
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $1E
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BEQ loc_02B474
    DEC 
    PHA 
    RTS 

  loc_02B474:
    TXA 
    LSR 
    CMP #$0006
    BEQ loc_02B483
    CMP #$0009
    BEQ loc_02B483
    JMP $&SlopeFlatExit

  loc_02B483:
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02B498
    JMP $&SlopeType05Handler

  loc_02B498:
    CMP #$000A
    BNE loc_02B4A0
    JMP $&SlopeType0AHandler

  loc_02B4A0:
    JSR $&tile_collision.MapCellLeft
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02B4B5
    JMP $&SlopeType05Handler

  loc_02B4B5:
    CMP #$000A
    BNE loc_02B4BD
    JMP $&SlopeType0AHandler

  loc_02B4BD:
    JMP $&SlopeFlatExit

  loc_02B4C0:
    LDA $playerFlags
    BIT #$1000
    BNE loc_02B4CB
    JMP $&SlopeFlatDecelerate

  loc_02B4CB:
    STZ $slopeStepCounter
    STZ $decelStepCounter
    PHX 
    PHD 
    LDY $playerActor
    LDA $playerXPos
    STA $001A
    LDA $playerYPos
    STA $001E
    LDA #$0000
    TCD 
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellDown
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellRight
    STX $00
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellDown
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BEQ SlopeFlatExit

  loc_02B535:
    DEC 
    PHA 
    RTS 
}

SlopeType03Handler {
    JSR $&ApplySlopeCurvePosNS
    BRA loc_02B54A
}

SlopeType05Handler {
    JSR $&ApplySlopeCurveNegEW
    BRA loc_02B54A
}

SlopeType0AHandler {
    JSR $&ApplySlopeCurvePosEW
    BRA loc_02B54A

  SlopeType0CHandler:
    JSR $&ApplySlopeCurveNegNS

  loc_02B54A:
    JSR $&ClampSpeeds
    PLD 
    PLX 
    RTL 
}

SlopeFlatExit {
    JSR $&ClampSpeeds
    STZ $slopeFracAccum
    STZ $slopeStepCounter
    PLD 
    PLX 
}

SlopeFlatDecelerate {
    LDA $playerSpeedEw
    BEQ loc_02B564
    JSR $&DecelerateEW
    RTL 

  loc_02B564:
    LDA $playerFlags
    BIT #$1000
    BEQ loc_02B572
    AND #$EFFF
    STA $playerFlags

  loc_02B572:
    LDA $playerSpeedNs
    BNE loc_02B578
    RTL 

  loc_02B578:
    JSR $&DecelerateNS
    RTL 
}

SlopeTileDispatch [
  #$0000   ;00
  #$0000   ;01
  #$0000   ;02
  &SlopeType03Handler   ;03
  #$0000   ;04
  &SlopeType05Handler   ;05
  #$0000   ;06
  #$0000   ;07
  #$0000   ;08
  #$0000   ;09
  &SlopeType0AHandler   ;0A
  #$0000   ;0B
  &SlopeType0CHandler   ;0C
  #$0000   ;0D
  #$0000   ;0E
  #$0000   ;0F
]

ApplySlopeCurveNegEW {
    LDA $slopeStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrA
    TAY 
    LDA $0000, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 
}

ApplySlopeCurvePosEW {
    LDA $slopeStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrA
    TAY 
    LDA $0000, Y
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 

  loc_02B5D8:
    STZ $slopeStepCounter
    LDA #$1000
    TSB $playerFlags
    RTS 
}

ApplySlopeCurvePosNS {
    LDA $slopeStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrB
    TAY 
    LDA $0000, Y
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 
}

ApplySlopeCurveNegNS {
    LDA $slopeStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrB
    TAY 
    LDA $0000, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 
}

ClampSpeeds {
    LDA $playerSpeedEw
    BEQ loc_02B649
    BPL loc_02B63B
    EOR #$FFFF
    INC 
    CMP $maxSpeedEw
    BPL loc_02B62F
    RTS 

  loc_02B62F:
    LDA $maxSpeedEw
    DEC 
    EOR #$FFFF
    INC 
    STA $playerSpeedEw
    RTS 

  loc_02B63B:
    CMP $maxSpeedEw
    BPL loc_02B641
    RTS 

  loc_02B641:
    LDA $maxSpeedEw
    DEC 
    STA $playerSpeedEw
    RTS 

  loc_02B649:
    LDA $playerSpeedNs
    BNE loc_02B64F
    RTS 

  loc_02B64F:
    BPL loc_02B667
    EOR #$FFFF
    INC 
    CMP $maxSpeedNs
    BPL loc_02B65B
    RTS 

  loc_02B65B:
    LDA $maxSpeedNs
    DEC 
    EOR #$FFFF
    INC 
    STA $playerSpeedNs
    RTS 

  loc_02B667:
    CMP $maxSpeedNs
    BPL loc_02B66D
    RTS 

  loc_02B66D:
    LDA $maxSpeedNs
    DEC 
    STA $playerSpeedNs
    RTS 
}

DecelerateEW {
    LDA $playerFlags
    BIT #$1000
    BEQ loc_02B67E
    RTS 

  loc_02B67E:
    LDA $playerSpeedEw
    BPL loc_02B687
    EOR #$FFFF
    INC 

  loc_02B687:
    CMP #$0003
    BPL loc_02B690
    STZ $playerSpeedEw
    RTS 

  loc_02B690:
    LDA $playerSpeedEw
    BMI loc_02B6D1
    LDA $joypadCurrent
    BIT #$0100
    BEQ loc_02B69E
    RTS 

  loc_02B69E:
    JSR $&ReadDecelerationStep
    BEQ loc_02B6B0
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD

  loc_02B6B0:
    LDA $joypadCurrent
    BIT #$0200
    BNE loc_02B6B9
    RTS 

  loc_02B6B9:
    JSR $&ReadDecelerationStep
    BNE loc_02B6BF
    RTS 

  loc_02B6BF:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD
    RTS 

  loc_02B6CD:
    STZ $decelStepCounter
    RTS 

  loc_02B6D1:
    LDA $joypadCurrent
    BIT #$0200
    BEQ loc_02B6DA
    RTS 

  loc_02B6DA:
    JSR $&ReadDecelerationStep
    BEQ loc_02B6E8
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD

  loc_02B6E8:
    LDA $joypadCurrent
    BIT #$0100
    BNE loc_02B6F1
    RTS 

  loc_02B6F1:
    JSR $&ReadDecelerationStep
    BNE loc_02B6F7
    RTS 

  loc_02B6F7:
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD
    RTS 
}

ReadDecelerationStep {
    LDA $decelStepCounter
    INC $decelStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $decelCurvePtr
    TAY 
    LDA $0000, Y
    RTS 
}

DecelerateNS {
    LDA $playerFlags
    BIT #$1000
    BEQ loc_02B71D
    RTS 

  loc_02B71D:
    LDA $playerSpeedNs
    BPL loc_02B726
    EOR #$FFFF
    INC 

  loc_02B726:
    CMP #$0003
    BPL loc_02B72F
    STZ $playerSpeedNs
    RTS 

  loc_02B72F:
    LDA $playerSpeedNs
    BMI loc_02B770
    LDA $joypadCurrent
    BIT #$0400
    BEQ loc_02B73D
    RTS 

  loc_02B73D:
    JSR $&ReadDecelerationStepNS
    BEQ loc_02B74F
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C

  loc_02B74F:
    LDA $joypadCurrent
    BIT #$0800
    BNE loc_02B758
    RTS 

  loc_02B758:
    JSR $&ReadDecelerationStepNS
    BNE loc_02B75E
    RTS 

  loc_02B75E:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C
    RTS 

  loc_02B76C:
    STZ $slopeStepCounter
    RTS 

  loc_02B770:
    LDA $joypadCurrent
    BIT #$0800
    BEQ loc_02B779
    RTS 

  loc_02B779:
    JSR $&ReadDecelerationStepNS
    BEQ loc_02B787
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C

  loc_02B787:
    LDA $joypadCurrent
    BIT #$0400
    BNE loc_02B790
    RTS 

  loc_02B790:
    JSR $&ReadDecelerationStepNS
    BNE loc_02B796
    RTS 

  loc_02B796:
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C
    RTS 
}

ReadDecelerationStepNS {
    LDA $decelStepCounter
    INC $decelStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $decelCurvePtr
    TAY 
    LDA $0000, Y
    RTS 
}