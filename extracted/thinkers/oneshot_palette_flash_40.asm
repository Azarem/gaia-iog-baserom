; One-shot palette flash using animation index #40 for a bright white flash effect.
; 
; Spawned by Angel Village Kara scene and Seaside Palace fountain cutscene (often twice in succession). Used when a strong white-out flash is needed rather than the warmer #18/#19 pair.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_40 [
  thinker-def < #00, #08, {

  code_00B7F6:
    COP [PaletteStart] ( #40 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]