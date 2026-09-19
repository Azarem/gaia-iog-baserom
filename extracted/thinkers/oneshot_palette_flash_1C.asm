; One-shot palette flash using animation index #1C.
; 
; Spawned after #1B in Mu and Edward Castle sequences, and alone in Angkor snake pit, Gold Ship descent, and crow crew scenes. Completes the second phase of cutscene palette flashes in those areas.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_1C [
  thinker-def < #00, #08, {

  code_00B7EC:
    COP [PaletteStart] ( #1C )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]