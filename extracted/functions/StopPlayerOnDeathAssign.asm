; Death-state utility called by combat_collision when HP hits zero.
; 
; Zeros playerSpeedEw and playerSpeedNs, clears the actor frame counter, and sets flag $0200 on the player actor to freeze movement. Ensures the player stops immediately before GameOverSequence takes over the entry point.
---------------------------------------------

!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

StopPlayerOnDeathAssign {
    LDA #$0000
    STA $playerSpeedEw
    STA $playerSpeedNs
    STA $0008, Y
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}