; Shop clerk 1 in the Euro flea market — farewell dialog.
; 
; NPC: "Going home? Thank you very much." Friendly shopkeeper
; who acknowledges the player leaving the store.
---------------------------------------------

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

eu97_clerk1 [
  actor-def < #04, #00, #10, {

  code_07CB98:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07CBDE )
    COP [BranchIfPlayerAt] ( #$0170, #$00D0, &code_07CBA9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07CBA9 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_07CC0A )
    COP [SpawnAfterFlags] ( @code_07CBD3, #$2000 )
    COP [StageSpriteMoveY] ( #06, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_07CBD3 {
    LDY $playerActor
    LDA $0016, Y
    INC 
    STA $0016, Y
    RTL 
}

code_07CBDE {
    COP [PrintDialogString] ( &dialogstring_07CBE3 )
    RTL 
}

dialogstring_07CBE3 `[TPL:A]Clerk: Going home?[N]Thank you very much.[END]`

dialogstring_07CC0A `[TPL:A]Clerk: This is the[N]exit. Please use the[N]entrance![END]`