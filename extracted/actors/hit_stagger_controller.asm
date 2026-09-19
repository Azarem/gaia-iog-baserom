; Runtime knockback and hit-recovery controller (Bank 00) spawned on virtually every player and enemy hit via ApplyPlayerHitstun and combat_collision.asm.
; 
; HitStaggerMain copies the victim's position, reads a 3-deep stack-encoded direction index, and selects velocity curves from movement_delta_table. HitStaggerDirection runs a 16-frame SetEntryExit loop syncing victim coordinates, probing axis alignment via distance thresholds ($20/$30/$40 depending on hit-type byte).
; 
; On completion it either routes to HitStaggerReturnAI (restores PlayerIdleEntry and iframe $FFE2 for the player, or re-enables AI for enemies with $0400 set), or falls through to onHitCallback/onDeathCallback dispatch and StandardEnemyDefeatHandler when HP reaches zero. Never scene-placed; always spawned at priorities $2000–$2400.
---------------------------------------------

?INCLUDE 'movement_delta_table'
?INCLUDE 'player_character'
?INCLUDE 'StandardEnemyDefeatHandler'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!onHitCallback                  7F1000
!onDeathCallback                7F1004
!free101C                       7F101C

---------------------------------------------

HitStaggerMain {
    LDA $extendedFlags, X ; HitStaggerMain: copy attacker coords to scratch for knockback probe
    BIT #$0020
    BNE loc_00D885
    LDA #$0008
    TSB $10

  loc_00D885:
    LDA #$0008            ; Stack-encoded direction index (3 deep) selects knockback curve
    TSB $12
    LDA $12
    BIT #$0010
    BNE loc_00D8C6
    PHX 
    LDY $24
    LDA $0014, Y
    STA $orbitAngle, X
    STA $14
    LDA $0016, Y
    STA $orbitDiameter, X
    STA $16
    TYX 
    LDA $free101C, X
    PLX 
    STA $free101C, X
    LDA $0028, X
    CMP #$0004
    BCS loc_00D8C6
    PEA $&HitStaggerDirection-1
    DEC 
    BMI loc_00D8D6
    DEC 
    BMI loc_00D8E0
    DEC 
    BMI loc_00D8ED
    BRA loc_00D8FA

  loc_00D8C6:
    COP [WaitByte] ( #0F )
    LDA $10
    BIT #$0400
    BEQ loc_00D8D3
    JMP $&HitStaggerReturnAI

  loc_00D8D3:
    JMP $&HitStaggerResolveHit

  loc_00D8D6:
    LDA #$6000
    TRB $12
    SEC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 

  loc_00D8E0:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    SEC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 

  loc_00D8ED:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    CLC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 

  loc_00D8FA:
    LDA #$6000
    TRB $12
    CLC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 
}

HitStaggerDirection {
    COP [SetEntryExit]    ; HitStaggerDirection: 16-frame SetEntryExit loop syncs victim position
    COP [LoopInit] ( #10 )
    LDY $24
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [LoopNext]
    LDA $10
    BIT #$0400
    BEQ loc_00D921
    JMP $&HitStaggerReturnAI

  loc_00D921:
    LDA $10
    BIT #$0008
    BEQ HitStaggerResolveHit
    LDA $26
    BNE loc_00D95B
    LDA $orbitDiameter, X
    SEC 
    SBC $16
    BEQ HitStaggerResolveHit
    BPL loc_00D93B
    EOR #$FFFF
    INC 

  loc_00D93B:
    BIT #$000F
    BNE loc_00D945
    JSR $&HitStaggerCheckKnockbackDistance
    BCC HitStaggerResolveHit

  loc_00D945:
    LDX $24
    LDA $002C, X
    BNE loc_00D94F
    STZ $0008, X

  loc_00D94F:
    LDA #$0000
    STA $002E, X
    STA $moveScratch2, X
    BRA loc_00D98A

  loc_00D95B:
    LDA $orbitAngle, X
    SEC 
    SBC $14
    BEQ HitStaggerResolveHit
    BPL loc_00D96A
    EOR #$FFFF
    INC 

  loc_00D96A:
    BIT #$000F
    BNE loc_00D974
    JSR $&HitStaggerCheckKnockbackDistance
    BCC HitStaggerResolveHit

  loc_00D974:
    LDX $24
    LDA $002E, X
    BNE loc_00D97E
    STZ $0008, X

  loc_00D97E:
    LDA #$0000
    STA $002C, X
    STA $moveScratch1, X
}

HitStaggerResolveHit {
    LDX $24               ; ResolveHit: HP zero routes to onDeathCallback or StandardEnemyDefeatHandler

  loc_00D98A:
    LDA $currentHp, X
    BNE loc_00D9D0
    LDA $0010, X
    BIT #$0040
    BNE loc_00D9E7
    ORA #$0040
    STA $0010, X
    LDA $onDeathCallback, X
    BEQ loc_00D9BC
    STA $0000, X
    LDA $7F1006, X
    STA $0002, X
    LDA #$0000
    STA $0008, X
    STA $002C, X
    STA $002E, X
    BRA loc_00D9E7

  loc_00D9BC:
    LDA #$*StandardEnemyDefeatHandler
    STA $0002, X
    LDA #$&StandardEnemyDefeatHandler
    STA $0000, X
    LDA #$0000
    STA $0008, X
    BRA loc_00D9E7

  loc_00D9D0:
    LDA $onHitCallback, X
    BEQ loc_00D9E0
    STA $0000, X
    LDA #$0000
    STA $onHitCallback, X

  loc_00D9E0:
    LDA #$FFF4
    STA $iframeCounter, X

  loc_00D9E7:
    TDC 
    TAX 
    COP [Die]
}

HitStaggerReturnAI {
    PHX                   ; HitStaggerReturnAI: restore PlayerIdleEntry, iframe $FFE2, clear joypad $0F00
    LDX $playerActor
    LDA $playerFlags
    BIT #$0A00
    BNE loc_00DA03
    LDA #$*player_character.PlayerIdleEntry
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, X

  loc_00DA03:
    LDA #$FFE2
    STA $iframeCounter, X
    PLX 
    LDA #$0F00
    TRB $joypadMaskStd
    COP [Die]
}

HitStaggerCheckKnockbackDistance {
    STA $0000             ; Knockback distance thresholds vary by hit-type byte at $7F101C
    PEA $&HitStaggerKnockbackCallbackPass-1
    LDA $free101C, X
    BNE loc_00DA26
    LDA $0000
    CMP #$0030
    RTS 

  loc_00DA26:
    DEC 
    BNE loc_00DA30
    LDA $0000
    CMP #$0020
    RTS 

  loc_00DA30:
    DEC 
    BNE loc_00DA3A
    LDA $0000
    CMP #$0040
    RTS 

  loc_00DA3A:
    LDA $0000
    CMP #$0040
    RTS 
}

HitStaggerKnockbackCallbackPass {
    CLC 
    BNE loc_00DA45
    RTS 

  loc_00DA45:
    SEC 
    RTS 
}

HitStaggerApplyKnockbackDelta {
    PEA $&HitStaggerStoreMovementDelta-1 ; ApplyKnockbackDelta: free101C tier picks movement_delta_table row $44/$46
    LDA $free101C, X
    BNE loc_00DA54
    LDY #$0044
    RTS 

  loc_00DA54:
    DEC 
    BNE loc_00DA5B
    LDY #$0046
    RTS 

  loc_00DA5B:
    DEC 
    BNE loc_00DA62
    LDY #$0046
    RTS 

  loc_00DA62:
    LDY #$0046
    RTS 
}

HitStaggerStoreMovementDelta {
    LDA $&movement_delta_table, Y ; StoreMovementDelta: BCS sets Y-delta; BCC sets X-delta with axis flag
    BCS loc_00DA73
    STA $2C
    LDA #$0001
    STA $26
    RTS 

  loc_00DA73:
    STA $2E
    STZ $26
    RTS 
}