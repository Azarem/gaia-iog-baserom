; COP handlers that query the player or linked actors (Bank 00, COP #44-#49 in hex = copdef ids 68-73).
; 
; #44 BranchIfPlayerInRelTiles and #45 BranchIfPlayerInAbsTiles test whether the player actor is inside a tile rectangle and branch (four bytes: minX, minY, maxX, maxY, then a &Code target). #46/#47 copy this actor's position to its previous/next linked actor. #48 GetPlayerFacing returns the player's facing in A. #49 BranchIfBodyNe branches when characterForm differs from a byte.
; 
; Rectangle tests use unsigned compares with an exclusive lower bound and an inclusive upper bound (minX < player.X ≤ maxX, same for Y). Uses in extracted/: #44 44, #45 140, #48 6; #46, #47 and #49 have no users.
---------------------------------------------

?BANK 00

?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!characterForm                  0AD4

---------------------------------------------

; COP #44 (copdef id 68): relative tile-rectangle branch. Operands: four signed bytes in the order minX, minY, maxX, maxY (tiles, relative to this actor) plus a &Code target.
; 
; Each byte is sign-extended, multiplied by 16 (ASL ×4) and added to the actor's own X ($14) or Y ($16). The player is inside when minX < player.X ≤ maxX and minY < player.Y ≤ maxY (unsigned compares on the player actor's $14/$16). Inside → jump to the target; otherwise skip the six-byte operand block (4 bytes + &Code).

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
    CMP $0014, X          ; minX vs player X: BCS (minX ≥ player.X) = outside; inside needs player.X > minX
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
    CMP $0016, X          ; minY vs player Y: BCS (minY ≥ player.Y) = outside; inside needs player.Y > minY
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
; COP #45 (copdef id 69): absolute tile-rectangle branch. Operands: four bytes in the order minX, minY, maxX, maxY (absolute tile coordinates) plus a &Code target.
; 
; Each byte is multiplied by 16 and compared with the player actor's position. The tested point is (player.X, player.Y − 8): inside when minX×16 < X ≤ maxX×16 and minY×16 < Y−8 ≤ maxY×16. The adjusted Y is kept in scratch $0000. Inside → jump to the target; otherwise skip the six-byte operand block.

BranchIfPlayerInAbsTiles {
    PHY 
    LDX $playerActor      ; Load player actor pointer for absolute tile test
    LDY #$0000
    LDA $0016, X          ; Test point Y = player Y − 8 (kept in scratch $0000); X is compared unadjusted
    SEC 
    SBC #$0008
    STA $0000
    LDA [$0A]             ; Read first tile X byte (no sign extension, absolute coordinates)
    INY 
    AND #$00FF
    ASL                   ; Tile→pixel: ASL ×4 = ×16
    ASL 
    ASL 
    ASL 
    CMP $0014, X          ; minX×16 vs player X: BCS = outside (inside needs player.X > minX×16)
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000             ; minY×16 vs player Y−8: BCS = outside
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
; COP #46 (id 70), no operands, no users. Copies this actor's pixel position ($14/$16) to its previous linked actor ($04). No null check: with no previous actor ($04 = 0) it would write to WRAM $0014/$0016.

CopyPosToPrev {
    TYX 
    LDY $04               ; Get previous linked actor ($04 = prev pointer)
    BRA loc_00964F
}

---------------------------------------------
; COP #47 (id 71), no operands, no users. Copies this actor's pixel position ($14/$16) to its next linked actor ($06); shares the copy code with CopyPosToPrev. No null check.

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
; COP #49 (id 73), no users. One byte (form ID) plus a &Code target: branches when characterForm ($0AD4) is not equal to the byte; when equal it skips the 2-byte target.

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