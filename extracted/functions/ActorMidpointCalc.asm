---------------------------------------------

ActorMidpointCalc {
    PHX 
    LDY $04
    LDX $06
    LDA $0014, Y
    CLC 
    ADC $0014, X
    CLC 
    BPL loc_0AA42C
    SEC 

  loc_0AA42C:
    ROR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $0016, X
    CLC 
    BPL loc_0AA43A
    SEC 

  loc_0AA43A:
    ROR 
    STA $16
    PLX 
    RTL 
}