; Credits NPC group B — mid-game farewell characters (~155 lines).
; 
; Second batch of credits NPCs. Characters from Freejia,
; the Gold Ship, and other mid-game locations.
---------------------------------------------

?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E3EB [
  actor-def < #00, #00, #18, {

  code_09E3EE:
    COP [SpawnBefore] ( @e_actor_09E31A )

  code_09E3F3:
    COP [SetEntryHere]
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
    COP [HaltIfMaxFrames] ( #$1770 )
    COP [SetLinkedEntryPtr] ( &code_09E431 )
    COP [HaltIfMaxFrames] ( #$17E8 )
    COP [SetLinkedEntryPtr] ( &code_09E422 )
    COP [HaltIfMaxFrames] ( #$17EB )
    COP [SetLinkedEntryPtr] ( &code_09E40C )
    COP [HaltIfMaxFrames] ( #$17EE )
    COP [SetLinkedEntryPtr] ( &code_09E413 )
    COP [HaltIfMaxFrames] ( #$17F2 )
    COP [SetLinkedEntryPtr] ( &code_09E405 )
    COP [HaltIfMaxFrames] ( #$17F6 )
    COP [SetLinkedEntryPtr] ( &code_09E422 )
    COP [HaltIfMaxFrames] ( #$17FB )
    COP [SetLinkedEntryPtr] ( &code_09E40C )
    COP [HaltIfMaxFrames] ( #$1800 )
    COP [SetLinkedEntryPtr] ( &code_09E413 )
    COP [HaltIfMaxFrames] ( #$1806 )
    COP [SetLinkedEntryPtr] ( &code_09E405 )
    COP [HaltIfMaxFrames] ( #$180C )
    COP [SetLinkedEntryPtr] ( &code_09E422 )
    COP [HaltIfMaxFrames] ( #$1813 )
    COP [SetLinkedEntryPtr] ( &code_09E40C )
    COP [HaltIfMaxFrames] ( #$181A )
    COP [SetLinkedEntryPtr] ( &code_09E413 )
    COP [HaltIfMaxFrames] ( #$1822 )
    COP [SetLinkedEntryPtr] ( &code_09E405 )
    COP [HaltIfMaxFrames] ( #$182A )
    COP [SetLinkedEntryPtr] ( &code_09E422 )
    COP [HaltIfMaxFrames] ( #$1968 )
    COP [SetLinkedEntryPtr] ( &code_09E429 )
    COP [HaltIfMaxFrames] ( #$1988 )
    COP [SetLinkedEntryPtr] ( &code_09E41A )
    COP [HaltIfMaxFrames] ( #$19B0 )
    COP [SetLinkedEntryPtr] ( &code_09E3F6 )
    COP [HaltIfMaxFrames] ( #$1E78 )
    COP [SetLinkedEntryPtr] ( &code_09E3FD )
    COP [HaltIfMaxFrames] ( #$1F70 )
    COP [SetLinkedEntryPtr] ( &code_09E3F3 )
    COP [HaltIfMaxFrames] ( #$3DA4 )
    COP [SetLinkedEntryPtr] ( &code_09E456 )
    COP [HaltIfMaxFrames] ( #$3DEC )
    COP [SetLinkedEntryPtr] ( &code_09E43F )
    COP [HaltIfMaxFrames] ( #$4164 )
    COP [SetLinkedEntryPtr] ( &code_09E446 )
    COP [HaltIfMaxFrames] ( #$417C )
    COP [SetLinkedEntryPtr] ( &code_09E43F )
    COP [HaltIfMaxFrames] ( #$46C8 )
    COP [SetLinkedEntryPtr] ( &code_09E44E )
    COP [HaltIfMaxFrames] ( #$4748 )
    COP [SetLinkedEntryPtr] ( &code_09E3F3 )
    COP [SetEntryHere]
    RTL 
}