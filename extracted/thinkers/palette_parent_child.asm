; Parent thinker that starts palette animation #03 and, when flag byte $01 is set, spawns a child thinker that continuously steps the same palette.
; 
; The parent stores the child thinker ID in chatPtr and kills/restarts the child when flag $01 clears. Used on scenes $FD and $FF together with parallax_thinker and ambient palette cycling. Keeps a sustained palette effect running while a scene flag indicates an active state.
---------------------------------------------

!chatPtr                        7F000A

---------------------------------------------

palette_parent_child [
  thinker-def < #00, #08, {

  loc_00B600:
    COP [PaletteStart] ( #03 )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &PaletteParentChildSpawnWave )
    RTL 
} >
]

PaletteParentChildSpawnWave {
    COP [SpawnThinker] ( @PaletteParentChildWaveLoop )
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

PaletteParentChildWaveLoop {
    COP [PaletteStart] ( #03 )
    COP [PaletteStep]
    BRA PaletteParentChildWaveLoop
}