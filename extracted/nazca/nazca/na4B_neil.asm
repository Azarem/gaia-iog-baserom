; Neil at Nazca — the scientist's excitement.
; 
; Extended NPC (~114 lines). "It was a long way, but you did a
; good job. This is the most famous of the ground paintings."
; Later: "Ha ha ha. Don't be in such a hurry. Wait for everyone
; else." Neil's scientific enthusiasm about the Nazca lines.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

na4B_neil [
  actor-def < #12, #00, #10, {

  code_05E844:
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05E8F7 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_05E8BE )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetOnInteract] ( &code_05E8C3 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [CallScript] ( &code_05E8CB )
    COP [SetOnInteract] ( &code_05E8F2 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #16, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #16, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetFlagByte] ( #0B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E8BE {
    COP [PrintDialogString] ( &dialogstring_05E9F0 )
    RTL 
}

code_05E8C3 {
    COP [PrintDialogString] ( &dialogstring_05EA25 )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_05E8CB {
    COP [PrintDialogString] ( &dialogstring_05EB2E+M )

  loc_05E8CF:
    COP [PrintDialogString] ( &dialogstring_05EB94 )
    COP [DialogueOptions] ( #04, #00, &code_list_05E8D9 )
}

code_list_05E8D9 [
  &code_05E8E3   ;00
  &code_05E8E3   ;01
  &code_05E8E3   ;02
  &code_05E8E9   ;03
  &code_05E8E3   ;04
]

code_05E8E3 {
    COP [PrintDialogString] ( &dialogstring_05EBE5 )
    BRA loc_05E8CF
}

code_05E8E9 {
    COP [PrintDialogString] ( &dialogstring_05EC0E )
    COP [SetFlagByte] ( #09 )
    COP [RestoreSavedPtr]
}

code_05E8F2 {
    COP [PrintDialogString] ( &dialogstring_05EC5B )
    RTL 
}

dialogstring_05E8F7 `[DEF][TPL:6]Neil: [N]It was a long way, but [N]you did a good job. [FIN]This is the most famous [N]of the ground paintings-- [N]the Condor. Have you [N]ever heard of it? [FIN]No one knows why[N]ancient people drew[N]pictures like this.[FIN]Whenever I come here[N]I'm overwhelmed by[N]the grand scale.[FIN]You should go see[N]it for yourself.[PAL:0][END]`

dialogstring_05E9F0 `[DEF][TPL:6]Neil: [N]Ha ha ha. Don't be in [N]such a hurry. Wait for [N]everyone else.[PAL:0][END]`

dialogstring_05EA25 `[DEF][TPL:6]Neil: [N]We'll talk about it when [N]everyone comes back. [FIN]The Mystic Statue that[N]Will spoke of is[N]somewhere on this[N]plain? [FIN][CLD][PAU:28][DEF][TPL:3]Erik: [N]I thought I'd seen the [N]paintings before,[FIN]but doesn't this Condor[N]look like Cygnus?[FIN][CLD][PAU:14][DEF][TPL:6]Neil: [N]Of course! I [N]hadn't noticed!! [FIN]When we look at it, we[N]see Cygnus, but ancient[N]people probably just [N]saw a condor... [END]`

dialogstring_05EB2E `[DEF][TPL:6]Neil: [N]We'll talk about it when [N]everyone comes back. [FIN][::][DEF][TPL:6][DLY:0]Neil: Of course! [N]Cygnus has nine stars,[N]and there are nine[N]stones... [FIN]`

dialogstring_05EB94 `[CLR][TPL:0]Where is the red star[N]that appeared recently?[FIN] Condor's Head[N] Condor's Right Foot[N] Condor's Left Foot[N] Condor's Tail`

dialogstring_05EBE5 `[CLR][TPL:0]Will: I would think it [N]would be at the bottom. [FIN]`

dialogstring_05EC0E `[CLR][TPL:0]Will: Of course! At the[N]joint of its left foot! [FIN][TPL:6]Neil: [N]Let's check the [N]left foot![PAL:0][END]`

dialogstring_05EC5B `[DEF][TPL:6]Neil: Not bad! [N]It's as exciting [N]as inventing something![PAL:0][END]`