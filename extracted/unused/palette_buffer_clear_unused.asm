---------------------------------------------

palette_buffer_clear_unused [
  thinker-def < #00, #08, {

  loc_00B6FF:
    PHX 
    LDA #$0000
    LDX #$0000

  loc_00B706:
    STA $7F0A94, X
    INX 
    INX 
    CPX #$000E
    BNE loc_00B706
    PLX 
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B6FF

  loc_00B71B:
    COP [KillThinker]
    RTL 
} >
]