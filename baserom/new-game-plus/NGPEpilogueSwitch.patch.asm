
h_epilogue_thinker [
  thinker_def < #00, #08, {

  e_epilogue_thinker:
    PHX
    LDA $0D8C
    XBA
    ASL
    TAX
    LDA $306354, X
    BIT #$0080
    BNE epilogue_init_next
    ORA #$0080
    STA $306354, X

    LDA $3063FC, X
    CLC
    ADC #$0080
    STA $3063FC, X
    
    LDA $3063FE, X
    EOR #$0080
    STA $3063FE, X

  epilogue_init_next:
    PLX
    COP [3D]
    RTL
} > ]


------------------------------------------
?INCLUDE 'scene_thinkers'
------------------------------------------

thinker_spawn_0CEA9B+: thinker-spawn < #00, @h_epilogue_thinker >

