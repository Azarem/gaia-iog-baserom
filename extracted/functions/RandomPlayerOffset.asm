; Generates a random position near the player within ±128px on each axis.
; 
; Computes playerX + random(-128..+127) → $14, playerY + random(-128..+127) → $16.
; Sets frame counter $08 = $3C (60 frames). Used by VFX actors that need a
; randomized spawn point around the player (e.g., particle effects, spell visuals).
---------------------------------------------

!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

RandomPlayerOffset {
    COP [RngByte]         ; Random 0..255
    SEC 
    SBC #$0080            ; Center to -128..+127
    CLC 
    ADC $playerXPos
    STA $14               ; Random X near player
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $playerYPos
    STA $16               ; Random Y near player
    LDA #$003C            ; 60-frame lifetime
    STA $08
    RTL 
}