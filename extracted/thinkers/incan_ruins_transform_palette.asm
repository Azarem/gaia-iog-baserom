!cgramPalette                   7F0A00

---------------------------------------------

incan_ruins_transform_palette [
  thinker-def < #00, #08, {

  code_00B673:
    COP [BranchIfFlagByte] ( #52, #01, &code_00B69B )
    COP [BranchIfFlagByte] ( #4D, #01, &code_00B686 )

  loc_00B67F:
    COP [PaletteStart] ( #1A )
    COP [PaletteStep]
    BRA loc_00B67F
} >
]

code_00B686 {
    COP [PaletteStart] ( #34 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )

  code_00B68E:
    COP [PaletteStart] ( #33 )
    COP [PaletteStep]
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B68E )
    BRA code_00B686
}

code_00B69B {
    PHX 
    LDX $005A
    COP [KillThinker]
    TXA 
    CLC 
    ADC #$0010
    TAX 
    COP [KillThinker]
    PLX 

  loc_00B6AA:
    PHX 
    LDA #$1421
    LDX #$0000

  loc_00B6B1:
    STA $7F0A40, X
    INX 
    INX 
    CPX #$0020
    BNE loc_00B6B1
    PLX 
    LDA #$1442
    STA $cgramPalette
    COP [PaletteStart] ( #36 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B6AA
}