?BANK 04

!joypadMaskStd                  065A
!playerYPos                     09A4

---------------------------------------------

sc02_entry [
  actor-def < #00, #00, #30, {

  code_04BE3B:
    COP [BranchIfFlagByte] ( #15, #01, &code_04BE57 )
    COP [SetFlagByte] ( #15 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04BE87 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04BE57 {
    COP [SetEntryContinue]
    LDA $playerYPos
    CMP #$00D0
    BEQ loc_04BE62
    RTL 

  loc_04BE62:
    COP [BranchIfFlagByte] ( #04, #01, &code_04BE73 )
    COP [QueueMapChange] ( #01, #$0290, #$02B0, #03, #$4300 )
    RTL 
}

code_04BE73 {
    COP [BranchIfButton] ( #$0400, &code_04BE7E )
    COP [SetEntryExitNow] ( @code_04BE57 )
}

code_04BE7E {
    COP [PrintDialogString] ( &dialogstring_04BF35 )
    COP [SetEntryExitNow] ( @code_04BE57 )
}

dialogstring_04BE87 `[DLG:3,6][SIZ:D,4][TPL:0]It was natural for the[N]four friends to call [N]this seaside cave their[N]second home.[FIN]Usually, when lessons[N]were done at the school,[FIN]they gathered there to[N]talk and play games[N]until sundown.[PAL:0][END]`

dialogstring_04BF35 `[TPL:A][TPL:4]Lance: [N]What, Will? [N]Going home already?[FIN]It's not dinner time [N]yet. Let's play a little[N]while longer.[PAL:0][END]`