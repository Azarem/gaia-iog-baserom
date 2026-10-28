; One-shot fixed-color fade using palette bundle #40 (backdrop COLDATA triplet at $7F0C00).
; 
; Bundle #40 is one strip of 16 three-byte frames with 1 extra tick between frames (32 ticks): red, green and blue fall together from 31 by 2 per frame (the last step is 3) to 0, a fast white-to-black fade, so a white flash that decays. The visible result depends on the scene enabling color math: Kara's room sets CGADSUB $21 (add to BG1 and the backdrop), the fountain scene sets $03 (add to BG1 and BG2).
; 
; Spawned twice in each of the Angel Village Kara scene and the Seaside Palace fountain cutscene, with a 60-frame wait between the two spawns, so each scene shows two flashes.
---------------------------------------------

---------------------------------------------

oneshot_backdrop_fade_out_fast_40 [
  thinker-def < #00, #08, {

; Thinker body: PaletteStart bundle $40 then PaletteStep runs the fast backdrop COLDATA fade (white to black), then KillThinker and RTL.

  FadeBackdropOutFast40:
    COP [PaletteStart] ( #40 ) ; Bundle #40: backdrop fixed color white to black, 16 frames, 2 ticks each
    COP [PaletteStep]     ; Runs the whole bundle: yields until the 16-frame strip has played, then continues
    COP [KillThinker]
    RTL 
} >
]