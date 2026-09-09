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