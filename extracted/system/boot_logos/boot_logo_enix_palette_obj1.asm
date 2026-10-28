; Enix logo palette thinker for OBJ palette 1 (Bank 00, 47187-47206): the second of the three thinkers that run the Enix logo's palette cycle (see boot_logo_enix_palette_obj0). Spawned together with it and boot_logo_enix_palette_obj2 by scene $FB's thinker list (thinker_spawn_0CEB1D, slot 1, param #02, never read) and run in parallel with them in both visits of the scene.
; 
; Plays palette bundles $51, $53 and $55 in order (PaletteStart + PaletteStep each), then KillThinker. The bundles (palette_bundle_enix_obj1_reveal / _whiten / _settle) hold exactly the same colour frames as $50, $52 and $54 (see boot_logo_enix_palette_obj0) but write them to CGRAM colors $91 to $9F, colors 1 to 15 of OBJ palette 1, with the same 1 / 1 / 3 extra ticks. So the effect is a black to rainbow-ramp reveal, a white flash and a settle.
; OBJ palette 1 colours 8 of the 16 parts of the 4 x 4 emblem block of the second logo (parts $00 to $04 and $0B to $0D of sprite_group_000010: the upper two rows); boot_logo_enix_palette_obj0 does the other 8 with palette 0. The first logo does not use it.
; 
; === CORRECTIONS ===
; 
; The old name was boot_logo_palette_quintet, a spawn-order name that read like a second company; this is the same Enix logo as the other two thinkers, on OBJ palette 1. The old header said it runs 'after the Enix palette sequence'; it runs at the same time. The I054 note gave the spawn param as #01; the three slots carry #01, #02 and #03 and this one is #02 (none is read). Which logo uses OBJ palette 1 (OQ-I054-1) is answered by the sprite tables: the second logo's emblem, the Enix logo.
---------------------------------------------

---------------------------------------------

; Thinker, part 2 of the Enix logo palette cycle: bundles $51, $53 and $55 on OBJ palette 1 (CGRAM colors $91 to $9F): the same reveal, flash and settle as boot_logo_enix_palette_obj0.

boot_logo_enix_palette_obj1 [
  thinker-def < #00, #08, {

; Entry. Three PaletteStart / PaletteStep pairs (bundles $51, $53, $55), then KillThinker and RTL.

  BootLogoEnixObj1Entry:
    COP [PaletteStart] ( #51 ) ; Bundle $51: reveal the ramp on OBJ palette 1 (8 steps)
    COP [PaletteStep]
    COP [PaletteStart] ( #53 ) ; Bundle $53: ramp turns white
    COP [PaletteStep]
    COP [PaletteStart] ( #55 ) ; Bundle $55: white fades back to the ramp
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]