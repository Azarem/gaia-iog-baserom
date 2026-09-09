!joypadMaskStd                  065A
!playerWallType                 09B0
!playerSpeedEw                  09B2

---------------------------------------------

h_sc02_card [
  actor-def < #34, #00, #10, {

  code_04ACC0:
    COP [SetSpritePriority] ( #30 )
    COP [AddPosition] ( #08, #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04ACCA {
    COP [StageSprAndHitbox] ( #38 )
    STZ $08
    COP [SetEntryContinue]
    LDA $playerWallType
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    BPL loc_04ACE1
    EOR #$FFFF
    INC 

  loc_04ACE1:
    CMP #$0008
    BCS loc_04AD01
    LDA $playerSpeedEw
    CLC 
    ADC #$000A
    SEC 
    SBC $16
    BPL loc_04ACF6
    EOR #$FFFF
    INC 

  loc_04ACF6:
    CMP #$0008
    BCS loc_04AD01
    COP [BranchIfButton] ( #$8001, &code_04AD0B )

  loc_04AD01:
    COP [BranchIfFlagByte] ( #08, #01, &code_04AD08 )
    RTL 
}

code_04AD08 {
    COP [SetEntryContinue]
    RTL 
}

code_04AD0B {
    COP [PrintWideString] ( &widestring_04AD1A )
    COP [SetFlagByte] ( #08 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [Die]
}

widestring_04AD1A `[DLG:3,6][SIZ:D,3,0]テムは カードを 拾いあげた.[FIN]それは まぎれもなく[N]ダイヤのエースだった!![END]`