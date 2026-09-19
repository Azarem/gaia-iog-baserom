?INCLUDE 'spriteset_enemies'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

ec0D_canal_worm [
  actor-def < #22, #08, #20, {

  code_0A8003:
    LDA #$0011
    TSB $12

  code_0A8008:
    COP [WaitWhileOffscreen] ( #18 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #77 )
    LDA #$2000
    TRB $10
    COP [SpawnMarkedAfter] ( @code_0A8264, #$0301 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3F )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0A825C, #$0301 )
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #04, &code_0A80D1 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #05, &code_0A80EC )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #06, &code_0A8107 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #07, &code_0A8122 )
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #00, &code_0A813D )
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #01, &code_0A8158 )
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #02, &code_0A8173 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #03, &code_0A818E )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    JMP $&code_0A80C3
} >
]

code_0A809B {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]

  code_0A80A0:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  code_0A80A5:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  code_0A80AA:
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]

  code_0A80AF:
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]

  code_0A80B4:
    COP [StageSpriteFrame] ( #A8 )
    COP [AnimOnce]

  code_0A80B9:
    COP [StageSpriteFrame] ( #A9 )
    COP [AnimOnce]

  code_0A80BE:
    COP [StageSpriteFrame] ( #AA )
    COP [AnimOnce]
}

code_0A80C3 {
    COP [StageSpriteLoop] ( #2B, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #35 )
    COP [AnimOnce]
    JMP $&code_0A8008
}

code_0A80D1 {
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #00, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #00, #03 )
    COP [StageSpriteLoop] ( #2B, #02 )
    COP [AnimLoop]
    JMP $&code_0A80A0
}

code_0A80EC {
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #FC, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #04, #03 )
    COP [StageSpriteLoop] ( #2C, #02 )
    COP [AnimLoop]
    JMP $&code_0A80A5
}

code_0A8107 {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #F8, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #04, #00 )
    COP [StageSpriteLoop] ( #2D, #02 )
    COP [AnimLoop]
    JMP $&code_0A80AA
}

code_0A8122 {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #FC, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #04, #04 )
    COP [StageSpriteLoop] ( #2E, #02 )
    COP [AnimLoop]
    JMP $&code_0A80AF
}

code_0A813D {
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #00, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #00, #04 )
    COP [StageSpriteLoop] ( #2F, #02 )
    COP [AnimLoop]
    JMP $&code_0A80B4
}

code_0A8158 {
    COP [StageSpriteFrame] ( #B0 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #04, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #03, #04 )
    COP [StageSpriteLoop] ( #B0, #02 )
    COP [AnimLoop]
    JMP $&code_0A80B9
}

code_0A8173 {
    COP [StageSpriteFrame] ( #B1 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #08, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #03, #00 )
    COP [StageSpriteLoop] ( #B1, #02 )
    COP [AnimLoop]
    JMP $&code_0A80BE
}

code_0A818E {
    COP [StageSpriteFrame] ( #B2 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #04, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #03, #03 )
    COP [StageSpriteLoop] ( #B2, #02 )
    COP [AnimLoop]
    JMP $&code_0A80C3
}

code_0A81A9 {
    LDA #$0080
    TSB $12
    COP [SpawnLastRel] ( @code_0A8250, #00, #00, #$0300 )
    LDA $0010, Y
    ORA $10
    STA $0010, Y
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0A822B, #$2200 )
    LDA #$0002
    JSR $&code_0A8200
    COP [SpawnMarkedAfter] ( @code_0A822B, #$2200 )
    LDA #$0003
    JSR $&code_0A8200
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteLoop] ( #08, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]

  loc_0A81F0:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A81F0
    COP [Die]
}

code_0A8200 {
    STA $0008, Y
    LDA $0010, Y
    ORA $10
    STA $0010, Y
    LDA $2C
    STA $002C, Y
    LDA $2E
    STA $002E, Y
    PHX 
    LDA $moveXAlt, X
    PHA 
    LDA $moveYAlt, X
    TYX 
    STA $moveYAlt, X
    PLA 
    STA $moveXAlt, X
    PLX 
    RTS 
}

code_0A822B {
    LDA #$2000
    TRB $10
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteLoop] ( #26, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]

  loc_0A8240:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8240
    COP [Die]
}

code_0A8250 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0A825C {
    COP [StageSpriteLoop] ( #34, #09 )
    COP [AnimLoop]
    COP [Die]
}

code_0A8264 {
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [Die]
}