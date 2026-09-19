; One-frame thinker that writes warm color-add values ($66, $82) to the SNES COLDATA register, then immediately kills itself.
; 
; Provides an instant warm screen tint without a full palette fade. Spawned on Larai Cliff and related overworld scenes as part of their ambient thinker sets.
---------------------------------------------

!COLDATA                        2132

---------------------------------------------

oneshot_coldata_warm_flash [
  thinker-def < #00, #08, {

  code_00B660:
    SEP #$20
    LDA #$66
    STA $COLDATA
    LDA #$82
    STA $COLDATA
    REP #$20
    COP [KillThinker]
    RTL 
} >
]