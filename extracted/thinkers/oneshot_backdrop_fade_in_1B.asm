; One-shot fixed-color ramp using palette bundle #1B (it plays a palette-bundle animation, but the target is the backdrop COLDATA triplet at $7F0C00, not a CGRAM palette).
; 
; Bundle #1B is one strip of 32 three-byte frames with 4 extra ticks between frames (32 × 5 = 160 ticks): the fixed color rises from black through yellow (red and green climb first; blue stays 0 until the middle of the strip) to almost white. PaletteStep keeps yielding until the whole strip has played, then KillThinker ends the thinker. Only visible while the scene has color math enabled.
; 
; Spawned in the Mu prayer room (twice) and the Edward Castle prison cell. In Mu it is followed much later by flash #1C, which fades the same color from white back to black.
---------------------------------------------

---------------------------------------------

oneshot_backdrop_fade_in_1B [
  thinker-def < #00, #08, {

; Thinker body: PaletteStart bundle $1B then PaletteStep runs the slow backdrop fixed-color ramp black toward near-white, then KillThinker and RTL.

  FadeBackdropIn1B:
    COP [PaletteStart] ( #1B ) ; Bundle #1B: backdrop fixed color black to near white, 32 frames, 5 ticks each
    COP [PaletteStep]     ; Runs the whole bundle: yields until the 32-frame strip has played, then continues
    COP [KillThinker]
    RTL 
} >
]