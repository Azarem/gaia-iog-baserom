?INCLUDE 'CollisionLayerRenderer'

!mapBoundsX                     0692
!orbitAngle                     7F0010

---------------------------------------------

pyD7_actor_08C4EA [
  actor-def < #1D, #01, #03, {

  code_08C4ED:
    LDA #$0001
    STA $24

  code_08C4F2:
    COP [BranchIfPlayerAt] ( #$0378, #$04A0, &code_08C4FC )
    BRA loc_08C504
} >
]

code_08C4FC {
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_08C504:
    COP [AddPosition] ( #00, #FE )
    LDA $0E
    XBA 
    STA $orbitAngle, X
    LDA #$2000
    STA $0E
    JSL $@CollisionLayerRenderer

  loc_08C518:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08C525 )
    RTL 
}

code_08C525 {
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2C2C )
    JSR $&code_08C58A
    COP [CallScript] ( &code_08C549 )
    COP [SetEntryExit]
    JSL $@CollisionLayerRenderer
    COP [PlaySoundBoth] ( #$1515 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_08C548 )
    BRA loc_08C518
}

code_08C548 {
    RTL 
}

code_08C549 {
    LDA $orbitAngle, X
    STA $26
    LDA $24
    BPL loc_08C564
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    DEC 
    STA $0026, Y
    DEC $26
    BEQ loc_08C575
    RTL 

  loc_08C564:
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    INC 
    STA $0026, Y
    DEC $26
    BEQ loc_08C575
    RTL 

  loc_08C575:
    LDA $24
    EOR #$FFFF
    INC 
    STA $24
    COP [RestoreSavedPtr]
}

pyD7_actor_08C57F [
  actor-def < #1D, #01, #03, {

  code_08C582:
    LDA #$FFFF
    STA $24
    JMP $&code_08C4F2
} >
]

code_08C58A {
    PHX 
    PHP 
    SEP #$20
    LDX #$0000
    LDA $0697
    DEC 
    STA $000E

  loc_08C598:
    LDY #$000F

  loc_08C59B:
    LDA #$0F
    STA $7FC103, X
    STA $7FC20C, X
    REP #$20
    TXA 
    CLC 
    ADC #$0010
    TAX 
    SEP #$20
    DEY 
    BPL loc_08C59B
    DEC $000E
    BMI loc_08C5C7
    REP #$20
    TXA 
    CLC 
    ADC $mapBoundsX
    CLC 
    ADC #$FF00
    TAX 
    SEP #$20
    BRA loc_08C598

  loc_08C5C7:
    PLP 
    PLX 
    RTS 
}