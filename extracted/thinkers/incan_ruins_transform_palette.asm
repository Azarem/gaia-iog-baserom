; Multi-phase palette thinker for the Incan Ruins transformation sequence.
; 
; Default state loops palette #1A; flag $4D triggers palettes #34 then #33; flag $52 enters the final phase that fills CGRAM buffer entries, applies palette #36, and kills sibling thinkers. Spawned on Incan Ruins scenes $2B, $2C, and related entries in scene_thinkers. Drives the visual transformation when the ruins change after story events.
---------------------------------------------

!cgramPalette                   7F0A00

---------------------------------------------

incan_ruins_transform_palette [
  thinker-def < #00, #08, {

  code_00B673:
    COP [BranchIfFlagByte] ( #52, #01, &IncanRuinsTransformPaletteFinal ) ; Ruins fully transformed?
    COP [BranchIfFlagByte] ( #4D, #01, &IncanRuinsTransformPaletteWarmup ) ; Transformation starting?

  loc_00B67F:
    COP [PaletteStart] ( #1A ) ; Default state: loop normal ruins palette
    COP [PaletteStep]
    BRA loc_00B67F
} >
]

---------------------------------------------
; Warmup phase: alternate between palette #34 and #33 until flag $FF clears

IncanRuinsTransformPaletteWarmup {
    COP [PaletteStart] ( #34 ) ; First warmup palette
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )

  code_00B68E:
    COP [PaletteStart] ( #33 ) ; Second warmup palette
    COP [PaletteStep]
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B68E ) ; Loop #33 while flag $FF set
    BRA IncanRuinsTransformPaletteWarmup ; Restart cycle
}

---------------------------------------------
; Final phase: kill sibling thinkers, fill CGRAM with transformed palette, loop #36

IncanRuinsTransformPaletteFinal {
    PHX 
    LDX $005A             ; Sibling thinker slot
    COP [KillThinker]     ; Kill first sibling
    TXA 
    CLC 
    ADC #$0010            ; Next thinker slot (+$10)
    TAX 
    COP [KillThinker]     ; Kill second sibling
    PLX 

  loc_00B6AA:
    PHX 
    LDA #$1421            ; Transformed ruins palette color value
    LDX #$0000

  loc_00B6B1:
    STA $7F0A40, X        ; Fill 16 CGRAM entries ($40–$5F) with color
    INX 
    INX 
    CPX #$0020            ; 16 words = $20 bytes
    BNE loc_00B6B1
    PLX 
    LDA #$1442            ; Set main CGRAM palette entry
    STA $cgramPalette
    COP [PaletteStart] ( #36 ) ; Final transformation palette
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 ) ; Exit when flag $FF cleared by scene
    BRA loc_00B6AA        ; Loop until stopped
}