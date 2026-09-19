?INCLUDE 'sE6_gaia'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4

---------------------------------------------

ir29_transform [
  actor-def < #00, #00, #30, {

  code_09CF89:
    COP [BranchIfFlagWord] ( #$011F, #01, &code_09CFEB )
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_09CF98
    RTL 

  loc_09CF98:
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [StageBgChange] ( #1F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011F )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    LDA $characterForm
    BEQ loc_09CFE5
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_09CFED )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_FreedanToWill
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_FreedanToWill
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_09CFE5
    RTL 

  loc_09CFE5:
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_09CFEB {
    COP [Die]
}

dialogstring_09CFED `[TPL:A]After the demon [N]disappears, Will returns[N]to his original shape...[END]`