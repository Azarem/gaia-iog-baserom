; COP handlers for sine-wave HDMA effects, gravity physics, spiral orbits, and camera panning (Bank $00, 11 COP handlers + 2 internal subroutines).
; 
; InitSineHdma builds four interleaved HDMA tables at a specified WRAM base, computing sine amplitudes via UnsignedDivide. TickSineHdma advances the sine table offset each frame, rebuilding from camera position. BindSineHdma binds a sine table to an HDMA channel via SetupHdmaChannel_Indirect.
; 
; InitGravity sets up gravity state: initial velocity, acceleration factor, and a target Y from a tile offset. TickGravity applies quadratic acceleration (tick×(tick/2), right-shifted by factor) via hardware multiply to update velocity, returning A=$FFFF when the actor reaches its Y target.
; 
; InitSpiral stores orbit diameter and angle. SpiralStep applies signed delta operands to diameter/angle and calls ApplyOrbitalOffsetFromRef for circular motion.
; 
; CameraPanDown/Up/Right/Left scroll cameraTargetX/Y by a step value from CameraScrollStepLookup each frame, yielding via RTL until the camera reaches bounds.
; 
; Internal: BuildSineHdmaTable generates per-scanline scroll offsets from sine_table_8bit via hardware multiply into double-buffered WRAM tables. BuildSineLookupTable fills the 512-entry sineTableA/B arrays with amplitude-scaled sine values, guarded by displayModeFlags/animScratch2 trigger bits.
---------------------------------------------

?BANK 00

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'cop_handlers_movement'
?INCLUDE 'hardware_math'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'math_lookup_tables'

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

; COP #5F with one word (WRAM base for four interleaved HDMA tables) and one byte (scanline count). Builds four staggered HDMA channel tables, scales amplitude via UnsignedDivide, and initializes sine-HDMA state in animScratch/retPtr1.

InitSineHdma {
    PHY 
    PHB 
    TYX                   ; InitSineHdma: read WRAM base for four $0200-byte HDMA tables
    LDA [$0A]             ; Read WRAM base operand — root of four $0200-byte HDMA indirect tables
    INC $0A
    INC $0A
    STA $0062
    STA $spritesetPtr, X  ; Cache base in spritesetPtr for TickSineHdma
    CLC 
    ADC #$0200            ; Compute four table bases spaced $0200 apart at DP $62/$5E/$06/$08
    STA $005E
    CLC 
    ADC #$0200            ; Table 3 at base+$0400
    STA $0006
    CLC 
    ADC #$0200            ; Table 4 at base+$0600
    STA $0008
    LDA [$0A]             ; Read scanline count byte — determines HDMA table rows
    INC $0A
    AND #$00FF
    STA $0E
    ORA #$0080            ; Set HDMA repeat bit — each scanline group replays the same data values
    STA $0004
    LDA $0E
    ASL 
    STA $0E
    LSR 
    DEC 
    STA $animScratch, X   ; Max frame index = scanline count − 1; stored in animScratch
    LDA $0E
    LSR 
    LDY #$0100            ; $0100 ÷ scanlines = entries per table; ×3 below for 3-byte HDMA entry stride
    JSL $@hardware_math.UnsignedDivide ; UnsignedDivide for HDMA table spacing
    AND #$00FF
    STA $000E
    ASL                   ; ×3: each HDMA indirect entry is 3 bytes (control + pointer word)
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
    ADC #$0100
    STA $00
    CLC 
    ADC #$0200
    STA $02
    LDY #$0000

  loc_009BFD:
    LDA $04               ; Fill loop: write 3-byte HDMA indirect entries (control + pointer) to all four tables
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
; COP #60 with one byte (delay) and one byte (camera-reference index). Decrements/reloads the delay counter in animScratch+2, advances retPtr1, selects camera X/Y from cameraTarget arrays, and rebuilds the sine HDMA table via BuildSineHdmaTable.

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
    INC                   ; Advance phase by 1 each reload
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
    LDA $cameraTargetX, Y ; Load cameraTargetX for horizontal sine offset
    STA $0018
    LDA $cameraTargetY, Y ; Load cameraTargetY for vertical sine offset
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
; COP #61 with two word operands: HDMA table address and channel configuration. Ping-pongs the table pointer by +$0200 based on $0036 bit 0, then registers the channel through SetupHdmaChannel_Indirect.

BindSineHdma {
    TYX 
    LDA [$0A]             ; Read HDMA table address operand
    INC $0A
    INC $0A
    TAY 
    LDA $0036             ; $0036 bit 0 = frame parity; odd frames offset table +$0200 for double-buffer
    LSR                   ; $0036 bit 0 = frame parity for double-buffer selection
    BCC loc_009CA5
    TYA 
    CLC 
    ADC #$0200            ; Odd frame: offset table by $0200 for ping-pong buffer
    TAY 

  loc_009CA5:
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect ; Register HDMA channel with indirect table address
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #63 with one signed byte (initial velocity), one byte (acceleration factor), and one signed byte (target Y tile offset). Seeds scratch1010 gravity state and computes the absolute target Y in moveYAlt from the actor's current $16 position.

InitGravity {
    TYX 
    LDA [$0A]             ; Read signed velocity byte; sign-extend negative ($80+) to 16-bit
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009CC4
    ORA #$FF00

  loc_009CC4:
    STA $scratch1010+2, X ; Store initial velocity in scratch1010+2
    LDA [$0A]             ; Read acceleration factor (right-shift count for curve attenuation)
    INC $0A
    AND #$00FF
    STA $scratch1010, X   ; Acceleration factor: right-shift count that attenuates the quadratic curve
    LDA [$0A]             ; Read signed target Y tile offset byte
    INC $0A
    AND #$00FF
    ASL                   ; Tile→pixel: ASL ×4 (×16); BIT #$0800 tests original sign bit for negation
    ASL 
    ASL 
    ASL 
    BIT #$0800            ; BIT $0800: test original sign for signed tile offset
    BEQ loc_009CE7
    EOR #$FFFF
    INC 

  loc_009CE7:
    CLC                   ; Absolute target Y = current position ($16) + signed pixel offset
    ADC $16
    STA $moveYAlt, X
    LDA #$0000            ; Zero tick counter; gravity acceleration grows quadratically over time
    STA $scratch1010+4, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #64 with no operands. Increments a tick counter and applies quadratic acceleration (tick² × factor) via hardware multiply to update velocity; RTI returns A=$FFFF when the actor reaches moveYAlt target, otherwise A=$0000.

TickGravity {
    TYX 
    LDA $scratch1010, X   ; Load acceleration factor into Y
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
    PHA                   ; Subtract acceleration from velocity, negate for downward movement delta
    LDA $scratch1010+2, X ; Subtract gravity from initial velocity
    SEC 
    SBC $01, S
    STA $01, S
    PLA 
    EOR #$FFFF            ; Invert gravity delta for upward bounce boundary check
    INC 
    STA $moveScratch2, X  ; Store inverted gravity as Y movement delta in moveScratch2
    BMI loc_009D4A        ; Delta still negative → actor above target, continue falling
    LDA $16
    BMI loc_009D4A
    LDA $moveYAlt, X      ; Target − current: borrow means actor passed target → return $FFFF done
    SEC 
    SBC $16
    BCS loc_009D4A
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

; COP #6C spiral-orbit initializer taking two byte operands: starting orbitDiameter and orbitAngle. Stores both values into the corresponding actor WRAM fields ($7F0010/$7F0012) for use by the paired SpiralStep COP handler. Does not move the actor itself; it only seeds orbital motion state. Used by Mu vampires bat-spawn patterns.

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
; COP #6D with two signed byte operands (diameter delta, angle delta). Adds them to orbitDiameter and orbitAngle, then calls ApplyOrbitalOffsetFromRef using the actor reference in $0000 to reposition orbitally.

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
    LDY $0000             ; Load reference actor pointer from $0000
    JSL $@ApplyOrbitalOffsetFromRef ; Apply orbital offset: sine/cosine of angle × diameter → position
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #DC (script name PanCameraDown) southward camera pan with no operands. Decrements the per-actor frame counter at $2A each invocation; when it underflows, reloads from CameraScrollStepLookup using the speed index in $2B low nibble, then adds that step to cameraTargetY. Yields via RTL until cameraTargetY reaches cameraBoundsY, then resumes the script. Called from forced_walk and other cutscene scroll actors.

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
    JSR $&cop_handlers_movement.CameraScrollStepLookup ; CameraScrollStepLookup: fetch speed from scroll table
    BCC loc_00ACFC        ; Carry clear = valid step; carry set = end of table → resume script
    LDA $0A
    STA $02, S
    RTI 

  loc_00ACFC:
    STA $2A               ; Reload frame delay from scroll step entry

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
; COP #DD with no operands. Mirrors CameraPanDown: decrements $2A, reloads scroll step from CameraScrollStepLookup via $2B low nibble, subtracts from cameraTargetY, and yields RTL until cameraTargetY reaches cameraOffsetY.

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
; COP #DE with no operands. Decrements $2A, fetches scroll step from CameraScrollStepLookup, adds to cameraTargetX, and yields RTL until cameraTargetX reaches cameraBoundsX.

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
    JSR $&cop_handlers_movement.CameraScrollStepLookup ; CameraScrollStepLookup: fetch next scroll speed from table
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
; COP #DF with no operands. Decrements $2A, fetches scroll step from CameraScrollStepLookup, subtracts from cameraTargetX, and yields RTL until cameraTargetX reaches cameraOffsetX.

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
; Computes a double-buffered WRAM table base from spritesetPtr + $0100, ping-ponging by $0200 on $0036 bit 0 (frame parity). Divides $0100 by half the scanline count to compute a per-scanline sine table step size, then iterates through all scanlines: looks up sine_table_8bit at the current angle, multiplies by actor amplitude ($7F0008) via SNES hardware multiply, handles sign correction for negative sine values, and writes camera-offset scroll values into both horizontal ($62) and vertical ($5E) HDMA data regions.
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
    LDA $0036             ; Frame parity ($0036 bit 0): offset both pointers for ping-pong buffer swap
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
    STA $L_WRDIVB         ; Wait for SNES hardware divider (16 cycles)
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
    BPL loc_00AE8F        ; WRMPYB: start hardware multiply (sine × amplitude)
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH         ; Negative sine: RDMPYH × $FF correction then combine with RDMPYL
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
    REP #$20              ; Positive sine path: RDMPYH masked to byte is the complete product
    NOP                   ; Positive sine path: RDMPYH masked is complete product
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
    AND #$00FF            ; BuildSineLookupTable: check displayModeFlags bit 6 for rebuild trigger
    TAX 
    INY 
    INY                   ; Alternate trigger: animScratch2 bit 0
    CPY $0E
    BNE loc_00AE4D        ; Nonzero: trigger bit is set, branch to process acknowledgment
    PLB 
    PLA 
    TCD 
    TAX 
    RTS                   ; Clear displayModeFlags rebuild trigger
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
    BNE loc_00AED4        ; 256-entry loop: sine_table_8bit × amplitude → sineTableA/B word entries
    LDA $animScratch2, X  ; Alternate trigger: animScratch2 bit 0
    BIT #$0001            ; Negative sine: RDMPYH × $FF correction + ADC RDMPYL
    BEQ loc_00AF19
    AND #$FFFE            ; Clear trigger bit after acknowledging
    STA $animScratch2, X  ; Write scaled sine to sineTableA ($7E8900+X)
    BRA loc_00AEDA        ; Mirror to sineTableB ($7E8B00+X)

  loc_00AED4:
    AND #$FFBF            ; Clear trigger flag after acknowledging rebuild request
    STA $displayModeFlags ; Advance sine index by step ($0E)

  loc_00AEDA:
    SEP #$20              ; Loop until 256 entries ($0200 bytes) written
    LDA $7F0008, X        ; Actor amplitude → WRMPYA for sine scaling
    STA $WRMPYA           ; Actor amplitude → WRMPYA; same scaling technique as BuildSineHdmaTable
    LDX #$0000            ; Positive sine: RDMPYH masked to byte = complete product
    TXY 

  loc_00AEE7:
    LDA $&math_lookup_tables.sine_table_8bit, Y ; 256-entry loop: sine_table_8bit[Y] × amplitude → sineTableA/B[X] word entries
    STA $WRMPYB           ; STA WRMPYB: sine sample × amplitude
    BPL loc_00AF1C
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH           ; Negative sine: RDMPYH × $FF then ADC RDMPYL for sign-extended product
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
    REP #$20              ; Positive sine: RDMPYH masked to byte is the complete unsigned product
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