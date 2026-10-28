; One-shot fixed-color fade using palette bundle #1C (backdrop COLDATA triplet at $7F0C00).
; 
; Bundle #1C is one strip of 32 three-byte frames, 4 extra ticks between frames (160 ticks): red, green and blue fall together from 31 to 0, a white-to-black fade. It is the counterpart of #1B (black to white). PaletteStep yields until the strip has played, then KillThinker ends the thinker. Only visible while color math is enabled.
; 
; Spawned after #1B in the Mu prayer room (the second spawn is a repeat of the sequence) and in the Edward Castle prison, and alone in the Angkor Wat snake pit entry, the Gold Ship descent and the crow-crew scene.
---------------------------------------------

---------------------------------------------

oneshot_backdrop_fade_out_1C [
  thinker-def < #00, #08, {

; Thinker body: PaletteStart bundle $1C then PaletteStep runs the backdrop white-to-black fade counterpart to bundle $1B, then KillThinker and RTL.

  FadeBackdropOut1C:
    COP [PaletteStart] ( #1C ) ; Bundle #1C: backdrop fixed color white to black, 32 frames, 5 ticks each
    COP [PaletteStep]     ; Runs the whole bundle: yields until the 32-frame strip has played, then continues
    COP [KillThinker]
    RTL 
} >
]