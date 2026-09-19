; Scene thinker that loops palette animation #02 via PaletteStart/PaletteStep until stopped.
; 
; Runs only while flag byte $1C is clear and flag byte $16 is set; when either condition flips it kills itself. Spawned on South Cape overworld group alongside the green tint and ambient cycler thinkers. Provides a warm palette transition used during overworld/daytime palette shifts.
---------------------------------------------

---------------------------------------------

flag_gated_palette_warm [
  thinker-def < #00, #08, {

  code_00B5C2:
    COP [BranchIfFlagByte] ( #1C, #01, &FlagGatedPaletteWarmKill )
    COP [BranchIfFlagByte] ( #16, #00, &FlagGatedPaletteWarmKill )

  loc_00B5CE:
    COP [PaletteStart] ( #02 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B5CE
} >
]

FlagGatedPaletteWarmKill {
    COP [KillThinker]
    RTL 
}