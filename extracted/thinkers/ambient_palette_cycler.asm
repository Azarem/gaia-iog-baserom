; Generic ambient palette animation thinker (Bank 00): 59 spawn entries in the scene spawn lists of tables/scene_thinkers.
; 
; The script is an endless loop of two COP ops. PaletteRestart (re)starts the palette bundle whose ID is already in animScratch+2; for a thinker that value is the spawn parameter byte, so nothing is hardcoded here. PaletteStep then plays the bundle: its entry point stays on that op and it yields until the last strip frame has been shown, after which execution falls through to the BRA and the whole bundle starts again. One six-byte routine therefore repeats any palette bundle forever, and a scene attaches several instances with different bundle IDs to animate independent colour ranges at once. The thinker has no flag gating and no exit of its own; it lives as long as the scene's thinkers.
; 
; Examples (bundles decoded from palette_bundles): bundle $30 (scenes 21-23) is six one-frame strips (wait value 5 each) that each rewrite a six-colour ramp starting at CGRAM colour $72, rotated by one colour per strip, i.e. a colour rotation; bundle $13 (scenes 1D and 27) is four frames of a 16-colour palette starting at colour $C0 with wait value 9 per frame. The bundle-ID list per scene is in scene_thinkers; what each bundle looks like on screen was not traced for all of them. The earlier "torch flicker, water shimmer, sky gradient" list was a guess.
---------------------------------------------

---------------------------------------------

ambient_palette_cycler [
  thinker-def < #00, #08, {

; Endless loop: PaletteRestart restarts the bundle (ID in animScratch+2 = the spawn parameter), PaletteStep plays it through, BRA restarts it.

  PaletteCycleLoop:
    COP [PaletteRestart]  ; Apply strip 0 of bundle animScratch+2 (the spawn parameter) and yield
    COP [PaletteStep]     ; Play the bundle: this op repeats each tick until the bundle has ended, then execution continues
    BRA PaletteCycleLoop  ; Bundle finished: start it again
} >
]