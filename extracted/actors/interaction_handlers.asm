; Runtime push and collect interaction scripts (Bank 00) spawned as marked-after actors on pushable solids, statues, prison cells, and force-ball puzzles.
; 
; collect_handler_gem waits for button $31 while the player is near, checks facing via GetPlayerFacingDirection, and nudges the player toward the gem in 2-pixel steps until aligned. push_handler_solid requires the same button, verifies facing and ≥$20 pixel offset, confirms clearance with BranchIfSolidOffset, then moves the block one tile while toggling status bit $0010 during the 16-frame push loop.
; 
; push_handler_forceball mirrors push logic but requires specific player body sprites ($003A–$003D) and uses AddPosition instead of tile snapping — used for Mu force-ball puzzles. Spawn sites include Edward Castle statues, Incan Ruins guards, Sky Garden armor, South Cape Seth boulder, prison gem cell, and DarkGemDropSystem.
---------------------------------------------

?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!orbitAngle                     7F0010

---------------------------------------------

collect_handler_gem {
    COP [SetSavedPtr] ( &collect_handler_gem )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &CollectGemOnButton )

  CollectGemIdleRtl:
    RTL 
}

CollectGemOnButton {
    COP [BranchIfPlayerNear] ( #0F, &CollectGemBranchOnX )
    RTL 
}

CollectGemBranchOnX {
    COP [BranchOnPlayerX] ( #$000F, &CollectGemBranchOnY, &CollectGemAlignWest, &CollectGemBranchOnY )
}

CollectGemAlignWest {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL CollectGemAlignEast
    BPL CollectGemNudgeWestHalf
    EOR #$FFFF
    INC 

  CollectGemNudgeWestHalf:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE CollectGemRestoreWest
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ CollectGemRestoreWest
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestoreWest
    RTL 

  CollectGemRestoreWest:
    COP [RestoreSavedPtr]

  CollectGemAlignEast:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE CollectGemRestoreEast
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ CollectGemRestoreEast
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestoreEast
    RTL 

  CollectGemRestoreEast:
    COP [RestoreSavedPtr]
}

CollectGemBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &CollectGemIdleRtl, &CollectGemAlignNorth, &CollectGemIdleRtl )
}

CollectGemAlignNorth {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL CollectGemAlignSouth
    BPL CollectGemNudgeNorthHalf
    EOR #$FFFF
    INC 

  CollectGemNudgeNorthHalf:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE CollectGemRestoreNorth
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ CollectGemRestoreNorth
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestoreNorth
    RTL 

  CollectGemRestoreNorth:
    COP [RestoreSavedPtr]

  CollectGemAlignSouth:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE CollectGemRestoreSouth
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    CLC 
    ADC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ CollectGemRestoreSouth
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestoreSouth
    RTL 

  CollectGemRestoreSouth:
    COP [RestoreSavedPtr]

  push_handler_solid:
    COP [SetSavedPtr] ( &push_handler_solid ) ; push_handler_solid: BranchIfButton A, BranchIfPlayerNear radius $0F
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &PushSolidOnButton )

  PushSolidIdleRtl:
    RTL 
}

PushSolidOnButton {
    COP [BranchIfPlayerNear] ( #0F, &PushSolidCheckState )
    RTL 
}

PushSolidCheckState {
    LDY $04               ; Skip push if parent actor $10 bit $80 set and $12 bit $0010 clear
    LDA $0010, Y
    BIT #$0080
    BEQ PushSolidBranchOnX
    LDA $0012, Y
    BIT #$0010
    BNE PushSolidBranchOnX
    NOP 
    NOP 
    NOP 
    RTL 

  PushSolidBranchOnX:
    COP [BranchOnPlayerX] ( #$000F, &PushSolidBranchOnY, &PushSolidMoveWest, &PushSolidBranchOnY )
}

PushSolidMoveWest {
    LDY $playerActor      ; Push west: abs delta-Y≥$20, facing north, solid offset clear, nudge −$10 Y
    LDA $0016, Y
    SEC 
    SBC $16
    BPL PushSolidMoveEast
    BPL PushSolidDistWest
    EOR #$FFFF
    INC 

  PushSolidDistWest:
    CMP #$0020
    BCC PushSolidRestoreWest
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushSolidRestoreWest
    COP [BranchIfSolidOffset] ( #00, #FF, &PushSolidRestoreWest )
    COP [ClearLowHere]
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&PushSolidClearPushingFlag
}

PushSolidRestoreWest {
    COP [RestoreSavedPtr]

  PushSolidMoveEast:
    CMP #$0020
    BCC PushSolidRestoreEast
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushSolidRestoreEast
    COP [BranchIfSolidOffset] ( #00, #01, &PushSolidRestoreEast )
    COP [ClearLowHere]
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&PushSolidClearPushingFlag
}

PushSolidRestoreEast {
    COP [RestoreSavedPtr]
}

PushSolidBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &PushSolidIdleRtl, &PushSolidMoveNorth, &PushSolidIdleRtl )
}

PushSolidMoveNorth {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL PushSolidMoveSouth
    BPL PushSolidDistNorth
    EOR #$FFFF
    INC 

  PushSolidDistNorth:
    CMP #$0020
    BCC PushSolidRestoreNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushSolidRestoreNorth
    COP [BranchIfSolidOffset] ( #FF, #00, &PushSolidRestoreNorth )
    COP [ClearLowHere]
    LDA $14
    SEC 
    SBC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&PushSolidClearPushingFlag
}

PushSolidRestoreNorth {
    COP [RestoreSavedPtr]

  PushSolidMoveSouth:
    CMP #$0020
    BCC PushSolidRestoreSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushSolidRestoreSouth
    COP [BranchIfSolidOffset] ( #01, #00, &PushSolidRestoreSouth )
    COP [ClearLowHere]
    LDA $14
    CLC 
    ADC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&PushSolidClearPushingFlag
}

PushSolidRestoreSouth {
    COP [RestoreSavedPtr]
}

PushSolidSetPushingFlag {
    LDY $04               ; PushSolidSetPushingFlag: OR parent $12 bit $0010 during 16-frame push loop
    LDA $0012, Y
    PHA 
    ORA #$0010
    STA $0012, Y
    PLA 
    AND #$0010
    STA $24
    RTS 
}

PushSolidClearPushingFlag {
    LDY $04               ; PushSolidClearPushingFlag: restore original bit $0010 state from saved $24
    LDA $0012, Y
    AND #$FFEF
    ORA $24
    STA $0012, Y
    RTS 
}

push_handler_forceball {
    COP [SetSavedPtr] ( &push_handler_forceball ) ; push_handler_forceball: requires player anim $3A–$3D matching direction
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &PushForceballOnButton )
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  PushForceballIdleRtl:
    RTL 
}

PushForceballOnButton {
    COP [BranchIfPlayerNear] ( #0F, &PushForceballBranchOnX )
    RTL 
}

PushForceballBranchOnX {
    COP [BranchOnPlayerX] ( #$000F, &PushForceballBranchOnY, &PushForceballMoveWest, &PushForceballBranchOnY )
}

PushForceballMoveWest {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL PushForceballMoveEast
    BPL PushForceballDistWest
    EOR #$FFFF
    INC 

  PushForceballDistWest:
    CMP #$0020
    BCC PushForceballRestoreWest
    LDA $0028, Y
    CMP #$003A
    BNE PushForceballRestoreWest
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushForceballRestoreWest
    COP [BranchIfSolidOffset] ( #00, #FF, &PushForceballRestoreWest )
    COP [AddPosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
}

PushForceballRestoreWest {
    COP [RestoreSavedPtr]

  PushForceballMoveEast:
    CMP #$0020
    BCC PushForceballRestoreEast
    LDA $0028, Y
    CMP #$003B
    BNE PushForceballRestoreEast
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushForceballRestoreEast
    COP [BranchIfSolidOffset] ( #00, #01, &PushForceballRestoreEast )
    COP [AddPosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
}

PushForceballRestoreEast {
    COP [RestoreSavedPtr]
}

PushForceballBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &PushForceballIdleRtl, &PushForceballMoveNorth, &PushForceballIdleRtl )
}

PushForceballMoveNorth {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL PushForceballMoveSouth
    BPL PushForceballDistNorth
    EOR #$FFFF
    INC 

  PushForceballDistNorth:
    CMP #$0020
    BCC PushForceballRestoreNorth
    LDA $0028, Y
    CMP #$003D
    BNE PushForceballRestoreNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushForceballRestoreNorth
    COP [BranchIfSolidOffset] ( #FF, #00, &PushForceballRestoreNorth )
    COP [AddPosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
}

PushForceballRestoreNorth {
    COP [RestoreSavedPtr]

  PushForceballMoveSouth:
    CMP #$0020
    BCC PushForceballRestoreSouth
    LDA $0028, Y
    CMP #$003C
    BNE PushForceballRestoreSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushForceballRestoreSouth
    COP [BranchIfSolidOffset] ( #01, #00, &PushForceballRestoreSouth )
    COP [AddPosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
}

PushForceballRestoreSouth {
    COP [RestoreSavedPtr]
}