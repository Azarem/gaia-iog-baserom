; Snaps an enemy actor to the nearest 16x16 tile grid position using MoveToward.
; 
; Clears hit/dodge callbacks, then enters a loop: computes the nearest grid-
; aligned target (rounding X with 8px bias, Y to 16px boundary), sets moveXAlt/
; moveYAlt as the target, and calls MoveToward at max speed. Loops until both
; X and Y are aligned to grid (low 4 bits = 0). Called after spawning enemies
; to ensure they start exactly on-grid for collision and tile alignment.
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002

---------------------------------------------

EnemyPositionSnap {
    LDA #$0000            ; Clear combat callbacks
    STA $onDodgeCallback, X
    STA $onHitCallback, X

  loc_0AA3B2:
    LDA $14               ; Compute nearest X grid position
    SEC 
    SBC #$0008            ; Offset by half-tile for rounding
    BIT #$0008            ; Check which half of tile
    BEQ loc_0AA3C6
    AND #$FFF0            ; Round to tile + $18 (upper half)
    CLC 
    ADC #$0018
    BRA loc_0AA3CD

  loc_0AA3C6:
    AND #$FFF0            ; Round to tile + $08 (lower half)
    CLC 
    ADC #$0008

  loc_0AA3CD:
    STA $moveXAlt, X      ; Set X target
    LDA $16               ; Compute nearest Y grid position
    BIT #$0008
    BEQ loc_0AA3E1
    AND #$FFF0            ; Round to tile + $10
    CLC 
    ADC #$0010
    BRA loc_0AA3E4

  loc_0AA3E1:
    AND #$FFF0            ; Round to tile boundary

  loc_0AA3E4:
    STA $moveYAlt, X      ; Set Y target
    COP [SetEntryContinue]
    COP [MoveToward] ( #FF, #01 ) ; Move toward target at max speed
    LDA $14               ; Check if aligned: (X-8) | Y low nibble = 0?
    SEC 
    SBC #$0008
    ORA $16
    BIT #$000F
    BNE loc_0AA3B2        ; Not aligned → loop
    COP [ResumeAfterSnap] ; Aligned → resume normal script
}