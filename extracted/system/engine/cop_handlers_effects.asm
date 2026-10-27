; COP handlers for sine-wave HDMA effects, gravity, spiral orbits and camera panning (Bank $00, 11 COP handlers + 2 internal subroutines).
; 
; Sine HDMA. InitSineHdma (COP #5F) takes a WRAM base and a wave period n (scanlines per HDMA entry; #08–#40 observed) and builds four indirect-HDMA tables at base, +$0200, +$0400 and +$0600. Each table holds 256/n three-byte entries (line count n | $80 = repeat mode, data pointer) that all point at the same n data words at table + $0100, so one sine period repeats down the 256 scanlines. Tables 1 and 2 are the even/odd frame buffers for the horizontal scroll and tables 3 and 4 those for the vertical scroll; one BindSineHdma per axis binds the pair. TickSineHdma (COP #60) advances a delay counter and the sine phase and rebuilds the data of the current frame's buffers from a camera coordinate (BuildSineHdmaTable). BindSineHdma (COP #61) binds a table (+$0200 on odd frames) to an HDMA channel through SetupHdmaChannel_Indirect. The effect actor keeps its table base in spritesetPtr, the amplitude in $7F0008 (the spriteset bank field, unused by these non-sprite actors), the phase in retPtr1 and the delay counter in animScratch+2.
; 
; Gravity. InitGravity (COP #63) seeds the initial upward speed v0, a shift factor f and a target Y (moveYAlt = Y + tile offset × 16). TickGravity (COP #64) increments a tick counter t and sets the Y delta moveScratch2 = ((t × (t >> 1)) >> f) − v0 (ApplyMovement consumes it), returning A = $FFFF once the actor has moved down past the target Y and A = $0000 otherwise.
; 
; Spiral. InitSpiral (COP #6C) stores orbitDiameter and orbitAngle (256 angle units = one turn). SpiralStep (COP #6D) adds signed deltas to both and calls ApplyOrbitalOffsetFromRef with the reference actor in $0000 (the script stores it there first), so the actor circles or spirals around that actor. Only mu67_vampires uses them.
; 
; Camera pan. CameraPanDown/Up/Right/Left (COP #DC–#DF) move cameraTargetY/X by the step in the low nibble of $2B every call. $2A counts the calls left on the current step; when it underflows the next table word is fetched with CameraScrollStepLookup (low byte = delay → $2A, high byte = step → $2B; a zero high byte ends the table and the script resumes). They yield with PLA PLA RTL until the target reaches cameraBoundsY/X (down/right) or passes cameraOffsetY/X (up/left).
; 
; Internal: BuildSineHdmaTable generates per-scanline scroll offsets from sine_table_8bit via hardware multiply into the double-buffered WRAM tables. BuildSineLookupTable fills the two 256-word arrays sineTableA/B with amplitude-scaled sine values, guarded by displayModeFlags/animScratch2 trigger bits.
---------------------------------------------

?BANK 00

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'cop_handlers_movement'
?INCLUDE 'hardware_math'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'math_lookup_tables'

!frameCounter                   0036
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!displayModeFlags               09EC
!WRMPYA                         4202
!WRMPYB                         4203
!RDMPYL                         4216
!RDMPYH                         4217
!sineTableA                     7E8900
!sineTableB                     7E8B00
!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveYAlt                       7F001A
!moveScratch2                   7F002E
!scratch1010                    7F1010
!L_WRMPYB                       804203
!L_WRDIVL                       804204
!L_WRDIVB                       804206
!L_RDDIVL                       804214
!L_RDMPYL                       804216
!L_RDMPYH                       804217

---------------------------------------------

; COP #5F with one word (WRAM table base) and one byte (wave period n, scanlines per HDMA entry). Builds the four indirect-HDMA tables described in the block note: 256/n entries each, line count n | $80 (repeat mode), every entry pointing at the same n data words at table + $0100. Scales the entry count with UnsignedDivide, caches the base in spritesetPtr and resets the delay counter (animScratch+2) and phase (retPtr1) to 0.
; 
; In this build the handler also stores the post-operand script pointer in the actor's $00/$02 entry fields before RTI (the two untagged LDA $0C / STA $02 / LDA $0A / STA $00 lines come from a transforms.json patch).

InitSineHdma {
    PHY 
    PHB 
    TYX                   ; X = actor slot (Y and DBR were pushed above)
    LDA [$0A]             ; Read WRAM base operand — root of four $0200-byte HDMA indirect tables
    INC $0A
    INC $0A
    STA $0062
    STA $spritesetPtr, X  ; Cache the table base in spritesetPtr (repurposed) for BuildSineHdmaTable
    CLC 
    ADC #$0200            ; Table 2 at base+$0200; the four bases go to the global scratch $0062, $005E, $0006, $0008
    STA $005E
    CLC 
    ADC #$0200            ; Table 3 at base+$0400
    STA $0006
    CLC 
    ADC #$0200            ; Table 4 at base+$0600
    STA $0008
    LDA [$0A]             ; Read the wave period n: scanlines per HDMA entry (#08–#40 observed)
    INC $0A
    AND #$00FF
    STA $0E
    ORA #$0080            ; Line-count byte = n | $80: repeat mode, each of the n lines reads its own data word
    STA $0004
    LDA $0E
    ASL 
    STA $0E               ; $0E = 2n: byte length of one data table (n words)
    LSR 
    DEC 
    STA $animScratch, X   ; animScratch = n − 1 (not read by these handlers)
    LDA $0E
    LSR 
    LDY #$0100            ; Y = $0100 (dividend), A = n (divisor)
    JSL $@hardware_math.UnsignedDivide ; A = $0100 / n = HDMA entries per table (covers 256 scanlines)
    AND #$00FF
    STA $000E
    ASL                   ; ×3: each entry is 3 bytes (line count + data pointer word); $000E = header bytes per table
    CLC 
    ADC $000E
    STA $000E
    SEP #$20
    LDA #$7E              ; Set DBR to $7E for WRAM table writes
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    LDA $62
    CLC 
    ADC #$0100            ; Data words sit at table base + $0100; table 2 data is $0200 further (STA $02 below)
    STA $00
    CLC 
    ADC #$0200
    STA $02
    LDY #$0000

  loc_009BFD:
    LDA $04               ; Fill loop: write 3-byte HDMA entries (line count + data pointer) to all four tables; every entry points at the same n data words, so the wave repeats every n lines
    STA ($62), Y
    STA ($5E), Y
    STA ($06), Y
    STA ($08), Y
    INY 
    LDA $00
    STA ($62), Y
    LDA $02
    STA ($5E), Y
    CLC 
    ADC #$0200
    STA ($06), Y
    CLC 
    ADC #$0200
    STA ($08), Y
    INY 
    INY 
    CPY $0E
    BNE loc_009BFD
    LDA #$0000            ; Zero delay counter and sine phase — wave starts from phase 0
    STA $5E
    STA $animScratch+2, X
    STA $retPtr1, X
    PLB 
    PLA 
    TAX 
    TCD 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #60 with one byte (delay) and one byte (camera offset). Counts down animScratch+2; on underflow it reloads the delay from the first operand and adds 1 to the sine phase (retPtr1), so the phase advances once every delay + 1 calls. Then reads the second operand as a byte offset into the camera scroll words (cameraTargetX/Y + offset; #02 in every observed call; bit 7 set masks the offset to its low nibble) and rebuilds the HDMA data with BuildSineHdmaTable.

TickSineHdma {
    TYX 
    LDA $animScratch+2, X ; Read delay counter from animScratch+2
    DEC                   ; Decrement delay; underflow reloads from operand and advances sine phase
    BPL loc_009C58
    LDA [$0A]             ; Reload delay from operand on underflow
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    LDA $retPtr1, X       ; Advance sine phase by 1 each reload cycle
    INC 
    STA $retPtr1, X
    BRA loc_009C5E

  loc_009C58:
    STA $animScratch+2, X
    INC $0A

  loc_009C5E:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Bit 7: mask low nibble for indexed cameraTarget; else use full byte as index
    BEQ loc_009C7C
    AND #$000F
    TAY 
    LDA $cameraTargetX, Y ; Camera X (cameraTargetX + offset) → $0018
    STA $0018
    LDA $cameraTargetY, Y ; Camera Y (cameraTargetY + offset) → $001C
    STA $001C
    BRA loc_009C89

  loc_009C7C:
    TAY 
    LDA $cameraTargetX, Y
    STA $0018
    LDA $cameraTargetY, Y
    STA $001C

  loc_009C89:
    JSR $&BuildSineHdmaTable ; Rebuild sine HDMA table from camera position each tick
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #61 with a long Address (table base word + bank byte, e.g. $7E8800) and a byte channel-config index (hdma_channel_config entry, #0D–#10 observed). Adds $0200 to the table address on odd frames ($0036 bit 0, the double buffer), then calls SetupHdmaChannel_Indirect with Y = table address and A = bank byte | index << 8.

BindSineHdma {
    TYX 
    LDA [$0A]             ; Read HDMA table address operand
    INC $0A
    INC $0A
    TAY 
    LDA $frameCounter     ; $0036 bit 0 = frame parity; odd frames offset table +$0200 for double-buffer
    LSR 
    BCC loc_009CA5
    TYA 
    CLC 
    ADC #$0200            ; Odd frame: offset table by $0200 for ping-pong buffer
    TAY 

  loc_009CA5:
    LDA [$0A]             ; Second operand word: bank byte (low) + hdma_channel_config index (high) → A
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect ; Y = table address, A low = indirect bank, A high = channel-config index
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #63 with one signed byte (initial upward speed v0, sign-extended), one byte (shift factor f) and one byte (target Y tile offset). Stores v0 in scratch1010+2, f in scratch1010 and zeroes the tick counter scratch1010+4. The target Y is moveYAlt = $16 + offset × 16 (here moveYAlt holds a pixel Y, not a movement index, so a later StageMoveY on the same actor overwrites it). A negative offset byte ($80–$FF) is not sign-extended: the result is $16 − byte × 16. Every observed call uses offset #00.

InitGravity {
    TYX 
    LDA [$0A]             ; Read the signed initial speed v0; sign-extend negative ($80+) to 16-bit
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009CC4
    ORA #$FF00

  loc_009CC4:
    STA $scratch1010+2, X ; scratch1010+2 = v0 (initial upward speed, px/frame)
    LDA [$0A]             ; Read acceleration factor (right-shift count for curve attenuation)
    INC $0A
    AND #$00FF
    STA $scratch1010, X   ; Acceleration factor: right-shift count that attenuates the quadratic curve
    LDA [$0A]             ; Read signed target Y tile offset byte
    INC $0A
    AND #$00FF
    ASL                   ; Tile offset × 16 = pixels (ASL ×4); the original bit 7 lands in $0800
    ASL 
    ASL 
    ASL 
    BIT #$0800            ; Original bit 7 set: negate the product (−(byte × 16), not a sign extension)
    BEQ loc_009CE7
    EOR #$FFFF
    INC 

  loc_009CE7:
    CLC                   ; Absolute target Y = current position ($16) + signed pixel offset
    ADC $16
    STA $moveYAlt, X      ; moveYAlt = target Y pixel (not a movement index here)
    LDA #$0000            ; Zero the tick counter (scratch1010+4); the Y delta grows with its square
    STA $scratch1010+4, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #64 with no operands. Increments the tick counter t and sets the Y delta moveScratch2 = ((t × (t >> 1)) >> f) − v0 using the hardware multiplier (positive = down; v0 is never updated, the curve is recomputed from t each call). RTI returns A = $FFFF once the delta is not negative, the actor's Y is not negative and Y has moved past the target in moveYAlt; otherwise A = $0000.

TickGravity {
    TYX 
    LDA $scratch1010, X   ; Load acceleration factor (→ Y for shift loop)
    TAY 
    LDA $scratch1010+4, X ; Increment tick counter; factor (in Y) controls curve attenuation via shift
    INC 
    STA $scratch1010+4, X
    SEP #$20
    STA $WRMPYA           ; Tick count → WRMPYA; tick>>1 → WRMPYB: product ≈ tick²/2
    LSR 
    STA $WRMPYB
    LDA #$00
    XBA 
    REP #$20
    LDA $RDMPYL           ; Read hardware multiply result (raw gravity magnitude)

  loc_009D1A:
    DEY                   ; Right-shift product by factor count: higher factor = gentler ramp
    BMI loc_009D20
    LSR 
    BRA loc_009D1A

  loc_009D20:
    PHA                   ; Push g = (t × t/2) >> f
    LDA $scratch1010+2, X ; v0 = initial speed (never updated)
    SEC 
    SBC $01, S            ; Stack = v0 − g
    STA $01, S
    PLA 
    EOR #$FFFF            ; Negate: Y delta = g − v0 (negative = up)
    INC 
    STA $moveScratch2, X  ; moveScratch2 = Y delta for ApplyMovement
    BMI loc_009D4A        ; Delta negative: still rising, not landed yet
    LDA $16
    BMI loc_009D4A        ; Actor Y negative (above the playfield): not landed
    LDA $moveYAlt, X      ; target − Y: a borrow means the actor is below the target → return $FFFF
    SEC 
    SBC $16
    BCS loc_009D4A        ; No borrow: target not reached yet
    LDA $0A
    STA $02, S
    LDA #$FFFF            ; A=$FFFF: signal target reached to caller
    RTI 

  loc_009D4A:
    LDA $0A
    STA $02, S
    LDA #$0000            ; Return $0000: still falling, gravity continues next frame
    RTI 
}
---------------------------------------------

; COP #6C spiral-orbit initializer taking two byte operands: starting orbitDiameter and orbitAngle (256 units = one full turn). Stores them in the actor fields $7F0012/$7F0010 for the paired SpiralStep. Does not move the actor. mu67_vampires seeds quarter-turn angles #00/#40/#80/#C0 with diameter 0, then SpiralStep (#03, #02) grows the spiral until orbitDiameter ≥ $80.

InitSpiral {
    TYX 
    LDA [$0A]             ; Read starting orbit diameter byte
    INC $0A
    AND #$00FF
    STA $orbitDiameter, X ; Store in orbitDiameter ($7F0012)
    LDA [$0A]             ; Read starting orbit angle byte
    INC $0A
    AND #$00FF
    STA $orbitAngle, X    ; Store in orbitAngle ($7F0010)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #6D with two signed byte operands (diameter delta, angle delta). Adds them to orbitDiameter and orbitAngle, then calls ApplyOrbitalOffsetFromRef with Y = the reference actor read from the global scratch $0000, which the calling script must set first (mu67_vampires does LDA $24 / STA $0000). The actor is placed at the reference actor's position plus the angle/diameter offset.

SpiralStep {
    TYX 
    LDA [$0A]             ; Read signed byte deltas, accumulate into orbitDiameter/orbitAngle, reposition
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A9BE
    ORA #$FF00

  loc_00A9BE:
    CLC 
    ADC $orbitDiameter, X ; Accumulate diameter delta into orbitDiameter
    STA $orbitDiameter, X
    LDA [$0A]             ; Read signed angle delta byte
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A9D6
    ORA #$FF00

  loc_00A9D6:
    CLC 
    ADC $orbitAngle, X    ; Accumulate angle delta into orbitAngle
    STA $orbitAngle, X
    LDY $0000             ; Y = reference actor from $0000 (the script stores it there first)
    JSL $@ApplyOrbitalOffsetFromRef ; Place the actor at the reference actor + (angle, diameter) offset
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #DC (script name PanCameraDown) southward camera pan with no operands. Decrements the frame counter $2A each call; when it underflows, loads the next scroll-table word with CameraScrollStepLookup (low byte → $2A, high byte → $2B; a zero high byte ends the table and the script resumes). Each call adds the low nibble of $2B to cameraTargetY. Yields via PLA PLA RTL until cameraTargetY reaches cameraBoundsY, then resumes the script. Called from forced_walk and other cutscene scroll actors.

CameraPanDown {
    TYX 
    LDA $2A               ; Read frame delay counter from $2A
    AND #$00FF
    DEC                   ; Decrement; negative → time to fetch next scroll step
    BMI loc_00ACF0
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ACFE

  loc_00ACF0:
    REP #$20
    JSR $&cop_handlers_movement.CameraScrollStepLookup ; Fetch the next table word: A = delay (low byte) | step (high byte)
    BCC loc_00ACFC        ; Carry clear = valid word; carry set = zero step byte (end of table) → resume script
    LDA $0A
    STA $02, S
    RTI 

  loc_00ACFC:
    STA $2A               ; Reload $2A (delay) and $2B (step) from the table word (16-bit store)

  loc_00ACFE:
    LDA $2B               ; $2B low nibble = pixel step added to cameraTargetY each pan tick
    AND #$000F
    CLC 
    ADC $cameraTargetY    ; Add step to cameraTargetY (scroll south)
    STA $cameraTargetY
    CMP $cameraBoundsY    ; Compare against cameraBoundsY (bottom limit)
    BPL loc_00AD12        ; Reached boundary → resume script
    PLA                   ; Not at cameraBoundsY — pop RTI frame and yield RTL until boundary
    PLA 
    RTL 

  loc_00AD12:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #DD with no operands. Mirrors CameraPanDown: decrements $2A, reloads the step word with CameraScrollStepLookup, subtracts the step in $2B (low nibble) from cameraTargetY, and yields until cameraTargetY drops below cameraOffsetY. If the step would exceed the current cameraTargetY the script resumes without storing it.

CameraPanUp {
    TYX 
    LDA $2A
    AND #$00FF
    DEC                   ; CameraPanUp: same pattern but subtracts from cameraTargetY
    BMI loc_00AD28
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AD36

  loc_00AD28:
    REP #$20
    JSR $&cop_handlers_movement.CameraScrollStepLookup
    BCC loc_00AD34
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD34:
    STA $2A

  loc_00AD36:
    LDA $2B
    AND #$000F
    SEC                   ; Same as PanDown but subtracts step from cameraTargetY toward cameraOffsetY
    SBC $cameraTargetY
    BEQ loc_00AD47
    BPL loc_00AD52
    EOR #$FFFF
    INC 

  loc_00AD47:
    STA $cameraTargetY
    CMP $cameraOffsetY    ; Compare against cameraOffsetY (top limit)
    BMI loc_00AD52
    PLA 
    PLA 
    RTL 

  loc_00AD52:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #DE with no operands. Decrements $2A, reloads the step word with CameraScrollStepLookup, adds the step in $2B (low nibble) to cameraTargetX, and yields until cameraTargetX reaches cameraBoundsX.

CameraPanRight {
    TYX 
    LDA $2A
    AND #$00FF
    DEC                   ; CameraPanRight: same pattern but adds to cameraTargetX
    BMI loc_00AD68
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AD76

  loc_00AD68:
    REP #$20
    JSR $&cop_handlers_movement.CameraScrollStepLookup ; Fetch the next table word: A = delay | step << 8
    BCC loc_00AD74
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD74:
    STA $2A

  loc_00AD76:
    LDA $2B               ; Same as PanDown but adds step to cameraTargetX toward cameraBoundsX
    AND #$000F
    CLC 
    ADC $cameraTargetX    ; Add step to cameraTargetX (scroll right)
    STA $cameraTargetX
    CMP $cameraBoundsX    ; Compare against cameraBoundsX (right limit)
    BPL loc_00AD8A
    PLA 
    PLA 
    RTL 

  loc_00AD8A:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #DF with no operands. Decrements $2A, reloads the step word with CameraScrollStepLookup, subtracts the step in $2B (low nibble) from cameraTargetX, and yields until cameraTargetX drops below cameraOffsetX. If the step would exceed the current cameraTargetX the script resumes without storing it.

CameraPanLeft {
    TYX 
    LDA $2A
    AND #$00FF
    DEC                   ; CameraPanLeft: same pattern subtracting from cameraTargetX
    BMI loc_00ADA0
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ADAE

  loc_00ADA0:
    REP #$20
    JSR $&cop_handlers_movement.CameraScrollStepLookup
    BCC loc_00ADAC
    LDA $0A
    STA $02, S
    RTI 

  loc_00ADAC:
    STA $2A

  loc_00ADAE:
    LDA $2B               ; Same as PanUp but subtracts from cameraTargetX toward cameraOffsetX
    AND #$000F
    SEC 
    SBC $cameraTargetX    ; Subtract step from cameraTargetX (scroll left)
    BEQ loc_00ADBF
    BPL loc_00ADCA
    EOR #$FFFF
    INC 

  loc_00ADBF:
    STA $cameraTargetX
    CMP $cameraOffsetX    ; Compare against cameraOffsetX (left limit)
    BMI loc_00ADCA
    PLA 
    PLA 
    RTL 

  loc_00ADCA:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; Internal JSR helper that fills two interleaved HDMA indirect-data tables with per-scanline scroll offsets derived from sine_table_8bit.
; 
; Computes a double-buffered WRAM table base from spritesetPtr + $0100, ping-ponging by $0200 on $0036 bit 0 (frame parity). Divides $0100 by the wave period n (half of the byte count in actor $0E) to get the sine angle step per scanline, then iterates over the n scanlines of one period: looks up sine_table_8bit at the current angle, multiplies by actor amplitude ($7F0008) via SNES hardware multiply, handles sign correction for negative sine values, and writes camera-offset scroll values into both horizontal ($62) and vertical ($5E) HDMA data regions.
; 
; Called by TickSineHdma with camera coordinates in DP $18 (X) and $1C (Y). Operates in data bank $7E with DP zeroed. Returns via RTS.

BuildSineHdmaTable {
    PHX 
    PHB 
    LDA $spritesetPtr, X  ; Double-buffered WRAM: base from spritesetPtr + $0100, secondary at +$0400
    CLC 
    ADC #$0100            ; +$0100: offset to data region past indirect headers
    STA $0062
    CLC 
    ADC #$0400            ; +$0400: second table data region for vertical
    STA $005E
    LDA $frameCounter     ; Frame parity ($0036 bit 0): offset both pointers for ping-pong buffer swap
    LSR                   ; Frame parity bit 0: swap buffers for flicker-free HDMA
    BCC loc_00ADFA
    LDA $0062
    CLC 
    ADC #$0200
    STA $0062
    CLC 
    ADC #$0400
    STA $005E

  loc_00ADFA:
    SEP #$20
    LDA $7F0008, X        ; Actor amplitude byte ($7F0008) → WRMPYA for per-scanline sine scaling
    STA $WRMPYA
    LDA #$7E              ; Set DBR to $7E for WRAM sine table writes
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    LDA $000E, X
    STA $0E               ; Store scanline count into DP $0E
    LSR 
    PHA 
    LDA #$0100            ; $0100 ÷ half-scanlines = per-scanline step through sine_table_8bit
    STA $L_WRDIVL
    PLA 
    SEP #$20
    STA $L_WRDIVB         ; WRDIVB: start hardware divide (NOPs below provide 16-cycle wait)
    LDA #$00
    XBA 
    NOP                   ; 6 NOPs: wait for SNES hardware divider latency (16 cycles)
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $L_RDDIVL         ; Read divider result: per-scanline step size
    REP #$20
    STA $00
    LDY #$0000

  loc_00AE36:
    INY                   ; Count trailing zeros in step to compute starting-angle left-shift
    LSR 
    BCC loc_00AE36
    DEY 
    LDA $retPtr1, X       ; Starting angle = (retPtr1 phase + camera Y), left-shifted by step alignment
    CLC 
    ADC $1C

  loc_00AE42:
    ASL                   ; Left-shift angle by step alignment count
    DEY 
    BNE loc_00AE42
    AND #$00FF
    TAX 
    LDY #$0000

  loc_00AE4D:
    SEP #$20              ; Per-scanline: look up sine sample, scale by amplitude, write HDMA scroll data
    LDA $@math_lookup_tables.sine_table_8bit, X ; Fetch sine sample from sine_table_8bit at current angle
    STA $L_WRMPYB         ; Per-scanline: sine sample × amplitude → HDMA scroll data
    BPL loc_00AE8F        ; Positive sine sample → simplified positive-value path
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH         ; Negative sample: signed fix-up. result = RDMPYH + low byte of (amplitude × $FF) = RDMPYH − amplitude, sign-extended (B = $FF)
    PHA 
    LDA #$FF
    STA $L_WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $L_RDMPYL
    REP #$20
    PHA                   ; Camera X added for horizontal; camera Y for vertical HDMA
    CLC                   ; Camera X added for horizontal table ($62); camera Y for vertical ($5E)
    ADC $18
    STA ($62), Y
    PLA 
    CLC 
    ADC $1C               ; Add camera Y offset for vertical HDMA table
    STA ($5E), Y
    TXA 
    CLC 
    ADC $00               ; Advance sine angle by step, wrap at 256 for circular table traversal
    AND #$00FF
    TAX 
    INY 
    INY 
    CPY $0E
    BNE loc_00AE4D
    PLB 
    PLA 
    TAX 
    TCD 
    RTS 

  loc_00AE8F:
    REP #$20              ; Return to 16-bit A for HDMA table word writes
    NOP                   ; NOP timing: wait for hardware multiply result
    LDA $L_RDMPYH
    AND #$00FF
    PHA 
    CLC 
    ADC $18
    STA ($62), Y
    PLA 
    CLC 
    ADC $1C
    STA ($5E), Y
    TXA 
    CLC 
    ADC $00
    AND #$00FF            ; Mask angle to byte for circular sine table traversal
    TAX 
    INY 
    INY 
    CPY $0E
    BNE loc_00AE4D        ; Loop until all scanlines processed
    PLB 
    PLA 
    TCD 
    TAX 
    RTS 
}

---------------------------------------------
; Internal helper that fills the 512-byte sineTableA ($7E8900) and sineTableB ($7E8B00) arrays with amplitude-scaled sine values.
; 
; Guard conditions: proceeds only if displayModeFlags bit 6 ($0040) is set or animScratch2 bit 0 ($0001) is set; clears the trigger bit after acknowledging it. This ensures tables are only regenerated when flagged as needed by the HDMA system.
; 
; Reads actor amplitude from $7F0008 into WRMPYA, then iterates 256 word entries: looks up each sine sample from sine_table_8bit at step intervals of $0E, multiplies by amplitude via hardware multiply, corrects negative samples (multiply RDMPYH by $FF, add RDMPYL for sign extension), and writes the scaled 16-bit result to both sineTableA and sineTableB at the same index.
; 
; Called by GenHdmaSine (COP #00) to populate the full sine tables used by HDMA wave effects. Returns via RTS.

BuildSineLookupTable {
    PHP 
    PHX 
    LDA $displayModeFlags ; Guard: rebuild only when displayModeFlags bit 6 or animScratch2 bit 0 set
    BIT #$0040
    BNE loc_00AED4        ; Bit 6 set: proceed to rebuild sine tables
    LDA $animScratch2, X  ; Load animScratch2 to test rebuild trigger (bit 0)
    BIT #$0001            ; Test bit 0: rebuild trigger flag in animScratch2
    BEQ loc_00AF19
    AND #$FFFE            ; Clear trigger bit after acknowledging
    STA $animScratch2, X  ; Store updated animScratch2 with trigger bit cleared
    BRA loc_00AEDA        ; Skip to shared BuildSineLookupTable entry point

  loc_00AED4:
    AND #$FFBF            ; Clear trigger flag after acknowledging rebuild request
    STA $displayModeFlags ; Store displayModeFlags with bit 6 cleared

  loc_00AEDA:
    SEP #$20              ; Switch to 8-bit A for byte-level sine table generation
    LDA $7F0008, X        ; Actor amplitude → WRMPYA for sine scaling
    STA $WRMPYA           ; Actor amplitude → WRMPYA; same scaling technique as BuildSineHdmaTable
    LDX #$0000            ; Initialize sine table loop counter X=0
    TXY 

  loc_00AEE7:
    LDA $&math_lookup_tables.sine_table_8bit, Y ; 256-entry loop: sine_table_8bit[Y] × amplitude → sineTableA/B[X] word entries
    STA $WRMPYB           ; STA WRMPYB: sine sample × amplitude
    BPL loc_00AF1C
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH           ; Negative sample: same signed fix-up as BuildSineHdmaTable (RDMPYH − amplitude, B = $FF)
    PHA 
    LDA #$FF
    STA $WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $RDMPYL
    REP #$20
    STA $sineTableA, X    ; Write scaled sine value to sineTableA ($7E8900+X)
    STA $sineTableB, X    ; Mirror to sineTableB ($7E8B00+X)
    TYA 
    SEP #$20
    CLC 
    ADC $0E               ; Advance sine index by step ($0E) for next entry
    TAY 
    INX 
    INX 
    CPX #$0200            ; Loop until 256 entries ($0200 bytes = 256 words) written
    BNE loc_00AEE7

  loc_00AF19:
    PLX 
    PLP 
    RTS 

  loc_00AF1C:
    REP #$20              ; 16-bit A for word-sized sineTable writes
    NOP 
    LDA $RDMPYH
    REP #$20
    AND #$00FF
    STA $sineTableA, X
    STA $sineTableB, X
    TYA 
    SEP #$20
    CLC 
    ADC $0E
    TAY 
    INX 
    INX 
    CPX #$0200
    BNE loc_00AEE7
    PLX 
    PLP 
    RTS 
}