; Computes the midpoint between two actors referenced by DP pointers $04 and $06.
; 
; Loads X positions ($0014) from both actors, adds them, and divides by 2 using
; a signed ROR (CLC/BPL/SEC before ROR handles sign extension). Same for Y ($0016).
; Result stored in caller's $14/$16. Used by combat collision to find the hit
; point between attacker and target.
---------------------------------------------

---------------------------------------------

ActorMidpointCalc {
    PHX 
    LDY $04               ; Actor A pointer
    LDX $06               ; Actor B pointer
    LDA $0014, Y          ; A.x + B.x
    CLC 
    ADC $0014, X
    CLC                   ; Signed divide by 2: set carry if negative
    BPL loc_0AA42C
    SEC 

  loc_0AA42C:
    ROR                   ; (A.x + B.x) / 2 → midpoint X
    STA $14
    LDA $0016, Y          ; A.y + B.y
    CLC 
    ADC $0016, X
    CLC                   ; Same signed divide for Y
    BPL loc_0AA43A
    SEC 

  loc_0AA43A:
    ROR                   ; (A.y + B.y) / 2 → midpoint Y
    STA $16
    PLX 
    RTL 
}