; Moon Tribe trial in their cave (scene $1B).
; 
; With flag word $011C set at spawn the actor dies. Otherwise it locks the joypad ($CFFC), prints the challenge (the creatures touched by the comet's light; destroy them within 20 seconds to get the Incan Statue), unlocks, and runs a decimal countdown from 20 (orbitAngle = $20; orbitDiameter counts #3C ticks per second; sound #10 each second) drawn as digit sprites next to the player. When enemiesRemaining reaches 0 in time it locks the joypad ($FFFC), prints the success dialog, plays sound $0F0F, applies BG change #1C and sets $011C. When the countdown ends first it prints 'In that case, I can't give you the statue.' The trial grants no item itself; the statue is handed out by it1B_inca_statue_b (GiveItem #04).
---------------------------------------------

?INCLUDE 'oam_digit_compose'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!enemiesRemaining               0AEC
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

it1B_trial [
  actor-def < #00, #00, #30, {

  code_04F898:
    COP [BranchOnFlagWord] ( #$011C, #01, &code_04F902 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04F941 )
    LDA #$CFFC
    TRB $joypadMaskStd
    LDA #$2200
    STA $0E
    LDA #$0020
    STA $orbitAngle, X
    LDA #$003C
    STA $orbitDiameter, X
    COP [SetEntryHere]
    LDA $enemiesRemaining
    BEQ loc_04F904
    LDA $orbitDiameter, X
    DEC 
    BEQ loc_04F8D9
    STA $orbitDiameter, X
    BRA loc_04F8F3

  loc_04F8D9:
    LDA #$003C
    STA $orbitDiameter, X
    SED 
    LDA $orbitAngle, X
    SEC 
    SBC #$0001
    CLD 
    STA $orbitAngle, X
    BEQ loc_04F904
    COP [PlaySoundCh1] ( #10 )

  loc_04F8F3:
    JSR $&code_04FAB2
    LDA $orbitAngle, X
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    RTL 
} >
]

code_04F902 {
    COP [Die]

  loc_04F904:
    JSR $&code_04FAB2
    LDA $orbitAngle, X
    STA $0000
    JSL $@oam_digit_compose.ComposeDigitSprites
    LDA $enemiesRemaining
    BEQ loc_04F91E
    COP [PrintDialogString] ( &dialogstring_04FA25 )
    COP [SetEntryHere]
    RTL 

  loc_04F91E:
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04FA65 )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #1C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011C )
    COP [SetEntryHere]
    RTL 
}

dialogstring_04F941 `[DLG:3,6][SIZ:D,4]Moon Tribe: This[N]is the final shape[N]of those touched[N]by the comet's light.[FIN]They are horrible[N]creatures whose hearts [N]are filled with [N]hatred and destruction.[FIN]If you can destroy them [N]within 20 seconds, I'll [N]give you the Incan [N]Statue. Ku ku ku... [END]`

dialogstring_04FA25 `[DLG:3,11][SIZ:D,4]Moon Tribe: [N]In that case, I can't [N]give you the statue. [N]Ku ku ku... [END]`

dialogstring_04FA65 `[DLG:3,11][SIZ:D,3]Moon Tribe:[N]Hey, hey! Good boy![N]Ku ku ku...[FIN]Then I'll give you [N]the Incan Statue. [END]`

code_04FAB2 {
    LDA $playerXPos
    CLC 
    ADC #$0007
    STA $14
    LDA $playerYPos
    SEC 
    SBC #$0020
    STA $16
    RTS 
}