?INCLUDE 'chunk_03BAE1'
?INCLUDE 'system_core'

!worldReadyFlag                 0654

---------------------------------------------

actor_0BE1C5 [
  actor-def < #00, #00, #20, {

  code_0BE1C8:
    LDA $worldReadyFlag
    BNE loc_0BE1CE
    RTL 

  loc_0BE1CE:
    BPL loc_0BE1D1
    RTL 

  loc_0BE1D1:
    LDA #$0085
    STA $24
    LDY #$8000
    BRA loc_0BE1DE

  loc_0BE1DB:
    LDY #$0000

  loc_0BE1DE:
    SEP #$20
    LDA $24
    PHA 
    PLB 
    REP #$20
    BRA loc_0BE1EB

  loc_0BE1E8:
    REP #$20
    PLA 

  loc_0BE1EB:
    LDA #$BF02
    CMP $0000, Y
    BEQ loc_0BE204
    INY 
    BNE loc_0BE1EB
    LDA $24
    INC 
    STA $24
    CMP #$000C
    BNE loc_0BE1DB

  loc_0BE200:
    NOP 
    NOP 
    BRA loc_0BE200

  loc_0BE204:
    LDA $0002, Y
    INY 
    JSR $&code_0BE22E
    BCS loc_0BE1EB
    PHA 
    PHB 
    TYA 
    STA $0100
    LDA $01, S
    STA $0102
    PLB 
    PLA 
    INY 
    INY 
    INY 
    PHY 
    TAY 
    SEP #$20
    JSL $@system_core.UpdateFrameRender
    REP #$20
    JSL $@chunk_03BAE1.sub_03E255
    PLY 
    BRA loc_0BE1EB
} >
]

code_0BE22E {
    CMP #$8000
    BCC loc_0BE235
    CLC 
    RTS 

  loc_0BE235:
    SEC 
    RTS 
}