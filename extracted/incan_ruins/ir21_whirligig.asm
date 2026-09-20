; Whirligig — spinning blade trap that fires projectile when player nears.
; 
; Starts at position (+8,+8) with actor flags $0020. Waits offscreen,
; then when player is within 6 tiles, plays rising animation with
; Y movement loop (#1B, 64 frames), sets collision priority max, then
; spawns a rotating projectile child that orbits using sin/cos tables
; from math_lookup_tables. Projectile child reads orbitAngle to rotate
; in a circle around the parent position.
---------------------------------------------

?INCLUDE 'math_lookup_tables'

!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!iframeCounter                  7F0028

---------------------------------------------

ir21_whirligig [
  actor-def < #1B, #00, #00, {

  code_0A98BF:
    COP [OrActorFlags] ( #$0020 )
    COP [AddPosition] ( #08, #08 )
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #06, &code_0A98D2 )
    RTL 
} >
]

code_0A98D2 {
    COP [StageSpriteLoopMoveY] ( #1B, #40, #14 )
    COP [AnimLoop]
    COP [CollPrioritySetMax]
    COP [SpawnMarkedAfter] ( @code_0A98E9, #$2300 )

  loc_0A98E2:
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    BRA loc_0A98E2
}

code_0A98E9 {
    LDA #$0000
    STA $chatPtr, X
    LDA $16
    SEC 
    SBC #$0040
    STA $16
    LDY $04
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    COP [SetEntryExit]
    PHX 
    LDX $04
    TXY 
    LDA $iframeCounter, X
    BEQ loc_0A991A
    BMI loc_0A991A
    PLX 
    JMP $&code_0A99C2

  loc_0A991A:
    PLX 
    LDA $orbitAngle, X
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $14
    LDA $orbitDiameter, X
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $16
    STA $16
    COP [BranchOnPlayerX] ( #$0028, &code_0A9947, &code_0A994D, &code_0A994B )
}

code_0A9947 {
    DEC $14
    BRA code_0A994D
}

code_0A994B {
    INC $14
}

code_0A994D {
    COP [BranchOnPlayerY] ( #$0028, &code_0A9957, &code_0A995D, &code_0A995B )
}

code_0A9957 {
    DEC $16
    BRA code_0A995D
}

code_0A995B {
    INC $16
}

code_0A995D {
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    PHX 
    LDY $0004, X
    LDA $chatPtr, X
    AND #$007F
    ASL 
    TAX 
    SEP #$20
    LDA #$00
    XBA 
    LDA $&math_lookup_tables.sine_table_8bit, X
    BPL loc_0A9985
    XBA 
    DEC 
    XBA 
    SEC 
    ROR 
    BRA loc_0A9986

  loc_0A9985:
    LSR 

  loc_0A9986:
    REP #$20
    CLC 
    ADC $0018
    STA $0014, Y
    SEP #$20
    LDA #$00
    XBA 
    LDA $&math_lookup_tables.signed_sine_table, X
    BPL loc_0A99A0
    XBA 
    DEC 
    XBA 
    SEC 
    ROR 
    BRA loc_0A99A1

  loc_0A99A0:
    LSR 

  loc_0A99A1:
    REP #$20
    CLC 
    ADC $001C
    STA $0016, Y
    PLX 
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    LDA $chatPtr, X
    INC 
    STA $chatPtr, X
}

code_0A99C2 {
    RTL 
}