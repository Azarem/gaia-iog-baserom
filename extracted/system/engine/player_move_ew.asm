?BANK 02

?INCLUDE 'map_coords'
?INCLUDE 'player_character'
?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!collisionLayer                 7FC000

---------------------------------------------

DispatchEastMove {
    SEP #$20
    JSR $&tile_collision.ProbeCurrentBL
    CMP #$09
    BNE loc_02D382
    JMP $&EastWallNorthInteract

  loc_02D382:
    CMP #$03
    BNE loc_02D389
    JMP $&EastSlopeRight

  loc_02D389:
    CMP #$0C
    BNE loc_02D390
    JMP $&EastSlopeLeft

  loc_02D390:
    JSR $&tile_collision.ProbeCurrentBR
    CMP #$06
    BNE loc_02D39A
    JMP $&EastWallSouthInteract

  loc_02D39A:
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0E
    BCC loc_02D3A4
    JMP $&EastBlockedWall

  loc_02D3A4:
    CMP #$02
    BEQ EastInteractTile
    CMP #$08
    BEQ EastStairsTile
    CMP #$09
    BNE loc_02D3B3
    JMP $&EastWallNorthProbe

  loc_02D3B3:
    JSR $&tile_collision.CheckSubTileAlignX
    BCS loc_02D3C1
    CMP #$06
    BNE loc_02D3BF
    JMP $&EastSlideJumpShim

  loc_02D3BF:
    BRA loc_02D3E0

  loc_02D3C1:
    CMP #$06
    BEQ EastBlockedWall
    JSR $&tile_collision.MapCellDown
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS EastBlockedWall
    CMP #$02
    BEQ EastBlockedWall
    CMP #$06
    BNE loc_02D3DC
    JMP $&EastSlideJumpShim

  loc_02D3DC:
    CMP #$09
    BEQ EastBlockedWall

  loc_02D3E0:
    REP #$20
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 
}

EastBlockedWall {
    JSR $&tile_collision.SetActorCollisionFlag
    JSR $&AutoAlignNS_East
    BCS SnapXEastCollision
    PHP 
    REP #$20
    BRA loc_02D3FD
}

SnapXEastCollision {
    PHP 
    REP #$20
    STZ $playerSpeedNs

  loc_02D3FD:
    LDA $24
    CLC 
    ADC $26
    AND #$FFC0
    STA $26
    STZ $24
    PLP 
    RTS 

  EastInteractTile:
    JSR $&tile_collision.CheckSubTileAlignX
    BCS EastBlockedWall
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.LadderClimbNorth
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA EastBlockedWall

  EastStairsTile:
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D434
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$08
    BNE EastBlockedWall

  loc_02D434:
    LDA #$08
    TSB $09AF
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.ClimbVineEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA SnapXEastCollision
}

EastSlopeRight {
    JSR $&tile_collision.ProbeCurrentBR
    CMP #$03
    BEQ loc_02D458
    JMP $&EastBlockedWall

  loc_02D458:
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D477
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D477
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02D477
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D477:
    LDA #$10
    TSB $09AF
    JMP $&tile_collision.ApplyMovementDeltas
}

EastSlopeLeft {
    JSR $&tile_collision.ProbeCurrentBR
    CMP #$0C
    BEQ loc_02D489
    JMP $&EastBlockedWall

  loc_02D489:
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D4A8
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D4A8
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02D4A8
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D4A8:
    LDA #$10
    TSB $09AF
    REP #$20
    LDA $slopeFracAccum
    BPL loc_02D4B7
    STZ $slopeFracAccum

  loc_02D4B7:
    LDA $24
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02D4D7
    STA $24
    ASL 
    ASL 
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum

  loc_02D4D7:
    JMP $&tile_collision.ApplyMovementDeltas
}

EastWallNorthInteract {
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$09
    BNE loc_02D4E4
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D4E4:
    JSR $&tile_collision.ProbeFutureBL
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D504
    CMP #$09
    BNE loc_02D504

  loc_02D4F0:
    JSR $&tile_collision.MapCellDown
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    BRA loc_02D51C

  loc_02D504:
    JSR $&player_move_diag.SnapXDiagCollision
    JSR $&tile_collision.ProbeFutureBL
    BCC loc_02D51C
    CMP #$01
    BEQ loc_02D51C
    CMP #$09
    BEQ loc_02D51C
    REP #$20

  loc_02D516:
    JSR $&SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D51C:
    REP #$20
    JSR $&ComputeEastSnapOffset
    JMP $&FineAdjustXWest
}

EastWallNorthProbe {
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS loc_02D516
    BRA loc_02D4F0

  ClearSpeedNS_3:
    REP #$20
    STZ $playerSpeedNs
    RTS 
}

EastWallSouthInteract {
    JSR $&tile_collision.ProbeCurrentTL
    CMP #$06
    BNE loc_02D540
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D540:
    JSR $&tile_collision.ProbeFutureBR
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D560
    CMP #$06
    BNE loc_02D560

  loc_02D54C:
    JSR $&tile_collision.MapCellUp
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    BRA loc_02D574

  loc_02D560:
    JSR $&SnapXWestCollision
    JSR $&tile_collision.ProbeFutureBR
    CMP #$06
    BEQ loc_02D574
    REP #$20
    STZ $24
    JSR $&player_move_ns.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D574:
    REP #$20
    JSR $&ComputeEastSnapOffset
    JMP $&FineAdjustXEast
}

EastSlideJumpShim {
    BRA loc_02D54C

  ClearSpeedNS_4:
    REP #$20
    STZ $playerSpeedNs
    RTS 
}

AutoAlignNS_East {
    REP #$20
    LDA $AA
    BIT #$0040
    BNE loc_02D5F7
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02D5F7
    LDA $22
    LSR 
    LSR 
    AND #$000F
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02D5F7
    CMP #$0006
    BCC loc_02D5D0
    JSR $&tile_collision.ProbeFutureBR
    CMP #$000E
    BCS loc_02D5D0
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeToLowerGrid
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D5D0:
    LDA $04
    CMP #$0009
    BCS loc_02D5F7
    JSR $&tile_collision.ProbeFutureBL
    CMP #$000E
    BCS loc_02D5F7
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeToUpperGrid
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D5F7:
    SEC 
    RTS 
}

ComputeEastSnapOffset {
    REP #$20
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentBL
    CMP #$09
    BEQ loc_02D619
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D640
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
    BNE loc_02D640

  loc_02D619:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1E
    PHA 
    LDA $24
    LSR 
    LSR 
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02D63D
    LDA #$0010
    STA $02

  loc_02D63D:
    PLA 
    BRA loc_02D64A

  loc_02D640:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02D64A:
    LDA $1E
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}

FineAdjustXEast {
    LDX $playerActor
    LDA $0014, X
    SEC 
    SBC #$0008
    AND #$000F
    BNE loc_02D667
    LDA #$0010

  loc_02D667:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02D672
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D672:
    LDA #$0010
    SEC 
    SBC $02
    STA $02
    LDA $0014, X
    SEC 
    SBC #$0008
    BIT #$000F
    BNE loc_02D68A
    SEC 
    SBC #$0010

  loc_02D68A:
    AND #$FFF0
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}

FineAdjustXWest {
    LDX $playerActor
    LDA $0014, X
    SEC 
    SBC #$0008
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02D6B6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D6B6:
    LDA #$0010
    SEC 
    SBC $02
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    LDA $0014, X
    SEC 
    SBC #$0008
    AND #$FFF0
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}

DispatchWestMove {
    SEP #$20
    JSR $&map_coords.ProbeLeftTiles
    BNE loc_02D6EB
    BCS loc_02D6E8
    JMP $&WestRampDown

  loc_02D6E8:
    JMP $&EastRampDown

  loc_02D6EB:
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$09
    BNE loc_02D6F5
    JMP $&code_02D79B

  loc_02D6F5:
    JSR $&tile_collision.ProbeCurrentBR
    CMP #$06
    BNE loc_02D6FF
    JMP $&code_02D7EF

  loc_02D6FF:
    JSR $&tile_collision.ProbeFutureTR
    CMP #$0E
    BCS loc_02D753
    CMP #$09
    BNE loc_02D70D
    JMP $&WestWallNorthFlag

  loc_02D70D:
    JSR $&tile_collision.CheckSubTileAlignY
    BCS loc_02D71B
    CMP #$06
    BNE loc_02D719
    JMP $&code_02D81B

  loc_02D719:
    BRA loc_02D734

  loc_02D71B:
    CMP #$06
    BEQ loc_02D753
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS loc_02D753
    CMP #$06
    BNE loc_02D730
    JMP $&code_02D81B

  loc_02D730:
    CMP #$09
    BEQ loc_02D753

  loc_02D734:
    CMP #$07
    BEQ WestLadderTile
    JSR $&tile_collision.ProbeCurrentBL
    CMP #$05
    BNE loc_02D742
    JMP $&EastRampUp

  loc_02D742:
    CMP #$0A
    BNE loc_02D749
    JMP $&WestRampUp

  loc_02D749:
    REP #$20
    LDA $22
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02D753:
    JSR $&tile_collision.SetActorCollisionFlag
    JSR $&AutoAlignNS_West
    BCS SnapXWestCollision
    PHP 
    REP #$20
    BRA loc_02D766
}

SnapXWestCollision {
    PHP 
    REP #$20
    STZ $playerSpeedEw

  loc_02D766:
    LDA $20
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0020
    STA $22
    STZ $20
    PLP 
    RTS 

  WestLadderTile:
    JSR $&tile_collision.CheckSubTileAlignY
    BCS loc_02D753
    JSR $&player_move_diag.DiagClearReturnFlags
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyRightEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02D753

  WestWallNorthDiag:
    SEP #$20
}

code_02D79B {
    LDA #$80
    TSB $AB
    JSR $&tile_collision.ProbeFutureTR
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D7C7
    CMP #$09
    BNE loc_02D7C7

  loc_02D7AB:
    JSR $&tile_collision.MapCellRight
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7B9
    CMP #$0A
    BNE ClearSpeedEW_5

  loc_02D7B9:
    JSR $&tile_collision.MapCellUp
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7D9
    CMP #$09
    BNE ClearSpeedEW_5
    BRA loc_02D7D9

  loc_02D7C7:
    JSR $&player_move_ns.SnapYSouthCollision
    JSR $&tile_collision.ProbeFutureTR
    BCC loc_02D7D9
    CMP #$09
    BEQ loc_02D7D9
    JSR $&SnapXWestCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D7D9:
    REP #$20
    JSR $&ComputeWestSnapOffset
    JMP $&player_move_diag.DiagPushRight
}

WestWallNorthFlag {
    LDA #$04
    TSB $AB
    BRA loc_02D7AB

  ClearSpeedEW_5:
    REP #$20
    STZ $playerSpeedEw
    RTS 
}

WestWallSouthDiag {
    SEP #$20
}

code_02D7EF {
    LDA #$80
    TSB $AB
    JSR $&tile_collision.ProbeFutureBR
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D823
    CMP #$06
    BNE loc_02D823

  loc_02D7FF:
    JSR $&tile_collision.MapCellLeft
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D80D
    CMP #$05
    BNE ClearSpeedEW_6

  loc_02D80D:
    JSR $&tile_collision.MapCellUp
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D835
    CMP #$06
    BNE ClearSpeedEW_6
    BRA loc_02D835
}

code_02D81B {
    STX $00
    LDA #$08
    TSB $AB
    BRA loc_02D7FF

  loc_02D823:
    JSR $&SnapXEastCollision
    JSR $&tile_collision.ProbeFutureBR
    BCC loc_02D835
    CMP #$06
    BEQ loc_02D835
    JSR $&SnapXWestCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D835:
    REP #$20
    JSR $&ComputeWestSnapOffset
    JMP $&player_move_diag.DiagPushLeft

  ClearSpeedEW_6:
    REP #$20
    STZ $playerSpeedEw
    RTS 
}

WestRampDown {
    JSR $&player_move_diag.DiagClearReturnFlags
    JSR $&tile_collision.ProbeCurrentTR
    LDA $1A
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.ProbeFutureTR
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JMP $&WestRedirectToNorth

  loc_02D899:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02D8A1
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D8A1:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02D8CE
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02D8CE

  code_02D8C7:
    LDA $20
    CLC 
    ADC $26
    STA $26

  code_02D8CE:
    LDA #$1000
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTR
    CMP #$0E
    BCS loc_02D8EA
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0E
    BCS loc_02D8E7
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D8E7:
    JMP $&code_02D92F

  loc_02D8EA:
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0E
    BCS loc_02D8F4
    JMP $&code_02D937

  loc_02D8F4:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02D90A
    AND #$FFF0

  loc_02D90A:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $playerSpeedEw
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02D92F {
    REP #$20
    JSR $&SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02D937 {
    REP #$20
    JSR $&player_move_ns.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

WestRampUp {
    JSR $&player_move_diag.DiagClearReturnFlags
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ loc_02D958
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D958:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02D960
    JMP $&code_02D8C7

  loc_02D960:
    LDA $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$000F
    ASL 
    ASL 
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02D8CE
}

WestRedirectToNorth {
    JSR $&tile_collision.ProbeFutureTR
    CMP #$0009
    BNE loc_02D983
    JMP $&WestWallNorthDiag

  loc_02D983:
    JMP $&tile_collision.ApplyMovementDeltas
}

EastRampDown {
    JSR $&player_move_diag.DiagClearReturnFlags
    JSR $&tile_collision.ProbeCurrentBR
    LDA $1A
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.MapCellLeft
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.ProbeFutureTR
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ loc_02D9DC
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02D9DC
    JMP $&EastRedirectToSouth

  loc_02D9DC:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02D9E4
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D9E4:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02DA19
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DA19

  code_02DA0E:
    LDA $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26

  code_02DA19:
    LDA #$1000
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTR
    CMP #$0E
    BCS loc_02DA35
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0E
    BCS loc_02DA32
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DA32:
    JMP $&code_02DA7A

  loc_02DA35:
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0E
    BCS loc_02DA3F
    JMP $&code_02DA82

  loc_02DA3F:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02DA55
    AND #$FFF0

  loc_02DA55:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $playerSpeedEw
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DA7A {
    REP #$20
    JSR $&SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DA82 {
    REP #$20
    JSR $&player_move_ns.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

EastRampUp {
    JSR $&player_move_diag.DiagClearReturnFlags
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ loc_02DAA3
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DAA3:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02DAAB
    JMP $&code_02DA0E

  loc_02DAAB:
    LDA $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$000F
    ASL 
    ASL 
    SEC 
    SBC $20
    STA $24
    JMP $&code_02DA19
}

EastRedirectToSouth {
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0006
    BNE loc_02DACA
    JMP $&WestWallSouthDiag

  loc_02DACA:
    JMP $&tile_collision.ApplyMovementDeltas
}

AutoAlignNS_West {
    PHP 
    REP #$20
    LDA $06, S
    BNE loc_02DB1F
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02DB1F
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02DB1F
    STA $04
    CMP #$0004
    BCC loc_02DB04
    JSR $&tile_collision.ProbeFutureBR
    AND #$00FF
    CMP #$000E
    BCS loc_02DB04
    LDX #$0026
    JSR $&player_move_main.NudgeToLowerGrid
    PLP 
    CLC 
    RTS 

  loc_02DB04:
    LDA $04
    CMP #$000B
    BCS loc_02DB1F
    JSR $&tile_collision.ProbeFutureTR
    AND #$00FF
    CMP #$000E
    BCS loc_02DB1F
    LDX #$0026
    JSR $&player_move_main.NudgeToUpperGrid
    PLP 
    CLC 
    RTS 

  loc_02DB1F:
    PLP 
    SEC 
    RTS 
}

ComputeWestSnapOffset {
    REP #$20
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTR
    CMP #$09
    BEQ loc_02DB44
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02DB6B
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
    BNE loc_02DB6B

  loc_02DB44:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A
    PHA 
    LDA $20
    LSR 
    LSR 
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02DB68
    LDA #$0010
    STA $02

  loc_02DB68:
    PLA 
    BRA loc_02DB75

  loc_02DB6B:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02DB75:
    LDA $1A
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}