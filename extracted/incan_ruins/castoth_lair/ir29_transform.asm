; Aftermath actor of the Castoth fight (scene $29, scene row ;04).
; 
; With flag word $011F set at spawn it dies. Otherwise it waits until enemiesRemaining ($0AEC) is 0, locks the joypad ($EFFC), applies BG change #1F, sets $011F, fades to music #1B and waits #77. When characterForm is 0 (Will) it only unlocks the joypad. For any other form it locks the joypad ($CFFC), waits #59, prints 'After the demon disappears, Will returns to his original shape...', unlocks, sets the player actor's code pointer to sE6_gaia.Transform_FreedanToWill, sets playerFlags bit $0800, waits until that bit clears and unlocks the joypad ($EFFC).
---------------------------------------------

?INCLUDE 'sE6_gaia'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!enemiesRemaining               0AEC

---------------------------------------------

ir29_transform [
  actor-def < #00, #00, #30, {

  code_09CF89:
    COP [BranchOnFlagWord] ( #$011F, #01, &code_09CFEB )
    COP [SetEntryHere]
    LDA $enemiesRemaining
    BEQ loc_09CF98
    RTL 

  loc_09CF98:
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [StageBgChange] ( #1F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011F )
    COP [FadeThenStartMusic] ( #1B )
    COP [WaitByte] ( #77 )
    LDA $characterForm
    BEQ loc_09CFE5
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_09CFED )
    LDA #$CFFC
    TRB $joypadMaskStd
    LDY $playerActor
    LDA #$*sE6_gaia.Transform_FreedanToWill
    STA $0002, Y
    LDA #$&sE6_gaia.Transform_FreedanToWill
    STA $0000, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryHere]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_09CFE5
    RTL 

  loc_09CFE5:
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]

code_09CFEB {
    COP [Die]
}

dialogstring_09CFED `[TPL:A]After the demon [N]disappears, Will returns[N]to his original shape...[END]`