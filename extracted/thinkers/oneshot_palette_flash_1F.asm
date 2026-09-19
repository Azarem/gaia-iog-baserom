; One-shot palette flash using animation index #1F.
; 
; Spawned by the Itory Moon Tribe camp scene. Provides a single-step palette flash tied to that area's lunar/tribe event visuals.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_1F [
  thinker-def < #00, #08, {

  code_00B800:
    COP [PaletteStart] ( #1F )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]