?BANK 00

?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!characterForm                  0AD4

---------------------------------------------

; COP #44 relative tile-region branch taking four signed byte offsets (minX, maxX, minY, maxY) plus one &Code operand. Builds a pixel rectangle relative to the current actor position and tests whether the player actor falls inside it on both axes. If the player is inside, the script jumps to the branch target; otherwise it skips the six-byte operand block.

BranchIfPlayerInRelTiles {
    PHY 
    LDX $playerActor      ; Load player actor pointer for position testing
    LDY #$0000
    LDA [$0A]             ; Read 4 signed tile-offset bytes as relative rectangle operands
    INY 
    AND #$00FF
    BIT #$0080            ; Test sign bit for sign extension (negative offset)
    BEQ loc_009580
    ORA #$FF00

  loc_009580:
    ASL                   ; Tile→pixel: ASL ×4 = multiply by 16
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14               ; minX = actor.X + signed tile offset × 16
    CMP $0014, X          ; Test player.X ≥ minX (BCS = player below minimum → outside)
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_00959A
    ORA #$FF00

  loc_00959A:
    ASL                   ; minY tile->pixel conversion + actor.Y
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16               ; minY = actor.Y + signed tile offset × 16
    CMP $0016, X          ; Test player.Y ≥ minY
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095B4
    ORA #$FF00

  loc_0095B4:
    ASL                   ; maxX tile→pixel conversion
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14               ; maxX = actor.X + signed tile offset × 16
    CMP $0014, X          ; Test player.X ≤ maxX (BCC = player exceeds maximum → outside)
    BCC loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095CE
    ORA #$FF00

  loc_0095CE:
    ASL                   ; maxY tile→pixel conversion
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16               ; maxY = actor.Y + signed tile offset × 16
    CMP $0016, X          ; Test player.Y ≤ maxY
    BCC loc_0095E0
    PLX                   ; Inside rectangle: restore X and branch to target
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_0095E0:
    PLX                   ; Outside rectangle: skip 6-byte operand block
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #45 with four byte operands (min tile X, max tile X, min tile Y, max tile Y) plus one &Code branch. Converts tile coords to pixels (×16) and branches if the player actor's position falls inside the rectangle (Y compared against player Y minus 8).

BranchIfPlayerInAbsTiles {
    PHY 
    LDX $playerActor      ; Load player actor pointer for absolute tile test
    LDY #$0000
    LDA $0016, X          ; Get player Y, subtract 8 for sprite center offset
    SEC                   ; Player Y - 8 for sprite center offset
    SBC #$0008
    STA $0000
    LDA [$0A]             ; Read first tile X byte (no sign extension, absolute coordinates)
    INY 
    AND #$00FF
    ASL                   ; Tile→pixel: ASL ×4 = ×16
    ASL 
    ASL 
    ASL 
    CMP $0014, X          ; Compare minX × 16 against player X
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000             ; minY x 16 vs player Y
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL                   ; maxX tile → pixel for upper-bound check
    ASL 
    ASL 
    ASL 
    CMP $0014, X          ; Player X ≤ maxX (BCC = outside)
    BCC loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL                   ; maxY tile → pixel
    ASL 
    ASL 
    ASL 
    CMP $0000             ; Player Y ≤ maxY (BCC = outside)
    BCC loc_00963D
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_00963D:
    PLX 
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #46 with no operands. Copies the current actor's pixel position ($14/$16) to the previous linked actor at offset $04.

CopyPosToPrev {
    TYX 
    LDY $04               ; Get previous linked actor ($04 = prev pointer)
    BRA loc_00964F
}

---------------------------------------------
; COP #47 with no operands. Copies the current actor's pixel position ($14/$16) to the next linked actor at offset $06.

CopyPosToNext {
    TYX 
    LDY $06               ; Get next linked actor ($06 = next pointer)

  loc_00964F:
    LDA $14               ; Copy actor X position to linked actor's $14
    STA $0014, Y
    LDA $16               ; Copy actor Y position to linked actor's $16
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #48 with no operands. Saves the script return address and calls GetPlayerFacingDirection; the facing value (0–3) is returned in accumulator A on RTI.

GetPlayerFacing {
    TYX 
    LDA $0A               ; Save script resume pointer
    STA $02, S
    JSL $@GetPlayerFacingDirection ; Call GetPlayerFacingDirection — returns 0–3 in A
    RTI 
}

---------------------------------------------
; COP #49 with one byte (expected form ID) plus one &Code branch. Branches to the target offset when characterForm ($0AD4) does not match the operand; if the form matches, skips the branch.

BranchIfBodyNe {
    TYX 
    LDA [$0A]             ; Read expected body form ID byte
    INC $0A
    AND #$00FF
    CMP $characterForm    ; Compare against characterForm ($0AD4)
    BNE loc_00967C        ; Not equal -> branch to target offset
    LDA $0A               ; Match: skip 2-byte branch operand and continue
    INC 
    INC 
    STA $02, S
    RTI 

  loc_00967C:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}