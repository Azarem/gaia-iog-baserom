; Reverse the destination of each telekinesis step when the Negative Arc is equipped.
; Keep the existing facing, distance, collision, and one-tile slide logic.
; Gem attraction has its own handler and does not use these hooks.
?INCLUDE 'interaction_handlers'

!negativeArcEquippedItem       7E0AC6

interaction_handlers.PushSolidMovePlayerNorth! {
    LDY $playerActor
    LDA $0016, Y
    SEC
    SBC $16
    BPL PushSolidMovePlayerSouth
    BPL PushSolidDistPlayerNorth
    EOR #$FFFF
    INC

  interaction_handlers.PushSolidDistPlayerNorth!:
    CMP #$0020
    BCC PushSolidRestorePlayerNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushSolidRestorePlayerNorth
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcSolidMoveNorth
    JMP $&NegativeArcSolidMoveSouth

  NegativeArcSolidMoveNorth:
    COP [BranchIfSolidOffset] ( #00, #FF, &PushSolidRestorePlayerNorth )
    COP [ClearSolidHere]
    LDA $16
    SEC
    SBC #$0010
    STA $16
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC
    STA $0016, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

interaction_handlers.PushSolidRestorePlayerNorth! {
    COP [RestoreSavedPtr]

  interaction_handlers.PushSolidMovePlayerSouth!:
    CMP #$0020
    BCC PushSolidRestorePlayerSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushSolidRestorePlayerSouth
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcSolidMoveSouth
    JMP $&NegativeArcSolidMoveNorth

  NegativeArcSolidMoveSouth:
    COP [BranchIfSolidOffset] ( #00, #01, &PushSolidRestorePlayerSouth )
    COP [ClearSolidHere]
    LDA $16
    CLC
    ADC #$0010
    STA $16
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    INC
    STA $0016, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

interaction_handlers.PushSolidMovePlayerWest! {
    LDY $playerActor
    LDA $0014, Y
    SEC
    SBC $14
    BPL PushSolidMovePlayerEast
    BPL PushSolidDistPlayerWest
    EOR #$FFFF
    INC

  interaction_handlers.PushSolidDistPlayerWest!:
    CMP #$0020
    BCC PushSolidRestorePlayerWest
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushSolidRestorePlayerWest
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcSolidMoveWest
    JMP $&NegativeArcSolidMoveEast

  NegativeArcSolidMoveWest:
    COP [BranchIfSolidOffset] ( #FF, #00, &PushSolidRestorePlayerWest )
    COP [ClearSolidHere]
    LDA $14
    SEC
    SBC #$0010
    STA $14
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC
    STA $0014, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

interaction_handlers.PushSolidRestorePlayerWest! {
    COP [RestoreSavedPtr]

  interaction_handlers.PushSolidMovePlayerEast!:
    CMP #$0020
    BCC PushSolidRestorePlayerEast
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushSolidRestorePlayerEast
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcSolidMoveEast
    JMP $&NegativeArcSolidMoveWest

  NegativeArcSolidMoveEast:
    COP [BranchIfSolidOffset] ( #01, #00, &PushSolidRestorePlayerEast )
    COP [ClearSolidHere]
    LDA $14
    CLC
    ADC #$0010
    STA $14
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    INC
    STA $0014, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

interaction_handlers.PushForceballMovePlayerNorth! {
    LDY $playerActor
    LDA $0016, Y
    SEC
    SBC $16
    BPL PushForceballMovePlayerSouth
    BPL PushForceballDistPlayerNorth
    EOR #$FFFF
    INC

  interaction_handlers.PushForceballDistPlayerNorth!:
    CMP #$0020
    BCC PushForceballRestorePlayerNorth
    LDA $0028, Y
    CMP #$003A
    BNE PushForceballRestorePlayerNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushForceballRestorePlayerNorth
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcForceballMoveNorth
    JMP $&NegativeArcForceballMoveSouth

  NegativeArcForceballMoveNorth:
    COP [BranchIfSolidOffset] ( #00, #FF, &PushForceballRestorePlayerNorth )
    COP [NudgePosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC
    STA $0016, Y
    COP [LoopEnd]
}

interaction_handlers.PushForceballRestorePlayerNorth! {
    COP [RestoreSavedPtr]

  interaction_handlers.PushForceballMovePlayerSouth!:
    CMP #$0020
    BCC PushForceballRestorePlayerSouth
    LDA $0028, Y
    CMP #$003B
    BNE PushForceballRestorePlayerSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushForceballRestorePlayerSouth
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcForceballMoveSouth
    JMP $&NegativeArcForceballMoveNorth

  NegativeArcForceballMoveSouth:
    COP [BranchIfSolidOffset] ( #00, #01, &PushForceballRestorePlayerSouth )
    COP [NudgePosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    INC
    STA $0016, Y
    COP [LoopEnd]
}

interaction_handlers.PushForceballMovePlayerWest! {
    LDY $playerActor
    LDA $0014, Y
    SEC
    SBC $14
    BPL PushForceballMovePlayerEast
    BPL PushForceballDistPlayerWest
    EOR #$FFFF
    INC

  interaction_handlers.PushForceballDistPlayerWest!:
    CMP #$0020
    BCC PushForceballRestorePlayerWest
    LDA $0028, Y
    CMP #$003D
    BNE PushForceballRestorePlayerWest
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushForceballRestorePlayerWest
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcForceballMoveWest
    JMP $&NegativeArcForceballMoveEast

  NegativeArcForceballMoveWest:
    COP [BranchIfSolidOffset] ( #FF, #00, &PushForceballRestorePlayerWest )
    COP [NudgePosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC
    STA $0014, Y
    COP [LoopEnd]
}

interaction_handlers.PushForceballRestorePlayerWest! {
    COP [RestoreSavedPtr]

  interaction_handlers.PushForceballMovePlayerEast!:
    CMP #$0020
    BCC PushForceballRestorePlayerEast
    LDA $0028, Y
    CMP #$003C
    BNE PushForceballRestorePlayerEast
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushForceballRestorePlayerEast
    LDA $negativeArcEquippedItem
    CMP #$002A
    BNE NegativeArcForceballMoveEast
    JMP $&NegativeArcForceballMoveWest

  NegativeArcForceballMoveEast:
    COP [BranchIfSolidOffset] ( #01, #00, &PushForceballRestorePlayerEast )
    COP [NudgePosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    INC
    STA $0014, Y
    COP [LoopEnd]
}
