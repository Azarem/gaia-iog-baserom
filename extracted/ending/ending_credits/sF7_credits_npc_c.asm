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
    COP [SetEntryHere]
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
    COP [HaltIfMaxFrames] ( #$0438 )
    COP [SetLinkedEntryPtr] ( &code_09E4E8 )
    COP [HaltIfMaxFrames] ( #$0528 )
    COP [SetLinkedEntryPtr] ( &code_09E4FE )
    COP [HaltIfMaxFrames] ( #$0B70 )
    COP [SetLinkedEntryPtr] ( &code_09E4F6 )
    COP [HaltIfMaxFrames] ( #$0C78 )
    COP [SetLinkedEntryPtr] ( &code_09E4E5 )
    COP [HaltIfMaxFrames] ( #$3F0C )
    COP [SetLinkedEntryPtr] ( &code_09E52A )
    COP [HaltIfMaxFrames] ( #$3F54 )
    COP [SetLinkedEntryPtr] ( &code_09E505 )
    COP [HaltIfMaxFrames] ( #$4164 )
    COP [SetLinkedEntryPtr] ( &code_09E50C )
    COP [HaltIfMaxFrames] ( #$417C )
    COP [SetLinkedEntryPtr] ( &code_09E505 )
    COP [HaltIfMaxFrames] ( #$4434 )
    COP [SetLinkedEntryPtr] ( &code_09E51C )
    COP [HaltIfMaxFrames] ( #$4470 )
    COP [SetLinkedEntryPtr] ( &code_09E505 )
    COP [HaltIfMaxFrames] ( #$447A )
    COP [SetLinkedEntryPtr] ( &code_09E523 )
    COP [HaltIfMaxFrames] ( #$44AC )
    COP [SetLinkedEntryPtr] ( &code_09E505 )
    COP [HaltIfMaxFrames] ( #$46C8 )
    COP [SetLinkedEntryPtr] ( &code_09E514 )
    COP [HaltIfMaxFrames] ( #$4748 )
    COP [SetLinkedEntryPtr] ( &code_09E4E5 )
    COP [SetEntryHere]
    RTL 
}