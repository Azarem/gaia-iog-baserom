; Initial wall tile setup for the mine zigzag area (map $41).
; 
; Draws solid metatile #05 at two positions (column $26 row 1, and
; column $22 row 1), then marks both tiles as solid-high collision.
; Used to block off passages before the player clears them. Despawns
; immediately after drawing.
---------------------------------------------

---------------------------------------------

dm41_solid_wall_setup [
  actor-def < #00, #00, #30, {

  code_05D6F6:
    COP [DrawMetatileAbs] ( #26, #01, #05 )
    COP [DrawMetatileAbs] ( #22, #01, #05 )
    COP [SolidHighAbs] ( #26, #01 )
    COP [SolidHighAbs] ( #22, #01 )
    COP [Die]
} >
]