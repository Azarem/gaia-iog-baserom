; One-shot thinker spawned by GameOverSequence (COP SpawnThinker) that plays palette bundle $10, then bundle $0E, then kills itself.
; 
; PaletteStart selects a palette bundle and PaletteStep then plays its strips one frame per tick, continuing past the op only when the bundle ends, so each pair runs one whole bundle. combat_collision assigns GameOverSequence to the player when HP reaches zero; the sequence masks the joypad and spawns this thinker together with GameOverCutsceneSprites. Bundle $10 is one strip of 8 frames of 16 colour words each, written to colour indices $81-$90 with 3 extra ticks per frame; its last frame is a pale blue / lavender set (for example $7E10 = R16 G16 B31, $7F18 = R24 G24 B31, $7BDE = R30 G30 B30) and its first frame begins $1080, $1008, $104A. Bundle $0E is a single frame of 15 words written to colour indices $F1-$FF: the same 15 colours as the first 15 words of that last frame. Which screen elements use those colour indices is not traced.
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