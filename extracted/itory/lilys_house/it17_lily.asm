; Lily in her house -- quest direction NPC.
; 
; Multi-state dialog covering: directing Will to the Elder,
; explaining the Inca Statue location in the cave,
; and revealing the Moon Tribe's mountain location.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

it17_lily [
  actor-def < #1C, #00, #10, {

  code_04E5A4:
    COP [BranchIfFlagByte] ( #37, #01, &code_04E5F2 )
    COP [SetOnInteract] ( &code_04E5F4 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04E7C9 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [PrintDialogString] ( &dialogstring_04E869 )
    COP [SetFlagByte] ( #37 )
    LDA #$0000
    STA $0D60
    LDA #$0002
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$00C4, #$02B4, #00, #05 )
    COP [QueueMapChange] ( #1A, #$0150, #$01A0, #00, #$2200 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04E5F2 {
    COP [Die]
}

code_04E5F4 {
    COP [BranchIfNoItem] ( #03, &code_04E609 )
    COP [BranchIfFlagByte] ( #47, #01, &code_04E604 )
    COP [PrintDialogString] ( &dialogstring_04E62C )
    RTL 
}

code_04E604 {
    COP [PrintDialogString] ( &dialogstring_04E679 )
    RTL 
}

code_04E609 {
    COP [PrintDialogString] ( &dialogstring_04E6E6 )
    COP [DialogueOptions] ( #02, #01, &code_list_04E613 )
}

code_list_04E613 [
  &code_04E619   ;00
  &code_04E61E   ;01
  &code_04E619   ;02
]

code_04E619 {
    COP [PrintDialogString] ( &dialogstring_04E78B )
    RTL 
}

code_04E61E {
    COP [PrintDialogString] ( &dialogstring_04E778 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

dialogstring_04E62C `[TPL:B][TPL:2]Lilly: The Elder is in [N]the flower garden. He's [N]very old, but very wise.[N]Shall we go see him?[PAL:0][END]`

dialogstring_04E679 `[TPL:A][TPL:2]Lilly: What? Inca[N]Statue?[FIN]It's said that[N]it's in a cave on the[N]outskirts of town....[FIN]Seems there's a wall[N]there that sounds[N]different when struck...[PAL:0][END]`

dialogstring_04E6E6 `[TPL:B][TPL:2]Lilly:[N]What? Moon Tribe?[FIN]I know.[N]Not a tribe, more like[N]a strange shadow form.[FIN]A high mountain peak[N]near here has[N]become their home.[FIN]Shall we go?[N][PAL:0] Yes, let's go.[N] Let's quit.`

dialogstring_04E778 `[CLR][TPL:2]Lilly: OK.[N]I'll lead.[PAL:0][END]`

dialogstring_04E78B `[CLR][TPL:2]Lilly: If you[N]make him mad, you'll[N]lose your life,[N]so you'd better stop it.[PAL:0][END]`

dialogstring_04E7C9 `[TPL:A][TPL:2]Lilly: No! [N]It's too dangerous [N]for princesses! [FIN]If you don't want to [N]bother Will, just [N]wait here quietly. [FIN][TPL:1]Kara: [N]I seem to be the only [N]one left out. [FIN]So I'll talk to[N]Grandma Lola.[N]Nyaa nyaa!!![PAL:0][END]`

dialogstring_04E869 `[TPL:A][TPL:0]Will: [N]She's sulking... [FIN][TPL:2]Lilly:[N]It's good medicine for[N]a selfish girl.[FIN]The mountain pass will[N]be difficult, but let's[N]do the best we can.[FIN][DLG:3,6][SIZ:D,3][PAL:0]So Will and Lilly go to [N]the peak where the [N]Moon Tribe lives. [END]`