; Helper called once by CheckPlayerDeath (combat_collision) when playerHp reaches zero (Bank 00, RTL). Y = the player actor's address (CheckPlayerDeath loads it with LDY playerActor) and A is 16 bits wide.
; 
; CheckPlayerDeath has already set playerFlags $0200 (game over) and replaced the player actor's entry point ($00/$02) with GameOverSequence before it calls this routine. This routine then zeroes playerSpeedEw and playerSpeedNs (the player stops moving), zeroes the actor's $08 (the wait counter that the actor runner decrements before running a script, so a pending hold time cannot delay GameOverSequence) and ORs $0200 into the player actor's own flag word $10.
; 
; Two different $0200 bits: playerFlags $0200 = game over, set by the caller before this call (it is what CheckPlayerDeath and GlobalInputHandler test); bit $0200 of the actor's $10, set here, is a different bit. The Psycho Slider sets and clears the same actor bit. The routine writes only playerSpeedEw, playerSpeedNs and the actor's $08 and $10; it never writes playerFlags.
---------------------------------------------

!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

; Zero playerSpeedEw, playerSpeedNs and the actor's $08, then set $0200 in the actor's $10 and return. In: Y = player actor address, 16-bit A.

StopPlayerOnDeath {
    LDA #$0000            ; A = 0
    STA $playerSpeedEw    ; Stop east-west movement
    STA $playerSpeedNs    ; Stop north-south movement
    STA $0008, Y          ; Zero the actor's wait counter ($08) so GameOverSequence runs on the next tick
    LDA $0010, Y          ; Actor flag word $10
    ORA #$0200            ; Set actor bit $0200 (not the playerFlags game-over bit; no reader of this actor bit found)
    STA $0010, Y
    RTL                   ; Return to CheckPlayerDeath
}