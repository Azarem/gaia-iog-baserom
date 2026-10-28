; Elliptical orbit offset (Bank 00, 62514-62606). It ADDS an offset to the actor's own position ($14 / $16), computed from two independent angle / diameter pairs in the actor's extended WRAM page, so the caller must first write the orbit centre into $14 / $16 before every call (otherwise the offset accumulates). gw8A_sand_fanger reloads the centre from moveXAlt / moveYAlt, awB1_goldcap from its own WRAM fields.
; 
; Fields, one byte each, indexed by X = actor slot ($7F0010 + X ...): +0 X angle, +1 Y angle, +2 X diameter, +3 Y diameter. orbitAngle and orbitDiameter are the word views of the two pairs (low byte = X, high byte = Y). One angle step is 1.40625 degrees (256 per turn).
; 
; X offset = (|sine_table_8bit[angleX]| x diameterX) >> 8 with the sign of the table value; Y offset = the same with signed_cosine_table_8bit[angleY] and diameterY. The table peak is $7F, so each offset is about +/- diameter / 2 and the diameter is the full width of the ellipse. With equal angles the point starts below the centre (sine 0, cosine at its peak, Y grows downward) and moves right, then up, then left: counter-clockwise on screen. Different angle rates give Lissajous paths.
; 
; The sign travels in the carry flag from the table lookup through Multiply8x8Unsigned, which preserves carry. The routine clobbers A, Y and the flags; X (the actor slot) and D are preserved. It ends with A and the index registers 16-bit.
; 
; Callers (3 sites): gw8A_sand_fanger (2) and awB1_goldcap (1, where the X diameter grows by 3 and the Y diameter by 2 per step so the path spirals outward). The old header also listed statue_inventory_reward, which uses ApplyOrbitalOffsetFromRef instead.
---------------------------------------------

?INCLUDE 'hardware_math'
?INCLUDE 'math_lookup_tables'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ApplyOrbitalOffsetXY {
    LDA $orbitAngle, X    ; X angle (low byte of orbitAngle); the high byte is the Y angle, read below via $7F0011
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&math_lookup_tables.sine_table_8bit, Y ; sine_table_8bit[angleX]: the magnitude is multiplied by the diameter, the sign is kept in carry
    BPL loc_00F446
    EOR #$FF              ; Negative table value: take the magnitude (EOR #$FF, INC) and remember the sign in carry (SEC)
    INC 
    SEC 

  loc_00F446:
    XBA 
    LDA $orbitDiameter, X ; X diameter (low byte of orbitDiameter): A = diameter, B = |sine|
    JSL $@hardware_math.Multiply8x8Unsigned ; Unsigned A x B; carry (the sign) is preserved
    REP #$20
    XBA                   ; High byte of the product = |sine| x diameter / 256
    AND #$00FF
    BCC loc_00F45B        ; Carry set (negative sine): negate the offset
    EOR #$FFFF
    INC 

  loc_00F45B:
    CLC 
    ADC $14               ; X position += offset (the caller put the orbit centre in $14)
    STA $14
    LDA #$0000
    SEP #$20
    CLC 
    LDA $7F0011, X        ; Y angle (high byte of orbitAngle)
    TAY 
    LDA $&math_lookup_tables.signed_cosine_table_8bit, Y ; signed_cosine_table_8bit[angleY]: the Y axis uses the cosine table
    BPL loc_00F474
    EOR #$FF
    INC 
    SEC 

  loc_00F474:
    XBA 
    LDA $7F0013, X        ; Y diameter (high byte of orbitDiameter)
    JSL $@hardware_math.Multiply8x8Unsigned
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F489
    EOR #$FFFF
    INC 

  loc_00F489:
    CLC 
    ADC $16               ; Y position += offset: the actor ends at centre + (dx, dy)
    STA $16
    RTL 
}