; One-shot thinker spawned by GameOverSequence that steps palette animations #10 then #0E before killing itself.
; 
; Produces the desaturated death-screen palette fade at the start of the game-over flow. Not scene-spawned directly; always invoked when the player dies and combat_collision assigns GameOverSequence.
---------------------------------------------

---------------------------------------------

DeathPaletteFadeThinker {
    COP [PaletteStart] ( #10 )
    COP [PaletteStep]
    COP [PaletteStart] ( #0E )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}