?INCLUDE 'chunk_008000'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

h_ec0A_kara [
  actor-def < #15, #00, #10, {

  code_04C67F:
    COP [BranchIfFlagByte] ( #22, #01, &code_04C77C )
    COP [SetSpritePriority] ( #30 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04C729 )
    COP [BranchIfFlagByte] ( #19, #01, &code_04C720 )
    COP [BranchIfFlagByte] ( #1A, #01, &code_04C6CC )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetFlagByte] ( #1A )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04C790 )
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #16, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04C7A5 )
    COP [SetFlagByte] ( #02 )
} >
]

code_04C6CC {
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SetTilePos] ( #0B, #0C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_04C6DF )
    RTL 
}

code_04C6DF {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04C7BA )
    COP [WaitByte] ( #1D )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoopMoveY] ( #15, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #15, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #15, #10 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04C80D )
    COP [SetFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [PrintDialogString] ( &dialogstring_04C8CD )
    COP [SetFlagByte] ( #19 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04C720 {
    COP [SetOnInteract] ( &code_04C783 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_04C729 {
    COP [SpawnAfterFlags] ( @code_04CA50, #$2000 )
    COP [SetTilePos] ( #05, #0A )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04C788 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SolidHighAbs] ( #06, #36 )
    COP [ClearLowHere]
    LDA #$1000
    TRB $10
    LDA #$0300
    TSB $10
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0012
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
}

code_04C77C {
    COP [Die]

  loc_04C77E:
    COP [PrintDialogString] ( &dialogstring_04C8CD )
    RTL 
}

code_04C783 {
    COP [PrintDialogString] ( &dialogstring_04C962 )
    RTL 
}

code_04C788 {
    COP [PrintDialogString] ( &dialogstring_04C967 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_04C790 `[TPL:9][TPL:1]カレン: だあれ?[PAL:0][PAU:5A][CLD]`

dialogstring_04C7A5 `[TPL:9][TPL:1][CLR]カレン: お客さま?[PAL:0][END]`

dialogstring_04C7BA `[TPL:B][TPL:1]カレン:[N]あなたは きのうの···[FIN][TPL:0]テム: エドワード国王に[N]水しょうの指輪を 持ってくるように[N]言われたんだけどさ···[PAL:0][END]`

dialogstring_04C80D `[TPL:A][TPL:1]カレン:[N]ひどい! ひどいっ![N]ひっどーいっ![FIN]また お父樣は 他人の 大切な物を[N]明り上げようと してるのねっ![FIN]あたしもね ちょっと[N]お城をぬけだしたら おしおきで[N]ここから 出してくれないのよ![FIN]でも このところ お城のふんいきが[N]ちょっとおかしいの.[FIN]お母さまったら 殺し屋まで[N]やとったのよ.[N]うす気味 悪いわ···[PAL:0][END]`

dialogstring_04C8CD `[PAU:28][TPL:A][TPL:1]カレン: ねえ テム.[N]あたし とっても 不安なの.[N]父も母も 人が変わったみたい.[FIN]おねがい,わたしを たすけて.[N]どうか ここから連れだして![N]おねがい····[FIN][SFX:10][PAL:0]兵士: おひめさま···[FIN][::][TPL:1]カレン:[N]おねがい,きっと きてね,テム.[PAL:0][END]`

dialogstring_04C962 `[TPL:A][JMP:&ec0A_kara.dialogstring_04C8CD+M]`

dialogstring_04C967 `[TPL:B][TPL:1]カレン:[N]やっぱり きてくれたのね![N]どうもありがとう.[FIN]外の兵隊さん,ねてたでしょう?[N]じつは 彼の むかしのあだ名,[N]鼻ちょうちん っていうのよ.[N]今も ねむってばっかり.[FIN][TPL:0]テム:[N]きみのコブタが きてくれて···[FIN][TPL:1]カレン: ペギーっていうの.[N]かわいいでしょう?[FIN][TPL:1]カレン: とっても かしこい子よ.[N]ちょっとばかり 不思議な力も[N]あるし···[FIN]さあ, わたしを ここから[N]連れだして![PAL:0][END]`

code_04CA50 {
    COP [BranchIfFlagByte] ( #22, #01, &code_04CACD )
    COP [SolidHighAbs] ( #1E, #2D )
    COP [SolidHighAbs] ( #1F, #2D )
    COP [SolidHighAbs] ( #20, #2D )
    COP [SolidHighAbs] ( #21, #2D )

  code_04CA66:
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #1E, #2C, #22, #2D, &code_04CA71 )
    RTL 
}

code_04CA71 {
    COP [BranchIfButton] ( #$0400, &code_04CA7C )
    COP [SetEntryExitNow] ( @code_04CA66 )
}

code_04CA7C {
    COP [BranchIfFlagByte] ( #01, #00, &code_04CA89 )
    COP [BranchIfNoItem] ( #0A, &code_04CA9B )
    BRA loc_04CA92
}

code_04CA89 {
    COP [PrintDialogString] ( &dialogstring_04CACF )
    COP [SetEntryExitNow] ( @code_04CA66 )

  loc_04CA92:
    COP [PrintDialogString] ( &dialogstring_04CAF9 )
    COP [SetEntryExitNow] ( @code_04CA66 )
}

code_04CA9B {
    COP [SetFlagByte] ( #22 )
    COP [SetFlagWord] ( #$0119 )
    COP [PrintDialogString] ( &dialogstring_04CB41 )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0402
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0104, #$0334, #00, #02 )
    COP [QueueMapChange] ( #06, #$0058, #$01C0, #00, #$2110 )
    COP [SetEntryContinue]
    RTL 
}

code_04CACD {
    COP [Die]
}

dialogstring_04CACF `[TPL:A][TPL:0]テム:[N](いや カレンを 連れ出すなら[N]今のうちだな···)[END]`

dialogstring_04CAF9 `[TPL:A][TPL:1]カレン: あ そうだっ![N]長旅に なるかもしれないし[N]食べ物を 持っていきましょ.[FIN]地下室へ いってくれない?[PAL:0][END]`

dialogstring_04CB41 `[TPL:A][TPL:1]カレン:[N]さあ. いよいよ 出発ね.[FIN]まずは テムの家へ行ってみましょ.[N]ローラおばあさまやビルおじいさまの[N]ことが 心配だわ.[FIN][DLG:3,6][SIZ:D,3,0][PAL:0]二人は テムの家へと足をはやめた.[END]`