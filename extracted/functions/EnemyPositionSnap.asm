; Grid-snap helper for COP SnapToGrid (#43) (Bank 0A, 697255-697341). It is not a function that is called: SnapToGrid saves the script's resume address in snapResumePtr ($7F1018) and the bank in $7F101A, then rewrites the COP return frame so that its RTI lands here, and ResumeAfterSnap (#4A) at the end restores them. SnapToGrid only redirects when ((X - 8) OR Y) AND $0F is non-zero; it first clears the movement override chain ($2C / $2E). The five script sites are av6D_steelbones (1), ec0C_ribber (1) and sg4D_cyber (3).
; 
; Targets: X = the nearest value that is 8 (mod 16), a tile centre (actor X is the centre, so the alignment test is (X - 8) AND $0F); Y = the nearest multiple of 16 (a tie at 8 rounds up). Both go to moveXAlt / moveYAlt and MoveToward (#FF, #01) glides there at 1 px per frame while keeping the current animation (#FF). #01 is a speed in px/frame, so the old 'max speed' wording was wrong and the glide is slow. When it ends the alignment is tested again and the targets are recomputed if the test fails (the actor was pushed or the glide was cut short).
; 
; The hit and dodge callbacks ($7F1000 / $7F1002) are cleared on entry so a hit or dodge cannot redirect the actor's entry pointer during the glide. Nothing in this routine restores them; the callers re-arm them later (ec0C_ribber and av6D_steelbones also write SetHitCallback #0000 around their snap).
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002

---------------------------------------------

EnemyPositionSnap {
    LDA #$0000            ; Clear the hit and dodge callbacks so no hit or dodge can redirect the actor's entry pointer during the glide
    STA $onDodgeCallback, X
    STA $onHitCallback, X

  loc_0AA3B2:
    LDA $14               ; Target X: nearest value that is 8 (mod 16), a tile centre; the alignment test uses (X - 8) AND $0F
    SEC 
    SBC #$0008            ; v = X - 8; bit 3 of v says which half of its 16-px cell X lies in
    BIT #$0008            ; Check which half of tile
    BEQ loc_0AA3C6
    AND #$FFF0            ; Upper half: floor16(v) + $18 = the next tile centre to the east
    CLC 
    ADC #$0018
    BRA loc_0AA3CD

  loc_0AA3C6:
    AND #$FFF0            ; Lower half: floor16(v) + $08 = this cell's tile centre
    CLC 
    ADC #$0008

  loc_0AA3CD:
    STA $moveXAlt, X      ; Set X target
    LDA $16               ; Target Y: nearest multiple of 16 (the Y line); no centre offset on Y
    BIT #$0008
    BEQ loc_0AA3E1
    AND #$FFF0            ; Upper half: floor16(Y) + $10 (a tie at 8 rounds up)
    CLC 
    ADC #$0010
    BRA loc_0AA3E4

  loc_0AA3E1:
    AND #$FFF0            ; Lower half: floor16(Y)

  loc_0AA3E4:
    STA $moveYAlt, X      ; Set Y target
    COP [SetEntryHere]    ; Re-entry point = the MoveToward below (that COP yields every frame while it glides)
    COP [MoveToward] ( #FF, #01 ) ; Glide to (moveXAlt, moveYAlt): #FF = keep the current animation, speed 1 px per frame (not 'max speed')
    LDA $14               ; Check if aligned: (X-8) | Y low nibble = 0?
    SEC 
    SBC #$0008
    ORA $16
    BIT #$000F
    BNE loc_0AA3B2        ; Not aligned (pushed, or the glide was cut short): recompute the targets
    COP [ResumeAfterSnap] ; Aligned: restore the script address and bank saved by SnapToGrid and continue the interrupted script
}