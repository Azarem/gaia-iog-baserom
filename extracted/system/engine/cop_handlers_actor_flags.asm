; Two collision-layer branch COP handlers (39658–39817, Bank 00).
; 
; Despite the block name (cop_handlers_actor_flags), these are collision probes, not flag setters: both sample the collision layer at the actor's tile and branch on the result (7 script sites between them, in gw82_archer, gw82_eyesore and dm_follower_behavior).
; - BranchIfBehindWall (COP #5D): branch when the tile occludes the actor (blocked, out of bounds, or an odd type); fall through (skip the operand) when the actor is visible.
; - BranchIfCollisionTypeEq (COP #62): branch when the tile's low nibble EQUALS the operand or the position is out of bounds.
; 
; Both convert the actor position with pixel >> 4 (no −1 row adjustment, unlike TileCollisionQuery / ParseSignedTileOffset in cop_handlers_collision) and read the byte through [$80],Y after CalcTileMapOffset (Y ≥ $4000 = out of the map). The handlers return by writing the next script address to the COP frame ($02,S) and RTI.
---------------------------------------------

?BANK 00

?INCLUDE 'tile_collision_physics'

---------------------------------------------

; COP #5D wall-occlusion branch taking one &Code operand. Converts the actor pixel position to tile coordinates, samples the collision layer via CalcTileMapOffset, and decides whether the tile hides the actor. If the actor is behind a wall (high nibble set, or a low nibble other than 0 or $0E, or the position is out of the map), the script jumps to the branch target; if it is visible, the operand is skipped and the script continues. The branch is taken on occlusion, as the COP name says.
; 
; When bit 4 of byte $0F of the actor (the high byte of oamXorFlags $0E; that is OAM attribute priority bit 0, inferred) is set, the handler takes the "layer-aware" path, where both outcomes of the tile test lead to "visible", so only the out-of-map check can occlude. Used by Eyesore, the diamond-mine enemies, and similar actors.

BranchIfBehindWall {
    TYX 
    LDA $14               ; Convert actor X to tile coordinate (pixel ÷ 16 via LSR ×4)
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16               ; Convert actor Y to tile coordinate
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    PHD 
    LDA #$0000
    TCD                   ; D = 0: tile scratch $18/$1C and the map pointer [$80] are global direct-page values
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset: get collision layer pointer for tile
    CPY #$4000            ; Y ≥ $4000 means out-of-bounds → treat as occluded
    BCS loc_009B37
    LDA $000F, X          ; Absolute slot+$0F: high byte of oamXorFlags ($0E); the word's other byte is the low byte of flags $10
    AND #$0010            ; Bit 4 of byte $0F = OAM priority bit 0 (inferred): set selects the layer-aware path
    BEQ loc_009B1C
    LDA [$80], Y          ; Layer-aware mode: read the collision byte
    AND #$000F
    BEQ loc_009B2D        ; Type 0 → visible
    BRA loc_009B2D        ; Any other type → also visible (both paths share this target, so the nibble test has no effect)

  loc_009B1C:
    LDA [$80], Y          ; Standard mode: test solid nibble ($F0)
    BIT #$00F0
    BNE loc_009B37        ; Any solid bit → occluded (take branch)
    AND #$000F            ; Low nibble = 0 (empty) → visible
    BEQ loc_009B2D
    CMP #$000E            ; Type $0E = passthrough → visible despite nonzero nibble
    BNE loc_009B37

  loc_009B2D:
    PLD                   ; Visible: skip branch operand and continue script
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B37:
    PLD                   ; Occluded: take branch to target
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #62 with one byte (collision type nibble) and one &Code branch target. Samples the collision layer at the actor's tile via CalcTileMapOffset; jumps to the branch target when the tile's low nibble EQUALS the operand or the position is out of bounds, otherwise skips the branch operand. The COP name BranchIfCollisionTypeEq says "not equal" but the code branches on equality (BEQ). The solid nibble is ignored: a solid tile whose low nibble matches also branches. The operand is stored in absolute $0000 (global scratch) before D is zeroed, then compared with CMP $00, which reads the same location.

BranchIfCollisionTypeEq {
    TYX 
    LDA $14               ; Convert actor X pixel to tile coords (÷16)
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16               ; Convert actor Y to tile coords
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    LDA [$0A]             ; Read expected collision type byte operand
    INC $0A
    AND #$00FF
    STA $0000             ; Store in DP $00 for comparison
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset for collision lookup
    CPY #$4000            ; Y ≥ $4000 = out of bounds → take branch
    BCS loc_009B7F
    LDA [$80], Y          ; Read collision layer byte at tile position
    AND #$000F            ; Mask to low nibble (collision type)
    CMP $00               ; Compare against expected type
    BEQ loc_009B7F        ; Match → take branch target
    PLD 
    LDA $0A               ; No match: skip branch operand and continue
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B7F:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}