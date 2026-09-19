; Orbital position math helper (Bank 00) called via JSL from 15+ boss, projectile, and VFX actors including Castoth, Mummy Queen, Mountain Temple fire sprites, Lily orbit effects, player attack orbs, and item_use_system.
; 
; Given reference actor Y in Y register and angle/radius in the caller's $7F0010/$7F0012 WRAM fields, it first copies the reference actor's $14/$16 into its own DP position, then applies sine/cosine offsets using math_lookup_tables (sine_table_8bit and signed_sine_table) multiplied by orbitDiameter through hardware_math.SignedMultiply.
; 
; A secondary entry label skips the initial copy so callers can reapply rotation from an already-positioned base point. Result updates actor $14/$16 for circular or elliptical motion around a parent actor or anchor — used for satellites, orbiting flames, and spinning attack visuals.
---------------------------------------------

?INCLUDE 'hardware_math'
?INCLUDE 'math_lookup_tables'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ApplyOrbitalOffsetFromRef {
    LDA $0014, Y          ; ApplyOrbitalOffsetFromRef: index sine_table_8bit by orbitAngle for X offset
    STA $14
    LDA $0016, Y
    STA $16

  code_00F3D3:
    LDA $orbitAngle, X
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.sine_table_8bit, Y
    BPL loc_00F3E7
    EOR #$FF
    INC 
    SEC 

  loc_00F3E7:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F3FC
    EOR #$FFFF
    INC 

  loc_00F3FC:
    CLC 
    ADC $14
    STA $14
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.signed_sine_table, Y
    BPL loc_00F40D
    EOR #$FF
    INC 
    SEC 

  loc_00F40D:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F422
    EOR #$FFFF
    INC 

  loc_00F422:
    CLC                   ; Second pass uses signed_sine_table for Y offset; add results to $14/$16
    ADC $16
    STA $16
    RTL 
}