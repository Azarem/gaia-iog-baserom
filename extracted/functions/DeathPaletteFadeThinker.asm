; One-shot thinker spawned by GameOverSequence (COP SpawnThinker) that plays palette bundle $10, then bundle $0E, then kills itself.
; 
; PaletteStart selects a palette bundle and PaletteStep then plays its strips one frame per tick, continuing past the op only when the bundle ends, so each pair runs one whole bundle. combat_collision assigns GameOverSequence to the player when HP reaches zero; the sequence masks the joypad and spawns this thinker together with GameOverCutsceneSprites. What the two bundles contain (the earlier 'desaturated death-screen fade' wording) was not decoded (OQ-I026-4).
---------------------------------------------

---------------------------------------------

DeathPaletteFadeThinker {
    COP [PaletteStart] ( #10 ) ; Select palette bundle $10
    COP [PaletteStep]     ; Play bundle $10 to its end (one frame per tick, the op repeats until the bundle is done)
    COP [PaletteStart] ( #0E ) ; Select palette bundle $0E
    COP [PaletteStep]     ; Play bundle $0E to its end
    COP [KillThinker]     ; Remove this thinker
    RTL 
}