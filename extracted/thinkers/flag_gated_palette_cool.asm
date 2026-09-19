; Scene thinker that loops palette animation #4C via PaletteStart/PaletteStep until stopped.
; 
; Uses the same flag-byte gate as the warm variant ($1C set or $16 clear causes KillThinker). Spawned on many interior and Dark Space scenes from the standard ambient thinker group. Applies a cool palette tone for caves, dungeons, and dim indoor areas.
---------------------------------------------

---------------------------------------------

flag_gated_palette_cool [
  thinker-def < #00, #08, {

  code_00B5E1:
    COP [BranchIfFlagByte] ( #1C, #01, &FlagGatedPaletteCoolKill )
    COP [BranchIfFlagByte] ( #16, #00, &FlagGatedPaletteCoolKill )

  loc_00B5ED:
    COP [PaletteStart] ( #4C )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B5ED
} >
]

FlagGatedPaletteCoolKill {
    COP [KillThinker]
    RTL 
}