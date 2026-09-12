!joypadMaskStd                  065A
!jewelsCollected                0AB0

---------------------------------------------

wa79_kara [
  actor-def < #1D, #00, #10, {

  code_07A53A:
    COP [BranchIfFlagByte] ( #94, #01, &code_07A59E )
    COP [BranchIfFlagByte] ( #97, #01, &code_07A5F6 )
    COP [BranchIfFlagByte] ( #96, #01, &code_07A5ED )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #91, #01, &code_07A5A0 )
    COP [SetOnInteract] ( &code_07A5FF )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #28 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_07A860, #$0010, #$FFF2, #$1002 )
    COP [StageSpriteLoop] ( #1D, #3C )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_07A6AF )
    COP [SetFlagByte] ( #03 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A59E {
    COP [Die]
}

code_07A5A0 {
    COP [BranchIfFlagByte] ( #92, #01, &code_07A5E1 )
    COP [GiveItem] ( #16, &code_07A5AD )
    BRA code_07A5CB
}

code_07A5AD {
    COP [BranchIfNoItem] ( #01, &code_07A5B7 )
    COP [BranchIfNoItem] ( #06, &code_07A5E8 )
}

code_07A5B7 {
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 

  loc_07A5C6:
    COP [GiveItem] ( #16, &code_07A5CB )
}

code_07A5CB {
    COP [SetFlagByte] ( #92 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07A79C )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_07A5E1 {
    COP [SetOnInteract] ( &code_07A604 )
    COP [SetEntryContinue]
    RTL 
}

code_07A5E8 {
    COP [RemoveItem] ( #06 )
    BRA loc_07A5C6
}

code_07A5ED {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A609 )
    COP [SetEntryContinue]
    RTL 
}

code_07A5F6 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A60E )
    COP [SetEntryContinue]
    RTL 
}

code_07A5FF {
    COP [PrintDialogString] ( &dialogstring_07A613 )
    RTL 
}

code_07A604 {
    COP [PrintDialogString] ( &dialogstring_07A7E2 )
    RTL 
}

code_07A609 {
    COP [PrintDialogString] ( &dialogstring_07A811 )
    RTL 
}

code_07A60E {
    COP [PrintDialogString] ( &dialogstring_07A833 )
    RTL 
}

dialogstring_07A613 `[TPL:B][TPL:1][SFX:1B]Kara: Watermia is very [N]pretty, but I've heard [N]a terrible rumor. [FIN]They play games with[N]human lives...[FIN]Freejia was the same [N]way, but beautiful. [N]Things always have [N]another side to them...[PAL:0][END]`

dialogstring_07A6AF `[TPL:A][TPL:1][SFX:1B]Kara: [N]Yes. Birthday cake! [N]Neil made it. [FIN][TPL:6][SFX:1A]Neil: Ha ha ha. [N]My first cake. [FIN]It was harder than[N]building an airplane.[FIN][TPL:2][SFX:19]Lilly:[N]Thank you, everyone . . .[FIN]I'm the luckiest[N]girl in the world.[FIN][TPL:0][SFX:10]So began Lilly's[N]little birthday[N]party.[FIN]The end of the party...[PAL:0][END]`

dialogstring_07A79C `[TPL:A][TPL:0]Will:[N]So in the morning...[FIN]When I awoke, Lance [N]had disappeared...[PAL:0][END]`

dialogstring_07A7E2 `[TPL:A][TPL:1]Kara: [N]What happened to Lance [N]and Lilly? I'm worried.[PAL:0][END]`

dialogstring_07A811 `[TPL:A][TPL:1]Kara: [N]A Kruk is an odd animal.[PAL:0][END]`

dialogstring_07A833 `[TPL:B][TPL:1]Kara: [N]Neil's family runs [N]a trading company in[N]Euro.[PAL:0][END]`

code_07A860 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #37, #20, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}