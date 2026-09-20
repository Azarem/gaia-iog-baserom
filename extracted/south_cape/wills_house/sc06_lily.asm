; Lily's appearance in Will's house after the kidnapping.
; 
; Introduces Lily and Itory Village. Dialog sequence where Lily
; offers to help, Kara insists on coming, and they depart.
; Sets the Itory Village storyline in motion.
---------------------------------------------

?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A

---------------------------------------------

sc06_lily [
  actor-def < #36, #00, #30, {

  code_04AAFC:
    COP [BranchOnFlagByte] ( #26, #01, &code_04AB93 )
    COP [BranchOnFlagByte] ( #25, #01, &code_04AB95 )
    COP [BranchOnFlagByte] ( #21, #00, &code_04ABDA )
    COP [WaitOnFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #36, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #36, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #36, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #3C )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0002
    JSL $@InitPlayerScriptVariant
    COP [SetEntryHereAndYield]
    COP [PrintDialogString] ( &dialogstring_04AC0C )
    COP [SetFlagByte] ( #02 )
    COP [WaitOnFlagByte] ( #02, #00 )
    COP [StageSpriteLoop] ( #22, #28 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04AC45 )
    COP [StageSpriteLoop] ( #25, #28 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04AC77 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04ABDC )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [SetInteractHandler] ( &code_04ABE4 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04AB93 {
    COP [Die]
}

code_04AB95 {
    COP [SetTilePos] ( #08, #1B )
    LDA #$2000
    TRB $10
    COP [SetInteractHandler] ( &code_04ABE9 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #29, #11 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [StageSpriteMoveX] ( #29, #13 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04AEC1 )
    COP [ClearFlagByte] ( #02 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [PrintDialogString] ( &dialogstring_04AEF7 )
    COP [ClearFlagByte] ( #03 )
    COP [SetEntryHere]
    RTL 
}

code_04ABDA {
    COP [Die]
}

code_04ABDC {
    COP [PrintDialogString] ( &dialogstring_04AD69 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_04ABE4 {
    COP [PrintDialogString] ( &dialogstring_04ADCA )
    RTL 
}

code_04ABE9 {
    COP [PrintDialogString] ( &dialogstring_04ADFE )
    COP [DialogueOptions] ( #02, #02, &code_list_04ABF3 )
}

code_list_04ABF3 [
  &code_04ABF9   ;00
  &code_04ABFE   ;01
  &code_04ABF9   ;02
]

code_04ABF9 {
    COP [PrintDialogString] ( &dialogstring_04AE24 )
    RTL 
}

code_04ABFE {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04AE61 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

dialogstring_04AC0C `[TPL:E][TPL:2]Lilly:[N]Don't worry, you two.[FIN][TPL:0]Will: [N]You're the one who...[PAL:0][END]`

dialogstring_04AC45 `[TPL:E][TPL:2]Lilly: [N]Itory village.[FIN][TPL:1]Kara: I've never heard[N]of this village![END]`

dialogstring_04AC77 `[TPL:E][TPL:2]Lilly: Naturally. My[N]village has a barrier[N]around it.[FIN]Ordinary people like you[N]can't see it. [FIN]Lilly: [N]Let's go, Will! [FIN][TPL:0]Will: OK![FIN][TPL:1]Kara: [N]I'm going, too![FIN][TPL:2]Lilly: It's far too[N]dangerous[N]for a princess.[FIN][TPL:1]Kara: You can't stop[N]royalty! I do whatever[N]I want!![FIN][TPL:2]Lilly:[N]Typical of a princess...[PAL:0][END]`

dialogstring_04AD69 `[TPL:E][TPL:2]Lilly: Before we go to[N]my village, should we[N]meet the townspeople?[FIN]We might not be back[N]here for a long time.[PAL:0][END]`

dialogstring_04ADCA `[TPL:E][TPL:2]Lilly: Is that OK?[N]We should see how[N]things are in the village.[PAL:0][END]`

dialogstring_04ADFE `[TPL:B][TPL:2]Lilly: Are you[N]ready to go?[N][PAL:0] Yes[N] No`

dialogstring_04AE24 `[CLR][TPL:2]Lilly: All right.[N]If you decide to[N]go, come back here[N]when you're through.[PAL:0][END]`

dialogstring_04AE61 `[CLR][TPL:1]Kara: I think[N]something wonderful[N]is going to happen.[FIN][TPL:2]Lilly:[N]No. From here on there[N]will be many hardships....[N]Hmmmmm.[END]`

dialogstring_04AEC1 `[TPL:A][TPL:2]Lilly: That's what I[N]expected. Have you ever[N]been outside the castle?[END]`

dialogstring_04AEF7 `[TPL:A][TPL:2]Lilly: Are you totally[N]ignorant of the world!? [FIN]Lilly: [N]Will is my friend.[N]Understand?[END]`