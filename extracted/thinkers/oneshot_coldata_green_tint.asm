!COLDATA                        2132

---------------------------------------------

oneshot_coldata_green_tint [
  thinker-def < #00, #08, {

  code_00B6E7:
    SEP #$20
    LDA #$2B
    STA $COLDATA
    LDA #$44
    STA $COLDATA
    LDA #$82
    STA $COLDATA
    REP #$20
    COP [KillThinker]
    RTL 
} >
]