; Palette-phase thinker of the Gold Ship wreck scenes (Bank 00, 46705-46802). The three scene_thinkers lists that spawn it are $2B (ship wreck), $2D (ship wreck interior) and $2F (adrift), all Gold Ship scenes, and the flags it reads, $4D and $52, are set and cleared by dc2F_adrift (also gs2E_sleep and gs2B_erik).
; 
; === PHASE PICK (spawn only) ===
; 
; The two flag tests run once when the thinker spawns; the loops after them never return to the tests, so the phase is fixed for the scene visit (scene $2F reloads for each adrift 'day', which re-spawns the thinker with the then-current flags). Flag $52 set: final phase. Else flag $4D set: GoldShipWreckPaletteFlag4D (bundle #34 once, then the #33 loop). Neither: default.
; 
; === DEFAULT: bundle #1A forever ===
; 
; A 12-strip palette cycle on colours $21-$2C (palette 2, colours 1-12): each strip is a 24-byte window that slides one colour at a time (wait 2-5), the peak colour $4164 a bright blue, so a highlight travels through the 12 colours. PaletteStart + PaletteStep play all strips and BRA repeats. It reads as a water glint cycle (an inference from the colours).
; 
; === FLAG $4D: GoldShipWreckPaletteFlag4D ===
; 
; Bundle #34 once (a one-shot: 16 colours at $70, palette 7, and one colour at $59), then the scene-setup latch $FF is set and bundle #33 (the same 12-strip cycle as #1A with other colour values) loops while $FF stays set. When the latch is cleared (next scene setup or inventory open) the thinker restarts with #34. #34 plays once per latch cycle.
; 
; === FLAG $52: GoldShipWreckPaletteFlag52 ===
; 
; Kills the thinker at the list head ($5A) and the one in the next pool slot (+$10): the first two thinkers spawned, which are scanline_band_hdma_thinker records 0 and 1 in all three lists (pool slots are handed out in ascending order from $0F00). KillThinker works on the slot in X and uses D only for its operand pointer, so D can stay on this thinker. Then it fills palette-buffer bytes $7F0A40-$7F0A5F, colours $20-$2F (palette 2), with $1421 (very dark blue, R1 G1 B5) so the colours the cycle used stay flat, sets colour 0 ($7F0A00) to $1442, applies bundle #36 (17 colours at $50, 16 at $70), sets $FF and waits for the latch to clear before repeating the fill and #36 (the kills are not repeated).
; 
; What $4D and $52 mean in story terms (adrift day / night / starvation phase) and what the colours depict is not decoded.
---------------------------------------------

!cgramPalette                   7F0A00

---------------------------------------------

gold_ship_wreck_palette [
  thinker-def < #00, #08, {

  code_00B673:
    COP [BranchOnFlagByte] ( #52, #01, &GoldShipWreckPaletteFlag52 ) ; Flag $52 set at spawn (Gold Ship adrift sequence): final phase
    COP [BranchOnFlagByte] ( #4D, #01, &GoldShipWreckPaletteFlag4D ) ; Flag $4D set at spawn: bundle #34 then the #33 loop. The flags are tested only here, never again while the thinker lives

  loc_00B67F:
    COP [PaletteStart] ( #1A ) ; Neither flag: bundle #1A, a 12-strip cycle on colours $21-$2C (a bright blue highlight travelling through 12 colours)
    COP [PaletteStep]     ; Plays all 12 strips (wait 2-5 each), then falls through
    BRA loc_00B67F        ; Repeat forever; the flag tests above are not run again
} >
]

---------------------------------------------
; Flag $4D phase: bundle #34 once (recolour of palette 7 and colour $59), set the latch $FF, loop bundle #33 (12-strip cycle on colours $21-$2C) while $FF is set, restart with #34 when it is cleared.

GoldShipWreckPaletteFlag4D {
    COP [PaletteStart] ( #34 ) ; One-shot recolour: bundle #34 writes 16 colours at $70 (palette 7) and 1 colour at $59
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF ) ; $FF = scene-setup latch (set when scene setup ends, cleared when it starts and when the inventory opens); set here as well

  code_00B68E:
    COP [PaletteStart] ( #33 ) ; Bundle #33: the same 12-strip cycle on colours $21-$2C as #1A, other colour values
    COP [PaletteStep]
    COP [BranchOnFlagByte] ( #FF, #01, &code_00B68E ) ; Loop #33 while the latch $FF is set; when it is cleared, fall out and restart with #34
    BRA GoldShipWreckPaletteFlag4D ; Latch cleared (next scene setup or inventory open): restart at #34
}

---------------------------------------------
; Flag $52 phase: kill the first two thinkers of the scene (the scanline-band HDMA thinkers), flatten palette 2 to a dark blue in the palette buffer, set colour 0, apply bundle #36, then wait for the latch $FF to clear and repeat the fill and #36.

GoldShipWreckPaletteFlag52 {
    PHX 
    LDX $005A             ; X = head of the thinker list: the first thinker spawned in the scene (slot $0F00)
    COP [KillThinker]     ; Kill it. KillThinker acts on X; D only supplies the operand pointer, so D can stay on this thinker
    TXA 
    CLC 
    ADC #$0010            ; Thinker slots are $10 apart and handed out in order: the second thinker spawned (slot $0F10)
    TAX 
    COP [KillThinker]     ; Kill it. In all three scene lists these two are scanline_band_hdma_thinker records 0 and 1
    PLX 

  loc_00B6AA:
    PHX                   ; Save X: the COPs below need X = this thinker's slot
    LDA #$1421            ; BGR555 $1421 = R1 G1 B5, a very dark blue
    LDX #$0000

  loc_00B6B1:
    STA $7F0A40, X        ; Fill buffer bytes $40-$5F = colours $20-$2F (palette 2) with the dark blue; flattens the colours the cycle used
    INX 
    INX 
    CPX #$0020            ; 16 words = $20 bytes
    BNE loc_00B6B1
    PLX 
    LDA #$1442            ; BGR555 $1442 = R2 G2 B5, dark blue
    STA $cgramPalette     ; Colour 0 of the palette staging buffer ($7F0A00)
    COP [PaletteStart] ( #36 ) ; Bundle #36: one-shot, 17 colours at $50 and 16 colours at $70
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF ) ; Latch $FF set again
    COP [WaitOnFlagByte] ( #FF, #00 ) ; Park until the latch is cleared (next scene setup or inventory open), then repeat the fill and #36
    BRA loc_00B6AA        ; Back to the fill, not to the kills
}