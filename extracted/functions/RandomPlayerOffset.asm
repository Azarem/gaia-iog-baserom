; Actor entry code that places the actor at a random point within -128..+127 px of the player on each axis.
; 
; Not a JSL helper: awB1_goldcap and pyDD_mummy_queen spawn it with SpawnAfterMarked( @RandomPlayerOffset, #$2000 ) and keep the child slot (TYA, then STA $26 / scratch1010+6).
; posX ($14) = playerXPos + (RngByte - $80), posY ($16) = playerYPos + (RngByte - $80), then $08 = $3C. $08 is the wait counter (wram-memory-map), so the actor skips 60 passes and runs again on the 61st tick; its entry pointer is never changed, so it should run this code again and re-roll the position: a marker that hops every 61 ticks, not a lifetime.
; UNVERIFIED-RUNTIME: the rerun from the unchanged $00 after the wait. unused_random_position_noref is an unreferenced sibling without the player offset.
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
    LDA #$003C            ; Wait counter $08 = $3C: skips 60 passes, so the entry code runs again after 61 ticks (a re-roll), not a lifetime
    STA $08
    RTL 
}