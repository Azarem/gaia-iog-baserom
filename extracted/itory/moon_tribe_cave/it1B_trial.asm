?INCLUDE 'chunk_03BAE1'

!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

it1B_trial [
  actor-def < #00, #00, #30, {

  code_04F898:
    COP [BranchIfFlagWord] ( #$011C, #01, &code_04F902 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04F941 )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$2200
    STA $0E
    LDA #$0020
    STA $orbitAngle, X
    LDA #$003C
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $0AEC
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
    JSL $@chunk_03BAE1.func_03BAF1
    RTL 
} >
]

code_04F902 {
    COP [Die]

  loc_04F904:
    JSR $&code_04FAB2
    LDA $orbitAngle, X
    STA $0000
    JSL $@chunk_03BAE1.func_03BAF1
    LDA $0AEC
    BEQ loc_04F91E
    COP [PrintWideString] ( &widestring_04FA25 )
    COP [SetEntryContinue]
    RTL 

  loc_04F91E:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04FA65 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #1C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011C )
    COP [SetEntryContinue]
    RTL 
}

widestring_04F941 `[DLG:3,6][SIZ:D,4]Moon Tribe: This[N]is the final shape[N]of those touched[N]by the comet's light.[FIN]They are horrible[N]creatures whose hearts [N]are filled with [N]hatred and destruction.[FIN]If you can destroy them [N]within 20 seconds, I'll [N]give you the Incan [N]Statue. Ku ku ku... [END]`

widestring_04FA25 `[DLG:3,11][SIZ:D,4]Moon Tribe: [N]In that case, I can't [N]give you the statue. [N]Ku ku ku... [END]`

widestring_04FA65 `[DLG:3,11][SIZ:D,3]Moon Tribe:[N]Hey, hey! Good boy![N]Ku ku ku...[FIN]Then I'll give you [N]the Incan Statue. [END]`

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