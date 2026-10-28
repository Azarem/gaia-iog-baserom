; Walk-step table (Bank 01, 109534-109551): nine 2-byte direction-velocity entries, indexed by a step code $00-$08. Each entry is { byte 0 = player animation index, byte 1 = move_chain_table index (velocity chain) }. The two bytes are read together as one word, animation index in the low byte.
; 
; Where the step code comes from and what reads it:
; - Scene entry: InitActorFromSceneData indexes the table with the scene's facing value (warpFacing $0650) and stores only byte 0 as the player's initial animation index ($28). The velocity byte is not used there.
; - In-scene forced walks (forced_walk): ReadDirSprite_YVelocity / ReadDirSprite_XVelocity fetch one step code per step from the warp's walk-step stream, hand byte 0 to StagePlayerSprFromDP through $0000, and use byte 1 to load the head of a delta-node chain from move_chain_table into $2E (Y axis) or $2C (X axis).
; 
; The old header called byte 0 a 'base sprite frame' and byte 1 a 'movement speed' with entries named S, N, E, W, SE, SW, NE, NW. Neither holds: the entries are step codes, not compass directions, and byte 1 is a table index, not a speed (see the part note for the decoded rows).
; 
; Checked: all nine entries decoded against FacingDirectionLookup (GetPlayerFacingDirection) and move_chain_table; both loaders and the scene-entry reader read in full. Not traced at runtime (UNVERIFIED-RUNTIME): what each step code looks like in game.
---------------------------------------------

?BANK 01

---------------------------------------------

; Step code -> (animation index, move_chain_table index). FacingDirectionLookup maps animation index 8 = down, 9 = up, 2 = left, 3 = right; move_chain_table index $11 / $12 / $13 / $14 = +1 / -1 / +1 / -1 on one frame in 2 / 2 / 4 / 4 (average +1/2, -1/2, +1/4, -1/4 pixel per frame, assuming one node per frame as ApplyMovement does).
; 
; | Code | Anim | Facing | Velocity chain |
; |------|------|--------|----------------|
; | $00 | 9 | up | $12 (-1/2 px per frame) |
; | $01 | 8 | down | $11 (+1/2) |
; | $02 | 9 | up | $14 (-1/4) |
; | $03 | 8 | down | $11 (+1/2) |
; | $04 | 9 | up | $14 (-1/4) |
; | $05 | 9 | up | $12 (-1/2) |
; | $06 | 2 | left | none ($00) |
; | $07 | 3 | right | none ($00) |
; | $08 | 8 | down | $13 (+1/4) |
; 
; Codes $00 = $05, $01 = $03 and $02 = $04 are identical rows (OQ-I061-2). Left and right steps carry no velocity chain: the east and west forced-walk actors move through the camera pan (CameraPanRight and its mirror), not through this table. The vertical sign of every chain agrees with the facing (up = negative, down = positive).

walk_step_table [
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