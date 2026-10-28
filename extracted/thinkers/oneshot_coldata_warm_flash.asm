; One-shot thinker (filter word $0800) that sets the PPU fixed colour (COLDATA $2132) to R = 6, G = 6, B = 2 with two writes, then kills itself.
; 
; COLDATA: bit $20 selects red, $40 green, $80 blue, the low five bits are the intensity; a write only changes the channels whose bits are set. $66 sets red and green to 6, $82 sets blue to 2. Whether the colour is added or subtracted, and where, is decided by CGWSEL / CGADSUB, which this thinker does not touch (the scene's display preset sets them).
; 
; Spawned by scene thinker lists $0CE850 (scene $23, slot $02) and $0CE872 (scene $27, slot $00) in tables/scene_thinkers.asm; the earlier note named them 'Larai Cliff and related overworld scenes', which is not backed by the table (scene names are not decoded). The tint holds until another COLDATA write: UploadCgramPalette rewrites COLDATA from backdropColors ($7F0C00-02) every NMI, bytes without channel bits change nothing, and scene_lifecycle zeroes those bytes at scene setup. Palette-bundle code can target backdropColors again (OQ-I033-5).
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

oneshot_coldata_warm_flash [
  thinker-def < #00, #08, {

  code_00B660:
    SEP #$20              ; 8-bit A for the COLDATA writes
    LDA #$66              ; $66 = red + green channel bits ($20 + $40) with intensity 6
    STA $COLDATA          ; COLDATA: red and green fixed colour = 6; blue unchanged
    LDA #$82              ; $82 = blue channel bit ($80) with intensity 2
    STA $COLDATA          ; COLDATA: blue fixed colour = 2; result R6 G6 B2
    REP #$20              ; Back to 16-bit A before the COP
    COP [KillThinker]     ; One-shot: remove this thinker from the list
    RTL 
} >
]