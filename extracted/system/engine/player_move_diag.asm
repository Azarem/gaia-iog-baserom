?BANK 02

?INCLUDE 'map_coords'
?INCLUDE 'player_character'
?INCLUDE 'player_move_ew'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!collisionLayer                 7FC000

---------------------------------------------

DispatchDiagDownLeft {
    SEP #$20
    LDA #$02
    TSB $AB
    JSR $&map_coords.ProbeRightTiles
    BNE loc_02DB93
    BCS loc_02DB90
    JMP $&DiagRampDownRight

  loc_02DB90:
    JMP $&DiagRampUpLeft

  loc_02DB93:
    JSR $&tile_collision.ProbeCurrentTL
    BCC loc_02DB9F
    CMP #$06
    BNE loc_02DB9F
    JMP $&code_02DC4B

  loc_02DB9F:
    JSR $&tile_collision.ProbeCurrentBL
    BCC loc_02DBAB
    CMP #$09
    BNE loc_02DBAB
    JMP $&code_02DC9F

  loc_02DBAB:
    JSR $&tile_collision.ProbeFutureTL
    BCC loc_02DBBB
    CMP #$0E
    BCS loc_02DC03
    CMP #$06
    BNE loc_02DBBB
    JMP $&code_02DC77

  loc_02DBBB:
    JSR $&tile_collision.CheckSubTileAlignY
    BCS loc_02DBC9
    CMP #$09
    BNE loc_02DBC7
    JMP $&code_02DCCB

  loc_02DBC7:
    BRA loc_02DBE2

  loc_02DBC9:
    CMP #$09
    BEQ loc_02DC03
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E
    BCS loc_02DC03
    CMP #$09
    BNE loc_02DBDE
    JMP $&code_02DCCB

  loc_02DBDE:
    CMP #$06
    BEQ loc_02DC03

  loc_02DBE2:
    CMP #$07
    BEQ DiagLadderTile
    JSR $&tile_collision.ProbeCurrentTR
    BCC loc_02DBF9
    CMP #$05
    BNE loc_02DBF2
    JMP $&DiagRampEdgeUL

  loc_02DBF2:
    CMP #$0A
    BNE loc_02DBF9
    JMP $&DiagRampEdgeDR

  loc_02DBF9:
    REP #$20
    LDA $22
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02DC03:
    JSR $&tile_collision.SetActorCollisionFlag
    JSR $&DiagAutoAlignNS
    BCS SnapXDiagCollision
    PHP 
    REP #$20
    BRA loc_02DC16
}

SnapXDiagCollision {
    PHP 
    REP #$20
    STZ $playerSpeedEw

  loc_02DC16:
    LDA $20
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0060
    STA $22
    STZ $20
    PLP 
    RTS 

  DiagLadderTile:
    JSR $&tile_collision.CheckSubTileAlignY
    BCS loc_02DC03
    JSR $&DiagClearReturnFlags
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyLeftEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02DC03

  DiagWallSouthFromDL:
    SEP #$20
}

code_02DC4B {
    LDA #$80
    TSB $AB
    JSR $&tile_collision.ProbeFutureTL
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02DC7D
    CMP #$06
    BNE loc_02DC7D

  loc_02DC5B:
    JSR $&tile_collision.MapCellRight
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DC69
    CMP #$05
    BNE loc_02DC97

  loc_02DC69:
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DC8F
    CMP #$06
    BNE loc_02DC97
    BRA loc_02DC8F
}

code_02DC77 {
    LDA #$04
    TSB $AB
    BRA loc_02DC5B

  loc_02DC7D:
    JSR $&player_move_ns.SnapYSouthCollision
    JSR $&tile_collision.ProbeFutureTL
    BCC loc_02DC8F
    CMP #$06
    BEQ loc_02DC8F
    JSR $&SnapXDiagCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DC8F:
    REP #$20
    JSR $&ComputeDiagSnapOffset
    JMP $&DiagPushRight

  loc_02DC97:
    REP #$20
    STZ $playerSpeedEw
    RTS 
}

DiagWallNorthFromDL {
    SEP #$20
}

code_02DC9F {
    LDA #$80
    TSB $AB
    JSR $&tile_collision.ProbeFutureBL
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02DCD3
    CMP #$09
    BNE loc_02DCD3

  loc_02DCAF:
    JSR $&tile_collision.MapCellLeft
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DCBD
    CMP #$0A
    BNE loc_02DCED

  loc_02DCBD:
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DCE5
    CMP #$09
    BNE loc_02DCED
    BRA loc_02DCE5
}

code_02DCCB {
    STX $00
    LDA #$08
    TSB $AB
    BRA loc_02DCAF

  loc_02DCD3:
    JSR $&player_move_ew.SnapXEastCollision
    JSR $&tile_collision.ProbeFutureBL
    BCC loc_02DCE5
    CMP #$09
    BEQ loc_02DCE5
    JSR $&SnapXDiagCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DCE5:
    REP #$20
    JSR $&ComputeDiagSnapOffset
    JMP $&DiagPushLeft

  loc_02DCED:
    REP #$20
    STZ $playerSpeedEw
    RTS 
}

DiagRampUpLeft {
    JSR $&DiagClearReturnFlags
    JSR $&tile_collision.ProbeCurrentTL
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BNE loc_02DD0F
    JMP $&code_02DD82

  loc_02DD0F:
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02DD82
    JSR $&tile_collision.ProbeFutureTL
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ loc_02DD4C
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02DD4C
    JMP $&DiagRedirectToSouth

  loc_02DD4C:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02DD54
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DD54:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
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
    BCC code_02DD8D
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02DD8D
}

code_02DD82 {
    LDA $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26

  code_02DD8D:
    LDA #$1000
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTL
    CMP #$0E
    BCS loc_02DDA9
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0E
    BCS loc_02DDA6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DDA6:
    JMP $&code_02DDF2

  loc_02DDA9:
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0E
    BCS loc_02DDB3
    JMP $&code_02DDFA

  loc_02DDB3:
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
    BEQ loc_02DDCD
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02DDCD:
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

code_02DDF2 {
    REP #$20
    JSR $&player_move_ew.SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DDFA {
    REP #$20
    JSR $&player_move_ns.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

DiagRampEdgeUL {
    JSR $&DiagClearReturnFlags
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ loc_02DE1B
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DE1B:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02DE23
    JMP $&code_02DD82

  loc_02DE23:
    LDA $20
    LSR 
    LSR 
    ORA #$F000
    CLC 
    ADC $1A
    INC 
    ORA #$FFF0
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $20
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02DD8D
}

DiagRedirectToSouth {
    JSR $&tile_collision.ProbeFutureTL
    CMP #$0006
    BNE loc_02DE4E
    JMP $&DiagWallSouthFromDL

  loc_02DE4E:
    JMP $&tile_collision.ApplyMovementDeltas
}

DiagRampDownRight {
    JSR $&DiagClearReturnFlags
    JSR $&tile_collision.ProbeCurrentBL
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BNE loc_02DE6D
    JMP $&code_02DEE4

  loc_02DE6D:
    JSR $&tile_collision.MapCellLeft
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02DEE4
    JSR $&tile_collision.ProbeFutureTL
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ loc_02DEAA
    JSR $&tile_collision.MapCellRight
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02DEAA
    JMP $&DiagRedirectToNorth

  loc_02DEAA:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02DEB2
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DEB2:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
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
    BCC code_02DEEB
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DEEB
}

code_02DEE4 {
    LDA $20
    CLC 
    ADC $26
    STA $26

  code_02DEEB:
    LDA #$1000
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTL
    CMP #$0E
    BCS loc_02DF07
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0E
    BCS loc_02DF04
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DF04:
    JMP $&code_02DF4C

  loc_02DF07:
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0E
    BCS loc_02DF11
    JMP $&code_02DF54

  loc_02DF11:
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
    BEQ loc_02DF2B
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02DF2B:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
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

code_02DF4C {
    REP #$20
    JSR $&player_move_ew.SnapXEastCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DF54 {
    REP #$20
    JSR $&player_move_ns.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

DiagRampEdgeDR {
    JSR $&DiagClearReturnFlags
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ loc_02DF75
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DF75:
    JSR $&tile_collision.CheckTileBoundaryXor
    BNE loc_02DF7D
    JMP $&code_02DEE4

  loc_02DF7D:
    LDA $20
    LSR 
    LSR 
    ORA #$F000
    CLC 
    ADC $1A
    INC 
    ORA #$FFF0
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $20
    STA $24
    JMP $&code_02DEEB
}

DiagRedirectToNorth {
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0009
    BNE loc_02DFA4
    JMP $&DiagWallNorthFromDL

  loc_02DFA4:
    JMP $&tile_collision.ApplyMovementDeltas
}

DiagAutoAlignNS {
    PHP 
    REP #$20
    LDA $06, S
    BNE loc_02DFF3
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02DFF3
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02DFF3
    STA $04
    CMP #$0004
    BCC loc_02DFDB
    JSR $&tile_collision.ProbeFutureBL
    CMP #$000E
    BCS loc_02DFDB
    LDX #$0026
    JSR $&player_move_main.NudgeToLowerGrid
    PLP 
    CLC 
    RTS 

  loc_02DFDB:
    LDA $04
    CMP #$000B
    BCS loc_02DFF3
    JSR $&tile_collision.ProbeFutureTL
    CMP #$000E
    BCS loc_02DFF3
    LDX #$0026
    JSR $&player_move_main.NudgeToUpperGrid
    PLP 
    CLC 
    RTS 

  loc_02DFF3:
    PLP 
    SEC 
    RTS 
}

ComputeDiagSnapOffset {
    REP #$20
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL
    CMP #$09
    BEQ loc_02E018
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02E044
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
    BNE loc_02E044

  loc_02E018:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A
    PHA 
    LDA $20
    BEQ loc_02E02E
    LSR 
    LSR 
    ORA #$0C00

  loc_02E02E:
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02E041
    LDA #$0010
    STA $02

  loc_02E041:
    PLA 
    BRA loc_02E04E

  loc_02E044:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02E04E:
    LDA $1A
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    STA $02
    RTS 
}

DiagPushLeft {
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BNE loc_02E06C
    LDA #$0010

  loc_02E06C:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02E077
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E077:
    AND #$000F
    STA $02
    LDA $03, S
    BEQ loc_02E096
    LDA $20
    BPL loc_02E088
    EOR #$FFFF
    INC 

  loc_02E088:
    CMP $03, S
    BEQ loc_02E0A3
    BPL loc_02E096
    STZ $20
    LDA #$0840
    TRB $AA
    RTS 

  loc_02E096:
    LDA $02
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    STA $24
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0A3:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

DiagPushRight {
    LDA $26
    LSR 
    LSR 
    ORA #$FFF0
    EOR #$FFFF
    INC 
    BNE loc_02E0BB
    LDA #$0010

  loc_02E0BB:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02E0C6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0C6:
    AND #$000F
    STA $02
    LDA $03, S
    BEQ loc_02E0E9
    LDA $20
    BPL loc_02E0D7
    EOR #$FFFF
    INC 

  loc_02E0D7:
    EOR #$FFFF
    INC 
    CMP $03, S
    BEQ loc_02E0F2
    BMI loc_02E0E9
    STZ $20
    LDA #$0440
    TRB $AA
    RTS 

  loc_02E0E9:
    LDA $02
    ASL 
    ASL 
    STA $24
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0F2:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

DiagClearReturnFlags {
    REP #$20
    LDA #$0000
    STA $05, S
    RTS 
}