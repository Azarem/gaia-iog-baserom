; Midpoint of two actors: posX ($14) and posY ($16) of the actor at DP $04 (A) and the actor at DP $06 (B), each summed and halved with a signed ROR (CLC / BPL / SEC before the ROR keeps the sign), stored into the caller's own $14 / $16. X is saved with PHX / PLX; Y is clobbered. Needs 16-bit A and index registers.
; 
; $04 and $06 are the actor's prevActorLink / nextActorLink (wram-memory-map). mtA0_acid_spider (code_0BA2BE) and awB0_zombie call it every frame from a SetEntryHere loop without setting either, so the child sits midway between its list neighbours; dm3D_flayzer calls it once to place a shot.
; Callers: mtA0_acid_spider (2 sites), awB0_zombie, av6E_draco (2), dm3D_flayzer, unused_mode7_boss. combat_collision does not call it; the older 'used by combat collision to find the hit point' was wrong.
; OQ-I038-3: when $06 is 0 (no successor) the B reads would hit low RAM at $0014 / $0016; whether callers guarantee a neighbour was not traced.
---------------------------------------------

---------------------------------------------

ActorMidpointCalc {
    PHX 
    LDY $04               ; Y = actor at $04 (A); $04 / $06 are prevActorLink / nextActorLink unless the caller loaded them
    LDX $06               ; X = actor at $06 (B); X was saved by the PHX above
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