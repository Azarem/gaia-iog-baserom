; One-shot thinker that plays palette bundle #18 to its end and then dies (Bank 00).
; 
; PaletteStart #18 applies the first frame and yields; the PaletteStep that follows re-runs every tick, copying one frame per step, and only lets the script continue when the bundle is finished, so this thinker lives for the whole bundle (not 'a single PaletteStep'); KillThinker then removes it.
; 
; Bundle #18 is one 32-frame strip of 3-byte backdrop triplets (destination backdropColors $7F0C00, which the NMI writes verbatim to COLDATA $2132, the fixed colour used by colour math), 3 extra ticks between frames. Decoded (R,G,B, 0-31): it ramps from (0,0,0) up to (27,27,31); blue rises 2 per frame until it saturates at frame 15 while red and green keep rising by about 1 per frame, so the fixed colour is a bluish white at the end. Oneshot_palette_flash_19 starts at that colour and fades it out through red to black. Whether the fixed colour is visible depends on the colour-math registers the spawner set up: mu66_rama_spirits and it15_lily write CGWSEL/CGADSUB just before spawning it.
; 
; Spawned by sE8_dark_gaia (Comet Lair, twice), awBF_spirit_guide, awBC_blinding_light, mu66_rama_spirits and it15_lily. In awBC_blinding_light it is spawned in a loop and the follow-up flash #19 only when the Black Crystal Glasses are equipped. No spawn in an Edward Castle script exists in the extracted code (the earlier note listed one).
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_18 [
  thinker-def < #00, #08, {

  FlashPalette18:
    COP [PaletteStart] ( #18 ) ; Start bundle #18 (32-frame COLDATA strip) and yield
    COP [PaletteStep]     ; Re-runs every tick, one bundle frame per step, until the last frame is applied
    COP [KillThinker]     ; Bundle finished: remove this thinker
    RTL 
} >
]