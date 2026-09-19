; Sets bit $0200 in the player actor's statusWord ($0010) to signal game-over state.
; 
; Called by death handlers to flag that the player has died. The main loop
; checks this bit to trigger the game over sequence.
---------------------------------------------

!playerActor                    09AA

---------------------------------------------

SetPlayerGameOverFlag {
    LDY $playerActor      ; Player actor DP pointer
    LDA $0010, Y
    ORA #$0200            ; Set game-over bit
    STA $0010, Y
    RTL 
}