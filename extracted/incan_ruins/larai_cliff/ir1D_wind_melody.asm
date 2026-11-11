; Wind Melody event at Larai Cliff (scene $1D).
; 
; With flag $32 set at spawn the actor dies. Otherwise it polls BranchIfPlayerAt for the exact pixel (0050,0170). On a match it locks the joypad ($EFFC), waits #1D, starts music #1B, waits #77, plays sound #16 on channel 1, prints 'The wind in the valley plays a melody. The statue seems to be singing...', starts music #1A, waits #77 and then polls APUIO1 until it reads $FF. Then it calls GiveItem #08 (Wind Melody): on success it prints 'You've learned the Melody of the Wind!' and sets $32; with a full inventory it prints the 'inventory is full' text and leaves $32 clear, so the event repeats on the next visit. Both paths unlock the joypad and die.
---------------------------------------------

!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

ir1D_wind_melody [
  actor-def < #00, #00, #30, {

  code_09C57C:
    COP [BranchOnFlagByte] ( #32, #01, &code_09C5CD )
    COP [SetEntryHere]
    COP [BranchIfPlayerAt] ( #$0050, #$0170, &code_09C58D )
    RTL 
} >
]

code_09C58D {
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    COP [PlaySoundCh1] ( #16 )
    COP [PrintDialogString] ( &dialogstring_09C5D5 )
    COP [StartMusic] ( #1A )
    COP [WaitByte] ( #77 )
    COP [SetEntryHere]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_09C5BB
    RTL 

  loc_09C5BB:
    COP [GiveItem] ( #08, &code_09C5CF )
    COP [PrintDialogString] ( &dialogstring_09C614 )
    COP [SetFlagByte] ( #32 )

  loc_09C5C7:
    LDA #$EFFC
    TRB $joypadMaskStd
}

code_09C5CD {
    COP [Die]
}

code_09C5CF {
    COP [PrintDialogString] ( &dialogstring_09C637 )
    BRA loc_09C5C7
}

dialogstring_09C5D5 `[TPL:10]The wind in the valley[N]plays a melody.[N]The statue seems to[N]be singing...[END]`

dialogstring_09C614 `[DLG:3,11][SIZ:D,3]You've learned the[N]Melody of the Wind![END]`

dialogstring_09C637 `[DLG:3,11][SIZ:D,3]You can hear the Melody [N]of the Wind. But your [N]inventory is full. [END]`