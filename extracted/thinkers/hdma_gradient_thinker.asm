; HDMA gradient/window thinker — generates diamond-shaped brightness gradients for screen
; effects during ending credits. Double-buffered: alternates between $7E7000 and $7E7100
; via chatPtr bit 0 (even/odd frame).
; 
; Two thinker variants:
;   crF7_thinker_05FB16 — simple mode: just queues the current HDMA buffer each frame.
;   thinker_def_05FB32 — full mode: compares current vs previous brightness parameters
;     ($F4/$F6 = intensity, $F8/$FA = radius, $FC/$FE = center offset), and if any changed,
;     regenerates the gradient pattern via HdmaGradientBuildV2 then updates the stored state.
; 
; The gradient generation (HdmaGradientBuildV1 for variant 1, HdmaGradientBuildV2 for variant 2) builds an
; HDMA scanline table describing a symmetric diamond/rhombus brightness pattern. It writes
; pairs of brightness values (add/subtract from base intensity $F4) at symmetric offsets
; from the center row, creating a vertically symmetric gradient window.
; 
; Helper routines:
;   HdmaSegmentSplitDown — splits a large vertical extent into max-127 HDMA segments (downward)
;   HdmaSegmentSplitUp — same, but for upward segments (sets bit 7 for direction flag)
;   HdmaParamChangeCheck — checks if parameters changed since last frame; toggles double buffer
;   HdmaNoChange — returns carry set (no change detected)
;   HdmaInitPrevState — initializes previous-state registers ($F4/$F8/$FC) to zero
;   HdmaCompareParams — compares current vs previous state; carry clear = changed
;   HdmaCopyCurrentToPrev — copies current state to previous state
---------------------------------------------

!tileStagingBuffer              7E7000
!chatPtr                        7F000A

---------------------------------------------

crF7_thinker_05FB16 [
  thinker-def < #04, #08, {

  HdmaGradientSimpleEntry:
    COP [SetEntryContinue]
    JSR $&HdmaGradientBuildV1 ; Regenerate gradient into current buffer
    LDA $chatPtr, X       ; Double-buffer select: odd/even frame
    LSR 
    BCC loc_05FB2B
    COP [QueueHdma] ( $7E7000, #26 ) ; Queue buffer A
    RTL 

  loc_05FB2B:
    COP [QueueHdma] ( $7E7100, #26 ) ; Queue buffer B
    RTL 
} >
]

thinker_def_05FB32 [
  thinker-def < #04, #08, {

  HdmaGradientFullEntry:
    JSR $&HdmaInitPrevState ; Clear previous-state registers on first frame
    COP [SetEntryContinue]
    JSR $&HdmaCompareParams ; Check if parameters changed
    BCS loc_05FB44        ; No change — skip regeneration
    JSR $&HdmaGradientBuildV2 ; Regenerate gradient pattern
    JSR $&HdmaCopyCurrentToPrev ; Update stored previous state

  loc_05FB44:
    LDA $chatPtr, X       ; Double-buffer select
    LSR 
    BCC loc_05FB52
    COP [QueueHdma] ( $7E7000, #26 ) ; Queue buffer A
    RTL 

  loc_05FB52:
    COP [QueueHdma] ( $7E7100, #26 ) ; Queue buffer B
    RTL 
} >
]

---------------------------------------------
; Gradient builder (variant 1) — build diamond brightness pattern in WRAM buffer

HdmaGradientBuildV1 {
    PHX 
    PHD 
    PHB 
    LDA #$0000            ; Set DP to page 0
    TCD 
    SEP #$20
    LDA #$7E              ; DBR = $7E (WRAM)
    PHA 
    PLB 
    REP #$20
    JSR $&HdmaParamChangeCheck ; Check for param change + toggle buffer
    BCC loc_05FB70        ; Changed — regenerate
    JMP $&HdmaGradientExitV1 ; No change — exit

  loc_05FB70:
    LDY $02
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA $FE
    BPL loc_05FB8A
    JMP $&HdmaGradientExitV1

  loc_05FB8A:
    AND #$FFFE
    STA $FC
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FB9D
    LDA #$00FE
    STA $1A

  loc_05FB9D:
    LDA $F8
    ASL 
    SEC 
    SBC $18
    BCC loc_05FBB8
    LSR 
    JSR $&HdmaSegmentSplitDown
    LDA $18
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    LDA $18
    BRA loc_05FBCA

  loc_05FBB8:
    LDA $F8
    ASL 
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    PLA 
    CLC 
    ADC $18
    LSR 

  loc_05FBCA:
    INC 
    JSR $&HdmaSegmentSplitUp
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA #$0000
    CLC 
    BRA loc_05FBE9

  code_05FBE5:
    LDA $1C
    INC 
    INC 

  loc_05FBE9:
    STA $1C
    STA $1E
    BIT #$FF00
    BEQ loc_05FBF7
    LDA #$00FE
    STA $1E

  loc_05FBF7:
    LDA $1C
    BIT #$FE00
    BNE loc_05FC27
    LDA $1C
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $1C
    TAY 
    SEP #$20
    LDA $1A
    CLC 
    ADC $F4
    BCC loc_05FC15
    LDA #$FF

  loc_05FC15:
    XBA 
    LDA $F4
    SEC 
    SBC $1A
    BCS loc_05FC1F
    LDA #$00

  loc_05FC1F:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FC27:
    LDA $18
    BIT #$FE00
    BNE loc_05FC57
    LDA $00
    CLC 
    ADC $18
    TAX 
    LDA $00
    SEC 
    SBC $18
    TAY 
    SEP #$20
    LDA $1E
    CLC 
    ADC $F4
    BCC loc_05FC45
    LDA #$FF

  loc_05FC45:
    XBA 
    LDA $F4
    SEC 
    SBC $1E
    BCS loc_05FC4F
    LDA #$00

  loc_05FC4F:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FC57:
    LDA $1C
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FC75

  loc_05FC66:
    LDA $18
    BMI HdmaGradientExitV1
    CMP $1C
    BCC HdmaGradientExitV1
    JMP $&code_05FBE5
}

HdmaGradientExitV1 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FC75:
    LDA $18
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18
    DEC 
    DEC 
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FC66
    LDA #$00FF
    STA $1A
    BRA loc_05FC66
}

---------------------------------------------
; Gradient builder (variant 2) — same diamond pattern but for thinker_def_05FB32

HdmaGradientBuildV2 {
    PHX 
    PHD 
    PHB 
    LDA #$0000            ; Set DP to page 0
    TCD 
    SEP #$20
    LDA #$7E              ; DBR = $7E (WRAM)
    PHA 
    PLB 
    REP #$20
    JSR $&HdmaParamChangeCheck ; Check for param change + toggle buffer
    BCC loc_05FCA9        ; Changed — regenerate
    JMP $&HdmaGradientExitV2 ; No change — exit

  loc_05FCA9:
    LDY $02
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA $FE
    BPL loc_05FCC3
    JMP $&HdmaGradientExitV2

  loc_05FCC3:
    AND #$FFFE
    STA $FC
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FCD6
    LDA #$00FE
    STA $1A

  loc_05FCD6:
    LDA $F8
    BMI loc_05FCF3
    SEC 
    SBC $18
    BCC loc_05FCF3
    JSR $&HdmaSegmentSplitDown
    LDA $18
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    LDA $18
    ASL 
    BRA loc_05FD0B

  loc_05FCF3:
    LDA $F8
    CLC 
    ADC $FC
    BMI loc_05FD0F
    LDA $F8
    PHA 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    PLA 
    CLC 
    ADC $18

  loc_05FD0B:
    INC 
    JSR $&HdmaSegmentSplitUp

  loc_05FD0F:
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA #$0000
    CLC 
    BRA loc_05FD29

  code_05FD26:
    LDA $1C
    INC 

  loc_05FD29:
    STA $1C
    STA $1E
    BIT #$FF00
    BEQ loc_05FD37
    LDA #$00FE
    STA $1E

  loc_05FD37:
    LDA $1C
    BIT #$FF00
    BNE loc_05FD6A
    LDA $1E
    ASL 
    PHA 
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $01, S
    TAY 
    PLA 
    SEP #$20
    LDA $1A
    CLC 
    ADC $F4
    BCC loc_05FD58
    LDA #$FF

  loc_05FD58:
    XBA 
    LDA $F4
    SEC 
    SBC $1A
    BCS loc_05FD62
    LDA #$00

  loc_05FD62:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FD6A:
    LDA $18
    BIT #$FF00
    BNE loc_05FD9D
    LDA $1A
    ASL 
    PHA 
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $01, S
    TAY 
    PLA 
    SEP #$20
    LDA $1E
    CLC 
    ADC $F4
    BCC loc_05FD8B
    LDA #$FF

  loc_05FD8B:
    XBA 
    LDA $F4
    SEC 
    SBC $1E
    BCS loc_05FD95
    LDA #$00

  loc_05FD95:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FD9D:
    LDA $1C
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FDBB

  loc_05FDAC:
    LDA $18
    BMI HdmaGradientExitV2
    CMP $1C
    BCC HdmaGradientExitV2
    JMP $&code_05FD26
}

HdmaGradientExitV2 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FDBB:
    LDA $18
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18
    DEC 
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FDAC
    LDA #$00FF
    STA $1A
    BRA loc_05FDAC
}

---------------------------------------------
; HDMA segment splitter (downward) — splits extent into max-127 scanline segments

HdmaSegmentSplitDown {
    BNE loc_05FDDA        ; Zero remaining? Done
    RTS 

  loc_05FDDA:
    PHA 
    CMP #$0080            ; Clamp to max 127 scanlines per segment
    BCC loc_05FDE3
    LDA #$007F

  loc_05FDE3:
    PHA 
    LDA $03, S            ; Subtract written lines from remainder
    SEC 
    SBC $01, S
    STA $03, S
    PLA 
    STA $0000, Y          ; Write scanline count
    LDA $04
    STA $0001, Y          ; Write brightness value
    INY                   ; Advance HDMA table pointer
    INY 
    INY 
    PLA 
    BRA HdmaSegmentSplitDown ; Loop for next segment
}

---------------------------------------------
; HDMA segment splitter (upward) — same as HdmaSegmentSplitDown but sets bit 7 for direction

HdmaSegmentSplitUp {
    BNE loc_05FDFD        ; Zero remaining? Done
    RTS 

  loc_05FDFD:
    PHA 
    CMP #$0080            ; Clamp to max 127 scanlines
    BCC loc_05FE06
    LDA #$007F

  loc_05FE06:
    PHA 
    LDA $03, S            ; Subtract from remainder
    SEC 
    SBC $01, S
    STA $03, S
    PLA 
    ORA #$0080            ; Set direction bit (upward)
    STA $0000, Y          ; Write scanline count + direction
    LDA $02
    STA $0001, Y          ; Write brightness value
    LDA $0000, Y          ; Update running address offset
    AND #$007F
    ASL 
    CLC 
    ADC $02
    STA $02
    INY 
    INY 
    INY 
    PLA 
    BRA HdmaSegmentSplitUp
}

---------------------------------------------
; Parameter change detection + double buffer toggle
; Compares $FE/$FC, $F6/$F4, $FA/$F8 — if all match, returns carry set (no change).
; On change: copies new params to previous, toggles chatPtr for double buffering,
; and sets up the write pointer for the appropriate buffer half.

HdmaParamChangeCheck {
    LDA $00FE             ; Compare center offset: current vs previous
    CMP $00FC
    BNE loc_05FE49
    LDA $00F6             ; Compare intensity: current vs previous
    CMP $00F4
    BNE loc_05FE4F
    LDA $00FA             ; Compare radius: current vs previous
    CMP $00F8
    BNE loc_05FE47
    JMP $&HdmaNoChange    ; All match — no change (SEC)

  loc_05FE47:
    BRA loc_05FE55

  loc_05FE49:
    STA $00FC             ; Update stored center offset
    LDA $00F6

  loc_05FE4F:
    STA $00F4             ; Update stored intensity
    LDA $00FA

  loc_05FE55:
    STA $00F8             ; Update stored radius
    LDA $chatPtr, X       ; Toggle double buffer frame counter
    INC 
    STA $chatPtr, X
    LSR                   ; Odd frame?
    BCC loc_05FE7E
    LDA #$7600            ; Buffer A write pointers
    STA $0000
    LDA #$7000
    STA $0002
    LDA #$00FF            ; End-of-table marker
    STA $7E7200
    LDA #$7200
    STA $04
    CLC                   ; Return CLC = params changed
    RTS 

  loc_05FE7E:
    LDA #$7A00            ; Buffer B write pointers
    STA $0000
    LDA #$7100
    STA $0002
    LDA #$00FF            ; End-of-table marker
    STA $7E7200
    LDA #$7200
    STA $04
    CLC                   ; Return CLC = params changed
    RTS 
}

---------------------------------------------
; Return carry set — no parameter change detected

HdmaNoChange {
    SEC 
    RTS 
}

---------------------------------------------
; Initialize previous-state registers to zero (called on thinker's first frame)

HdmaInitPrevState {
    STZ $00F4             ; Previous intensity = 0
    STZ $00F8             ; Previous radius = 0
    STZ $00FC             ; Previous center = 0
    RTS 
}

---------------------------------------------
; Compare current vs previous gradient parameters
; Returns: carry set = no change, carry clear = changed

HdmaCompareParams {
    LDA $00F4             ; Previous intensity
    CMP $00F6             ; Current intensity
    BNE loc_05FEBD
    LDA $00F8             ; Previous radius
    CMP $00FA             ; Current radius
    BNE loc_05FEBD
    LDA $00FC             ; Previous center
    CMP $00FE             ; Current center
    BNE loc_05FEBD
    RTS                   ; All same — return SEC (from caller)

  loc_05FEBD:
    CLC                   ; Changed — return CLC
    RTS 
}

---------------------------------------------
; Copy current gradient parameters to previous-state registers

HdmaCopyCurrentToPrev {
    LDA $00F6             ; Current intensity → previous
    STA $00F4
    LDA $00FA             ; Current radius → previous
    STA $00F8
    LDA $00FE             ; Current center → previous
    STA $00FC
    RTS 
}