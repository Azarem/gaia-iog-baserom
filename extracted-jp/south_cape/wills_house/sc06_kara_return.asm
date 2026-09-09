!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!decelStepCounter               09B8

---------------------------------------------

h_sc06_kara_return [
  actor-def < #1B, #00, #10, {

  code_04A341:
    COP [BranchIfFlagByte] ( #26, #01, &code_04A422 )
    COP [BranchIfFlagByte] ( #25, #01, &code_04A424 )
    COP [BranchIfFlagByte] ( #21, #00, &code_04A4C3 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0014, Y
    CLC 
    ADC #$0008
    STA $0014, Y
    COP [SpawnAfterFlags] ( @e_sc06_actor_04AC5A, #$2000 )
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_04A4D5 )
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_04A4F7 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04A539 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [SetTilePos] ( #03, #08 )
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1C, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #28 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_04A58C )
    COP [SetOnInteract] ( &code_04A4C5 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_04A6BA )
    COP [ClearFlagByte] ( #02 )
    COP [SetFlagByte] ( #25 )
    COP [ClearFlagWord] ( #$0119 )
    COP [SetOnInteract] ( &code_04A4CD )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04A422 {
    COP [Die]
}

code_04A424 {
    COP [SetTilePos] ( #0C, #1B )
    COP [SetOnInteract] ( &code_04A4CD )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04A782 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteMoveX] ( #20, #14 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04A79B )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #20, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetFlagByte] ( #26 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_04A7B4 )
    COP [DialogueOptions] ( #02, #02, &code_list_04A486 )
}

code_list_04A486 [
  &code_04A492   ;00
  &code_04A48C   ;01
  &code_04A492   ;02
]

code_04A48C {
    COP [PrintWideString] ( &widestring_04A7F1 )
    BRA loc_04A496
}

code_04A492 {
    COP [PrintWideString] ( &widestring_04A81D )

  loc_04A496:
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$00D4, #$03A4, #00, #03 )
    COP [QueueMapChange] ( #15, #$02D8, #$0370, #00, #$4500 )
    COP [SetEntryContinue]
    RTL 
}

code_04A4C3 {
    COP [Die]
}

code_04A4C5 {
    COP [PrintWideString] ( &widestring_04A5C6 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_04A4CD {
    COP [PrintWideString] ( &widestring_04A759 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

widestring_04A4D5 `[TPL:A][TPL:0]テム: うわっ![N]なんだよ この あれようは···[PAL:0][END]`

widestring_04A4F7 `[TPL:A][TPL:1]カレン: ひどい····![N]いったい だれがこんなことを···[FIN][TPL:0]テム:[N]おじいちゃんと おばあちゃんは!?[PAL:0][END]`

widestring_04A539 `[DLG:3,6][SIZ:D,3,0][TPL:1]カレン:[N]ビルおじいさまーっ![FIN][TPL:0]テム:[N]ローラおばあちーゃん![FIN][TPL:1]カレン:[N]あたし 2階を 見てくるっ![PAL:0][END]`

widestring_04A58C `[TPL:E][TPL:1]カレン: キャーーーーーーッ!!![N]きて! たすけて! テム![N]た,たいへん,たいへんよ![PAL:0][END]`

widestring_04A5C6 `[TPL:E][TPL:0]テム: どうしたの!?[FIN][TPL:1]カレン: このカベを見て![N]このしるし,黒いヒョウのマーク··[N]ブラックパンサーが きたんだわ![FIN][TPL:0]テム:[N]ブラックパンサーって···?[FIN][TPL:1]カレン:[N]最近 お母さまが やとった[N]殺し屋よ![FIN]しつっこくて 暗くて[N]ふきつな男なの.[FIN]ー度 こいつに ねらわれたら[N]もう,おしまい···[N]人の命なんてなんとも思わない男よ![FIN][TPL:0]テム: じゃあ[N]おじいちゃんと おばあちゃんは··[PAL:0][END]`

widestring_04A6BA `[TPL:E][TPL:1]カレン:[N]あなた だあれ!?[FIN][TPL:2]リリィ:[N]テムの お友達よーだ.[FIN][TPL:0]テム:[N]リリィ,きみはなにか知ってるの?[FIN][TPL:2]リリィ:[N]だいじょうぶ. ビルおじいちゃんも[N]ローラおばあちゃんも 無事だよ.[FIN]あたしの村にかくれてる.[FIN][TPL:1]カレン: あなたの村?[PAL:0][END]`

widestring_04A759 `[TPL:E][TPL:1]この先 何か すてきなことが[N]待っているような 気がするわ.[PAL:0][END]`

widestring_04A782 `[TPL:A][TPL:1]カレン:[N]いちいち たてつくわねえ.[END]`

widestring_04A79B `[TPL:A][TPL:1]カレン:[N]なによ フーテン娘![END]`

widestring_04A7B4 `[TPL:B][TPL:1]カレン: あら, テムは[N]あたしの おともだちよね?![N][PAL:0] うん,もちろんさ[N] よくわかんねえや···`

widestring_04A7F1 `[CLR][TPL:1]カレン:[N]うれしいわ,テム.[N]さあさ,手をつないで行きましょ.[FIN][JMP:&sc06_kara_return.widestring_04A81D+M]`

widestring_04A81D `[TPL:2][CLR]リリィ:[N]じゃあ,あたしと いっしょに[N]行きましょ. 行きましょ.[FIN][::][SFX:10][PAL:0]こうして 3人は[N]リリィの村へと 向かうのであった.[END]`
---------------------------------------------

e_sc06_actor_04AC5A {
    COP [SolidHighAbs] ( #05, #1D )
    COP [SolidHighAbs] ( #06, #1D )

  code_04AC62:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #25, #01, &code_04AC87 )
    COP [BranchIfPlayerInAbsTiles] ( #05, #1C, #07, #1D, &code_04AC73 )
    RTL 
}

code_04AC73 {
    COP [BranchIfButton] ( #$0400, &code_04AC7E )
    COP [SetEntryExitNow] ( @code_04AC62 )
}

code_04AC7E {
    COP [PrintWideString] ( &widestring_04AC91 )
    COP [SetEntryExitNow] ( @code_04AC62 )
}

code_04AC87 {
    COP [ClearLowAbs] ( #05, #1D )
    COP [ClearLowAbs] ( #06, #1D )
    COP [Die]
}

widestring_04AC91 `[TPL:A][TPL:0]テム:[N](いや 手がかりはきっと 家の中に[N] あるはずだ···)[PAL:0][END]`