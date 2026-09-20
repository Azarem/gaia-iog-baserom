; Credits NPC group C — later farewell characters (~113 lines).
; 
; Third batch from Watermia, Euro, and other locations.
---------------------------------------------

?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E4DD [
  actor-def < #00, #00, #18, {

  code_09E4E0:
    COP [SpawnBefore] ( @e_actor_09E464 )

  code_09E4E5:
    COP [SetEntryContinue]
    RTL 
} >
]

code_09E4E8 {
    LDA #$0025
    JSL $@CreditPositionLookup

  loc_09E4EE:
    COP [StageSpriteMoveX] ( #00, #12 )
    COP [AnimOnce]
    BRA loc_09E4EE

  code_09E4F6:
    COP [StageSpriteMoveX] ( #00, #11 )
    COP [AnimOnce]
    BRA code_09E4F6

  code_09E4FE:
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    BRA code_09E4FE

  code_09E505:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    BRA code_09E505

  code_09E50C:
    COP [StageSpriteMoveX] ( #1D, #02 )
    COP [AnimOnce]
    BRA code_09E50C

  code_09E514:
    COP [StageSpriteMoveX] ( #1D, #01 )
    COP [AnimOnce]
    BRA code_09E514

  code_09E51C:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    BRA code_09E51C

  code_09E523:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    BRA code_09E523

  code_09E52A:
    LDA #$0022
    JSL $@CreditPositionLookup

  loc_09E530:
    COP [StageSpriteMoveX] ( #23, #02 )
    COP [AnimOnce]
    BRA loc_09E530
}
---------------------------------------------

e_actor_09E464 {
    LDA $00E4
    BPL loc_09E46A
    RTL 

  loc_09E46A:
    COP [HaltIfCounterGte] ( #$0438 )
    COP [SetLinkedActorScript] ( &code_09E4E8 )
    COP [HaltIfCounterGte] ( #$0528 )
    COP [SetLinkedActorScript] ( &code_09E4FE )
    COP [HaltIfCounterGte] ( #$0B70 )
    COP [SetLinkedActorScript] ( &code_09E4F6 )
    COP [HaltIfCounterGte] ( #$0C78 )
    COP [SetLinkedActorScript] ( &code_09E4E5 )
    COP [HaltIfCounterGte] ( #$3F0C )
    COP [SetLinkedActorScript] ( &code_09E52A )
    COP [HaltIfCounterGte] ( #$3F54 )
    COP [SetLinkedActorScript] ( &code_09E505 )
    COP [HaltIfCounterGte] ( #$4164 )
    COP [SetLinkedActorScript] ( &code_09E50C )
    COP [HaltIfCounterGte] ( #$417C )
    COP [SetLinkedActorScript] ( &code_09E505 )
    COP [HaltIfCounterGte] ( #$4434 )
    COP [SetLinkedActorScript] ( &code_09E51C )
    COP [HaltIfCounterGte] ( #$4470 )
    COP [SetLinkedActorScript] ( &code_09E505 )
    COP [HaltIfCounterGte] ( #$447A )
    COP [SetLinkedActorScript] ( &code_09E523 )
    COP [HaltIfCounterGte] ( #$44AC )
    COP [SetLinkedActorScript] ( &code_09E505 )
    COP [HaltIfCounterGte] ( #$46C8 )
    COP [SetLinkedActorScript] ( &code_09E514 )
    COP [HaltIfCounterGte] ( #$4748 )
    COP [SetLinkedActorScript] ( &code_09E4E5 )
    COP [SetEntryContinue]
    RTL 
}