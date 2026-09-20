; One-shot thinker that runs palette animation #19 for a single step, then exits.
; 
; Used immediately after flash #18 in many cutscenes (Angkor Wat, Mu, Itory, future vision, Comet Lair) to complete a two-phase palette flash. Also spawned alone for dramatic entrance effects.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_19 [
  thinker-def < #00, #08, {

  FlashPalette19:
    COP [PaletteStart] ( #19 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]