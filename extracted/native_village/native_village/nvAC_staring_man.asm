---------------------------------------------

nvAC_staring_man1 [
  actor-def < #1D, #00, #18, {

  code_088E89:
    COP [BranchIfFlagByte] ( #AF, #00, &code_088EC0 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088EC2 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
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
} >
]

code_088EC0 {
    COP [Die]
}

code_088EC2 {
    COP [PrintDialogString] ( &dialogstring_088EDC )
    COP [DialogueOptions] ( #02, #01, &code_list_088ECC )
}

code_list_088ECC [
  &code_088ED2   ;00
  &code_088ED7   ;01
  &code_088ED2   ;02
]

code_088ED2 {
    COP [PrintDialogString] ( &dialogstring_088F71 )
    RTL 
}

code_088ED7 {
    COP [PrintDialogString] ( &dialogstring_088F15 )
    RTL 
}

dialogstring_088EDC `[TPL:E]The man looks deeply [N]into Will's eyes. [FIN]Stare back?[N] Yes[N] No`

dialogstring_088F15 `[CLR]The man seems to look [N]right into your heart... [FIN]We don't understand each[N]other's language, but[N]a seed has sprouted...[PAL:0][END]`

dialogstring_088F71 `[CLR]The man looked lonely...[PAL:0][END]`
---------------------------------------------

nvAC_staring_man2 [
  actor-def < #1A, #00, #18, {

  code_08925F:
    COP [BranchIfFlagByte] ( #AF, #00, &nvAC_staring_man2_destroy )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_088EC2 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1E, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]
---------------------------------------------

nvAC_staring_man2_destroy {
    COP [Die]
}