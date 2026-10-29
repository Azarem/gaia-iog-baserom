; Enix logo palette thinker for OBJ palette 2 (Bank 00, 47207-47226): the third of the three thinkers that run the Enix logo's palette cycle, the one for the block under the emblem. Scene $FB's thinker list (thinker_spawn_0CEB1D, slot 2, param #03, never read) spawns it together with boot_logo_enix_palette_obj0 and boot_logo_enix_palette_obj1. All three run side by side in BOTH visits of the scene (sFB_boot_logo reloads the scene for the second logo).
; 
; It plays palette bundles $56, $57 and $58 in order (PaletteStart selects a bundle, PaletteStep runs it to its end), then KillThinker. The bundles write CGRAM colors $A1 to $AF, colors 1 to 15 of OBJ palette 2 (30 bytes per frame, 8 frames per bundle, 1 extra tick per frame, 33 on the last frame of $58).
; $56 (palette_bundle_enix_obj2_fill_a): starts black and fills the 15 colors with the flat purple $68DA one at a time (colors 1 to 8 over the 8 frames).
; $57 (palette_bundle_enix_obj2_fill_b): continues the fill from 9 colors to all 15 (the last two frames are both full).
; $58 (palette_bundle_enix_obj2_dip): starts all purple; a darker dip opens around color 7 and gets wider and deeper each frame, ending in a V-shaped ramp from $64B9 at the ends down to $3C4F in the middle (colors 14 and 15 stay $68DA / $70DC), which is held for 34 ticks.
; This is read from the colour values (not run).
; 
; === WHERE THE COLOURS LAND ===
; 
; OBJ palette 2 is used only by the 4 x 2 block of 16 x 16 parts under the emblem in sprite_group_000010 (parts $10 to $17 of the second logo, see spm_boot_logos). The first logo is on OBJ palette 3, which no thinker touches, so in the first visit this thinker runs unseen.
---------------------------------------------

---------------------------------------------

; Thinker, part 3 of the Enix logo palette cycle: bundles $56, $57 and $58 on OBJ palette 2 (CGRAM colors $A1 to $AF): a purple fill, then a deepening dip in the middle of the ramp.

boot_logo_enix_palette_obj2 [
  thinker-def < #00, #08, {

; Entry. Three PaletteStart / PaletteStep pairs (bundles $56, $57, $58), then KillThinker and RTL.

  BootLogoEnixObj2Entry:
    COP [PaletteStart] ( #56 ) ; Bundle $56: purple fills colors 1 to 8 of 15, one per step
    COP [PaletteStep]     ; Runs the whole bundle (the op continues when it ends)
    COP [PaletteStart] ( #57 ) ; Bundle $57: the fill continues to all 15 colors
    COP [PaletteStep]
    COP [PaletteStart] ( #58 ) ; Bundle $58: a darker dip opens in the middle; the last frame holds 33 extra ticks
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]