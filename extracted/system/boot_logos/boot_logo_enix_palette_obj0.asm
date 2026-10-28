; Enix logo palette thinker for OBJ palette 0 (Bank 00, 47167-47186). The palette cycle of the Enix logo is run by three thinkers, one per OBJ palette: this one (OBJ palette 0, CGRAM colours $81-$8F, bundles $50 / $52 / $54), boot_logo_enix_palette_obj1 (OBJ palette 1, $91-$9F, bundles $51 / $53 / $55) and boot_logo_enix_palette_obj2 (OBJ palette 2, $A1-$AF, bundles $56 / $57 / $58). Scene $FB's thinker list (thinker_spawn_0CEB1D, slot 0, param #01) spawns all three together. They start with the scene and run side by side, in BOTH visits of scene $FB (sFB_boot_logo reloads the scene for the second logo), so each visit animates OBJ palettes 0, 1 and 2 at once. Only the second logo, the Enix logo (sprite_group_000010 in spm_boot_logos), uses those palettes, so only it changes colour; the first logo is on OBJ palette 3, which no thinker touches, so in the first visit these thinkers run unseen.
; 
; This thinker plays palette bundles $50, $52 and $54 in order: PaletteStart selects a bundle and PaletteStep runs it to its end (the op continues only when the bundle is finished), three times, then KillThinker. The param byte #01 is never read (PaletteStart overwrites animScratch+2 with the bundle ID). Header word $0800: bit 11 keeps it running in the lighter frame routines, bit 2 is clear (runs before the actors).
; 
; === THE BUNDLES (palette_bundles, bank $16) ===
; 
; Each bundle has 8 sub-entries of one frame each. A frame is 15 colors (30 bytes) written to CGRAM colors $81 to $8F, i.e. colors 1 to 15 of OBJ palette 0 (boot_logo_enix_palette_obj1 writes $91 to $9F, OBJ palette 1, and boot_logo_enix_palette_obj2 $A1 to $AF, OBJ palette 2). There is 1 extra tick between frames in $50 and $52 and 3 in $54.
; $50 (palette_bundle_enix_obj0_reveal): starts all black; a 13-color ramp from dark purple ($2C4B) to white ($7FFF) grows across colors 1 to 13, its white tip moving from color 1 to color 13 with the darker colors trailing it; colors 14 and 15 stay 0.
; $52 (palette_bundle_enix_obj0_whiten): the ramp turns white from its bright end towards its dark end until all 13 colors are white, while colors 14 and 15 brighten from $18C6 / $2108 to $4E73 / $6739.
; $54 (palette_bundle_enix_obj0_settle): starts all white and fades back down to the ramp (steps through $777D, $6AFA, ... to $2C4B ... $7FFF) while colors 14 and 15 darken to $1425 / $2449.
; So the logo's palette sweeps in, flashes to white and settles on a rainbow ramp: a shine effect. This is read from the colour values (not run).
; 
; === WHERE THE COLOURS LAND ===
; 
; In sprite_group_000010 (the second logo, spm_boot_logos) OBJ palette 0 colours 8 of the 16 parts of the 4 x 4 emblem block (parts $05 to $0A, $0E, $0F: the lower two rows), OBJ palette 1 the other 8 (parts $00 to $04, $0B to $0D: the upper two rows). Both get the same shine at the same time, so the emblem sweeps in, flashes white and settles.
; 
; === CORRECTIONS ===
; 
; The three thinkers were first called boot_logo_palette_enix, boot_logo_palette_quintet and boot_logo_palette_third. Those were spawn-order names and read like three companies or three steps; they are one palette cycle, the Enix logo's, split over OBJ palettes 0, 1 and 2 (the old header's 'animates the Enix logo colors' was right for all three). The old header called this the first of three thinkers and the Quintet note said it runs 'after the Enix palette sequence'; they are spawned together and run in parallel. The logo is the second logo of scene $FB, the 4 x 4 emblem with a wordmark under it; I054 left the question of which logo uses OBJ palettes 0 and 1 open (OQ-I054-1) and the sprite tables answer it.
---------------------------------------------

---------------------------------------------

; Thinker, part 1 of the Enix logo palette cycle: bundles $50, $52 and $54 on OBJ palette 0 (CGRAM colors $81 to $8F): reveal, flash to white, settle.

boot_logo_enix_palette_obj0 [
  thinker-def < #00, #08, {

; Entry. Three PaletteStart / PaletteStep pairs (bundles $50, $52, $54), then KillThinker and RTL.

  BootLogoEnixObj0Entry:
    COP [PaletteStart] ( #50 ) ; Bundle $50: reveal the ramp on OBJ palette 0 (8 steps)
    COP [PaletteStep]     ; Runs the whole bundle (the op continues when it ends)
    COP [PaletteStart] ( #52 ) ; Bundle $52: ramp turns white
    COP [PaletteStep]
    COP [PaletteStart] ( #54 ) ; Bundle $54: white fades back to the ramp (3 extra ticks per step)
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]