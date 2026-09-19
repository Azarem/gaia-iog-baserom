?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E591 [
  actor-def < #00, #00, #18, {

  code_09E594:
    COP [SpawnBefore] ( @e_actor_09E538 )

  code_09E599:
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E59C {
    LDA #$0042
    JSR $&CreditPositionLookup.func_09E8E4

  loc_09E5A2:
    COP [StageSpriteMoveX] ( #01, #12 )
    COP [AnimOnce]
    BRA loc_09E5A2

  code_09E5AA:
    COP [StageSpriteMoveX] ( #01, #11 )
    COP [AnimOnce]
    BRA code_09E5AA

  code_09E5B2:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    BRA code_09E5B2

  code_09E5B9:
    LDA #$0032
    JSR $&CreditPositionLookup.func_09E8E4

  loc_09E5BF:
    COP [StageSpriteMoveX] ( #2B, #02 )
    COP [AnimOnce]
    BRA loc_09E5BF

  code_09E5C7:
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    BRA code_09E5C7

  code_09E5CE:
    COP [StageSpriteMoveX] ( #27, #02 )
    COP [AnimOnce]
    BRA code_09E5CE

  code_09E5D6:
    COP [StageSpriteMoveX] ( #27, #01 )
    COP [AnimOnce]
    BRA code_09E5D6
}
---------------------------------------------

e_actor_09E538 {
    LDA $00E4
    BPL loc_09E53E
    RTL 

  loc_09E53E:
    COP [HaltIfCounterGte] ( #$04B0 )
    COP [SetLinkedActorScript] ( &code_09E59C )
    COP [HaltIfCounterGte] ( #$05A0 )
    COP [SetLinkedActorScript] ( &code_09E5B2 )
    COP [HaltIfCounterGte] ( #$0AC8 )
    COP [SetLinkedActorScript] ( &code_09E5AA )
    COP [HaltIfCounterGte] ( #$0BD0 )
    COP [SetLinkedActorScript] ( &code_09E599 )
    COP [HaltIfCounterGte] ( #$3FFC )
    COP [SetLinkedActorScript] ( &code_09E5B9 )
    COP [HaltIfCounterGte] ( #$402C )
    COP [SetLinkedActorScript] ( &code_09E5C7 )
    COP [HaltIfCounterGte] ( #$4164 )
    COP [SetLinkedActorScript] ( &code_09E5CE )
    COP [HaltIfCounterGte] ( #$417C )
    COP [SetLinkedActorScript] ( &code_09E5C7 )
    COP [HaltIfCounterGte] ( #$46C8 )
    COP [SetLinkedActorScript] ( &code_09E5D6 )
    COP [HaltIfCounterGte] ( #$4748 )
    COP [SetLinkedActorScript] ( &code_09E599 )
    COP [SetEntryContinue]
    RTL 
}