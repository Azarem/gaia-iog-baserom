!joypadCurrent                  0656
!joypadMaskStd                  065A

---------------------------------------------

h_ec0A_kara_guard [
  actor-def < #1D, #00, #10, {

  code_04C48C:
    COP [SetSpritePriority] ( #30 )
    COP [BranchIfFlagByte] ( #21, #01, &code_04C50E )
    COP [BranchIfFlagByte] ( #19, #01, &code_04C4D3 )
    COP [BranchIfFlagByte] ( #1A, #01, &code_04C4D3 )
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #FF )
    COP [SolidHighOffset] ( #00, #01 )
    COP [SetOnInteract] ( &code_04C519 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04C57D )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04C4D3 {
    COP [SetOnInteract] ( &code_04C527 )
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04C64C )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #19, #01 )

  loc_04C4FE:
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_04C50E {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04C54A )
    BRA loc_04C4FE
}

code_04C519 {
    COP [PrintDialogString] ( &dialogstring_04C54F )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

code_04C527 {
    COP [BranchIfFlagByte] ( #19, #01, &code_04C532 )
    COP [PrintDialogString] ( &dialogstring_04C619 )
    RTL 
}

code_04C532 {
    COP [PrintDialogString] ( &dialogstring_04C62C )
    COP [ClearLowHere]
    LDA #$0008
    STA $09C0
    LDA $joypadCurrent
    ORA #$0100
    STA $joypadCurrent
    COP [SolidHighHere]
    RTL 
}

code_04C54A {
    COP [PrintDialogString] ( &dialogstring_04C665 )
    RTL 
}

dialogstring_04C54F `[TPL:A]兵士:[N]ここは ひめさまのお部屋.[N]見知らぬ者を 通すわけにはいかん.[END]`

dialogstring_04C57D `[TPL:A]兵士:[N]うすよごれた 平民の少年です.[FIN][TPL:0]テム:[N]ぼくだよ,カレン![FIN][TPL:1]カレン:[N]あ··· その声は···[FIN]通しなさい. さもないと[N]あなたの むかしのあだ名を[N]バラすわよ.[FIN][PAL:0][SFX:10]兵士: うわッ.[N]そ,それだけは ごかんべんを![N]どうぞ お通りください.[END]`

dialogstring_04C619 `[TPL:8]まいったなぁ··· ブツブツ[END]`

dialogstring_04C62C `[TPL:9]さあ 用がすんだら[N]帰った 帰った![FIN]それっ![PAU:A][CLD]`

dialogstring_04C64C `[TPL:9]兵士:[N]おひめさま,もう そろそろ···[END]`

dialogstring_04C665 `[TPL:9]兵士:[N]すぴー すぴー···[END]`