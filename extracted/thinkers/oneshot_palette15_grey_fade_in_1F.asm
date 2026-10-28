; One-shot palette fade using bundle #1F. Unlike #1B/#1C/#40 it does not touch the backdrop color: it writes 16 colors at CGRAM $F0 (palette 15).
; 
; Bundle #1F is one strip of 8 frames of 16 colors, 7 extra ticks between frames (64 ticks): a grey ramp (red = green = blue) that rises from almost black (only color 0 at 4/4/4) to light grey (the last frame runs from 6/6/6 up to 30/30/30). PaletteStep yields until all 8 frames have played, then KillThinker ends the thinker; the final frame stays in the palette staging buffer.
; 
; Spawned once, by the Itory Moon Tribe camp actor code_09D137 (right after it sets event flag $2A).
---------------------------------------------

---------------------------------------------

oneshot_palette15_grey_fade_in_1F [
  thinker-def < #00, #08, {

; Thinker body: PaletteStart bundle $1F then PaletteStep fades 16 grey colors into CGRAM palette 15 at $F0, then KillThinker and RTL.

  FadePalette15In1F:
    COP [PaletteStart] ( #1F ) ; Bundle #1F: 8 frames of 16 grey colors at CGRAM $F0 (palette 15), 8 ticks per frame
    COP [PaletteStep]     ; Runs the whole bundle: yields until all 8 frames have played, then continues
    COP [KillThinker]
    RTL 
} >
]