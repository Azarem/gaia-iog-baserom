!joypadMaskStd                  065A

---------------------------------------------

st68_neil [
  actor-def < #12, #00, #10, {

  code_06AAD8:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06AAE4 )
} >
]

code_list_06AAE4 [
  &code_06AAEA   ;00
  &code_06AB2E   ;01
  &code_06AB30   ;02
]

code_06AAEA {
    COP [SolidHighHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06AB53 )
    COP [SetFlagByte] ( #01 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #3F )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_06AB4E )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #00, #0C, #10, &code_06AB1D )
    RTL 
}

code_06AB1D {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #03 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_06AB2E {
    COP [Die]
}

code_06AB30 {
    COP [SetTilePos] ( #18, #1A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06AD22 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06AD64 )
    COP [SetFlagByte] ( #01 )
    COP [SetEntryContinue]
    RTL 
}

code_06AB4E {
    COP [PrintDialogString] ( &dialogstring_06ACB9 )
    RTL 
}

dialogstring_06AB53 `[TPL:A][TPL:0]Five days have passed[N]since we entered[N]the tunnel.[FIN]The same scenery goes [N]on and on. It's hard to [N]keep track of time...[WAI][CLD][PAU:28][TPL:A][TPL:6]Neil: [N]Let's rest here [N]today. [FIN][TPL:3]Erik: I'm so tired. [N]I must have walked [N]500 miles today. [FIN][TPL:4]Lance: [N]This is crazy! [N]Having to walk so far! [FIN][TPL:1]Kara: Enough!! You've [N]been tired ever since [N]we started this trip. [FIN][TPL:2]Lilly: Lance's right, Kara[N]I think all of us feel the[N]same way! [FIN]Let's eat,[N]I'm hungry.[PAL:0][END]`

dialogstring_06ACB9 `[TPL:A][TPL:6]Neil: Thousands of [N]years ago people walked [N]through this tunnel. [FIN]Somehow, when I think [N]of the distant past, I [N]feel so insignificant.[PAL:0][END]`

dialogstring_06AD22 `[TPL:A][TPL:0]Two weeks since[N]entering the tunnel.[N]Still no end in sight.[PAL:0][END]`

dialogstring_06AD64 `[TPL:A][TPL:1]Kara: Last night when I [N]was sleeping I heard an [N]odd sound from above. [FIN][TPL:4]Lance: [N]Kara is very concerned [N]about that sound... [FIN]I'm too tired to[N]do anything.[PAL:0][END]`