?BANK 00

?INCLUDE 'tile_collision_physics'

---------------------------------------------

; COP #5D wall-occlusion branch taking one &Code operand. Converts the actor pixel position to tile coordinates, samples collisionLayer via CalcTileMapOffset, and checks layer-aware visibility. If the actor is visible (not behind a blocking tile), the script jumps to the branch target; if occluded, it skips the operand and continues. Used by Eyesore, diamond-mine enemies, and similar actors that should only activate when unobstructed.

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
    TCD                   ; CalcTileMapOffset: collision layer pointer for tile
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset: get collision layer pointer for tile
    CPY #$4000            ; Y ≥ $4000 means out-of-bounds → treat as occluded
    BCS loc_009B37
    LDA $000F, X
    AND #$0010            ; Test actor flag $0010 for layer-aware occlusion mode
    BEQ loc_009B1C
    LDA [$80], Y          ; Layer-aware mode: check collision nibble
    AND #$000F
    BEQ loc_009B2D
    BRA loc_009B2D

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
; COP #62 with one byte (collision type nibble) and one &Code branch target. Samples collisionLayer at the actor's tile via CalcTileMapOffset; jumps to the branch target when the tile's low nibble equals the operand or the position is out of bounds, otherwise skips the branch operand.

BranchIfCollisionTypeNe {
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