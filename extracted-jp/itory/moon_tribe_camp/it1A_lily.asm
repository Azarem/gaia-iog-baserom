?INCLUDE 'chunk_008000'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

h_it1A_lily [
  actor-def < #1B, #00, #10, {

  code_04EBE5:
    COP [BranchOnFlagByte] ( #4A, #01, &code_04EC8A )
    COP [SpawnAfterFlags] ( @code_04EEF4, #$2000 )
    COP [SpawnAfterFlags] ( @code_04EFA5, #$2000 )
    COP [BranchOnFlagByte] ( #49, #01, &code_04EC61 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04ECDD )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$1000
    TRB $10
    LDA #$0300
    TSB $10
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0004
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetInteractHandler] ( #$0000 )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchOnFlagByte] ( #49, #01, &code_04EC4D )
    RTL 
} >
]

code_04EC4D {
    COP [KillNext]
    LDA #$0000
    STA $2A
    COP [SetEntryHereAndYield]
    COP [PrintDialogString] ( &dialogstring_04ED09 )
    COP [SetInteractHandler] ( &code_04EC8C )
    COP [SetEntryHere]
    RTL 
}

code_04EC61 {
    COP [SetTilePos] ( #0D, #1A )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04EC91 )
    COP [WaitOnFlagByte] ( #4A, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #03, #01 )
    COP [AnimLoop]
}

code_04EC8A {
    COP [Die]
}

code_04EC8C {
    COP [PrintDialogString] ( &dialogstring_04ED09 )
    RTL 
}

code_04EC91 {
    COP [BranchIfHasItem] ( #04, &code_04EC9B )
    COP [PrintDialogString] ( &dialogstring_04ED2A )
    RTL 
}

code_04EC9B {
    COP [SetFlagByte] ( #4A )
    COP [PrintDialogString] ( &dialogstring_04ED77 )
    COP [DialogueOptions] ( #02, #02, &code_list_04ECA8 )
}

code_list_04ECA8 [
  &code_04ECAE   ;00
  &code_04ECB2   ;01
  &code_04ECAE   ;02
]

code_04ECAE {
    COP [PrintDialogString] ( &dialogstring_04EDD8 )
}

code_04ECB2 {
    COP [PrintDialogString] ( &dialogstring_04EE12 )
    LDA #$0000
    STA $0D60
    LDA #$0002
    STA $0D62
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0094, #$0254, #00, #06 )
    COP [QueueMapChange] ( #1C, #$0070, #$0160, #00, #$2200 )
    COP [SetEntryHere]
    RTL 
}

dialogstring_04ECDD `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]さあ 着いたわ.[N]ここが 月の種族のすみかよ.[END]`

dialogstring_04ED09 `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]じゃ あたし ここでまってるね.[END]`

dialogstring_04ED2A `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]どうだった?[FIN]·····.[N]その顔は ダメだったみたいね.[FIN]気をおとさないで もうー回[N]がんばっておいでよ.[END]`

dialogstring_04ED77 `[DLG:3,6][SIZ:D,4,0][TPL:2]リリィ:[N]あっ その 像はっ![N]テムってば すごい すごおぉい![FIN]これで 像が2つそろったわけね.[N]インカのイセキへ 行くつもり?[N][PAL:0] はい[N] いいえ`

dialogstring_04EDD8 `[CLR][TPL:2]リリィ:[N]うそ. あたし わかるもん.[N]言葉で そういっても[N]テムは 行くつもりなんでしょ.[FIN]`

dialogstring_04EE12 `[CLR][TPL:0]テム:[N]うん.[N]とうさんに 呼ばれたんだ···[FIN]すい星の光をあびた 化物たちと[N]戦うのは ちょっと こわいけど,[N]でも とうさんが 生きてるなら[N]危険をおかしてでも 会いたいんだ.[FIN]この気持ちは 両親を なくして[N]みなきゃ わからないさ···[FIN][TPL:2]リリィ:[N]やっぱり 男の子ねぇ···[FIN]わかったわ.[N]じゃ イセキへ 向かいましょ.[FIN][PAL:0][SFX:10]二人は インカのイセキへ[N]向かうのであった.[END]`

code_04EEF4 {
    COP [MarkSolidAbs] ( #15, #1C )
    COP [MarkSolidAbs] ( #16, #1C )

  code_04EEFC:
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #4A, #01, &code_04EF30 )
    COP [BranchIfPlayerInAbsTiles] ( #15, #1B, #17, #1C, &code_04EF0D )
    RTL 
}

code_04EF0D {
    COP [BranchIfPressed] ( #$0400, &code_04EF18 )
    COP [JumpNextFrame] ( @code_04EEFC )
}

code_04EF18 {
    COP [BranchOnFlagByte] ( #49, #01, &code_04EF27 )
    COP [PrintDialogString] ( &dialogstring_04EF3A )
    COP [JumpNextFrame] ( @code_04EEFC )
}

code_04EF27 {
    COP [PrintDialogString] ( &dialogstring_04EF73 )
    COP [JumpNextFrame] ( @code_04EEFC )
}

code_04EF30 {
    COP [ClearSolidAbs] ( #15, #1C )
    COP [ClearSolidAbs] ( #16, #1C )
    COP [Die]
}

dialogstring_04EF3A `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ: ちょっとぉ![N]目的があって ここへきたんでしょ?[N]いきなり 帰らないでよ.[END]`

dialogstring_04EF73 `[DLG:3,6][SIZ:D,3,0][TPL:0]テム:[N](インカの像を 手に入れなきゃ[N] かえれないな···)[PAL:0][END]`

code_04EFA5 {
    COP [MarkSolidAbs] ( #0C, #18 )
    COP [BranchOnFlagByte] ( #2A, #01, &code_04EFD4 )

  code_04EFAF:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #0C, #19, #0D, #1A, &code_04EFBA )
    RTL 
}

code_04EFBA {
    COP [BranchIfPressed] ( #$0800, &code_04EFC5 )
    COP [JumpNextFrame] ( @code_04EFAF )
}

code_04EFC5 {
    COP [BranchOnFlagByte] ( #2A, #01, &code_04EFD4 )
    COP [PrintDialogString] ( &dialogstring_04EFDD )
    COP [JumpNextFrame] ( @code_04EFAF )
}

code_04EFD4 {
    COP [SetFlagByte] ( #49 )
    COP [ClearSolidAbs] ( #0C, #18 )
    COP [Die]
}

dialogstring_04EFDD `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]うろうろするのは 月の種族と[N]話してからにしましょ.[END]`