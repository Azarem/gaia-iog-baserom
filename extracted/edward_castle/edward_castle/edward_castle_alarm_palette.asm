!COLDATA                        2132

---------------------------------------------

edward_castle_alarm_palette [
  thinker-def < #00, #08, {

  code_00B633:
    COP [BranchIfFlagByte] ( #22, #01, &code_00B65B )
    COP [BranchIfFlagByte] ( #21, #00, &code_00B65B )

  loc_00B63F:
    COP [PaletteStart] ( #05 )
    COP [PaletteStep]
    SEP #$20
    LDA #$24
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B63F
} >
]

code_00B65B {
    COP [KillThinker]
    RTL 
}