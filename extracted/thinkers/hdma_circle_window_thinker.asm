; Circular HDMA window generator (spotlight / iris) and its two thinkers (391960-392913, Bank 05).
; 
; It builds a per-scanline table of left and right edges for PPU window 1: QueueHdma uses hdma_channel_config entry #26 (WH0, $2126; transfer mode 1 = two registers, so every scanline writes WH0 = left edge and WH1 = right edge). The edges describe a filled circle, so the window is a circle that can move and grow or shrink. Lines outside the circle get the "empty window" value (left $FF, right $00: left > right, nothing is inside). The old description (diamond-shaped brightness gradient, intensity / radius / centre offset) was wrong: nothing here touches brightness or colour.
; 
; === PARAMETERS (direct page $F4-$FE, written by the scene scripts) ===
; 
;   $F6 = circle centre X in screen pixels       ($F4 = the value used for the last build)
;   $FA = circle centre Y in scanlines            ($F8 = the value used for the last build)
;   $FE = radius in pixels                        ($FC = the value used for the last build)
; 
; A negative radius switches the circle off: the builder leaves the default table (one line of empty window, then end of table). The "previous" copies are refreshed by HdmaParamChangeCheck. While HdmaCircleWindowBuildV2 runs, $FC is reused as the circle decision variable; the V2 thinker restores it afterwards with HdmaCopyCurrentToPrev.
; 
; Writers: sF7_credits sets centre ($80, $7F) with radius $FFFF (off) and later raises the radius from 0 to $3F; gs2A_shira sets centre ($40, $40) and radius $120 (the circle is larger than the screen), then dream_zoom_controller moves the centre to the screen position of world point ($88, $180) (X from bg1ScrollH, Y from mapScrollV) and shrinks the radius by 2 per frame from $A0 until it falls below $40; mu67_male_vampire sets radius $FFFF at its start and at its end, a 32-iteration loop in mu67_vampires (address 718387) raises it by 1 per frame while sub_0AF6D7 copies the vampire actor's screen position into the centre. sF7_credits and gs2A_shira also set W12SEL to $33 themselves (window 1 on BG1 and BG2); gs2A_shira writes WOBJSEL as well. The window setup of the Mu scene is not in the extracted actors (open question).
; 
; === THINKERS (scene_thinkers) ===
; 
; circle_window_thinker_v1 (variant 1): spawned only by scene F7 (credits). Every frame it calls HdmaCircleWindowBuildV1, then queues whichever table the double buffer selects.
; circle_window_thinker_v2 (variant 2): spawned by scenes 2A (Gold Ship dream) and 67 (Mu vampire lair). It clears the previous-parameter copies once (HdmaInitPrevState), so the first frame builds only if one of the current centre X, centre Y or radius ($F6, $FA, $FE) is non-zero; then each frame compares current and previous parameters, rebuilds with HdmaCircleWindowBuildV2 only when something changed, copies current to previous and queues the table.
; 
; === DOUBLE BUFFER AND MEMORY LAYOUT ===
; 
; HdmaParamChangeCheck adds 1 to chatPtr ($7F000A,X) on every change; bit 0 chooses the buffer the builder writes and the thinker queues (odd = buffer A, even = buffer B), so a table that HDMA is still reading is never rebuilt in place.
;   buffer A: HDMA table at $7E7000, row data centred on $7E7600 (the builder's $00 pointer)
;   buffer B: HDMA table at $7E7100, row data centred on $7E7A00
;   $7E7200: the shared "empty window" word ($00FF); the builder keeps its address in $04
; The table is an indirect HDMA table of 3-byte entries (line count, data pointer). Entries with a count below $80 hold one data word for that many lines (used for the empty lines above the circle: HdmaEmitHoldSegments); entries with bit 7 set are repeat mode, so HDMA fetches a new data word on every scanline (the circle rows: HdmaEmitRepeatSegments). Both splitters cap a segment at 127 lines.
; 
; === CIRCLE ALGORITHM (HdmaCircleWindowBuildV2) ===
; 
; A Bresenham-style integer circle. x starts at the radius (rounded down to even), y at 0 and the decision variable $FC at the radius. For each y it stores the word (left = centreX - x, right = centreX + x, each clamped to 0..255) on the rows centre + y and centre - y of the data area, then the transposed pair (row x with half-width y); then $FC = $FC - (2y - 1) and, when $FC goes negative, $FC = $FC + 2(x - 1) and x = x - 1. It stops when x < 0 or x < y. Rows beyond +-255 are skipped (the data area holds 256 words per side), so a radius over $FF is only drawn for its central rows. Rows near the top and bottom of the circle come out a few pixels wider than an ideal circle.
; The table is laid out as: lines above the circle (hold entries), the circle rows (repeat entries, 2 data bytes per line), then a final one-line empty entry and the end marker. When the circle is cut off by the top of the screen the first visible row starts at the matching data row; a circle entirely above the screen emits only the final empty entry.
; 
; HdmaCircleWindowBuildV1 follows the same structure but with different row arithmetic (see its part note): it spans only radius + 1 lines vertically and stores the row words at a one-byte stride. What the credits window looks like was not verified (open question).
; 
; === HELPERS ===
;   HdmaEmitHoldSegments - emit hold entries (count 1-127, data pointer $04 = the empty word) for a number of lines
;   HdmaEmitRepeatSegments - emit repeat-mode entries (count | $80) whose data pointer advances through the row data by 2 bytes per line
;   HdmaParamChangeCheck - compare current and previous parameters; on change store them, toggle the buffer, set the write pointers and the empty word
;   HdmaNoChange - return carry set
;   HdmaInitPrevState - zero the previous centre X, centre Y and radius
;   HdmaCompareParams - carry clear = something changed
;   HdmaCopyCurrentToPrev - previous = current
---------------------------------------------

!tileStagingBuffer              7E7000
!chatPtr                        7F000A

---------------------------------------------

; Variant 1 thinker for the ending credits (scene F7). Each frame: SetEntryHere re-entry, HdmaCircleWindowBuildV1 (which rebuilds only when the parameters changed), then QueueHdma of the buffer selected by chatPtr bit 0 (odd = $7E7000, even = $7E7100) on channel config #26 (WH0/WH1). It never zeroes the previous-parameter copies and never restores them, so while the radius is not negative the builder's use of $FC as a decision variable makes the next frame see a change: the table is rebuilt every frame and the buffers alternate every frame.

circle_window_thinker_v1 [
  thinker-def < #04, #08, {

; Credits circle-window thinker frame entry: SetEntryHere, HdmaCircleWindowBuildV1, then QueueHdma on config $26 using buffer A at tileStagingBuffer or B at $7E7100 based on chatPtr bit 0.

  CircleWindowV1Entry:
    COP [SetEntryHere]
    JSR $&HdmaCircleWindowBuildV1 ; Rebuild the circle table if the parameters changed since the last build
    LDA $chatPtr, X       ; chatPtr bit 0 = the buffer the builder wrote (it toggles only on a change); odd = buffer A
    LSR 
    BCC loc_05FB2B
    COP [QueueHdma] ( $tileStagingBuffer, #26 ) ; Queue buffer A (table at $7E7000) for config #26: WH0/WH1, the window 1 edges
    RTL 

  loc_05FB2B:
    COP [QueueHdma] ( $7E7100, #26 ) ; Queue buffer B (table at $7E7100) for config #26
    RTL 
} >
]

---------------------------------------------
; Variant 2 thinker for the Gold Ship dream (scene 2A) and the Mu vampire lair (scene 67). HdmaInitPrevState clears the previous centre X, centre Y and radius once (so the first frame builds only if one of the current centre X, centre Y or radius is non-zero); then every frame: HdmaCompareParams, and only on a change HdmaCircleWindowBuildV2 and HdmaCopyCurrentToPrev (which also restores $FC from $FE); finally QueueHdma of the buffer chosen by chatPtr bit 0 on channel config #26. An unchanged circle keeps re-queueing the same buffer.

circle_window_thinker_v2 [
  thinker-def < #04, #08, {

; Dream and vampire-lair thinker entry: HdmaInitPrevState once, then each frame HdmaCompareParams skips rebuild when unchanged, else HdmaCircleWindowBuildV2 and HdmaCopyCurrentToPrev, then QueueHdma with the same buffer select as V1.

  CircleWindowV2Entry:
    JSR $&HdmaInitPrevState ; First run: previous centre X, centre Y and radius = 0
    COP [SetEntryHere]
    JSR $&HdmaCompareParams ; Carry set = parameters unchanged since the last build
    BCS loc_05FB44        ; Unchanged: keep the table that is already built
    JSR $&HdmaCircleWindowBuildV2 ; Rebuild the circle table in the next buffer
    JSR $&HdmaCopyCurrentToPrev ; previous = current (also restores $FC, the builder's decision variable)

  loc_05FB44:
    LDA $chatPtr, X       ; chatPtr bit 0 selects the buffer: odd = A, even = B
    LSR 
    BCC loc_05FB52
    COP [QueueHdma] ( $tileStagingBuffer, #26 ) ; Queue buffer A (table at $7E7000) for config #26: WH0/WH1, the window 1 edges
    RTL 

  loc_05FB52:
    COP [QueueHdma] ( $7E7100, #26 ) ; Queue buffer B (table at $7E7100) for config #26
    RTL 
} >
]

---------------------------------------------
; Variant 1 circle builder (credits only). Same flow as HdmaCircleWindowBuildV2: HdmaParamChangeCheck (changed -> build, unchanged -> exit), default table (one empty line, end marker), negative radius exits, then the Bresenham loop with $18 = x, $1C = y and $FC = decision variable, filling words (left = centreX - half-width, right = centreX + half-width, clamped to a byte) into the row data and emitting hold / repeat segments.
; Differences from V2, all in the row arithmetic: the line counts are computed in half resolution (hold lines = (2 x centre Y - radius) / 2, circle lines = radius + 1, so the vertical extent is half of V2's 2 x radius + 1); data rows are addressed with a one-byte stride (index = $00 +- y) and each row is stored as a word, so neighbouring rows overwrite each other's second byte, while the repeat-mode entries read one word per line and advance the data pointer by 2 bytes; the "centre above the screen" tests of V2 are missing; and x is decreased by 2 instead of 1 when the decision variable goes negative. V1 therefore does not produce the same table as V2 for the same parameters. Its visible result in the credits (centre $80, $7F, radius up to $3F) is unverified (open question).
; On exit it restores DBR, D and X. It does not copy the parameters to the previous state; HdmaParamChangeCheck has already done that, apart from $FC, which stays at the final decision value.

HdmaCircleWindowBuildV1 {
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
    JSR $&HdmaParamChangeCheck ; Carry clear = parameters changed (buffer toggled, pointers set up); set = unchanged
    BCC loc_05FB70        ; Changed: rebuild
    JMP $&HdmaCircleWindowExitV1 ; No change — exit

  loc_05FB70:
    LDY $02               ; Y = write pointer into this frame's HDMA table ($02)
    LDA #$0001
    STA $0000, Y          ; Default entry: one line ...
    LDA $04
    STA $0001, Y          ; ... whose data pointer is $04, the empty-window word at $7E7200
    LDA #$0000
    STA $0003, Y          ; End of table (count 0) after that single entry
    LDA $FE               ; Radius: negative = circle off, keep the default table
    BPL loc_05FB8A
    JMP $&HdmaCircleWindowExitV1

  loc_05FB8A:
    AND #$FFFE
    STA $FC               ; $FC = decision variable, starts at the (even) radius
    STA $18               ; $18 = x, starts at the radius
    STA $1A               ; $1A = x as a half-width byte (limited to $FE below)
    BIT #$FF00
    BEQ loc_05FB9D
    LDA #$00FE
    STA $1A

  loc_05FB9D:
    LDA $F8               ; Centre Y
    ASL 
    SEC 
    SBC $18               ; 2 x centre Y - radius ...
    BCC loc_05FBB8
    LSR                   ; ... halved: hold lines before the shape (V1 draws radius + 1 lines, V2 2 x radius + 1)
    JSR $&HdmaEmitHoldSegments ; Emit hold entries (empty window) for those lines
    LDA $18
    EOR #$FFFF
    INC 
    CLC 
    ADC $00               ; $02 = $00 - radius: first data row (one-byte stride in V1)
    STA $02
    LDA $18               ; Line count of the circle rows = radius (V1), +1 below
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
    INC                   ; +1 for the centre row
    JSR $&HdmaEmitRepeatSegments ; Emit repeat-mode entries for the circle rows
    LDA #$0001            ; Final entry: one line of empty window ...
    STA $0000, Y
    LDA $04
    STA $0001, Y          ; ... pointer $04 (the empty word) ...
    LDA #$0000
    STA $0003, Y          ; ... and the end marker
    LDA #$0000
    CLC 
    BRA loc_05FBE9

; Bresenham row step inside HdmaCircleWindowBuildV1: advances Y offset $1C (by 2 on first entry), writes WH0/WH1 word pairs for symmetric rows, and loops until x drops below y or goes negative, else jumps back from the loop tail.

  CircleNextRowV1:
    LDA $1C
    INC 
    INC 

  loc_05FBE9:
    STA $1C               ; $1C = y (row offset from the centre)
    STA $1E               ; $1E = y as a half-width byte (limited to $FE below)
    BIT #$FF00
    BEQ loc_05FBF7
    LDA #$00FE
    STA $1E

  loc_05FBF7:
    LDA $1C
    BIT #$FE00            ; Skip the octant 1 rows once y reaches $200
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
    STA $0000, X          ; Store the (left, right) word on the row below the centre (word store, 1-byte stride in V1)
    STA $0000, Y          ; Same word on the mirrored row above the centre

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
    LDA $1C               ; Decision: $FC = $FC - (2y - 1)
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FC75        ; Negative: step x inward

  loc_05FC66:
    LDA $18
    BMI HdmaCircleWindowExitV1
    CMP $1C
    BCC HdmaCircleWindowExitV1
    JMP $&CircleNextRowV1
}

---------------------------------------------
; Restore path for HdmaCircleWindowBuildV1: PLB, PLD, PLX and return; taken when parameters unchanged, radius negative, or the Bresenham loop finishes.

HdmaCircleWindowExitV1 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FC75:
    LDA $18               ; $FC = $FC + 2(x - 1) ...
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18               ; ... and x = x - 2 (V2 steps by 1)
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
; Variant 2 circle builder (Gold Ship dream, Mu vampire lair). Runs with D = 0 and DBR = $7E. Steps: (1) HdmaParamChangeCheck stores the previous parameters, toggles the buffer and sets $00 (data centre), $02 (table write pointer) and $04 (empty word address). (2) A default table is written first: one line of empty window and the end marker, so a switched-off circle (negative radius) leaves a valid table. (3) The radius is rounded to even and becomes $18 (x), $FC (decision variable) and $1A (x as a clamped byte). (4) Empty lines above the circle: centre Y - radius lines go out through HdmaEmitHoldSegments; if the circle is cut off by the top of the screen (or the centre is above it) the data pointer starts at the first visible row instead, and a circle that ends above the screen emits nothing. (5) HdmaEmitRepeatSegments emits 2 x radius + 1 repeat lines over the row data. (6) A final one-line empty entry and the end marker follow. (7) The Bresenham loop fills the row data: $1C = y, $1E = y clamped to a byte, rows centre + y and centre - y, then the transposed octant; each word is (left, right) = centreX -/+ half-width clamped to 0 / 255, written with the right edge in the high byte for WH1.
; Row data uses 2 bytes per scanline (ASL of the row offset); rows with an offset of $100 or more are skipped.

HdmaCircleWindowBuildV2 {
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
    JSR $&HdmaParamChangeCheck ; Store the previous parameters, toggle the buffer, set $00 / $02 / $04; carry is clear here
    BCC loc_05FCA9        ; Changed — regenerate
    JMP $&HdmaCircleWindowExitV2 ; No change — exit

  loc_05FCA9:
    LDY $02               ; Y = write pointer into this frame's HDMA table ($02)
    LDA #$0001
    STA $0000, Y          ; Default entry: one line ...
    LDA $04
    STA $0001, Y          ; ... whose data pointer is $04, the empty-window word at $7E7200
    LDA #$0000
    STA $0003, Y          ; End of table (count 0) after that single entry
    LDA $FE               ; Radius: negative = circle off, keep the default table
    BPL loc_05FCC3
    JMP $&HdmaCircleWindowExitV2

  loc_05FCC3:
    AND #$FFFE            ; Radius rounded down to an even number
    STA $FC               ; $FC = decision variable, starts at the radius
    STA $18               ; $18 = x, starts at the radius
    STA $1A               ; $1A = x as a half-width byte (limited to $FE below)
    BIT #$FF00
    BEQ loc_05FCD6
    LDA #$00FE
    STA $1A

  loc_05FCD6:
    LDA $F8               ; Centre Y (the previous copy, just refreshed)
    BMI loc_05FCF3        ; Centre above the screen: skip the empty lines
    SEC 
    SBC $18               ; Centre Y - radius = empty lines before the circle
    BCC loc_05FCF3        ; Circle reaches the top edge: clipped path below
    JSR $&HdmaEmitHoldSegments ; Emit hold entries (empty window) for those lines
    LDA $18
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00               ; $02 = $00 - 2 x radius: data row of the circle's top line (2 bytes per row)
    STA $02
    LDA $18               ; Circle rows = 2 x radius + 1 (the INC below adds the +1)
    ASL 
    BRA loc_05FD0B

  loc_05FCF3:
    LDA $F8               ; Clipped path: lines from the top of the screen to the circle's bottom
    CLC 
    ADC $FC
    BMI loc_05FD0F        ; Circle ends above the screen: nothing to draw
    LDA $F8
    PHA 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00               ; $02 = $00 - 2 x centre Y: data row that scanline 0 maps to
    STA $02
    PLA 
    CLC 
    ADC $18               ; + radius = lines from the top of the screen to the circle's bottom

  loc_05FD0B:
    INC                   ; +1 for the centre row
    JSR $&HdmaEmitRepeatSegments ; Emit repeat-mode entries over the row data

  loc_05FD0F:
    LDA #$0001            ; Final entry: one line of empty window ...
    STA $0000, Y
    LDA $04
    STA $0001, Y          ; ... pointer $04 (the empty word) ...
    LDA #$0000
    STA $0003, Y          ; ... and the end marker
    LDA #$0000
    CLC 
    BRA loc_05FD29

; Row step inside HdmaCircleWindowBuildV2: increments $1C, emits hold/repeat HDMA segments for above- and below-centre rows while y stays in range, then returns to the x/y loop or exits to HdmaCircleWindowExitV2.

  CircleNextRowV2:
    LDA $1C
    INC 

  loc_05FD29:
    STA $1C               ; $1C = y (row offset from the centre)
    STA $1E               ; $1E = y as a half-width byte (limited to $FE below)
    BIT #$FF00
    BEQ loc_05FD37
    LDA #$00FE
    STA $1E

  loc_05FD37:
    LDA $1C
    BIT #$FF00            ; Octant 1 row only while y < $100 (the data holds 256 rows per side)
    BNE loc_05FD6A
    LDA $1E
    ASL 
    PHA 
    CLC 
    ADC $00               ; X = $00 + 2y: row below the centre
    TAX 
    LDA $00
    SEC 
    SBC $01, S            ; Y = $00 - 2y: row above the centre
    TAY 
    PLA 
    SEP #$20
    LDA $1A               ; Half-width = x
    CLC 
    ADC $F4               ; Right edge = centre X + x ...
    BCC loc_05FD58
    LDA #$FF              ; ... clamped to 255

  loc_05FD58:
    XBA                   ; Right edge into the high byte (it is WH1)
    LDA $F4               ; Left edge = centre X - x ...
    SEC 
    SBC $1A
    BCS loc_05FD62
    LDA #$00              ; ... clamped to 0

  loc_05FD62:
    REP #$20
    STA $0000, X          ; Store the (left = WH0, right = WH1) word on the row below the centre
    STA $0000, Y          ; Same word on the mirrored row above the centre

  loc_05FD6A:
    LDA $18
    BIT #$FF00            ; Octant 2 row only while x < $100
    BNE loc_05FD9D
    LDA $1A               ; Octant 2: row offset = x (limited to a byte), half-width = y
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
    LDA $1E               ; Half-width = y
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
    LDA $1C               ; Decision: $FC = $FC - (2y - 1)
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FDBB        ; Negative: step x inward

  loc_05FDAC:
    LDA $18               ; Loop while x >= 0 and x >= y
    BMI HdmaCircleWindowExitV2
    CMP $1C
    BCC HdmaCircleWindowExitV2
    JMP $&CircleNextRowV2 ; Next row: y = y + 1
}

---------------------------------------------
; Restore path for HdmaCircleWindowBuildV2: same register restore and return; also reached when HdmaParamChangeCheck reports no parameter change or radius is negative.

HdmaCircleWindowExitV2 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FDBB:
    LDA $18               ; $FC = $FC + 2(x - 1) ...
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18               ; ... and x = x - 1
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
; Emit hold entries for the lines above the circle. In: A = line count, Z set when A is zero; $04 = data pointer; Y = table write pointer. Each loop writes one 3-byte entry (count 1-127, pointer = $04, the shared empty-window word), subtracts the count from the remainder (kept on the stack) and repeats until nothing is left; the Z flag of the final PLA ends the loop. Count bit 7 stays clear, so HDMA holds the one word for the whole segment. These are the lines above the circle.

HdmaEmitHoldSegments {
    BNE loc_05FDDA        ; Z set (nothing left to emit): return below; otherwise emit the next entry
    RTS 

  loc_05FDDA:
    PHA 
    CMP #$0080            ; Segments are capped at 127 lines
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
    STA $0001, Y          ; Data pointer = $04, the shared empty-window word
    INY                   ; Advance HDMA table pointer
    INY 
    INY 
    PLA 
    BRA HdmaEmitHoldSegments ; Loop for next segment
}

---------------------------------------------
; Emit the circle's repeat-mode entries. In: A = line count (Z set when zero); $02 = pointer to the first row-data word of the first segment; Y = table write pointer. Each loop writes a 3-byte entry whose count byte is (count | $80), so HDMA reads a new data word on every scanline of the segment, with the data pointer in $02; $02 then advances by count x 2 bytes (one word per line). Segments are capped at 127 lines. Bit 7 is HDMA's repeat flag, not a direction flag: the old comment ("direction bit, upward") was wrong.

HdmaEmitRepeatSegments {
    BNE loc_05FDFD        ; Z set from the caller's A / the last PLA: nothing left
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
    ORA #$0080            ; Bit 7 = HDMA repeat mode: a new data word on every line
    STA $0000, Y          ; Count byte (count | $80)
    LDA $02
    STA $0001, Y          ; Data pointer = $02: first row-data word of this segment
    LDA $0000, Y          ; Advance the data pointer by count x 2 bytes (one word per line)
    AND #$007F
    ASL 
    CLC 
    ADC $02
    STA $02
    INY 
    INY 
    INY 
    PLA 
    BRA HdmaEmitRepeatSegments
}

---------------------------------------------
; Compare the current parameters with the ones used for the last build: radius $FE against $FC, centre X $F6 against $F4, centre Y $FA against $F8. All equal -> HdmaNoChange (carry set, nothing else happens). Any difference -> all three previous copies are updated, chatPtr,X is incremented and the table state is set for the buffer that bit 0 selects: odd = buffer A (row data centre $7600 in $00, table $7000 in $02), even = buffer B ($7A00 and $7100); in both cases $7E7200 receives the empty-window word $00FF and $04 = $7200. Returns carry clear = rebuild. The comparison order is radius, centre X, centre Y, and the stores use the entry point of the first field that differs, so every later field is refreshed too.

HdmaParamChangeCheck {
    LDA $00FE             ; Radius: current $FE against the last-built $FC
    CMP $00FC
    BNE loc_05FE49
    LDA $00F6             ; Centre X: current $F6 against the last-built $F4
    CMP $00F4
    BNE loc_05FE4F
    LDA $00FA             ; Centre Y: current $FA against the last-built $F8
    CMP $00F8
    BNE loc_05FE47
    JMP $&HdmaNoChange    ; All match — no change (SEC)

  loc_05FE47:
    BRA loc_05FE55

  loc_05FE49:
    STA $00FC             ; Store the new radius
    LDA $00F6

  loc_05FE4F:
    STA $00F4             ; Store the new centre X
    LDA $00FA

  loc_05FE55:
    STA $00F8             ; Store the new centre Y
    LDA $chatPtr, X       ; chatPtr + 1 on every change: bit 0 picks the buffer to build
    INC 
    STA $chatPtr, X
    LSR                   ; Odd change count? (bit 0 of chatPtr, not the frame parity)
    BCC loc_05FE7E        ; Even: buffer B below
    LDA #$7600            ; Odd: buffer A, row data centred on $7E7600
    STA $0000
    LDA #$7000            ; Buffer A table at $7E7000
    STA $0002
    LDA #$00FF            ; Empty-window word: left $FF, right $00 (left > right, so nothing is inside)
    STA $7E7200
    LDA #$7200            ; $04 = address of that word
    STA $04
    CLC                   ; Return CLC = params changed
    RTS 

  loc_05FE7E:
    LDA #$7A00            ; Buffer B, row data centred on $7E7A00
    STA $0000
    LDA #$7100            ; Buffer B table at $7E7100
    STA $0002
    LDA #$00FF            ; Empty-window word (same as buffer A)
    STA $7E7200
    LDA #$7200
    STA $04
    CLC                   ; Return CLC = params changed
    RTS 
}

---------------------------------------------
; Return with carry set: the parameters did not change.

HdmaNoChange {
    SEC 
    RTS 
}

---------------------------------------------
; Zero the previous centre X ($F4), centre Y ($F8) and radius ($FC) so that the first HdmaCompareParams of circle_window_thinker_v2 reports a change whenever the scene has set any non-zero parameter.

HdmaInitPrevState {
    STZ $00F4             ; Previous centre X = 0
    STZ $00F8             ; Previous centre Y = 0
    STZ $00FC             ; Previous radius = 0
    RTS 
}

---------------------------------------------
; Compare the previous parameters ($F4/$F8/$FC) with the current ones ($F6/$FA/$FE): centre X, centre Y, radius. All equal -> RTS with the carry that the last CMP left set; any difference -> CLC. The caller (circle_window_thinker_v2) branches on carry set = unchanged.

HdmaCompareParams {
    LDA $00F4             ; Previous centre X ...
    CMP $00F6             ; ... against the current centre X
    BNE loc_05FEBD
    LDA $00F8             ; Previous centre Y ...
    CMP $00FA             ; ... against the current centre Y
    BNE loc_05FEBD
    LDA $00FC             ; Previous radius ...
    CMP $00FE             ; ... against the current radius
    BNE loc_05FEBD
    RTS                   ; All equal: the last CMP left carry set

  loc_05FEBD:
    CLC                   ; Changed — return CLC
    RTS 
}

---------------------------------------------
; Previous parameters = current parameters (centre X $F6 -> $F4, centre Y $FA -> $F8, radius $FE -> $FC). This also restores $FC, which HdmaCircleWindowBuildV2 used as its decision variable.

HdmaCopyCurrentToPrev {
    LDA $00F6             ; Current centre X -> previous
    STA $00F4
    LDA $00FA             ; Current centre Y -> previous
    STA $00F8
    LDA $00FE             ; Current radius -> previous (restores $FC)
    STA $00FC
    RTS 
}