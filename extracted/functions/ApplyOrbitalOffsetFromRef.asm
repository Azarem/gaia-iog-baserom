; Orbit placement helper (Bank 00, 62409-62503). It sets the calling actor's position to a base point plus a circular offset: X += sin(angle) * r, Y += cos(angle) * r with r = diameter / 2. Two entries:
; - ApplyOrbitalOffsetFromRef: Y = a reference actor (slot address). Copies that actor's pixel X / Y ($0014 / $0016) into the caller's $14 / $16 first, then falls into the second entry.
; - ApplyOrbitalOffsetFromRef_AddToCurrent: skips the copy and ADDS the offset to whatever $14 / $16 already hold, so the caller must have written the centre there (otherwise the offset accumulates). It is entered from 5 sites (mtA1_fire_sprite 2, attack_ability_system, pyDD_queen_spirit_attack, unused_mode7_boss).
; 
; Inputs: X = the caller's actor slot, D = X (the DP $14 / $16 are the caller's), 16-bit A. orbitAngle ($7F0010,X) is read as a BYTE: 256 steps per turn, 1.40625 degrees each. orbitDiameter ($7F0012,X) is also read as a byte, so a diameter above 255 is not possible. The routine clobbers A, Y and the flags, keeps X and D, and returns with A 16-bit.
; 
; Arithmetic: for each axis the table value (sine_table_8bit for X, signed_cosine_table_8bit for Y, both indexed by the angle byte; the sine table is only a quarter wave and entries 64-255 read on into the cosine table) is turned into a magnitude, the sign is kept in the carry flag, the magnitude times the diameter is formed with Multiply8x8Unsigned (which preserves carry and Y), the high byte of the 16-bit product is taken (>> 8) and negated when the carry says so. The table peak is $7F, so each offset is about +/- diameter / 2 (the name 'diameter' is right: it is the full width of the circle). Angle 0 puts the actor directly BELOW the centre (cosine peak, Y grows downward); $40 is east, $80 north, $C0 west, so increasing angles turn counter-clockwise on screen.
; 
; Callers: 21 JSL sites in 11 files: attack_ability_system 2, btE4_kara, ec0E_lily, ir29_castoth, mtA1_fire_sprite 5, pyDD_queen_orb_shot, pyDD_queen_spirit_attack, cop_handlers_effects (SpiralStep, with the reference actor in $0000), item_use_system, statue_inventory_reward and unused_mode7_boss 6. 16 use the first entry and 5 the second. The elliptical variant with separate X / Y angles is ApplyOrbitalOffsetXY.
; 
; The old header said 'multiplied by orbitDiameter ... result updates actor $14/$16' without the sign, byte-width and rotation direction facts above. UNVERIFIED-RUNTIME (read from the code and the table headers).
---------------------------------------------

?INCLUDE 'hardware_math'
?INCLUDE 'math_lookup_tables'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

; First entry: copy the reference actor's pixel position (Y = its slot) into the caller's $14 / $16, then add the orbit offset.

ApplyOrbitalOffsetFromRef {
    LDA $0014, Y          ; Copy the reference actor's pixel X / Y (Y = its slot) into the caller's $14 / $16 as the orbit centre
    STA $14
    LDA $0016, Y
    STA $16

; Second entry: add the offset for the angle byte in orbitAngle and the diameter byte in orbitDiameter to the position already in $14 / $16 (no copy).

  ApplyOrbitalOffsetFromRef_AddToCurrent:
    LDA $orbitAngle, X    ; Second entry: angle word, only the low byte is used (256 steps per turn)
    AND #$00FF
    TAY 
    SEP #$20
    CLC                   ; Carry is the sign flag for the product, in both axes: clear = positive, set = negate (set when the table byte is negative)
    LDA $&math_lookup_tables.sine_table_8bit, Y ; Sine table entry for the X offset; a negative byte becomes its magnitude (EOR #$FF, INC)
    BPL loc_00F3E7
    EOR #$FF
    INC 
    SEC 

; X axis: multiply the sine magnitude by the diameter (carry = sign), keep the high byte, negate if needed.

  loc_00F3E7:
    XBA                   ; Magnitude in the high byte, diameter byte in A low; Multiply8x8Unsigned preserves carry and Y
    LDA $orbitDiameter, X
    JSL $@hardware_math.Multiply8x8Unsigned
    REP #$20              ; Product >> 8 (about diameter * sin / 2), negated when carry says so
    XBA 
    AND #$00FF
    BCC loc_00F3FC
    EOR #$FFFF
    INC 

; Add the signed X offset to $14, then repeat the same steps with the cosine table for Y.

  loc_00F3FC:
    CLC                   ; Add the signed X offset to the centre X in $14
    ADC $14
    STA $14
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.signed_cosine_table_8bit, Y ; Y axis: the same steps with the cosine table and the same index Y; the offset is added to $16
    BPL loc_00F40D
    EOR #$FF
    INC 
    SEC 

; Y axis: multiply the cosine magnitude by the diameter (carry = sign), keep the high byte, negate if needed.

  loc_00F40D:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.Multiply8x8Unsigned
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F422
    EOR #$FFFF
    INC 

; Add the signed Y offset to $16 and return.

  loc_00F422:
    CLC 
    ADC $16
    STA $16
    RTL 
}