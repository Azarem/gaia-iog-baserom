?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

e_sc02_actor_04AD52 {
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #37 )
    COP [AnimOnce]
    RTL 
}
---------------------------------------------

h_sc02_seth [
  actor-def < #33, #00, #10, {

  code_04B13E:
    COP [SpawnAfterAbsFlags] ( @e_sc02_actor_04AD52, #$00E8, #$00C0, #$0300 )
    COP [BranchIfFlagByte] ( #4C, #01, &code_04B243 )
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #20, #01, &code_04B269 )
    COP [BranchIfFlagByte] ( #16, #01, &code_04B237 )
    COP [SetOnInteract] ( &code_04B275 )
    LDA #$0800
    TSB $10

  code_04B16E:
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #00, &code_04B16E )
    LDA #$0800
    TRB $10
    LDA #$0200
    TRB $12
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [SetOnInteract] ( &code_04B27D )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0078, #$0090, &code_04B1A3 )
    RTL 
} >
]

code_04B1A3 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0000
    JSL $@chunk_008000.widestring_00C829
    COP [SetEntryExit]
    COP [PrintWideString] ( &widestring_04B317 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #05 )
    COP [SetOnInteract] ( &code_04B292 )
    LDY $06
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDY $06
    LDA $0014, Y
    CMP $orbitAngle, X
    BNE loc_04B1EA
    LDA $0016, Y
    CMP $orbitDiameter, X
    BNE loc_04B1EA
    RTL 

  loc_04B1EA:
    COP [WaitByte] ( #1F )
    COP [PrintWideString] ( &widestring_04B3FF )
    COP [SetFlagByte] ( #06 )
    COP [CallScript] ( &code_04B245 )
    COP [SetOnInteract] ( &code_04B297 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [CallScript] ( &code_04B245 )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04B46A )
    COP [SetFlagByte] ( #0A )
    LDA #$0800
    TSB $10
    LDA #$0200
    TSB $12
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #0B, #01 )
}

code_04B237 {
    COP [SetOnInteract] ( &code_04B278 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    RTL 
}

code_04B243 {
    COP [Die]
}

code_04B245 {
    COP [StageSpriteLoopMoveY] ( #14, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04B269 {
    COP [SetOnInteract] ( &code_04B282 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    RTL 
}

code_04B275 {
    COP [SetFlagByte] ( #02 )
}

code_04B278 {
    COP [PrintWideString] ( &widestring_04B29C )
    RTL 
}

code_04B27D {
    COP [PrintWideString] ( &widestring_04B2DE )
    RTL 
}

code_04B282 {
    COP [BranchIfFlagByte] ( #25, #01, &code_04B28D )
    COP [PrintWideString] ( &widestring_04B29C )
    RTL 
}

code_04B28D {
    COP [PrintWideString] ( &widestring_04B2C2 )
    RTL 
}

code_04B292 {
    COP [PrintWideString] ( &widestring_04B3D4 )
    RTL 
}

code_04B297 {
    COP [PrintWideString] ( &widestring_04B41F )
    RTL 
}

widestring_04B29C `[TPL:A][TPL:5]モリス:[N]あははっ.[N]また ぼくの勝ちに決ってますよ.[PAL:0][END]`

widestring_04B2C2 `[TPL:A][TPL:5]モリス:[N]なんでこうも 負けが···[PAL:0][END]`

widestring_04B2DE `[TPL:A][TPL:5]モリス: ぼくは 女性には[N]きょうみありませんね.[N]本を読んでた方が 楽しいですよ.[PAL:0][END]`

widestring_04B317 `[TPL:A][TPL:5]モリス:[N]さて みんな そろったし[N]今日は 何をしましょうか?[FIN][TPL:3]エリック:[N]ぼくは テムの ふしぎな力が[N]見たいなあ.[FIN]ほら いつか 見せてくれた[N]じゃない? 手をつかわないで[N]物を うごかすやつ.[FIN][TPL:4]ロブ: たしか[N]このどうくつの すみっこにある[N]石像を 動かしたんだよな.[FIN]テム.[N]もうー回見せてくれよっ.[PAL:0][END]`

widestring_04B3D4 `[TPL:A][TPL:5]モリス:[N]石像の方をむいて LRボタンを[N]おすんですよね.[PAL:0][END]`

widestring_04B3FF `[TPL:A][TPL:4]ロブ:[N]おおっ![N]うごいたああああっ!![PAL:0][PAU:28][CLD]`

widestring_04B41F `[TPL:A][TPL:5]モリス:[N]何回見ても すごいですねっ.[FIN]しかし 机とかは 動かないのに[N]なんで その石像だけは[N]動くんでしょう···[PAL:0][END]`

widestring_04B46A `[TPL:A][TPL:5]モリス:[N]チョウノウリョクって[N]いうのはですね,[FIN]言葉のとおり 人間の能力を[N]越えた力···[FIN]人間の感覚っていうのは[N]見て感じること,[FIN]聞いて感じること,[FIN]味わって感じること,[FIN]においをかいで感じること,[FIN]さわって感じること,[N]の5つだって 言われています.[FIN]チョウノウリョクっていうのは[N]6番目の力 なんじゃないかと[N]ぼくは 思っているんですけどね.[PAL:0][END]`