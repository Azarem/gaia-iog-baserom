; One-shot thinker that plays palette bundle #19 to its end and then dies (Bank 00).
; 
; PaletteStart #19 applies the first frame and yields; the PaletteStep that follows re-runs every tick, copying one frame per step, and only lets the script continue when the bundle is finished, so this thinker lives for the whole bundle (not 'a single step'); KillThinker then removes it.
; 
; Bundle #19 is one 32-frame strip of 3-byte backdrop triplets (destination backdropColors $7F0C00, which the NMI writes verbatim to COLDATA $2132, the fixed colour used by colour math), 3 extra ticks between frames. Decoded (R,G,B, 0-31): it starts at (27,27,31), shifts toward red ((31,16,16) around frames 15-16: green and blue fall, red rises) and then fades linearly to (0,0,0) on frame 31. It is the second half of the flash started by oneshot_palette_flash_18, whose last frame is (27,27,31). Whether the fixed colour is visible depends on the colour-math registers the spawner set up (CGWSEL/CGADSUB).
; 
; Spawned by sE8_dark_gaia (Comet Lair), awBF_spirit_guide, awBC_blinding_light (only when the Black Crystal Glasses are equipped), mu66_rama_spirits, it15_lily and future_vision_cutscene (here without flash 18).
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_19 [
  thinker-def < #00, #08, {

  FlashPalette19:
    COP [PaletteStart] ( #19 ) ; Start bundle #19 (32-frame COLDATA strip) and yield
    COP [PaletteStep]     ; Re-runs every tick, one bundle frame per step, until the last frame is applied
    COP [KillThinker]     ; Bundle finished: remove this thinker
    RTL 
} >
]