; Generic ambient palette animation thinker (Bank 00, priority $08) referenced ~60 times in scene_thinkers.asm.
; 
; The thinker script is an infinite loop: PaletteRestart once on entry, then PaletteStep every frame forever. The palette bundle index is not hardcoded — it comes from the thinker-spawn parameter byte, so one 8-byte routine drives torch flicker, water shimmer, sky gradients, and other ambient color cycling across the game.
; 
; Scenes attach multiple instances with different bundle IDs to animate independent palette slots concurrently. It is the most reused thinker in IOG and has no flag gating or termination logic of its own.
---------------------------------------------

---------------------------------------------

ambient_palette_cycler [
  thinker-def < #00, #08, {

  code_00B522:
    COP [PaletteRestart]
    COP [PaletteStep]
    BRA code_00B522       ; Check X grid alignment: (X - 8) for sprite center
} >
]