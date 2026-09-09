!chatPtr                        7F000A

---------------------------------------------

palette_parent_child [
  thinker-def < #00, #08, {

  loc_00B600:
    COP [PaletteStart] ( #03 )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_00B60C )
    RTL 
} >
]

code_00B60C {
    COP [SpawnThinker] ( @code_00B62A )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    COP [ExitIfFlagByte] ( #01, #00 )
    PHX 
    PHD 
    LDA $chatPtr, X
    TAX 
    TCD 
    COP [KillThinker]
    PLD 
    PLX 
    BRA loc_00B600
}

code_00B62A {
    COP [PaletteStart] ( #03 )
    COP [PaletteStep]
    BRA code_00B62A
}