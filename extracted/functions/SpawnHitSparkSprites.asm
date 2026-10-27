; Hit-spark OAM effect that writes four tile entries flanking the hit position into the OAM compose buffer at $7F3100.
; 
; Runs 8 frames at original Y, then 16 frames drifting upward. Spawned during inventory-screen hit feedback. Lightweight spark burst without full actor overhead.
---------------------------------------------

!oamWriteOffset                 00D8
!oamComposeBuffer               7F3100

---------------------------------------------

SpawnHitSparkSprites {
    COP [LoopStart] ( #08 )
    JSR $&AppendHitSparkOamEntry
    COP [LoopEnd]
    COP [LoopStart] ( #10 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    JSR $&AppendHitSparkOamEntry
    COP [LoopEnd]
    COP [Die]
}

AppendHitSparkOamEntry {
    PHX 
    LDX $oamWriteOffset
    LDA #$327A
    STA $oamComposeBuffer+4, X
    LDA $14
    SEC 
    SBC #$0004
    STA $oamComposeBuffer, X
    LDA $16
    STA $oamComposeBuffer+2, X
    LDA #$327B
    STA $oamComposeBuffer+A, X
    LDA $14
    CLC 
    ADC #$0004
    STA $oamComposeBuffer+6, X
    LDA $16
    STA $oamComposeBuffer+8, X
    LDA $oamWriteOffset
    CLC 
    ADC #$000C
    STA $oamWriteOffset
    PLX 
    RTS 
}