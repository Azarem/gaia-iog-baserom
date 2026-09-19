?INCLUDE 'hidden_red_jewel'

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

wa79_lance [
  actor-def < #03, #00, #10, {

  code_07AC7F:
    COP [BranchIfFlagByte] ( #97, #01, &code_07ACEC )
    COP [BranchIfFlagByte] ( #96, #01, &code_07ACD6 )
    COP [BranchIfFlagByte] ( #91, #01, &code_07ACD4 )
    COP [BranchIfFlagByte] ( #90, #00, &code_07ACD4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07AD31 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_07AD63 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #11 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #04 )
} >
]

code_07ACD4 {
    COP [Die]
}

code_07ACD6 {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_07AD02 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetEntryContinue]
    RTL 
}

code_07ACEC {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #F8 )
    COP [SetOnInteract] ( &code_07AD07 )
    COP [SetEntryContinue]
    RTL 
}

code_07AD02 {
    COP [PrintDialogString] ( &dialogstring_07ADA9 )
    RTL 
}

code_07AD07 {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07AD15 )
    COP [PrintDialogString] ( &dialogstring_07ADEA )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_07AD15 {
    COP [BranchIfFlagByte] ( #E2, #01, &code_07AD2C )
    COP [PrintDialogString] ( &dialogstring_07AEDE )
    COP [GiveItem] ( #01, &code_07AD28 )
    COP [SetFlagByte] ( #E2 )
    RTL 
}

code_07AD28 {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_07AD2C {
    COP [PrintDialogString] ( &dialogstring_07AFA7 )
    RTL 
}

dialogstring_07AD31 `[TPL:A][TPL:4]Lance: Let's have Lilly's [N]birthday party while [N]we're all together. [END]`

dialogstring_07AD63 `[TPL:A][TPL:4]Lance: Ah, Lilly. [N]Can I talk to you [N]for a minute? [FIN]I'll wait outside.[END]`

dialogstring_07ADA9 `[TPL:A][TPL:4]Lance: I made my father [N]very happy before. [FIN]I think he will slowly[N]recover.[PAL:0][END]`

dialogstring_07ADEA `[TPL:B][TPL:4]Lance: I'm sorry, but [N]I want to stay here. [N]I can't neglect [N]my father. [FIN]And so...[N][PAU:78]I feel a little awkward.[FIN]I wanted to spend[N]time with Lilly.[FIN]Of course, I don't feel [N]good about it. I wanted [N]to go on with everyone. [FIN]And I wanted to[N]stay with Lilly.[FIN]I've enjoyed the[N]journey. I hope[N]you're successful.[PAL:0][END]`

dialogstring_07AEDE `[TPL:B][TPL:4]Lance: [N]My father's getting [N]better every day. [FIN]Now we can talk.[N]I hope you get to[N]see your father soon.[FIN]Right. I believe you[N]have been collecting[N]Red Jewels.[FIN]I found a Red Jewel in[N]my father's possessions.[N]Please take it.[FIN][PAL:0]Will gets a Red Jewel![END]`

dialogstring_07AFA7 `[TPL:B][TPL:4]I hope you get to[N]see your father soon.[PAL:0][END]`