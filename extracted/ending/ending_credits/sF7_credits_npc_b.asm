?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E3EB [
  actor-def < #00, #00, #18, {

  code_09E3EE:
    COP [SpawnBefore] ( @e_actor_09E31A )

  code_09E3F3:
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E3F6 {
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    BRA code_09E3F6

  code_09E3FD:
    COP [StageSpriteMoveX] ( #03, #11 )
    COP [AnimOnce]
    BRA code_09E3FD

  code_09E405:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    BRA code_09E405

  code_09E40C:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    BRA code_09E40C

  code_09E413:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA code_09E413

  code_09E41A:
    COP [StageSpriteMoveX] ( #06, #01 )
    COP [AnimOnce]
    BRA code_09E41A

  code_09E422:
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    BRA code_09E422

  code_09E429:
    COP [StageSpriteMoveX] ( #07, #01 )
    COP [AnimOnce]
    BRA code_09E429

  code_09E431:
    LDA #$0031
    JSL $@CreditPositionLookup

  loc_09E437:
    COP [StageSpriteMoveX] ( #08, #01 )
    COP [AnimOnce]
    BRA loc_09E437

  code_09E43F:
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    BRA code_09E43F

  code_09E446:
    COP [StageSpriteMoveX] ( #2E, #02 )
    COP [AnimOnce]
    BRA code_09E446

  code_09E44E:
    COP [StageSpriteMoveX] ( #2E, #01 )
    COP [AnimOnce]
    BRA code_09E44E

  code_09E456:
    LDA #$0042
    JSL $@CreditPositionLookup

  loc_09E45C:
    COP [StageSpriteMoveX] ( #33, #02 )
    COP [AnimOnce]
    BRA loc_09E45C
}
---------------------------------------------

e_actor_09E31A {
    LDA $00E4
    BPL loc_09E320
    RTL 

  loc_09E320:
    COP [HaltIfCounterGte] ( #$1770 )
    COP [SetLinkedActorScript] ( &code_09E431 )
    COP [HaltIfCounterGte] ( #$17E8 )
    COP [SetLinkedActorScript] ( &code_09E422 )
    COP [HaltIfCounterGte] ( #$17EB )
    COP [SetLinkedActorScript] ( &code_09E40C )
    COP [HaltIfCounterGte] ( #$17EE )
    COP [SetLinkedActorScript] ( &code_09E413 )
    COP [HaltIfCounterGte] ( #$17F2 )
    COP [SetLinkedActorScript] ( &code_09E405 )
    COP [HaltIfCounterGte] ( #$17F6 )
    COP [SetLinkedActorScript] ( &code_09E422 )
    COP [HaltIfCounterGte] ( #$17FB )
    COP [SetLinkedActorScript] ( &code_09E40C )
    COP [HaltIfCounterGte] ( #$1800 )
    COP [SetLinkedActorScript] ( &code_09E413 )
    COP [HaltIfCounterGte] ( #$1806 )
    COP [SetLinkedActorScript] ( &code_09E405 )
    COP [HaltIfCounterGte] ( #$180C )
    COP [SetLinkedActorScript] ( &code_09E422 )
    COP [HaltIfCounterGte] ( #$1813 )
    COP [SetLinkedActorScript] ( &code_09E40C )
    COP [HaltIfCounterGte] ( #$181A )
    COP [SetLinkedActorScript] ( &code_09E413 )
    COP [HaltIfCounterGte] ( #$1822 )
    COP [SetLinkedActorScript] ( &code_09E405 )
    COP [HaltIfCounterGte] ( #$182A )
    COP [SetLinkedActorScript] ( &code_09E422 )
    COP [HaltIfCounterGte] ( #$1968 )
    COP [SetLinkedActorScript] ( &code_09E429 )
    COP [HaltIfCounterGte] ( #$1988 )
    COP [SetLinkedActorScript] ( &code_09E41A )
    COP [HaltIfCounterGte] ( #$19B0 )
    COP [SetLinkedActorScript] ( &code_09E3F6 )
    COP [HaltIfCounterGte] ( #$1E78 )
    COP [SetLinkedActorScript] ( &code_09E3FD )
    COP [HaltIfCounterGte] ( #$1F70 )
    COP [SetLinkedActorScript] ( &code_09E3F3 )
    COP [HaltIfCounterGte] ( #$3DA4 )
    COP [SetLinkedActorScript] ( &code_09E456 )
    COP [HaltIfCounterGte] ( #$3DEC )
    COP [SetLinkedActorScript] ( &code_09E43F )
    COP [HaltIfCounterGte] ( #$4164 )
    COP [SetLinkedActorScript] ( &code_09E446 )
    COP [HaltIfCounterGte] ( #$417C )
    COP [SetLinkedActorScript] ( &code_09E43F )
    COP [HaltIfCounterGte] ( #$46C8 )
    COP [SetLinkedActorScript] ( &code_09E44E )
    COP [HaltIfCounterGte] ( #$4748 )
    COP [SetLinkedActorScript] ( &code_09E3F3 )
    COP [SetEntryContinue]
    RTL 
}