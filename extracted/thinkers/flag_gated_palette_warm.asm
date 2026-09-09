---------------------------------------------

flag_gated_palette_warm [
  thinker-def < #00, #08, {

  code_00B5C2:
    COP [BranchIfFlagByte] ( #1C, #01, &code_00B5DC )
    COP [BranchIfFlagByte] ( #16, #00, &code_00B5DC )

  loc_00B5CE:
    COP [PaletteStart] ( #02 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B5CE
} >
]

code_00B5DC {
    COP [KillThinker]
    RTL 
}