; One-shot scene infrastructure actor (Bank 00) bundled as slot #03 or #04 in 26 field scene templates.
; 
; On its first and only tick it executes COP SetFlagByte (#00) to clear event flag byte zero, then immediately COP Die. This guarantees a clean per-scene flag baseline before other actors, warps, and dialogue scripts read flag bytes during scene entry.
; 
; The actor is intentionally minimal (8 bytes) and never persists beyond initialization. Scenes that omit it rely on prior state or other scripts to manage flags explicitly.
---------------------------------------------

---------------------------------------------

scene_flag_init [
  actor-def < #00, #00, #10, {

  code_00C66A:
    COP [SetFlagByte] ( #00 )
    COP [Die]
} >
]