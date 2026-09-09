?INCLUDE 'chunk_3B7DD'

!joypadMaskStd                  065A
!playerWallType                 09B0
!playerSpeedEw                  09B2
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

h_it1B_trial [
  actor-def < #00, #00, #30, {

  code_04F00F:
    COP [BranchIfFlagWord] ( #$011C, #01, &code_04F079 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04F0B8 )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$2200
    STA $0E
    LDA #$0040
    STA $orbitAngle, X
    LDA #$003C
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_04F07B
    LDA $orbitDiameter, X
    DEC 
    BEQ loc_04F050
    STA $orbitDiameter, X
    BRA loc_04F06A

  loc_04F050:
    LDA #$003C
    STA $orbitDiameter, X
    SED 
    LDA $orbitAngle, X
    SEC 
    SBC #$0001
    CLD 
    STA $orbitAngle, X
    BEQ loc_04F07B
    COP [PlaySoundCh1] ( #10 )

  loc_04F06A:
    JSR $&code_04F977
    LDA $orbitAngle, X
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    RTL 
} >
]

code_04F079 {
    COP [Die]

  loc_04F07B:
    JSR $&code_04F977
    LDA $orbitAngle, X
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    LDA $0AEC
    BEQ loc_04F095
    COP [PrintWideString] ( &widestring_04F157 )
    COP [SetEntryContinue]
    RTL 

  loc_04F095:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04F192 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #1C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011C )
    COP [SetEntryContinue]
    RTL 
}

widestring_04F0B8 `[DLG:3,6][SIZ:D,4,0]月の種族:[N]ここにいるのは すい星の光を[N]あびた 生物の なれの果て.[FIN]もはや にくしみと はかいの心しか[N]もたない 悲しい 生物.[FIN]この化け物たちを 40秒以内に[N]消し去ることが できたなら[N]インカの神像を さしあげましょう.[N]クックククククク···[END]`

widestring_04F157 `[DLG:3,11][SIZ:D,4,0]月の種族:[N]それでは インカの神像は[N]さしあげられませんね.[N]クックククククク···[END]`

widestring_04F192 `[DLG:3,11][SIZ:D,3,0]月の種族:[N]おやおや りっぱな ぼうやだこと.[N]クックククククク···[FIN]それでは インカの神像を[N]さしあげましょう.[END]`
---------------------------------------------

code_04F977 {
    LDA $playerWallType
    CLC 
    ADC #$0007
    STA $14
    LDA $playerSpeedEw
    SEC 
    SBC #$0020
    STA $16
    RTS 
}