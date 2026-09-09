?INCLUDE 'func_0AA41C'

!playerXPos                     09A2
!playerYPos                     09A4
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

dm3D_flayzer [
  actor-def < #00, #00, #00, {

  code_0AAA57:
    LDA #$0002
    TSB $12
    COP [SetHFlip]

  loc_0AAA5E:
    COP [WaitWhileOffscreen] ( #10 )
    COP [LoopInit] ( #02 )
    COP [SetHitCallback] ( #$0000 )
    COP [CallScript] ( &code_0AAE41 )
    COP [SetHitCallback] ( &code_0AAABE )
    COP [BranchIfPlayerNear] ( #04, &code_0AAABE )
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    COP [RngByte]
    AND #$0003
    STA $08
    COP [BranchIfPlayerNear] ( #04, &code_0AAABE )
    COP [LoopNext]
    BRA loc_0AAA5E
} >
]

dm3D_flayzer2 [
  actor-def < #00, #00, #00, {

  code_0AAA8D:
    LDA #$0002
    TSB $12

  loc_0AAA92:
    COP [WaitWhileOffscreen] ( #10 )
    COP [LoopInit] ( #02 )
    COP [SetHitCallback] ( #$0000 )
    COP [CallScript] ( &code_0AADC6 )
    COP [SetHitCallback] ( &code_0AAABE )
    COP [BranchIfPlayerNear] ( #04, &code_0AAABE )
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    COP [RngByte]
    AND #$0003
    STA $08
    COP [BranchIfPlayerNear] ( #04, &code_0AAABE )
    COP [LoopNext]
    BRA loc_0AAA92
} >
]

code_0AAABE {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0002
    TRB $12
    JMP $&code_0AAB59
}

dm3D_flayzer3 [
  actor-def < #00, #00, #00, {

  code_0AAACD:
    COP [RngByte]
    AND #$003F
    STA $08

  code_0AAAD4:
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [BranchIfSolidSouth] ( &code_0AAAEE )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [CallScript] ( &code_0AAB36 )
} >
]

code_0AAAEE {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [BranchIfSolidNorth] ( &code_0AAB08 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [CallScript] ( &code_0AAB36 )
}

code_0AAB08 {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0AAB1E )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [LoopNext]
}

code_0AAB1E {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AAAD4 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [LoopNext]
    BRA code_0AAAD4
}

code_0AAB36 {
    COP [StageSpriteLoop] ( #02, #40 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [StageSpriteLoop] ( #82, #40 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    COP [RestoreSavedPtr]
}

code_0AAB59 {
    LDA #$0001
    TSB $12
    COP [BranchNearerAxis] ( &code_0AAB64, &code_0AAB9B )
}

code_0AAB64 {
    COP [SetEntryExit]
    COP [BranchOnPlayerX] ( #$0030, &code_0AABDE, &code_0AAB70, &code_0AAC12 )
}

code_0AAB70 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AAB8B, &code_0AAB7A, &code_0AAB7A )
}

code_0AAB7A {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AAE15 )
    LDA #$0100
    TRB $10
    JMP $&code_0AAC12
}

code_0AAB8B {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AAD9A )
    LDA #$0100
    TRB $10
    BRA code_0AABDE
}

code_0AAB9B {
    COP [SetEntryExit]
    COP [BranchOnPlayerY] ( #$0030, &code_0AAC7A, &code_0AABA7, &code_0AAC46 )
}

code_0AABA7 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AABB1, &code_0AABC2, &code_0AABC2 )
}

code_0AABB1 {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AAD1E )
    LDA #$0100
    TRB $10
    JMP $&code_0AAC7A
}

code_0AABC2 {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AACA2 )
    LDA #$0100
    TRB $10
    BRA code_0AAC46

  code_0AABD2:
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AAC12 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AABDE {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_0AABE3:
    COP [BranchIfSolidWest] ( &code_0AAC06 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AABF3, &code_0AAC46 )
}

code_0AABF3 {
    COP [BranchOnPlayerX] ( #$0080, &code_0AABFD, &code_0AABFD, &code_0AAC12 )
}

code_0AABFD {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    BRA loc_0AABE3
}

code_0AAC06 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AAC46 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AAC12 {
    COP [StageSpriteFrame] ( #82 )
    COP [AnimOnce]

  loc_0AAC17:
    COP [BranchIfSolidEast] ( &code_0AAC3A )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AAC27, &code_0AAC46 )
}

code_0AAC27 {
    COP [BranchOnPlayerX] ( #$0080, &code_0AABFD, &code_0AAC31, &code_0AAC31 )
}

code_0AAC31 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    BRA loc_0AAC17
}

code_0AAC3A {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AAC7A )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
}

code_0AAC46 {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]

  loc_0AAC4B:
    COP [BranchIfSolidSouth] ( &code_0AAC6E )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AABDE, &code_0AAC5B )
}

code_0AAC5B {
    COP [BranchOnPlayerY] ( #$0080, &code_0AAC99, &code_0AAC65, &code_0AAC65 )
}

code_0AAC65 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    BRA loc_0AAC4B
}

code_0AAC6E {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AABDE )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
}

code_0AAC7A {
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]

  loc_0AAC7F:
    COP [BranchIfSolidNorth] ( &code_0AABD2 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AABDE, &code_0AAC8F )
}

code_0AAC8F {
    COP [BranchOnPlayerY] ( #$0080, &code_0AAC99, &code_0AAC99, &code_0AAC65 )
}

code_0AAC99 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAB59 )
    BRA loc_0AAC7F
}

code_0AACA2 {
    LDA $14
    STA $moveXAlt, X
    LDA $playerYPos
    AND #$FFF0
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #09, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAEA4, #F0, #D0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #F0, #D4, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #F0, #D8, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #F0, #DC, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #F0, #E0, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFC4, #F0, #E4, #$0302 )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    JMP $&code_0AAE8E
}

code_0AAD1E {
    LDA $14
    STA $moveXAlt, X
    LDA $playerYPos
    AND #$FFF0
    CLC 
    ADC #$0050
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #0A, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAEC9, #10, #E0, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #11, #DC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #12, #D8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #14, #D4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFB5, #12, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFD0, #0C, #D0, #$0300 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JMP $&code_0AAE8E
}

code_0AAD9A {
    LDA $playerXPos
    AND #$FFF0
    CLC 
    ADC #$0048
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #0B, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
}

code_0AADC6 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAEEE, #DE, #C0, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #E0, #C4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #E2, #C8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #E3, #CC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #E3, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFDD, #E3, #E8, #$0300 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    BRA code_0AAE8E
}

code_0AAE15 {
    LDA $playerXPos
    AND #$FFF0
    SEC 
    SBC #$0038
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #8B, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
}

code_0AAE41 {
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #88 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAF0B, #14, #C4, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #16, #C8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #18, #CC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #19, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFBA, #1A, #D4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAFE9, #1B, #D8, #$0300 )
    COP [StageSpriteFrame] ( #95 )
    COP [AnimOnce]
}

code_0AAE8E {
    COP [WaitByte] ( #4F )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [RestoreSavedPtr]
}

code_0AAEA4 {
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFFC
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #10 )
    LDA $16
    CLC 
    ADC #$0060
    STA $moveYAlt, X
    COP [BranchOnPlayerX] ( #$0018, &code_0AAF69, &code_0AAF5C, &code_0AAF69 )
}

code_0AAEC9 {
    LDA #$000C
    STA $7F100C, X
    LDA #$FFFC
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #11 )
    LDA $16
    SEC 
    SBC #$0040
    STA $moveYAlt, X
    COP [BranchOnPlayerX] ( #$0018, &code_0AAF75, &code_0AAF5C, &code_0AAF75 )
}

code_0AAEEE {
    LDA #$FFE8
    STA $7F100C, X
    LDA #$FFEA
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #12 )
    LDA $14
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    BRA loc_0AAF2B
}

code_0AAF0B {
    LDA #$0012
    STA $7F100C, X
    LDA #$FFEB
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #92 )
    LDA #$0002
    TSB $12
    LDA $14
    CLC 
    ADC #$0050
    STA $moveXAlt, X

  loc_0AAF2B:
    LDA $16
    CLC 
    ADC #$0030
    STA $16
    COP [BranchOnPlayerY] ( #$0018, &code_0AAF4E, &code_0AAF3D, &code_0AAF4E )
}

code_0AAF3D {
    LDA $16
    SEC 
    SBC #$0030
    STA $16
    LDA $playerYPos
    STA $moveYAlt, X
    BRA loc_0AAF7F
}

code_0AAF4E {
    LDA $16
    STA $moveYAlt, X
    SEC 
    SBC #$0030
    STA $16
    BRA loc_0AAF7F
}

code_0AAF5C {
    LDA $playerXPos
    CLC 
    ADC #$0008
    STA $moveXAlt, X
    BRA loc_0AAF7F
}

code_0AAF69 {
    LDA $14
    CLC 
    ADC #$0010
    STA $moveXAlt, X
    BRA loc_0AAF7F
}

code_0AAF75 {
    LDA $14
    SEC 
    SBC #$0010
    STA $moveXAlt, X

  loc_0AAF7F:
    LDA $24
    STA $orbitAngle, X
    COP [MoveToward] ( #FF, #08 )
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #1D )
    LDA $orbitAngle, X
    TAY 
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #04 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAFB5 {
    COP [StageSprAndHitbox] ( #0E )
    BRA loc_0AAFBD
}

code_0AAFBA {
    COP [StageSprAndHitbox] ( #0F )

  loc_0AAFBD:
    COP [SetEntryContinue]
    JSL $@func_0AA41C
    RTL 
}

code_0AAFC4 {
    COP [StageSprAndHitbox] ( #0E )
    COP [SetEntryExit]
    COP [AddPosition] ( #04, #18 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAFD0 {
    COP [StageSprAndHitbox] ( #0E )
    COP [WaitByte] ( #0F )
    COP [AddPosition] ( #00, #24 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAFDD {
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryExit]
    COP [AddPosition] ( #06, #04 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAFE9 {
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryExit]
    COP [AddPosition] ( #FA, #13 )
    COP [SetEntryContinue]
    RTL 
}