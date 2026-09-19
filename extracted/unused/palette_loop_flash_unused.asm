; Unreferenced one-shot thinker that runs PaletteStartLoop on animation #14 for 7 steps, then a single #0B palette step before exiting.
; 
; Would have produced a brief looping flash followed by a fade. Discarded alternative to the oneshot_palette_flash_* family.
---------------------------------------------

---------------------------------------------

palette_loop_flash_unused [
  thinker-def < #00, #08, {

  code_00B80A:
    COP [PaletteStartLoop] ( #14, #07 )
    COP [PaletteStepLoop]
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]