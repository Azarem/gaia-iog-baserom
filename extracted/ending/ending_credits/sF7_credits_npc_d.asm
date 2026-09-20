; Credits NPC group D — late-game farewell characters (~95 lines).
; 
; Fourth batch from Dao, the Pyramid area, and beyond.
---------------------------------------------

?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E591 [
  actor-def < #00, #00, #18, {

  code_09E594:
    COP [SpawnBefore] ( @e_actor_09E538 )

  code_09E599:
    COP [SetEntryHere]
    RTL 
} >
]

code_09E59C {
    LDA #$0042
    JSL $@CreditPositionLookup

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
    JSL $@CreditPositionLookup

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
    COP [HaltIfMaxFrames] ( #$04B0 )
    COP [SetLinkedEntryPtr] ( &code_09E59C )
    COP [HaltIfMaxFrames] ( #$05A0 )
    COP [SetLinkedEntryPtr] ( &code_09E5B2 )
    COP [HaltIfMaxFrames] ( #$0AC8 )
    COP [SetLinkedEntryPtr] ( &code_09E5AA )
    COP [HaltIfMaxFrames] ( #$0BD0 )
    COP [SetLinkedEntryPtr] ( &code_09E599 )
    COP [HaltIfMaxFrames] ( #$3FFC )
    COP [SetLinkedEntryPtr] ( &code_09E5B9 )
    COP [HaltIfMaxFrames] ( #$402C )
    COP [SetLinkedEntryPtr] ( &code_09E5C7 )
    COP [HaltIfMaxFrames] ( #$4164 )
    COP [SetLinkedEntryPtr] ( &code_09E5CE )
    COP [HaltIfMaxFrames] ( #$417C )
    COP [SetLinkedEntryPtr] ( &code_09E5C7 )
    COP [HaltIfMaxFrames] ( #$46C8 )
    COP [SetLinkedEntryPtr] ( &code_09E5D6 )
    COP [HaltIfMaxFrames] ( #$4748 )
    COP [SetLinkedEntryPtr] ( &code_09E599 )
    COP [SetEntryHere]
    RTL 
}