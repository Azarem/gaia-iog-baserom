; Utility JSL that swaps an actor from display mode $2000 to $1000.
; 
; Saves the low nibble of displayModeFlags ($0E) into scratch $24,
; forces $0E = $2000, clears $2000 in statusWord ($10), and sets
; $1000 in statusWord. Used by actors transitioning from spawned
; display state to an active rendering state.
---------------------------------------------

---------------------------------------------

ActorDisplayModeSwap {
    LDA $0E               ; Extract low nibble of displayModeFlags
    AND #$000F
    STA $24               ; Save to scratch $24 for caller
    LDA #$2000
    STA $0E               ; Force displayModeFlags = $2000
    LDA #$2000
    TRB $10               ; Clear bit $2000 in statusWord
    LDA #$1000
    TSB $10               ; Set bit $1000 in statusWord
    RTL 
}