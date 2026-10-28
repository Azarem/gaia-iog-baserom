; Spawn-time-gated palette swap for the South Cape interiors after the Kara-news cutscene (Bank 00, 46561-46589). Spawned in scenes 03-08 (Lance's, Eric's, Seth's and Will's houses, Chef's house and the church).
; 
; === GATE ===
; 
; Two BranchOnFlagByte checks run once when the thinker spawns: kill itself if event flag $1C is set, kill itself if event flag $16 is clear. Flag $16 is set by sc02_erik (the coastal-cave Kara-news cutscene) and $1C by sc06_monologue (Will's end-of-day narration), so the thinker lives in the window between those two events. The loop target is after the gate, so the flags are not checked again.
; 
; === BODY ===
; 
; PaletteStart #4C plus PaletteStep applies palette bundle $4C: a single 1-frame step that writes 7 colours starting at colour index $19 (decoded from the bundle table, delay 0).
; The thinker then sets event flag $FF itself and WaitOnFlagByte ( #FF, #00 ) parks until $FF is clear. $FF is the scene-setup-complete latch: scene_lifecycle clears it at the top of scene setup and again sets it at the end, and the inventory overlay clears it on open; both set it again when their setup finishes. The thinker list is rebuilt on every scene change, so within one scene visit the loop normally plays the bundle once; whether it resumes after an inventory open/close was not checked (the loop would replay the bundle).
; The spawn-record parameter byte is ignored (the bundle id is an immediate). Setting $FF early is a side effect on a shared flag; no other flag-$FF watcher was found in the lists of these scenes.
; 
; The earlier notes ('kills itself when conditions flip', 'many interior and Dark Space scenes') were wrong: the gate is evaluated only at spawn and only the scenes listed above spawn this thinker.
---------------------------------------------

---------------------------------------------

flag_gated_palette_cool [
  thinker-def < #00, #08, {

  code_00B5E1:
    COP [BranchOnFlagByte] ( #1C, #01, &FlagGatedPaletteCoolKill ) ; Gate: flag $1C (end-of-day narration) already set: die
    COP [BranchOnFlagByte] ( #16, #00, &FlagGatedPaletteCoolKill ) ; Gate: flag $16 (Kara-news cutscene) not yet set: die

; Palette loop: apply bundle $4C once, set flag $FF, wait until $FF is clear, then repeat (the gate above is not re-evaluated).

  loc_00B5ED:
    COP [PaletteStart] ( #4C ) ; Select palette bundle $4C
    COP [PaletteStep]     ; Apply the bundle (one step)
    COP [SetFlagByte] ( #FF ) ; Set the scene-setup latch $FF ourselves
    COP [WaitOnFlagByte] ( #FF, #00 ) ; Park until flag $FF is cleared (next scene setup or inventory open)
    BRA loc_00B5ED        ; Then play the bundle again
} >
]

---------------------------------------------
; Target of the gate: KillThinker, then RTL. Reached only at spawn.

FlagGatedPaletteCoolKill {
    COP [KillThinker]     ; Gate failed: remove this thinker
    RTL 
}