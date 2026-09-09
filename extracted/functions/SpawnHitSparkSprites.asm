!oamComposeBuffer               7F3100

---------------------------------------------

SpawnHitSparkSprites {
    COP [LoopInit] ( #08 )
    JSR $&code_00DD1D
    COP [LoopNext]
    COP [LoopInit] ( #10 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    JSR $&code_00DD1D
    COP [LoopNext]
    COP [Die]
}

code_00DD1D {
    PHX 
    LDX $00D8
    LDA #$327A
    STA $7F3104, X
    LDA $14
    SEC 
    SBC #$0004
    STA $oamComposeBuffer, X
    LDA $16
    STA $7F3102, X
    LDA #$327B
    STA $7F310A, X
    LDA $14
    CLC 
    ADC #$0004
    STA $7F3106, X
    LDA $16
    STA $7F3108, X
    LDA $00D8
    CLC 
    ADC #$000C
    STA $00D8
    PLX 
    RTS 
}