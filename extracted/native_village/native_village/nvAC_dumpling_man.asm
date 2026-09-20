; Man offering food in the Native Village — insect dumplings.
; 
; Interactive NPC (~112 lines). "The man holds out some food...
; Eat some? Yes/No" On Yes: "It tastes like dumplings made
; of insects... My heart was filled. It seemed as if we
; understood each other." Cultural exchange through food.
---------------------------------------------

---------------------------------------------

nvAC_dumpling_man1 [
  actor-def < #1C, #00, #18, {

  code_088D6E:
    COP [BranchOnFlagByte] ( #AF, #00, &code_088DC2 )
    LDA #$1000
    TSB $12
    COP [SetInteractHandler] ( &code_088DC4 )

  loc_088D7D:
    COP [BranchOnFlagByte] ( #03, #01, &code_088D9D )
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    BRA loc_088D7D
} >
]

code_088D9D {
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_088DC2 {
    COP [Die]
}

code_088DC4 {
    COP [PrintDialogString] ( &dialogstring_088DDE )
    COP [DialogueOptions] ( #02, #01, &code_list_088DCE )
}

code_list_088DCE [
  &code_088DD4   ;00
  &code_088DD9   ;01
  &code_088DD4   ;02
]

code_088DD4 {
    COP [PrintDialogString] ( &dialogstring_088E72 )
    RTL 
}

code_088DD9 {
    COP [PrintDialogString] ( &dialogstring_088E0F )
    RTL 
}

dialogstring_088DDE `[TPL:E]The man holds out[N]some food...[FIN]Eat some?[N] Yes[N] No`

dialogstring_088E0F `[CLR]It tastes like dumplings[N]made of insects...[FIN]My heart was filled.[N]It seemed as if we[N]understood each other.[PAL:0][END]`

dialogstring_088E72 `[CLR]The man looked sad...[PAL:0][END]`
---------------------------------------------

nvAC_dumpling_man2 [
  actor-def < #1A, #00, #18, {

  code_089203:
    COP [BranchOnFlagByte] ( #AF, #00, &code_089246 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_088DC4 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [StageSpriteMoveY] ( #1E, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_089246 {
    COP [Die]
}