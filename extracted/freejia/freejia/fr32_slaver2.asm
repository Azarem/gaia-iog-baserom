; Slave trader 2 in Freejia — interrogates Will about the escapee.
; 
; Interactive NPC (~97 lines). Asks: "A laborer escaped. Have you
; seen him? Yes/No" — dialog branches based on player choice.
; If Yes, says "Where?!"; if No: "Hmm. Tell me if you see him."
; Multi-state with flag progression tracking the escaped
; laborer subplot.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

fr32_slaver2 [
  actor-def < #1C, #00, #10, {

  code_05B855:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05B87E )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B880 )
    COP [WaitByte] ( #07 )

  code_05B864:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #5A, #00, &code_05B864 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #04, #02 )
    COP [AnimLoop]
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_05B87E {
    COP [Die]
}

code_05B880 {
    COP [PrintDialogString] ( &dialogstring_05B8CD )
    COP [DialogueOptions] ( #02, #02, &code_list_05B88A )
}

code_list_05B88A [
  &code_05B890   ;00
  &code_05B895   ;01
  &code_05B890   ;02
]

code_05B890 {
    COP [PrintDialogString] ( &dialogstring_05B8F1 )
    RTL 
}

code_05B895 {
    COP [PrintDialogString] ( &dialogstring_05B90C )
    COP [DialogueOptions] ( #02, #02, &code_list_05B89F )
}

code_list_05B89F [
  &code_05B8A5   ;00
  &code_05B8AA   ;01
  &code_05B8A5   ;02
]

code_05B8A5 {
    COP [PrintDialogString] ( &dialogstring_05B9AF+M )
    RTL 
}

code_05B8AA {
    COP [BranchIfFlagByte] ( #59, #01, &code_05B8B5 )
    COP [PrintDialogString] ( &dialogstring_05B9AF )
    RTL 
}

code_05B8B5 {
    COP [GiveItem] ( #01, &code_05B8C8 )
    COP [PrintDialogString] ( &dialogstring_05B94D )
    COP [SetFlagByte] ( #5A )
    LDA #$EFF0
    TSB $joypadMaskStd
    RTL 
}

code_05B8C8 {
    COP [PrintDialogString] ( &dialogstring_05B9EE )
    RTL 
}

dialogstring_05B8CD `[DEF]A laborer escaped.[N]Have you seen him?[N] Yes[N] No`

dialogstring_05B8F1 `[CLR]Hmm.[N]Tell me if you see him.[END]`

dialogstring_05B90C `[CLR]Tell me where and I'll[N]give you this Red Jewel.[N] Tell location.[N] Laugh and lie.`

dialogstring_05B94D `[CLR]Will tells where the [N]laborer is hiding. [FIN]Man: Thank you.[N]Here's a present.[N]Please accept it.[FIN]Will gets a Red Jewel. [END]`

dialogstring_05B9AF `[CLR]But Will doesn't know [N]where the laborer is. [FIN][::][CLR]Man:[N]Hey! Don't play[N]jokes on an adult!![END]`

dialogstring_05B9EE `[CLR]Man:[N]Is your inventory full?[N]Too bad...[END]`