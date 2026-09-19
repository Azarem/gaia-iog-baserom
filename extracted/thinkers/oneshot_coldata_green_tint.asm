; One-shot thinker that applies a green color-add tint via three COLDATA writes ($2B, $44, $82), then kills itself.
; 
; Runs once at scene load on South Cape scene group. Gives that area its distinctive green atmospheric cast before the warm palette cycler takes over.
---------------------------------------------

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