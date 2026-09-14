; Direction→sprite frame + velocity mapping. 9 entries for cardinal/diagonal directions plus idle states. Used by actor execution and forced walk systems.
---------------------------------------------

?BANK 01

---------------------------------------------

; Maps 9 cardinal/diagonal directions to sprite frame and velocity parameters. Each 2-byte direction-velocity entry: byte 0 = base animation frame for that direction, byte 1 = movement speed. Entries cover S, N, E, W, SE, SW, idle variants, and NE/NW. Referenced by actor_execution.asm (actor facing) and forced_walk.asm (forced movement velocity per direction).

direction_velocity_table [
  direction-velocity < #09, #12 >   ;00
  direction-velocity < #08, #11 >   ;01
  direction-velocity < #09, #14 >   ;02
  direction-velocity < #08, #11 >   ;03
  direction-velocity < #09, #14 >   ;04
  direction-velocity < #09, #12 >   ;05
  direction-velocity < #02, #00 >   ;06
  direction-velocity < #03, #00 >   ;07
  direction-velocity < #08, #13 >   ;08
]