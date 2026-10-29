; Parent thinker for the scenes that run palette bundle #03 and, while event flag #01 is set, a child thinker that keeps stepping the bundle. thinker-def <#00, #08>: filter word $0800, so it runs in RunThinkers_General and TypeC (every main-loop frame and the lighter frame routines); the child, spawned with SpawnThinker, inherits that word from the parent's animScratch2.
; 
; Flow: PaletteStart #03 loads bundle #03 and applies sub-entry 0, then SetEntryHere and a per-frame BranchOnFlagByte #01 poll (Val #01 = branch when the flag is set). While the flag is clear the parent only polls. When it is set, PaletteParentChildSpawnWave spawns PaletteParentChildWaveLoop (SpawnThinker returns the new slot in Y; TYA / STA store it in chatPtr = $7F000A,X), then WaitOnFlagByte #01, #00 halts until the flag clears. The parent then kills the child: PHX, PHD, X = D = the child slot from chatPtr, COP KillThinker, PLD, PLX (the handler unlinks and frees the slot named by X / D, so switching X and D is how a thinker kills another one; the only other site is the unused SceneTransPaletteThinker_unused). It jumps back to loc_00B600, which restarts bundle #03 at sub-entry 0 and polls again.
; 
; The child restarts PaletteStart #03 and runs PaletteStep in a BRA loop: PaletteStep yields until the next sub-entry is due and falls through when the bundle ends, so the palette cycles for as long as the flag is set. While the child runs the parent does not touch the palette. The child keeps its own bundle ID in its own $7F0002, so parent and child are independent users of bundle #03.
; 
; Spawn records in scene_thinkers.asm: scene $FD (thinker_spawn_0CEB30) and scene $FF (thinker_spawn_0CEB46), each with spawn parameter byte #03 (the same bundle number; the script hard-codes #03 and overwrites the parameter), next to scanline_band_hdma_thinker and ambient_palette_cycler ($FF also spawns inventory_bg3_scroll_hdma). docs/code/bank0C-scene-spawn-tables-comet.md lists the thinker for 'World Map, Inventory'; only $FD and $FF appear in the records. Which scripts set and clear flag #01 in those scenes was not traced.
---------------------------------------------

!chatPtr                        7F000A

---------------------------------------------

palette_parent_child [
  thinker-def < #00, #08, {

  loc_00B600:
    COP [PaletteStart] ( #03 ) ; Bundle #03: load and apply sub-entry 0, then yield (resumes at the SetEntryHere below)
    COP [SetEntryHere]    ; Re-entry point: from here the parent polls flag #01 every frame
    COP [BranchOnFlagByte] ( #01, #01, &PaletteParentChildSpawnWave ) ; Event flag #01 set (Val #01 = branch when set): spawn the stepping child; clear: fall to the RTL and poll again next frame
    RTL                   ; Flag clear: yield
} >
]

---------------------------------------------
; Spawns the child (PaletteParentChildWaveLoop) and stores its slot in chatPtr, waits for event flag #01 to clear, kills the child by running KillThinker with X = D = the child slot, then restarts the parent at loc_00B600 (bundle #03 sub-entry 0 and the flag poll).

PaletteParentChildSpawnWave {
    COP [SpawnThinker] ( @PaletteParentChildWaveLoop ) ; Spawn the stepping child as a thinker (it inherits this thinker's animScratch2 filter word); Y = the new slot
    TYA 
    STA $chatPtr, X       ; Remember the child slot in chatPtr ($7F000A,X) for the kill
    COP [SetEntryHere]    ; Re-entry point: wait for the flag to clear
    COP [WaitOnFlagByte] ( #01, #00 ) ; Halt until event flag #01 is clear (Val #00 = wait for clear)
    PHX                   ; Save this thinker's X (the COP needs X = D = the thinker it acts on)
    PHD                   ; Save D
    LDA $chatPtr, X       ; Child slot saved at spawn time
    TAX 
    TCD                   ; X = D = the child slot
    COP [KillThinker]     ; KillThinker acts on the child: unlinks it and returns its slot to the free list
    PLD                   ; Restore the parent's D
    PLX 
    BRA loc_00B600        ; Restart from the top: PaletteStart #03 puts the palette back at sub-entry 0, then the flag poll
}

---------------------------------------------
; Child thinker: PaletteStart #03 (load sub-entry 0, yield), PaletteStep (yield until the next sub-entry; falls through at the end of the bundle), BRA back. Runs until the parent kills it when flag #01 clears.

PaletteParentChildWaveLoop {
    COP [PaletteStart] ( #03 ) ; Child: (re)load bundle #03 sub-entry 0 and yield
    COP [PaletteStep]     ; PaletteStep: yields until the next sub-entry is due; continues here once the bundle has ended
    BRA PaletteParentChildWaveLoop ; Loop forever; the parent kills this thinker when flag #01 clears
}