; Nitropede enemy — explosive centipede variant in Sky Garden (~549 lines).
; 
; Aggressive multi-phase enemy that patrols and attacks.
; Similar segmented structure to Dynapede but with faster
; movement and explosive death mechanics. Complex
; directional AI with wall collision checks.
---------------------------------------------

?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'sg4D_dynapede'
?INCLUDE 'spriteset_enemies'
?INCLUDE 'StandardEnemyDefeatHandler'

!cameraTargetY                  06C2
!orbitAngle                     7F0010
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sg4E_nitropede1 [
  actor-def < #25, #00, #00, {

  code_0AC819:
    COP [SetSpritePalette] ( #04 )
    LDA #$0180
    TSB $12
    COP [SetDeathCallback] ( @code_0ACB92 )
    JSR $&code_0ACB7C

  loc_0AC829:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC848
} >
]
---------------------------------------------

sg4E_nitropede2 [
  actor-def < #23, #00, #00, {

  code_0AC832:
    COP [SetSpritePalette] ( #04 )
    LDA #$0180
    TSB $12
    COP [SetDeathCallback] ( @code_0ACB92 )
    JSR $&code_0ACB87

  code_0AC842:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0ACA4B
} >
]

code_0AC848 {
    LDA $10
    BIT #$4000
    BNE loc_0AC829
    COP [SetSavedPtr] ( &code_0AC848 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_0AC863

  code_0AC85A:
    COP [SetSavedPtr] ( &code_0AC85A )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  loc_0AC863:
    COP [BranchOnPlayerX] ( #$0020, &code_0ACB41, &code_0AC86D, &code_0ACB61 )
}

code_0AC86D {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC87D )
}

code_list_0AC87D [
  &code_0AC881   ;00
  &code_0AC94F   ;01
]

code_0AC881 {
    COP [RngByte]
    LSR 
    BCC loc_0AC8E9
    COP [BranchIfSolidOffset] ( #FE, #FC, &code_0AC8D1 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #FF, #FC, &code_0AC8D1 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0AC8D1 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #01, #FC, &code_0AC8D1 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #02, #FC, &code_0AC8D1 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #19, #50 )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC848
}

code_0AC8D1 {
    COP [BranchIfSolidNorth] ( &code_0ACA38 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0ACA60 )
    JMP $&code_0ACAF3

  loc_0AC8E9:
    COP [BranchIfSolidNorth] ( &code_0AC904 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC904 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0ACA60 )
    JSR $&code_0ACB87
    JMP $&code_0ACAF3
}

code_0AC904 {
    COP [BranchIfSolidOffset] ( #FE, #FC, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #FF, #FC, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #01, #FC, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #02, #FC, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #19, #50 )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC848
}

code_0AC94F {
    COP [RngByte]
    LSR 
    BCC loc_0AC9C6
    COP [BranchIfSolidOffset] ( #FE, #04, &code_0AC99F )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #FF, #04, &code_0AC99F )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0AC99F )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #01, #04, &code_0AC99F )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #02, #04, &code_0AC99F )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #1A, #4F )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC85A
}

code_0AC99F {
    COP [BranchIfSolidNorth] ( &code_0ACA38 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidSouth] ( &code_0ACA38 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0ACA4B )
    JSR $&code_0ACB87
    JMP $&code_0ACB1C

  loc_0AC9C6:
    COP [BranchIfSolidNorth] ( &code_0AC9ED )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC9ED )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidSouth] ( &code_0AC9ED )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC9ED )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0ACA4B )
    JSR $&code_0ACB87
    JMP $&code_0ACB1C
}

code_0AC9ED {
    COP [BranchIfSolidOffset] ( #FE, #04, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #FF, #04, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #01, #04, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #02, #04, &code_0ACA38 )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #1A, #4F )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC85A
}

code_0ACA38 {
    COP [RngByte]
    LSR 
    BCS loc_0ACA44
    COP [SetSavedPtr] ( &code_0AC848 )
    JMP $&code_0ACB41

  loc_0ACA44:
    COP [SetSavedPtr] ( &code_0AC85A )
    JMP $&code_0ACB61
}

code_0ACA4B {
    LDA $10
    BIT #$4000
    BEQ loc_0ACA55
    JMP $&code_0AC842

  loc_0ACA55:
    COP [SetSavedPtr] ( &code_0ACA4B )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_0ACA69
}

code_0ACA60 {
    COP [SetSavedPtr] ( &code_0ACA60 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_0ACA69:
    COP [BranchOnPlayerY] ( #$0020, &code_0ACAF3, &code_0ACA73, &code_0ACB1C )
}

code_0ACA73 {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0ACA83 )
}

code_list_0ACA83 [
  &code_0ACAA6   ;00
  &code_0ACA87   ;01
]

code_0ACA87 {
    COP [SetSavedPtr] ( &code_0ACA87 )
    COP [BranchIfSolidEast] ( &code_0ACACF )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0ACACF )
    COP [SetEntryHereAndYield]
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC85A )
    JSR $&code_0ACB7C
    JMP $&code_0ACB61
}

code_0ACAA6 {
    COP [SetSavedPtr] ( &code_0ACAA6 )
    COP [BranchIfSolidEast] ( &code_0ACAE1 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0ACAE1 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidWest] ( &code_0ACAE1 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ACAE1 )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC848 )
    JSR $&code_0ACB7C
    JMP $&code_0ACB41
}

code_0ACACF {
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidSouth] ( &code_0ACAE1 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0ACAE1 )
    COP [CallNear] ( &code_0ACB1C )
    BRA code_0ACA87
}

code_0ACAE1 {
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidNorth] ( &code_0ACACF )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ACACF )
    COP [CallNear] ( &code_0ACAF3 )
    BRA code_0ACAA6
}

code_0ACAF3 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ACA73 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0ACA73 )
    COP [StageSprAndHitbox] ( #2A )
    LDA #$2000
    TSB $12
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #04 )
    COP [StageMoveY] ( #3F )
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0ACB1C {
    COP [BranchIfSolidSouth] ( &code_0ACA73 )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #00, #02, &code_0ACA73 )
    COP [StageSprAndHitbox] ( #29 )
    LDA #$2000
    TRB $12
    COP [StageMoveY] ( #3F )
    COP [SetEntryHere]
    COP [WaitForAnimFrame] ( #08 )
    COP [StageMoveY] ( #00 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ACB41 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC86D )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0AC86D )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveX] ( #2B, #3E )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0ACB61 {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC86D )
    COP [SetEntryHereAndYield]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0AC86D )
    LDA #$4000
    TRB $12
    COP [StageSpriteMoveX] ( #2B, #3E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ACB7C {
    LDA #$1818
    STA $20
    LDA #$0610
    STA $22
    RTS 
}

code_0ACB87 {
    LDA #$0908
    STA $20
    LDA #$131E
    STA $22
    RTS 
}

code_0ACB92 {
    COP [SetEntryHere]
    COP [AnimOnce]
    PHX 
    LDA $28
    AND #$00FF
    SEC 
    SBC #$0023
    TAX 
    LDA $@sg4D_dynapede.byte_0AC79A, X
    AND #$00FF
    PLX 
    CMP #$0001
    BEQ loc_0ACBB6
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    BRA loc_0ACBBC

  loc_0ACBB6:
    COP [StageSpriteLoop] ( #34, #04 )
    COP [AnimLoop]

  loc_0ACBBC:
    LDA #$6000
    TRB $12
    COP [PlaySoundBoth] ( #$0505 )
    COP [LoopStart] ( #07 )
    COP [SpawnAfterFlags] ( @code_0ACC20, #$2302 )
    COP [WaitByte] ( #01 )
    COP [LoopEnd]
    COP [SpawnAfterFlags] ( @code_0ACBE0, #$2000 )
    COP [JumpFar] ( @StandardEnemyDefeatHandler )
}

code_0ACBE0 {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [LoopStart] ( #07 )
    COP [WaitByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0ACC74, #$2302 )
    LDY $06
    COP [RngByte]
    STA $0000
    AND #$00F0
    SEC 
    SBC #$0080
    ORA #$0008
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0000
    AND #$0070
    SEC 
    SBC #$0030
    CLC 
    ADC $16
    STA $0016, Y
    COP [WaitByte] ( #13 )
    COP [LoopEnd]
    COP [Die]
}

code_0ACC20 {
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0010
    CLC 
    ADC $14
    STA $14
    COP [SetSpritePalette] ( #00 )
    COP [SpawnListAppend] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [SetEntryHereAndYield]
    COP [SetSpritePalette] ( #04 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    PHX 
    LDX $04
    LDA #$0007
    SEC 
    SBC $loopCounter, X
    PLX 
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X
    COP [ReloadMoveDurations]
    COP [InitGravity] ( #0A, #09, #01 )

  loc_0ACC67:
    COP [SetEntryHereAndYield]
    COP [TickGravity]
    LDA $10
    BIT #$4000
    BEQ loc_0ACC67
    COP [Die]
}

code_0ACC74 {
    COP [SpawnAfterMarked] ( @code_0ACCC2, #$0301 )
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #13 )
    LDA $16
    STA $orbitAngle, X
    LDA $cameraTargetY
    SEC 
    SBC #$0100
    STA $16
    COP [StageMoveY] ( #0F )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryHere]
    LDA $16
    BPL loc_0ACCA1
    RTL 

  loc_0ACCA1:
    CMP $orbitAngle, X
    BCS loc_0ACCA8
    RTL 

  loc_0ACCA8:
    COP [StageMoveY] ( #00 )
    LDA #$0102
    TRB $10
    COP [PlaySoundCh1] ( #06 )
    COP [SetSpritePalette] ( #00 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0ACCC2 {
    COP [BranchIfSolidHere] ( &code_0ACCD2 )
    COP [SetMetasprite] ( @spriteset_enemies )

  loc_0ACCCB:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0ACCCB
}

code_0ACCD2 {
    COP [Die]
}