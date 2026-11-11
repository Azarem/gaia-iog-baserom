; Spawn-time-gated palette swap for the South Cape interiors after the Kara-news cutscene (Bank 00, 46561-46589). Spawned in scenes 03-08 (Lance's, Eric's, Seth's and Will's houses, Chef's house and the church).
; 
; === GATE ===
; 
; Two BranchOnFlagByte checks run once when the thinker spawns: kill itself if event flag $1C is set, kill itself if event flag $16 is clear. Flag $16 is set by sc02_erik (the coastal-cave Kara-news cutscene) and $1C by sc06_monologue (Will's end-of-day narration), so the thinker lives in the window between those two events. The loop target is after the gate, so the flags are not checked again.
; 
; === BODY ===
; 
; PaletteStart #4C plus PaletteStep applies palette bundle $4C: a single 1-frame step that writes 7 colours starting at colour index $19 (decoded from the bundle table, delay 0). Measured in scene 03 with flag $16 set: the seven colours go from (near) black ($0000 for $19-$1C, $0002, $0400, $0020 for $1D-$1F) to $18ED, $192F, $1D91, $1DF4, $2236, $2298, $26FB, dark brown to red-orange tones with red the largest channel.
; The thinker then sets event flag $FF itself and WaitOnFlagByte ( #FF, #00 ) parks until $FF is clear. $FF is the scene-setup-complete latch: scene_lifecycle clears it at the top of scene setup and again sets it at the end, and the inventory overlay clears it on open; both set it again when their setup finishes. Scene setup never wakes the loop: the thinker list is built after the clear at the top of scene setup, so the bundle plays once on entering the scene. It plays again after every inventory close: the overlay clears $FF at open, restores the saved thinker list at close and runs one thinker pass while $FF is still clear (UpdateFrameRender, after ResetThinkerWaitCounters) before it sets $FF again, so the wait ends in that pass (measured in scenes 03-07: one extra start of bundle $4C per open/close, after the overlay has closed, in the same scene; scene 08 masks the joypad on arrival, so no overlay was opened there).
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
    COP [WaitOnFlagByte] ( #FF, #00 ) ; Park until flag $FF is cleared (the first thinker pass after an inventory close)
    BRA loc_00B5ED        ; Then play the bundle again
} >
]

---------------------------------------------
; Target of the gate: KillThinker, then RTL. Reached only at spawn.

FlagGatedPaletteCoolKill {
    COP [KillThinker]     ; Gate failed: remove this thinker
    RTL 
}