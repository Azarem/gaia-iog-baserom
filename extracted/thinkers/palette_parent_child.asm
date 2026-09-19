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
    COP [SetEntryContinue] ; Animation sub-frame counter
    COP [BranchIfFlagByte] ( #01, #01, &PaletteParentChildSpawnWave )
    RTL 
} >
]

PaletteParentChildSpawnWave {
    COP [SpawnThinker] ( @PaletteParentChildWaveLoop ) ; Spawn child PaletteStart #03; store child actor index in chatPtr
    TYA 
    STA $chatPtr, X       ; Increment tick counter, yield RTL
    COP [SetEntryContinue]
    COP [ExitIfFlagByte] ( #01, #00 )
    PHX 
    PHD                   ; Zero -> all passes done
    LDA $chatPtr, X
    TAX 
    TCD                   ; Reset accumulators and tick for next halved pass
    COP [KillThinker]
    PLD 
    PLX                   ; Jump back to TickMoveStep at halved scale
    BRA loc_00B600
}

PaletteParentChildWaveLoop {
    COP [PaletteStart] ( #03 )
    COP [PaletteStep]
    BRA PaletteParentChildWaveLoop
}