?BANK 00

?INCLUDE 'player_character'

!joypadHeld                     0658
!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!climbStateData                 09E0
!statsPtr                       7F0020

---------------------------------------------

StairTriggerSouth [
  actor-def < #00, #00, #20, {

  code_00D0D4:
    LDY $playerActor
    LDA $16
    SEC 
    SBC #$0008
    CMP $0016, Y
    BCC loc_00D0E3
    RTL 

  loc_00D0E3:
    CLC 
    ADC #$0020
    CMP $0016, Y
    BCS loc_00D0ED
    RTL 

  loc_00D0ED:
    LDA $0014, Y
    CMP $14
    BEQ loc_00D0F5
    RTL 

  loc_00D0F5:
    JSR $&CheckMoveState
    BCC loc_00D0FB
    RTL 

  loc_00D0FB:
    LDA $0028, Y
    CMP #$0012
    BEQ loc_00D109
    CMP #$0013
    BEQ loc_00D109
    RTL 

  loc_00D109:
    LDA #$&ClimbSouth
    STA $0000, Y
    LDA #$*ClimbSouth
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

StairTriggerNorth [
  actor-def < #00, #00, #20, {

  code_00D11C:
    LDY $playerActor
    LDA $16
    SEC 
    SBC #$0008
    CMP $0016, Y
    BCC loc_00D12B
    RTL 

  loc_00D12B:
    CLC 
    ADC #$0020
    CMP $0016, Y
    BCS loc_00D135
    RTL 

  loc_00D135:
    LDA $0014, Y
    CMP $14
    BEQ loc_00D13D
    RTL 

  loc_00D13D:
    JSR $&CheckMoveState
    BCC loc_00D143
    RTL 

  loc_00D143:
    LDA $0028, Y
    CMP #$0015
    BEQ loc_00D151
    CMP #$0016
    BEQ loc_00D151
    RTL 

  loc_00D151:
    LDA #$&ClimbNorth
    STA $0000, Y
    LDA #$*ClimbNorth
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

StairTriggerWestEntry [
  actor-def < #00, #00, #20, {

  code_00D164:
    COP [AddPosition] ( #F8, #00 )
    BRA code_00D16D
} >
]

StairTriggerWest [
  actor-def < #00, #00, #20, {

  code_00D16D:
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $14
    SEC 
    SBC #$0008
    CMP $0014, Y
    BCC loc_00D17E
    RTL 

  loc_00D17E:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D188
    RTL 

  loc_00D188:
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D191
    RTL 

  loc_00D191:
    JSR $&CheckMoveState
    BCC loc_00D197
    RTL 

  loc_00D197:
    LDA $0028, Y
    CMP #$000F
    BEQ loc_00D1A5
    CMP #$0010
    BEQ loc_00D1A5
    RTL 

  loc_00D1A5:
    LDA #$&ClimbWest
    STA $0000, Y
    LDA #$*ClimbWest
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

StairTriggerEast [
  actor-def < #00, #00, #20, {

  code_00D1B8:
    LDY $playerActor
    LDA $14
    SEC 
    SBC #$0008
    CMP $0014, Y
    BCC loc_00D1C7
    RTL 

  loc_00D1C7:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D1D1
    RTL 

  loc_00D1D1:
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D1DA
    RTL 

  loc_00D1DA:
    LDY $playerActor
    JSR $&CheckMoveState
    BCC loc_00D1E3
    RTL 

  loc_00D1E3:
    LDY $playerActor
    LDA $0028, Y
    CMP #$000C
    BEQ loc_00D1F4
    CMP #$000D
    BEQ loc_00D1F4
    RTL 

  loc_00D1F4:
    LDA #$&ClimbEast
    STA $0000, Y
    LDA #$*ClimbEast
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

CheckMoveState {
    PHX 
    TYX 
    SEP #$20
    LDA $7F0008, X
    CMP #$8F
    REP #$20
    BEQ loc_00D215
    PLX 
    SEC 
    RTS 

  loc_00D215:
    PLX 
    CLC 
    RTS 
}

ClimbSouth {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $14
    SEC 
    SBC #$0004
    STA $14
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D238
    STA $statsPtr, X
    RTL 

  loc_00D238:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

ClimbNorth {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $14
    CLC 
    ADC #$0004
    STA $14
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D266
    STA $statsPtr, X
    RTL 

  loc_00D266:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

ClimbWest {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $16
    SEC 
    SBC #$0004
    STA $16
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D294
    STA $statsPtr, X
    RTL 

  loc_00D294:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

ClimbEast {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $16
    CLC 
    ADC #$0004
    STA $16
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D2C2
    STA $statsPtr, X
    RTL 

  loc_00D2C2:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}
---------------------------------------------

LockPlayerForClimb {
    LDA $0E
    ASL 
    ASL 
    PHX 
    LDX $playerActor
    STA $statsPtr, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags
    RTS 
}

UnlockPlayerAfterClimb {
    STZ $climbStateData
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0002
    TRB $playerFlags
    JSR $&RestorePlayerControl
    RTS 
}
---------------------------------------------

RestorePlayerControl {
    PHX 
    LDX $playerActor
    LDA #$*player_character.PlayerIdleEntry
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    LDA $0010, X
    AND #$FDFF
    ORA #$0008
    STA $0010, X
    LDA #$0F00
    TRB $joypadMaskStd
    LDA #$0800
    TRB $playerFlags
    PLX 
    RTS 
}