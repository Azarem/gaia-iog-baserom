!joypadMaskStd                  065A
!playerSpeedEw                  09B2

---------------------------------------------

h_sc02_entry [
  actor-def < #00, #00, #30, {

  code_04BA50:
    COP [BranchIfFlagByte] ( #15, #01, &code_04BA6C )
    COP [SetFlagByte] ( #15 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04BA9C )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04BA6C {
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$00D0
    BEQ loc_04BA77
    RTL 

  loc_04BA77:
    COP [BranchIfFlagByte] ( #04, #01, &code_04BA88 )
    COP [QueueMapChange] ( #01, #$0290, #$02B0, #03, #$4300 )
    RTL 
}

code_04BA88 {
    COP [BranchIfButton] ( #$0400, &code_04BA93 )
    COP [SetEntryExitNow] ( @code_04BA6C )
}

code_04BA93 {
    COP [PrintDialogString] ( &dialogstring_04BB02 )
    COP [SetEntryExitNow] ( @code_04BA6C )
}

dialogstring_04BA9C `[DLG:3,6][SIZ:D,3,0][TPL:0]この 海岸のどうくつは[N]ぼくらの 第2の家と言っても[N]おかしくはない.[FIN]教会での授業が 終った後は[N]たいてい ここに集まり[N]日がくれるまで 語り合う.[PAL:0][END]`

dialogstring_04BB02 `[TPL:A][TPL:4]ロブ:[N]何だよ. テム.[N]もう かえっちまうのか?[FIN]どうせ 夕食の時間は まだまだ[N]なんだから もう少し[N]遊んでこうぜ.[PAL:0][END]`