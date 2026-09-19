; Unused random position generator.
; 
; Sets $14/$16 to random values (X: 0..255, Y: 0..510), $08 = $3C.
; Similar to RandomPlayerOffset but without centering on the player.
; No references.
---------------------------------------------

?BANK 0A

---------------------------------------------

unused_random_position_noref {
    COP [RngByte]
    STA $14
    COP [RngByte]
    ASL 
    STA $16
    LDA #$003C
    STA $08
    RTL 
}