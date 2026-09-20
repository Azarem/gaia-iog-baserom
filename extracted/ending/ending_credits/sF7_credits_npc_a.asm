; Credits NPC group A — first farewell characters (~211 lines).
; 
; First batch of NPCs appearing during the credits walkthrough.
; Each character plays a brief farewell animation or poses
; as Will passes by. South Cape and early-game characters.
---------------------------------------------

?INCLUDE 'CreditPositionLookup'

---------------------------------------------

sF7_actor_09E26C [
  actor-def < #00, #00, #18, {

  code_09E26F:
    COP [SpawnBefore] ( @e_actor_09E14B )
    COP [SetMetasprite] ( $7E6000 )

  code_09E279:
    COP [SetEntryHere]
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
    JSL $@CreditPositionLookup

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
    JSL $@CreditPositionLookup

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
    JSL $@CreditPositionLookup

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
    COP [HaltIfMaxFrames] ( #$0F00 )
    COP [SetLinkedEntryPtr] ( &code_09E291 )
    COP [HaltIfMaxFrames] ( #$0F78 )
    COP [SetLinkedEntryPtr] ( &code_09E2A7 )
    COP [HaltIfMaxFrames] ( #$1068 )
    COP [SetLinkedEntryPtr] ( &code_09E30E )
    COP [HaltIfMaxFrames] ( #$1168 )
    COP [SetLinkedEntryPtr] ( &code_09E297 )
    COP [HaltIfMaxFrames] ( #$118C )
    COP [SetLinkedEntryPtr] ( &code_09E2D4 )
    COP [HaltIfMaxFrames] ( #$11A4 )
    COP [SetLinkedEntryPtr] ( &code_09E2CD )
    COP [HaltIfMaxFrames] ( #$1774 )
    COP [SetLinkedEntryPtr] ( &code_09E28A )
    COP [HaltIfMaxFrames] ( #$1968 )
    COP [SetLinkedEntryPtr] ( &code_09E2EA )
    COP [HaltIfMaxFrames] ( #$1E78 )
    COP [SetLinkedEntryPtr] ( &code_09E2F1 )
    COP [HaltIfMaxFrames] ( #$1F70 )
    COP [SetLinkedEntryPtr] ( &code_09E279 )
    COP [HaltIfMaxFrames] ( #$2F58 )
    COP [SetLinkedEntryPtr] ( &code_09E2DC )
    COP [HaltIfMaxFrames] ( #$2FD0 )
    COP [SetLinkedEntryPtr] ( &code_09E2A7 )
    COP [HaltIfMaxFrames] ( #$3066 )
    COP [SetLinkedEntryPtr] ( &code_09E2E2 )
    COP [HaltIfMaxFrames] ( #$3096 )
    COP [SetLinkedEntryPtr] ( &code_09E283 )
    COP [HaltIfMaxFrames] ( #$3138 )
    COP [SetLinkedEntryPtr] ( &code_09E307 )
    COP [HaltIfMaxFrames] ( #$35E8 )
    COP [SetLinkedEntryPtr] ( &code_09E2B6 )
    COP [HaltIfMaxFrames] ( #$35F8 )
    COP [SetLinkedEntryPtr] ( &code_09E28A )
    COP [HaltIfMaxFrames] ( #$3A24 )
    COP [SetLinkedEntryPtr] ( &code_09E2C5 )
    COP [HaltIfMaxFrames] ( #$3A34 )
    COP [SetLinkedEntryPtr] ( &code_09E28A )
    COP [HaltIfMaxFrames] ( #$3CB4 )
    COP [SetLinkedEntryPtr] ( &code_09E2BE )
    COP [HaltIfMaxFrames] ( #$3D68 )
    COP [SetLinkedEntryPtr] ( &code_09E2E2 )
    COP [HaltIfMaxFrames] ( #$3D80 )
    COP [SetLinkedEntryPtr] ( &code_09E2A7 )
    COP [HaltIfMaxFrames] ( #$4164 )
    COP [SetLinkedEntryPtr] ( &code_09E29F )
    COP [HaltIfMaxFrames] ( #$417C )
    COP [SetLinkedEntryPtr] ( &code_09E2A7 )
    COP [HaltIfMaxFrames] ( #$46C8 )
    COP [SetLinkedEntryPtr] ( &code_09E297 )
    COP [HaltIfMaxFrames] ( #$4748 )
    COP [SetLinkedEntryPtr] ( &code_09E279 )
    COP [HaltIfMaxFrames] ( #$48AC )
    COP [SetLinkedEntryPtr] ( &code_09E2F9 )
    COP [HaltIfMaxFrames] ( #$4920 )
    COP [SetLinkedEntryPtr] ( &code_09E28A )
    COP [HaltIfMaxFrames] ( #$4A4C )
    COP [SetLinkedEntryPtr] ( &code_09E2CD )
    COP [HaltIfMaxFrames] ( #$4D1C )
    COP [SetLinkedEntryPtr] ( &code_09E2EA )
    COP [HaltIfMaxFrames] ( #$6C0C )
    COP [SetLinkedEntryPtr] ( &code_09E2CD )
    COP [HaltIfMaxFrames] ( #$6D1A )
    COP [SetLinkedEntryPtr] ( &code_09E28A )
    COP [HaltIfMaxFrames] ( #$6D38 )
    COP [SetLinkedEntryPtr] ( &code_09E27C )
    COP [HaltIfMaxFrames] ( #$6E64 )
    COP [SetLinkedEntryPtr] ( &code_09E2AE )
    COP [HaltIfMaxFrames] ( #$6E74 )
    COP [SetLinkedEntryPtr] ( &code_09E27C )
    COP [SetEntryHere]
    RTL 
}