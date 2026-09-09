?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'StandardEnemyDefeatHandler'

---------------------------------------------

sg4D_dynapede [
  actor-def < #25, #00, #00, {

  code_0AC523:
    LDA #$0080
    TSB $12
    COP [SetDeathCallback] ( @code_0AC700 )

  loc_0AC52D:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC546
} >
]

sg4D_dynapede2 [
  actor-def < #23, #00, #00, {

  code_0AC536:
    LDA #$0080
    TSB $12
    COP [SetDeathCallback] ( @code_0AC700 )

  code_0AC540:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC5DF
} >
]

code_0AC546 {
    LDA $10
    BIT #$4000
    BNE loc_0AC52D
    COP [SetSavedPtr] ( &code_0AC546 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_0AC561

  code_0AC558:
    COP [SetSavedPtr] ( &code_0AC558 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  loc_0AC561:
    COP [BranchOnPlayerX] ( #$0020, &code_0AC6CA, &code_0AC56B, &code_0AC6E5 )
}

code_0AC56B {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC57B )
}

code_list_0AC57B [
  &code_0AC57F   ;00
  &code_0AC597   ;01
]

code_0AC57F {
    COP [BranchIfSolidNorth] ( &code_0AC5CD )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC5CD )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC5F4 )
    JMP $&code_0AC681
}

code_0AC597 {
    COP [BranchIfSolidNorth] ( &code_0AC5BB )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC5BB )
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC5BB )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC5BB )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC5DF )
    JMP $&code_0AC6A5
}

code_0AC5BB {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AC5CD )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC5CD )
    COP [CallScript] ( &code_0AC6E5 )
    BRA code_0AC57F
}

code_0AC5CD {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AC5BB )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC5BB )
    COP [CallScript] ( &code_0AC6CA )
    BRA code_0AC57F
}

code_0AC5DF {
    LDA $10
    BIT #$4000
    BEQ loc_0AC5E9
    JMP $&code_0AC540

  loc_0AC5E9:
    COP [SetSavedPtr] ( &code_0AC5DF )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_0AC5FD
}

code_0AC5F4 {
    COP [SetSavedPtr] ( &code_0AC5F4 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_0AC5FD:
    COP [BranchOnPlayerY] ( #$0020, &code_0AC681, &code_0AC607, &code_0AC6A5 )
}

code_0AC607 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC617 )
}

code_list_0AC617 [
  &code_0AC637   ;00
  &code_0AC61B   ;01
]

code_0AC61B {
    COP [SetSavedPtr] ( &code_0AC61B )
    COP [BranchIfSolidEast] ( &code_0AC65D )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC65D )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC558 )
    JMP $&code_0AC6E5
}

code_0AC637 {
    COP [SetSavedPtr] ( &code_0AC637 )
    COP [BranchIfSolidEast] ( &code_0AC66F )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC66F )
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AC66F )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC66F )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC546 )
    JMP $&code_0AC6CA
}

code_0AC65D {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC66F )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC66F )
    COP [CallScript] ( &code_0AC6A5 )
    BRA code_0AC61B
}

code_0AC66F {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AC65D )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC65D )
    COP [CallScript] ( &code_0AC681 )
    BRA code_0AC637
}

code_0AC681 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC607 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0AC607 )
    COP [StageSprAndHitbox] ( #26 )
    LDA #$2000
    TSB $12
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #04 )
    COP [StageForceMoveY] ( #3C )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC6A5 {
    COP [BranchIfSolidSouth] ( &code_0AC607 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC607 )
    COP [StageSprAndHitbox] ( #27 )
    LDA #$2000
    TRB $12
    COP [StageForceMoveY] ( #3C )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #08 )
    COP [StageForceMoveY] ( #00 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC6CA {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC56B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0AC56B )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveX] ( #28, #3D )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC6E5 {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC56B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0AC56B )
    LDA #$4000
    TRB $12
    COP [StageSpriteMoveX] ( #28, #3D )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC700 {
    COP [SetEntryContinue]
    COP [AnimOnce]
    PHX 
    LDA $28
    AND #$00FF
    SEC 
    SBC #$0023
    TAX 
    LDA $@byte_0AC79A, X
    AND #$00FF
    PLX 
    CMP #$0001
    BEQ loc_0AC724
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    BRA loc_0AC72A

  loc_0AC724:
    COP [StageSpriteLoop] ( #34, #04 )
    COP [AnimLoop]

  loc_0AC72A:
    LDA #$6000
    TRB $12
    COP [StageSprAndHitbox] ( #2E )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [PlaySoundBoth] ( #$0E0E )
    COP [SpawnAfterRelFlags] ( @code_0AC7B2, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7C6, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7D0, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7DA, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7E4, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7EE, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC7F8, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

byte_0AC79A [
  #01   ;00
  #01   ;01
  #00   ;02
  #01   ;03
  #01   ;04
  #00   ;05
  #01   ;06
  #01   ;07
  #00   ;08
  #01   ;09
  #01   ;0A
  #09   ;0B
  #00   ;0C
  #00   ;0D
  #01   ;0E
  #01   ;0F
  #00   ;10
  #00   ;11
  #00   ;12
  #00   ;13
  #00   ;14
  #00   ;15
  #00   ;16
  #01   ;17
]

code_0AC7B2 {
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [InitGravity] ( #03, #07, #00 )
    COP [StageForceMoveX] ( #03 )
    JMP $&code_0AC7FD
}

code_0AC7C6 {
    COP [InitGravity] ( #03, #07, #00 )
    COP [StageForceMoveX] ( #04 )
    BRA code_0AC7FD
}

code_0AC7D0 {
    COP [InitGravity] ( #04, #07, #01 )
    COP [StageForceMoveX] ( #01 )
    BRA code_0AC7FD
}

code_0AC7DA {
    COP [InitGravity] ( #04, #07, #01 )
    COP [StageForceMoveX] ( #02 )
    BRA code_0AC7FD
}

code_0AC7E4 {
    COP [InitGravity] ( #05, #07, #02 )
    COP [StageForceMoveX] ( #11 )
    BRA code_0AC7FD
}

code_0AC7EE {
    COP [InitGravity] ( #05, #07, #02 )
    COP [StageForceMoveX] ( #12 )
    BRA code_0AC7FD
}

code_0AC7F8 {
    COP [InitGravity] ( #06, #07, #03 )
}

code_0AC7FD {
    COP [TickGravity]
    CMP #$0000
    BMI loc_0AC808
    COP [SetEntryExit]
    BRA code_0AC7FD

  loc_0AC808:
    COP [PlaySoundCh1] ( #06 )
    COP [SetEntryExit]
    COP [AddPosition] ( #04, #14 )
    COP [JumpScript] ( @EnemyDeathFlash )
}