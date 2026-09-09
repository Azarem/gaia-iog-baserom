?BANK 02

?INCLUDE 'player_character'
?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_ew'
?INCLUDE 'player_move_main'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6

---------------------------------------------

DispatchSouthMove {
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL
    BCC loc_02D054
    CMP #$06
    BNE loc_02D046
    JMP $&SouthWallHandler

  loc_02D046:
    CMP #$03
    BNE loc_02D04D
    JMP $&SouthSlopeRight

  loc_02D04D:
    CMP #$0C
    BNE loc_02D054
    JMP $&SouthSlopeLeft

  loc_02D054:
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$09
    BNE loc_02D05E
    JMP $&NorthWallHandler

  loc_02D05E:
    JSR $&tile_collision.ProbeFutureTL
    CMP #$0E
    BCS loc_02D0AF
    CMP #$08
    BEQ loc_02D0AF
    CMP #$02
    BEQ SouthInteractTile
    CMP #$06
    BNE loc_02D074
    JMP $&SouthWallNudge

  loc_02D074:
    JSR $&tile_collision.CheckSubTileAlignX
    BCS loc_02D082
    CMP #$09
    BNE loc_02D080
    JMP $&NorthProbeRedirect

  loc_02D080:
    BRA loc_02D0A5

  loc_02D082:
    CMP #$09
    BEQ loc_02D0AF
    JSR $&tile_collision.MapCellDown
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS loc_02D0AF
    CMP #$08
    BEQ loc_02D0AF
    CMP #$02
    BEQ loc_02D0AF
    CMP #$09
    BNE loc_02D0A1
    JMP $&NorthProbeRedirect

  loc_02D0A1:
    CMP #$06
    BEQ loc_02D0AF

  loc_02D0A5:
    REP #$20
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 

  loc_02D0AF:
    JSR $&tile_collision.SetActorCollisionFlag
    JSR $&player_move_main.AutoAlignEW
    BCS SnapYSouthCollision
    PHP 
    REP #$20
    BRA loc_02D0C2

  SnapYSouthCollision:
    PHP 
    REP #$20
    STZ $playerSpeedNs

  loc_02D0C2:
    LDA $24
    CLC 
    ADC $26
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $26
    STZ $24
    PLP 
    RTS 

  SouthInteractTile:
    JSR $&tile_collision.CheckSubTileAlignX
    BCS loc_02D0AF
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.LadderClimbSouth
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02D0AF
}

SouthSlopeRight {
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$03
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D11A
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D11A
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08
    BPL loc_02D11A
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D11A:
    LDA #$10
    TSB $09AF
    JMP $&tile_collision.ApplyMovementDeltas
}

SouthSlopeLeft {
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$0C
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D14E
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D14E
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08
    BPL loc_02D14E
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D14E:
    LDA #$10
    TSB $09AF
    REP #$20
    LDA $slopeFracAccum
    BMI loc_02D15D
    STZ $slopeFracAccum

  loc_02D15D:
    LDA $24
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    EOR #$FFFF
    INC 
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02D185
    STA $24
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_02D185:
    JMP $&tile_collision.ApplyMovementDeltas
}

SouthWallHandler {
    JSR $&tile_collision.ProbeCurrentBR
    CMP #$06
    BNE loc_02D192
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D192:
    JSR $&tile_collision.ProbeFutureTL
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D1B2
    CMP #$06
    BNE loc_02D1B2

  loc_02D19E:
    JSR $&tile_collision.MapCellDown
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1
    BRA loc_02D1C6

  loc_02D1B2:
    JSR $&player_move_diag.SnapXDiagCollision
    JSR $&tile_collision.ProbeFutureTL
    CMP #$06
    BEQ loc_02D1C6

  loc_02D1BC:
    REP #$20
    STZ $24
    JSR $&player_move_ew.SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1C6:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset
    JMP $&player_move_ew.FineAdjustXWest
}

SouthWallNudge {
    LDA $AB
    BIT #$02
    BEQ loc_02D1E0
    JSR $&tile_collision.CheckSubTileAlignX
    BCS loc_02D1E0
    REP #$20
    STZ $24
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1E0:
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS loc_02D1BC
    BRA loc_02D19E

  ClearSpeedNS_1:
    REP #$20
    STZ $playerSpeedNs
    RTS 
}

NorthWallHandler {
    JSR $&tile_collision.ProbeCurrentBL
    CMP #$09
    BNE loc_02D1FC
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D1FC:
    JSR $&tile_collision.ProbeFutureTR
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D21C
    CMP #$09
    BNE loc_02D21C

  loc_02D208:
    JSR $&tile_collision.MapCellUp
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2
    BRA loc_02D230

  loc_02D21C:
    JSR $&player_move_ew.SnapXWestCollision
    JSR $&tile_collision.ProbeFutureTR
    CMP #$09
    BEQ loc_02D230
    REP #$20
    STZ $24
    JSR $&player_move_ew.SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D230:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset
    JMP $&player_move_ew.FineAdjustXEast
}

NorthProbeRedirect {
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    BRA loc_02D208

  ClearSpeedNS_2:
    REP #$20
    STZ $playerSpeedNs
    RTS 
}