?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E26C [
  actor-def < #00, #00, #18, {

  code_09E26F:
    COP [SpawnBefore] ( @e_actor_09E14B )
    COP [SetMetasprite] ( $7E6000 )

  code_09E279:
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E27C {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    BRA code_09E27C

  code_09E283:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    BRA code_09E283

  code_09E28A:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA code_09E28A

  code_09E291:
    LDA #$0031
    JSR $&CreditPositionLookup.func_09E8E4

  code_09E297:
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
    BRA code_09E297

  code_09E29F:
    COP [StageSpriteMoveX] ( #03, #02 )
    COP [AnimOnce]
    BRA code_09E29F

  code_09E2A7:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA code_09E2A7

  code_09E2AE:
    COP [StageSpriteMoveX] ( #04, #12 )
    COP [AnimOnce]
    BRA code_09E2AE

  code_09E2B6:
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    BRA code_09E2B6

  code_09E2BE:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    BRA code_09E2BE

  code_09E2C5:
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    BRA code_09E2C5

  code_09E2CD:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA code_09E2CD

  code_09E2D4:
    COP [StageSpriteMoveX] ( #07, #11 )
    COP [AnimOnce]
    BRA code_09E2D4

  code_09E2DC:
    LDA #$0031
    JSR $&CreditPositionLookup.func_09E8E4

  code_09E2E2:
    COP [StageSpriteMoveX] ( #07, #01 )
    COP [AnimOnce]
    BRA code_09E2E2

  code_09E2EA:
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    BRA code_09E2EA

  code_09E2F1:
    COP [StageSpriteMoveX] ( #08, #11 )
    COP [AnimOnce]
    BRA code_09E2F1

  code_09E2F9:
    LDA #$0035
    JSR $&CreditPositionLookup.func_09E8E4

  loc_09E2FF:
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    BRA loc_09E2FF

  code_09E307:
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    BRA code_09E307

  code_09E30E:
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]

  loc_09E313:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA loc_09E313
}
---------------------------------------------

e_actor_09E14B {
    LDA $00E4
    BPL loc_09E151
    RTL 

  loc_09E151:
    COP [HaltIfCounterGte] ( #$0F00 )
    COP [SetLinkedActorScript] ( &code_09E291 )
    COP [HaltIfCounterGte] ( #$0F78 )
    COP [SetLinkedActorScript] ( &code_09E2A7 )
    COP [HaltIfCounterGte] ( #$1068 )
    COP [SetLinkedActorScript] ( &code_09E30E )
    COP [HaltIfCounterGte] ( #$1168 )
    COP [SetLinkedActorScript] ( &code_09E297 )
    COP [HaltIfCounterGte] ( #$118C )
    COP [SetLinkedActorScript] ( &code_09E2D4 )
    COP [HaltIfCounterGte] ( #$11A4 )
    COP [SetLinkedActorScript] ( &code_09E2CD )
    COP [HaltIfCounterGte] ( #$1774 )
    COP [SetLinkedActorScript] ( &code_09E28A )
    COP [HaltIfCounterGte] ( #$1968 )
    COP [SetLinkedActorScript] ( &code_09E2EA )
    COP [HaltIfCounterGte] ( #$1E78 )
    COP [SetLinkedActorScript] ( &code_09E2F1 )
    COP [HaltIfCounterGte] ( #$1F70 )
    COP [SetLinkedActorScript] ( &code_09E279 )
    COP [HaltIfCounterGte] ( #$2F58 )
    COP [SetLinkedActorScript] ( &code_09E2DC )
    COP [HaltIfCounterGte] ( #$2FD0 )
    COP [SetLinkedActorScript] ( &code_09E2A7 )
    COP [HaltIfCounterGte] ( #$3066 )
    COP [SetLinkedActorScript] ( &code_09E2E2 )
    COP [HaltIfCounterGte] ( #$3096 )
    COP [SetLinkedActorScript] ( &code_09E283 )
    COP [HaltIfCounterGte] ( #$3138 )
    COP [SetLinkedActorScript] ( &code_09E307 )
    COP [HaltIfCounterGte] ( #$35E8 )
    COP [SetLinkedActorScript] ( &code_09E2B6 )
    COP [HaltIfCounterGte] ( #$35F8 )
    COP [SetLinkedActorScript] ( &code_09E28A )
    COP [HaltIfCounterGte] ( #$3A24 )
    COP [SetLinkedActorScript] ( &code_09E2C5 )
    COP [HaltIfCounterGte] ( #$3A34 )
    COP [SetLinkedActorScript] ( &code_09E28A )
    COP [HaltIfCounterGte] ( #$3CB4 )
    COP [SetLinkedActorScript] ( &code_09E2BE )
    COP [HaltIfCounterGte] ( #$3D68 )
    COP [SetLinkedActorScript] ( &code_09E2E2 )
    COP [HaltIfCounterGte] ( #$3D80 )
    COP [SetLinkedActorScript] ( &code_09E2A7 )
    COP [HaltIfCounterGte] ( #$4164 )
    COP [SetLinkedActorScript] ( &code_09E29F )
    COP [HaltIfCounterGte] ( #$417C )
    COP [SetLinkedActorScript] ( &code_09E2A7 )
    COP [HaltIfCounterGte] ( #$46C8 )
    COP [SetLinkedActorScript] ( &code_09E297 )
    COP [HaltIfCounterGte] ( #$4748 )
    COP [SetLinkedActorScript] ( &code_09E279 )
    COP [HaltIfCounterGte] ( #$48AC )
    COP [SetLinkedActorScript] ( &code_09E2F9 )
    COP [HaltIfCounterGte] ( #$4920 )
    COP [SetLinkedActorScript] ( &code_09E28A )
    COP [HaltIfCounterGte] ( #$4A4C )
    COP [SetLinkedActorScript] ( &code_09E2CD )
    COP [HaltIfCounterGte] ( #$4D1C )
    COP [SetLinkedActorScript] ( &code_09E2EA )
    COP [HaltIfCounterGte] ( #$6C0C )
    COP [SetLinkedActorScript] ( &code_09E2CD )
    COP [HaltIfCounterGte] ( #$6D1A )
    COP [SetLinkedActorScript] ( &code_09E28A )
    COP [HaltIfCounterGte] ( #$6D38 )
    COP [SetLinkedActorScript] ( &code_09E27C )
    COP [HaltIfCounterGte] ( #$6E64 )
    COP [SetLinkedActorScript] ( &code_09E2AE )
    COP [HaltIfCounterGte] ( #$6E74 )
    COP [SetLinkedActorScript] ( &code_09E27C )
    COP [SetEntryContinue]
    RTL 
}