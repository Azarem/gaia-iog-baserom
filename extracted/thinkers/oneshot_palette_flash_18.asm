; Minimal one-shot thinker that runs palette animation #18 for a single PaletteStep, then kills itself.
; 
; Spawned dynamically by cutscene actors during bright-flash moments (Angkor Wat shrine, Mu spirits, Itory Lily, Comet Lair, Edward Castle, and others). Typically paired with oneshot_palette_flash_19 for a warm-then-cool flash sequence.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_18 [
  thinker-def < #00, #08, {

  code_00B7CE:
    COP [PaletteStart] ( #18 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]