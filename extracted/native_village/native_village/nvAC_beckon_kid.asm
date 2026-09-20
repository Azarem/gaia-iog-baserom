; Beckoning child in the Native Village — leads Will somewhere.
; 
; Interactive NPC (~95 lines): "He tugs on Will's sleeve, as if
; he wants to take him somewhere. Go with him? Yes/No"
; The child guides Will to an important location if the
; player agrees. Non-verbal communication scene.
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

nvAC_beckon_kid [
  actor-def < #24, #00, #18, {

  code_08908D:
    COP [BranchOnFlagByte] ( #AF, #00, &code_089102 )
    COP [SetInteractHandler] ( &code_089104 )
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #B2, #01, &code_0890C1 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #28, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [MarkSolidHere]
} >
]

code_0890C1 {
    COP [WaitOnFlagByte] ( #06, #01 )
    COP [SetInteractHandler] ( #$0000 )
    LDA #$0800
    TRB $10
    COP [ClearSolidHere]
    LDA #$0148
    STA $moveXAlt, X
    LDA #$0120
    STA $moveYAlt, X
    COP [MoveToward] ( #29, #01 )
    LDA #$0188
    STA $moveXAlt, X
    LDA #$0140
    STA $moveYAlt, X
    COP [MoveToward] ( #29, #01 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_089121 )
    LDA #$0200
    TSB $12
    COP [SetEntryHere]
    RTL 
}

code_089102 {
    COP [Die]
}

code_089104 {
    COP [PrintDialogString] ( &dialogstring_089126 )
    COP [DialogueOptions] ( #02, #01, &code_list_08910E )
}

code_list_08910E [
  &code_089114   ;00
  &code_089119   ;01
  &code_089114   ;02
]

code_089114 {
    COP [PrintDialogString] ( &dialogstring_089190 )
    RTL 
}

code_089119 {
    COP [PrintDialogString] ( &dialogstring_089178 )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_089121 {
    COP [PrintDialogString] ( &dialogstring_0891A2 )
    RTL 
}

dialogstring_089126 `[TPL:E]He tugs on Will's[N]sleeve, as if he wants[N]to take him somewhere.[FIN]Go with him?[N] Yes[N] No`

dialogstring_089178 `[CLR]He beckons to him...[PAL:0][END]`

dialogstring_089190 `[CLR]He looks lonely...[PAL:0][END]`

dialogstring_0891A2 `[TPL:9][TPL:0]He faces the skeleton[N]with tears in his eyes...[FIN]Is this the skeleton of[N]a relative? A friend?[PAL:0][END]`