?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A

---------------------------------------------

sc06_kara [
  actor-def < #12, #00, #30, {

  code_049DAF:
    COP [BranchIfFlagByte] ( #1B, #01, &code_049EA0 )
    COP [BranchIfFlagByte] ( #3D, #01, &code_049EA2 )
    COP [BranchIfFlagByte] ( #16, #00, &code_049EA0 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #16, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_049EB4 )
    LDA #$0002
    JSL $@InitPlayerScriptVariant
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #3C )
    COP [AnimLoop]
    LDA #$0001
    JSL $@InitPlayerScriptVariant
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_049F09 )
    COP [SetFlagByte] ( #02 )
    COP [StageSpriteLoopMoveX] ( #19, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    LDA #$0003
    JSL $@InitPlayerScriptVariant
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_049F71 )
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_049FBC )
    COP [StageSpriteLoop] ( #13, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_04A04C )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #3D )

  loc_049E5A:
    COP [SetOnInteract] ( &code_049EAF )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #19 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #07, #01 )
    COP [StageSpriteLoop] ( #15, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04A0D7 )
    COP [SetFlagByte] ( #08 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #15, #E0, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #13, #A0, #11 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #09 )
    COP [PrintDialogString] ( &dialogstring_04A15A )
    COP [StageSpriteLoopMoveY] ( #16, #04, #11 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #1B )
} >
]

code_049EA0 {
    COP [Die]
}

code_049EA2 {
    COP [SetTilePos] ( #0A, #19 )
    COP [SolidHighHere]
    LDA #$2000
    TRB $10
    BRA loc_049E5A
}

code_049EAF {
    COP [PrintDialogString] ( &dialogstring_04A0D2 )
    RTL 
}

dialogstring_049EB4 `[TPL:A][TPL:1]Kara: [N]Hamlet! You shouldn't[N]snort at strangers![FIN]Is this your house?[FIN][TPL:0]Will: [N]Yeah...so?[PAL:0][END]`

dialogstring_049F09 `[TPL:9][TPL:1]Kara: Frankly, you look[N]a little shabby....[FIN][TPL:0]Will: [N]Well, excuse me...!![FIN][TPL:1]Kara: Your father?[N]Mother? Not here, huh?[PAL:0][END]`

dialogstring_049F71 `[DLG:3,13][SIZ:D,2][TPL:1]Kara: Is this a picture[N]of your parents?[FIN][TPL:0]Will: My father's an[N]explorer, he.....[PAL:0][END]`

dialogstring_049FBC `[TPL:A][TPL:1]Kara: I know. Olman,[N]the explorer. They say[N]he was lost.[FIN][TPL:0]Will: He'll come[N]back some day.[FIN][TPL:1]Kara: [N]Are you sad?[N]...No?[FIN]I'd be sad, if it were[N]me.[N]I'm sorry...[PAL:0][END]`

dialogstring_04A04C `[TPL:A][TPL:1]Kara: [N]Anyway, is there a[N]piano here?[FIN][TPL:0]Will: No, there isn't![N]But Grandma Lola is a[N]great singer.[FIN][::][TPL:1]Kara: They're singing[N]upstairs now. They[N]have such loud voices!![PAL:0][END]`

dialogstring_04A0D2 `[TPL:A][JMP:&sc06_kara.dialogstring_04A04C+M]`

dialogstring_04A0D7 `[TPL:A][TPL:1]Kara:[N]What do I care if you[N]lose your head?[FIN][PAL:0]Soldier: Princess![FIN]Do you think I have[N]nothing better to do[N]than chase you down?[FIN]I must take you home.[N]It's the King's orders![END]`

dialogstring_04A15A `[TPL:B][TPL:1]Kara: I'm sorry I lied[N]to you. I'm King[N]Edward's daughter, Kara.[FIN]Will. [N]I feel as though we've[N]met before, as if we[N]were good friends.[PAL:0][END]`