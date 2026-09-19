; Erik in the coastal cave -- Kara escape news cutscene.
; 
; Triggers the major early-game cutscene where Erik rushes in with
; news about Princess Kara's escape from Edward Castle. Multi-character
; dialog sequence with Lance and Seth reacting.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

sc02_erik [
  actor-def < #0A, #00, #10, {

  code_04B8B4:
    COP [BranchIfFlagByte] ( #4C, #01, &code_04B96F )
    COP [SetOnInteract] ( &code_04B995 )
    COP [BranchIfFlagByte] ( #20, #01, &code_04B95F )
    COP [BranchIfFlagByte] ( #16, #01, &code_04B962 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetFlagByte] ( #16 )
    COP [SetFlagByte] ( #04 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_04B9AF )
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04B9F2 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #03 )
    COP [WaitByte] ( #B3 )
    COP [ClearFlagByte] ( #03 )
    COP [PrintDialogString] ( &dialogstring_04BA55 )
    COP [StartMusic] ( #1C )
    COP [WaitByte] ( #77 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #11, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetOnInteract] ( &code_04B99A )
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [CallScript] ( &code_04B971 )
    COP [SetOnInteract] ( &code_04B99F )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [CallScript] ( &code_04B971 )
    COP [PrintDialogString] ( &dialogstring_04BC16 )
    COP [SetFlagByte] ( #09 )
} >
]

code_04B95F {
    COP [SetEntryContinue]
    RTL 
}

code_04B962 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04B99F )
    JMP $&code_04B95F
}

code_04B96F {
    COP [Die]
}

code_04B971 {
    COP [StageSpriteLoopMoveY] ( #0A, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04B995 {
    COP [PrintDialogString] ( &dialogstring_04BB59 )
    RTL 
}

code_04B99A {
    COP [PrintDialogString] ( &dialogstring_04BB89 )
    RTL 
}

code_04B99F {
    COP [BranchIfFlagByte] ( #21, #01, &code_04B9AA )
    COP [PrintDialogString] ( &dialogstring_04BBB6 )
    RTL 
}

code_04B9AA {
    COP [PrintDialogString] ( &dialogstring_04BBDA )
    RTL 
}

dialogstring_04B9AF `[DLG:3,6][SIZ:D,3][DLY:0]Suddenly Erik rushed in[N]with a desperate look[N]on his face.[PAU:3C][CLD]`

dialogstring_04B9F2 `[TPL:A][TPL:3]Erik: Ah! [N]News! Big news![FIN]The Princess of Edward [N]Castle has run away![FIN]They say she came to[N]South Cape![PAL:0][END]`

dialogstring_04BA55 `[TPL:B][TPL:4]Lance: That's all? [FIN]You came in such a hurry[N]that I thought something[N]really big had happened![FIN]The princess is probably[N]that spoiled girl, Kara..[N]The one you like[N]so much![FIN][TPL:3]Erik: LIAR![N]Maybe the soldiers[N]will come here[N]looking for her![FIN]The soldiers from[N]Edward Castle look so[N]cool. I want a steel[N]helmet, too.[PAL:0][END]`

dialogstring_04BB59 `[TPL:A][TPL:3]Erik: [N]And I thought everyone[N]would be surprised...[PAL:0][END]`

dialogstring_04BB89 `[TPL:A][TPL:3]Erik: [N]Last time you moved[N]the statue a long way.[PAL:0][END]`

dialogstring_04BBB6 `[TPL:A][TPL:3]Erik: [N]If I could only[N]do that...[PAL:0][END]`

dialogstring_04BBDA `[TPL:A][TPL:3]Erik: What's the matter?[N]You're not acting like[N]the same old Will.[PAL:0][END]`

dialogstring_04BC16 `[TPL:A][TPL:3]Erik: [N]I'm speechless...[FIN]Hey, Seth.[N]This is some type of[N]psychic power, right?[PAL:0][END]`