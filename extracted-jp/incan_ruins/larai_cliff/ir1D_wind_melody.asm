!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

h_ir1D_wind_melody [
  actor-def < #00, #00, #30, {

  code_058196:
    COP [BranchIfFlagByte] ( #32, #01, &code_0581E7 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0050, #$0170, &code_0581A7 )
    RTL 
} >
]

code_0581A7 {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PlaySoundCh1] ( #16 )
    COP [PrintDialogString] ( &dialogstring_0581EF )
    COP [StartMusic] ( #1A )
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_0581D5
    RTL 

  loc_0581D5:
    COP [GiveItem] ( #08, &code_0581E9 )
    COP [PrintDialogString] ( &dialogstring_05822A )
    COP [SetFlagByte] ( #32 )

  loc_0581E1:
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_0581E7 {
    COP [Die]
}

code_0581E9 {
    COP [PrintDialogString] ( &dialogstring_058243 )
    BRA loc_0581E1
}

dialogstring_0581EF `[TPL:10]谷風が 何かの メロディーを[N]かなでている.[N]まるで インカの石像が[N]歌っているようだ···[END]`

dialogstring_05822A `[DLG:3,11][SIZ:D,3,0]風のメロディーを 覚えた![END]`

dialogstring_058243 `[DLG:3,11][SIZ:D,3,0]風のメロディーが 聞こえる.[N]だが 持ち物が いっぱいだった.[END]`