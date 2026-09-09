---------------------------------------------

flag_gated_palette_cool [
  thinker-def < #00, #08, {

  code_00B5E1:
    COP [BranchIfFlagByte] ( #1C, #01, &code_00B5FB )
    COP [BranchIfFlagByte] ( #16, #00, &code_00B5FB )

  loc_00B5ED:
    COP [PaletteStart] ( #4C )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B5ED
} >
]

code_00B5FB {
    COP [KillThinker]
    RTL 
}