!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

h_it17_lily [
  actor-def < #1C, #00, #10, {

  code_04DE65:
    COP [BranchIfFlagByte] ( #37, #01, &code_04DEB3 )
    COP [SetOnInteract] ( &code_04DEB5 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04E08C )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [PrintDialogString] ( &dialogstring_04E126 )
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

code_04DEB3 {
    COP [Die]
}

code_04DEB5 {
    COP [BranchIfNoItem] ( #03, &code_04DECA )
    COP [BranchIfFlagByte] ( #47, #01, &code_04DEC5 )
    COP [PrintDialogString] ( &dialogstring_04DEED )
    RTL 
}

code_04DEC5 {
    COP [PrintDialogString] ( &dialogstring_04DF3D )
    RTL 
}

code_04DECA {
    COP [PrintDialogString] ( &dialogstring_04DFA4 )
    COP [DialogueOptions] ( #02, #01, &code_list_04DED4 )
}

code_list_04DED4 [
  &code_04DEDA   ;00
  &code_04DEDF   ;01
  &code_04DEDA   ;02
]

code_04DEDA {
    COP [PrintDialogString] ( &dialogstring_04E053 )
    RTL 
}

code_04DEDF {
    COP [PrintDialogString] ( &dialogstring_04E035 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

dialogstring_04DEED `[TPL:B][TPL:2]リリィ: 長老樣は 花畑の中よ.[N]もう 何才だか わからないくらい[N]お年寄りだけど とても物知りなの.会ってみたら?[PAL:0][END]`

dialogstring_04DF3D `[TPL:A][TPL:2]リリィ: え? インカの神像?[N]村の 西のはずれの どうくつに[N]まつられてるって 話だけど··[FIN]そういえば あそこには[N]たたくと 音のちがう カベが[N]あったような···[PAL:0][END]`

dialogstring_04DFA4 `[TPL:A][TPL:2]リリィ:[N]え? 月の種族?[FIN]うん 知ってるよ.[N]種族っていうより カゲのような[N]不思議な 生命体ね.[FIN]この近くの 高い高い山の頂上が[N]彼らのすみかに なってるんだけど.[FIN]行ってみる?[N][PAL:0] うん 行ってみたい[N] やっぱり やめとく`

dialogstring_04E035 `[CLR][TPL:2]リリィ: わかった.[N]じゃ 案内するね.[PAL:0][END]`

dialogstring_04E053 `[CLR][TPL:2]リリィ: そうね. 彼らを[N]おこらすと 命がないって言うし.[N]やめといたほうが いいかもね.[PAL:0][END]`

dialogstring_04E08C `[TPL:A][TPL:2]リリィ: だーめっ![N]おじょうさまには 危険すぎるもん.[FIN]テムに めいわくかけたくなかったら[N]ここで おとなしくまってて.[FIN][TPL:1]カレン:[N]ふんっ. なによっ.[N]あたしばっかり のけものにして.[FIN]ローラおばあさまと お話してるから[N]いいわよっ![N]いーーーーだっ!!![PAL:0][END]`

dialogstring_04E126 `[TPL:A][TPL:0]テム: [N]あーあ すねちゃった···[FIN][TPL:2]リリィ:[N]わがままな おじょうさまには[N]いい藥よ.[FIN]さあ 山道が たいへんだけど[N]がんばって いきましょ.[FIN][DLG:3,6][SIZ:D,3,0][PAL:0]こうして テムと リリィは[N]月の種族の住む 山の頂上へと[N]向かうのであった.[END]`