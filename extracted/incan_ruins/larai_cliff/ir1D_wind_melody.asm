!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

ir1D_wind_melody [
  actor-def < #00, #00, #30, {

  code_09C57C:
    COP [BranchIfFlagByte] ( #32, #01, &code_09C5CD )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0050, #$0170, &code_09C58D )
    RTL 
} >
]

code_09C58D {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    COP [PlaySoundCh1] ( #16 )
    COP [PrintWideString] ( &widestring_09C5D5 )
    COP [StartMusic] ( #1A )
    COP [WaitByte] ( #77 )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_09C5BB
    RTL 

  loc_09C5BB:
    COP [GiveItem] ( #08, &code_09C5CF )
    COP [PrintWideString] ( &widestring_09C614 )
    COP [SetFlagByte] ( #32 )

  loc_09C5C7:
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_09C5CD {
    COP [Die]
}

code_09C5CF {
    COP [PrintWideString] ( &widestring_09C637 )
    BRA loc_09C5C7
}

widestring_09C5D5 `[TPL:10]The wind in the valley[N]plays a melody.[N]The statue seems to[N]be singing...[END]`

widestring_09C614 `[DLG:3,11][SIZ:D,3]You've learned the[N]Melody of the Wind![END]`

widestring_09C637 `[DLG:3,11][SIZ:D,3]You can hear the Melody [N]of the Wind. But your [N]inventory is full. [END]`