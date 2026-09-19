; Hit-spark OAM effect that writes four tile entries flanking the hit position into the OAM compose buffer at $7F3100.
; 
; Runs 8 frames at original Y, then 16 frames drifting upward. Spawned during inventory-screen hit feedback. Lightweight spark burst without full actor overhead.
---------------------------------------------

!oamComposeBuffer               7F3100

---------------------------------------------

SpawnHitSparkSprites {
    COP [LoopInit] ( #08 )
    JSR $&AppendHitSparkOamEntry
    COP [LoopNext]
    COP [LoopInit] ( #10 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    JSR $&AppendHitSparkOamEntry
    COP [LoopNext]
    COP [Die]
}

AppendHitSparkOamEntry {
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