?INCLUDE 'func_09E8E4'

---------------------------------------------

sF7_actor_09E607 [
  actor-def < #00, #00, #18, {

  code_09E60A:
    COP [SpawnBefore] ( @func_09E5DE )

  code_09E60F:
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E612 {
    LDA #$0035
    JSL $@func_09E8E4

  loc_09E618:
    COP [StageSpriteMoveX] ( #02, #12 )
    COP [AnimOnce]
    BRA loc_09E618

  code_09E620:
    COP [StageSpriteMoveX] ( #02, #11 )
    COP [AnimOnce]
    BRA code_09E620

  code_09E628:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA code_09E628
}
---------------------------------------------

func_09E5DE {
    LDA $00E4
    BPL loc_09E5E4
    RTL 

  loc_09E5E4:
    COP [HaltIfCounterGte] ( #$0564 )
    COP [SetLinkedActorScript] ( &code_09E612 )
    COP [HaltIfCounterGte] ( #$0624 )
    COP [SetLinkedActorScript] ( &code_09E628 )
    COP [HaltIfCounterGte] ( #$099C )
    COP [SetLinkedActorScript] ( &code_09E620 )
    COP [HaltIfCounterGte] ( #$0A74 )
    COP [SetLinkedActorScript] ( &code_09E60F )
    COP [SetEntryContinue]
    RTL 
}