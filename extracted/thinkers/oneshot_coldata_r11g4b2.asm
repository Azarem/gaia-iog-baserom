; One-shot thinker (filter word $0800) that sets the PPU fixed colour (COLDATA $2132) to R = 11, G = 4, B = 2 with three writes, then kills itself.
; 
; COLDATA: bit $20 selects red, $40 green, $80 blue, the low five bits are the intensity; a write only changes the channels whose bits are set. $2B sets red to 11, $44 sets green to 4, $82 sets blue to 2. The fixed colour is red-dominant: if CGADSUB adds it the cast is orange-red, if it subtracts it the screen loses mostly red and looks green-cyan. This thinker does not touch CGWSEL / CGADSUB (the scene's display preset does), so the screen looks green-cyan only for a subtract preset; the name states the three channel intensities (R 11, G 4, B 2).
; 
; Spawned only by scene thinker list $0CE80C for scene $30 (slot $00 in tables/scene_thinkers.asm; scene $01 enters the same list four bytes later and skips it). Scene names are not decoded, so no scene-group name is given. Whether this runs before a warm palette cycler takes over is not traced: the same list also spawns two ambient_palette_cycler thinkers and a flag_gated_palette_warm thinker, and UploadCgramPalette rewrites COLDATA from backdropColors ($7F0C00-02) every NMI (bytes without channel bits change nothing, scene_lifecycle zeroes them at setup).
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

oneshot_coldata_r11g4b2 [
  thinker-def < #00, #08, {

  code_00B6E7:
    SEP #$20              ; 8-bit A for the COLDATA writes
    LDA #$2B              ; $2B = red channel bit ($20) with intensity 11
    STA $COLDATA          ; COLDATA: red fixed colour = 11
    LDA #$44              ; $44 = green channel bit ($40) with intensity 4
    STA $COLDATA          ; COLDATA: green fixed colour = 4
    LDA #$82              ; $82 = blue channel bit ($80) with intensity 2
    STA $COLDATA          ; COLDATA: blue fixed colour = 2; result R11 G4 B2
    REP #$20              ; Back to 16-bit A before the COP
    COP [KillThinker]     ; One-shot: remove this thinker from the list
    RTL 
} >
]