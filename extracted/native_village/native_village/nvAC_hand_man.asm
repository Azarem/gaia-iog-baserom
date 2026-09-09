---------------------------------------------

nvAC_hand_man1 [
  actor-def < #1D, #00, #18, {

  code_088C70:
    COP [BranchIfFlagByte] ( #AF, #00, &nvAC_hand_man1_destroy )
    LDA #$1000
    TSB $12
    COP [SetOnInteract] ( &code_088CC6 )

  loc_088C7F:
    COP [BranchIfFlagByte] ( #03, #01, &code_088C9F )
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    BRA loc_088C7F
} >
]

code_088C9F {
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

nvAC_hand_man1_destroy {
    COP [Die]
}

code_088CC6 {
    COP [PrintWideString] ( &widestring_088CE0 )
    COP [DialogueOptions] ( #02, #01, &code_list_088CD0 )
}

code_list_088CD0 [
  &code_088CD6   ;00
  &code_088CDB   ;01
  &code_088CD6   ;02
]

code_088CD6 {
    COP [PrintWideString] ( &widestring_088D54 )
    RTL 
}

code_088CDB {
    COP [PrintWideString] ( &widestring_088D1F )
    RTL 
}

widestring_088CE0 `[TPL:E]The man timidly held[N]out his hand...[FIN]Take his hand?[N] Yes[N] No`

widestring_088D1F `[CLR]We don't understand each[N]other's language, but[N]I think we agree...[PAL:0][END]`

widestring_088D54 `[CLR]The man looks lonely...[PAL:0][END]`
---------------------------------------------

nvAC_hand_man2 [
  actor-def < #1A, #00, #18, {

  code_08924B:
    COP [BranchIfFlagByte] ( #AF, #00, &code_08925A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088CC6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08925A {
    COP [Die]
}