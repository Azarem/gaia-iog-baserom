; COP handlers for actor death, removal, callbacks, position queries, movement staging, OAM attributes, and extended flags (Bank $00, 37 COP handlers + 2 internal routines).
; 
; Callback setters: SetDeathCallback, SetHitCallback, SetDodgeCallback, SetCollideCallback, SetCustomCallback write script pointers into WRAM callback fields ($7F1000–$7F1016). OrExtraFlags/AndExtraFlags modify the extendedFlags word ($7F002A).
; 
; SetLinkedEntryPtr writes a far script pointer into the linked actor's entry fields. BranchIfPlayerInRelTiles/AbsTiles test whether the player falls inside a tile rectangle. CopyPosToPrev/Next copy position to adjacent list actors. GetPlayerFacing loads player direction. BranchIfBodyNe branches on characterForm.
; 
; MarkDeath/Die handle actor death — Die with child flag $0040 routes through DieNow_UnlinkChildren to cascade-remove children by parentId, then patches the doubly-linked list. MarkDeathResumeHandler restores actor context after MarkDeath's PEA/RTS dispatch. KillPrev/KillNext remove adjacent actors.
; 
; StageMoveX/Y/XY set movement deltas via AnimFrameLookup. ForceDirSW/NE/Both set direction bits on $0012. ApplyMoveToChild propagates move to the child actor. ReloadMoveDurations refreshes frame durations without changing indices. SetPriorityMax/Min/ClearPriorityMax/Min control draw priority bits. SetOamPriority/Palette write OAM attribute fields. Mirror toggles (ToggleHMirror/VMirror, ClearHMirror, SetHMirror) flip sprites. NudgePosition applies signed pixel offsets.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!characterForm                  0AD4
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!extendedFlags                  7F002A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010

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
    LDA $0A               ; Outside: skip 6-byte operand block
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
    LDA $0A               ; GetPlayerFacing: call returns 0-3 in A
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
---------------------------------------------

; COP #57 with one &Code plus one byte (bank). Stores the word pointer in onDeathCallback ($7F1004) and the bank byte in $7F1006 for the actor's death script hook.

SetDeathCallback {
    TYX 
    LDA [$0A]             ; SetDeathCallback: read pointer word
    INC $0A
    INC $0A
    STA $onDeathCallback, X ; Store to onDeathCallback ($7F1004)
    LDA [$0A]             ; Read bank byte for death callback
    INC $0A
    AND #$00FF
    STA $7F1006, X        ; Store bank to $7F1006
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #58 with one &Code operand. Stores the script pointer in onHitCallback ($7F1000) for hit-event dispatch.

SetHitCallback {
    TYX 
    LDA [$0A]             ; Read hit callback pointer and store to $7F1000
    INC $0A
    INC $0A
    STA $onHitCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #59 with one &Code operand. Stores the script pointer in onDodgeCallback ($7F1002) for dodge-event dispatch.

SetDodgeCallback {
    TYX 
    LDA [$0A]             ; Read dodge callback pointer and store to $7F1002
    INC $0A
    INC $0A
    STA $onDodgeCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5A with one &Code operand. Stores the script pointer in onCollideCallback ($7F1008) for collision-event dispatch.

SetCollideCallback {
    TYX 
    LDA [$0A]             ; Read collide callback pointer and store to $7F1008
    INC $0A
    INC $0A
    STA $onCollideCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5E with one &Code operand. Stores the script pointer in scratch1010+6 ($7F1016) for custom actor callbacks.

SetCustomCallback {
    TYX 
    LDA [$0A]             ; Read custom callback pointer and store to $7F1016
    INC $0A
    INC $0A
    STA $scratch1010+6, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5B with one word operand. ORs the value into the actor's extendedFlags word at $7F002A.

OrExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and OR into extendedFlags ($7F002A)
    INC $0A
    INC $0A
    ORA $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5C with one word operand. ANDs the value with the actor's extendedFlags word at $7F002A.

AndExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and AND with extendedFlags ($7F002A)
    INC $0A
    INC $0A
    AND $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #6A (script name SetLinkedActorScript) linked-actor entry setter taking one &Code operand. Writes the far script pointer into the linked actor ($06).$0000 and clears that actor's movement staging fields. Does not alter the caller's entry point. Used in ending-credits parade controllers.

SetLinkedEntryPtr {
    TYX 
    LDA [$0A]             ; Read entry pointer word for linked actor
    INC $0A
    INC $0A
    LDY $06               ; Get next linked actor ($06)
    STA $0000, Y          ; Write entry point to linked actor $0000
    LDA #$0000            ; Clear linked actor's movement staging ($08, $2C, $2E)
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #A7 with no operands. Unlinks the actor via UnlinkActor; if actor flag bit $0040 on $12 is set, first cascade-unlinks child actors sharing the same parentId, then resumes the calling script via MarkDeathResumeHandler.

MarkDeath {
    TYX 
    PHD                   ; Save direct page before potential child-cascade path
    LDA $12               ; MarkDeath: save DP before child-cascade
    BIT #$0040            ; Child flag $0040: route through DieNow_UnlinkChildren to cascade-remove children
    BEQ loc_00A5EC
    PEA $&MarkDeathResumeHandler-1 ; Push MarkDeathResumeHandler−1 for RTS-trick return from child cascade
    BRA loc_00A60E

  loc_00A5EC:
    JSR $&actor_pool.UnlinkActor ; UnlinkActor: direct removal when no children
}

---------------------------------------------
; PEA/RTS return target reached from MarkDeath when the dying actor has child flag $0040 set.
; 
; Restores the actor's direct page (TCD) and index register (TAX) from the stack after the child-unlinking code in loc_00A60E completes, then RTIs to resume the calling script. Separated from MarkDeath because the child-unlinking path is shared with Die via BRA loc_00A60E.

MarkDeathResumeHandler {
    PLA                   ; Resume handler: restore DP/X after child-unlinking and continue script
    TAX 
    TCD 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #E0 with no operands. If actor flag bit $0040 on $12 is set, routes through DieNow_UnlinkChildren to cascade-remove linked child actors by parentId match; otherwise calls UnlinkActor directly. Returns via RTL to terminate the script.

Die {
    TYX 
    PHD 
    LDA $12               ; Test for child flag $0040 on dying actor
    BIT #$0040
    BEQ loc_00A605        ; Test $0040 child flag
    PEA $&DieNow_UnlinkChildren-1 ; Push DieNow_UnlinkChildren−1 for RTS-trick (RTL exit after cascade)
    BRA loc_00A60E

  loc_00A605:
    JSR $&actor_pool.UnlinkActor
}

---------------------------------------------
; Cascade child-actor removal for Die/MarkDeath when actor flag $0040 is set.
; 
; The entry point (PLA/TAX/TCD/PLA/PLA/RTL) is the normal non-child Die exit. The shared child-removal code at loc_00A60E walks the doubly-linked actor list both backward ($04 pointers) and forward ($06 pointers) from the dying actor, collecting contiguous runs of actors whose parentId matches the dying actor. It then returns all collected child slots via ReturnActorSlot and patches the list pointers with three cases: head-removed (new head = forward boundary), tail-removed (new tail = backward boundary), or mid-list splice (link boundaries to each other).

DieNow_UnlinkChildren {
    PLA 
    TAX 
    TCD 
    PLA 
    PLA 
    RTL 

  loc_00A60E:
    STX $0000             ; Save dying actor pointer to $0000 for parentId matching
    LDA $0004, X          ; Start backward walk: load prev pointer ($04)
    TAX 
    BEQ loc_00A626

  loc_00A617:
    LDA $parentId, X      ; Check if prev actor's parentId matches dying actor
    CMP $0000             ; Check if prev actor parentId matches dying actor
    BNE loc_00A626        ; Mismatch: this is the backward boundary (first non-child)
    LDA $0004, X          ; Match: continue walking backward through prev pointers
    TAX 
    BNE loc_00A617

  loc_00A626:
    STX $0002             ; Store backward boundary actor to $0002
    LDX $0000
    LDA $0006, X          ; Start forward walk: load next pointer ($06) from dying actor
    TAX 
    BEQ loc_00A641

  loc_00A632:
    LDA $parentId, X      ; Check if next actor's parentId matches dying actor
    CMP $0000
    BNE loc_00A641        ; Mismatch: forward boundary found
    LDA $0006, X
    TAX 
    BNE loc_00A632

  loc_00A641:
    STX $0004             ; Store forward boundary to $0004
    LDX $0002             ; Start at backward boundary, return all child slots to pool
    BNE loc_00A64F
    LDX $0056             ; Backward boundary is null: start from list head ($0056)
    JSR $&actor_pool.ReturnActorSlot ; Backward null: start from list head ($0056)

  loc_00A64F:
    LDA $0006, X          ; Walk forward through next pointers returning each child
    CMP $0004             ; Compare current against forward boundary ($0004)
    BEQ loc_00A65D        ; Reached boundary: stop returning slots
    TAX 
    JSR $&actor_pool.ReturnActorSlot ; Return this child slot to free list
    BRA loc_00A64F

  loc_00A65D:
    LDA $0002             ; Patch linked list: handle head-removed, tail-removed, or mid-splice
    BNE loc_00A675
    LDX $0004             ; Head removed: forward boundary becomes new list head ($0056)
    STX $0056
    STZ $0004, X          ; Clear new head's prev pointer
    LDA $03, S
    TAX 
    TCD 
    LDA $0004
    STA $06
    RTS 

  loc_00A675:
    LDA $0004
    BNE loc_00A68A
    LDX $0002             ; Tail removed: backward boundary becomes new tail ($0058)
    STX $0058
    STZ $0006, X          ; Clear new tail's next pointer
    LDA $03, S
    TAX 
    TCD 
    STZ $06
    RTS 

  loc_00A68A:
    LDY $0004             ; Mid-list splice: link boundaries to each other
    LDA $0002             ; Mid-splice: link forward.prev = backward boundary
    STA $0004, Y          ; Forward boundary's prev = backward boundary
    TAX 
    TYA 
    STA $0006, X          ; Backward boundary's next = forward boundary
    TAY 
    LDA $03, S
    TAX 
    TCD 
    TYA 
    STA $06
    RTS 
}

---------------------------------------------
; COP #A8 with no operands. Switches context to the previous linked actor ($04) and unlinks it via UnlinkActor.

KillPrev {
    PHY 
    LDA $04               ; Load prev pointer for KillPrev
    TCD                   ; Switch DP to prev actor (TCD makes prev's fields accessible)
    TAX 
    JSR $&actor_pool.UnlinkActor ; Unlink the previous actor from the linked list
    PLA                   ; Restore original actor context
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A9 with no operands. Switches context to the next linked actor ($06) and unlinks it via UnlinkActor.

KillNext {
    PHY 
    LDA $06               ; Load next pointer for KillNext
    TCD 
    TAX 
    JSR $&actor_pool.UnlinkActor ; Unlink the next actor from the linked list
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AA with one byte operand (movement index). Stores it in moveXAlt and sets animation frame duration at actor+$2C via AnimFrameLookup.

StageMoveX {
    TYX 
    LDA [$0A]             ; Read X movement index byte
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store to moveXAlt ($7F0018)
    JSR $&actor_pool.AnimFrameLookup ; Compute frame duration from movement delta table
    STA $2C               ; Store X frame duration to $2C
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AB with one byte operand (movement index). Stores it in moveYAlt and sets animation frame duration at actor+$2E via AnimFrameLookup.

StageMoveY {
    TYX 
    LDA [$0A]             ; Read Y movement index byte
    INC $0A               ; StageMoveY: read Y movement index
    AND #$00FF
    STA $moveYAlt, X      ; Store to moveYAlt ($7F001A)
    JSR $&actor_pool.AnimFrameLookup ; Compute Y frame duration
    STA $2E               ; Store to $2E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AC with two byte operands (X index, Y index). Stages both moveXAlt/moveYAlt and refreshes frame durations at $2C and $2E via AnimFrameLookup.

StageMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageMoveXY: read X index
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup ; AnimFrameLookup for X -> $2C
    STA $2C
    LDA [$0A]
    INC $0A               ; Read Y index
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup ; AnimFrameLookup for Y -> $2E
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AD with one byte operand (nonzero sets, zero clears). TSB or TRB bit $4000 on actor flags $12 to force or release southwest-facing direction.

ForceDirSW {
    TYX 
    LDA [$0A]
    INC $0A               ; Nonzero operand → set $4000 (force SW facing), zero → clear
    AND #$00FF
    BEQ loc_00A727
    LDA #$4000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A727:
    LDA #$4000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AE with one byte operand (nonzero sets, zero clears). TSB or TRB bit $2000 on actor flags $12 to force or release northeast-facing direction.

ForceDirNE {
    TYX 
    LDA [$0A]
    INC $0A               ; NE facing: nonzero → set $2000, zero → clear
    AND #$00FF
    BEQ loc_00A745
    LDA #$2000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A745:
    LDA #$2000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AF with one byte operand (nonzero sets, zero clears). TSB or TRB bits $6000 on actor flags $12 to force or release both diagonal direction bits.

ForceDirBoth {
    TYX 
    LDA [$0A]
    INC $0A               ; Both diagonals: nonzero → set $6000, zero → clear
    AND #$00FF
    BEQ loc_00A763
    LDA #$6000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A763:
    LDA #$6000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B0 with two byte operands (X index, Y index). Stages movement indices and AnimFrameLookup durations on the tail child actor referenced by $0058.

ApplyMoveToChild {
    PHY 
    LDX $0058             ; Load child actor tail pointer ($0058) for movement propagation
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store X move to child's moveXAlt
    JSR $&actor_pool.AnimFrameLookup ; Compute child's X frame duration
    STA $002C, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Store Y move to child's moveYAlt
    JSR $&actor_pool.AnimFrameLookup ; Compute child's Y frame duration
    STA $002E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B1 with no operands. Re-runs AnimFrameLookup for the current moveXAlt and moveYAlt values, refreshing frame durations at actor+$2C and +$2E.

ReloadMoveDurations {
    TYX 
    LDA $moveXAlt, X      ; Re-read current moveXAlt (index unchanged)
    JSR $&actor_pool.AnimFrameLookup ; Recompute X frame duration
    STA $002C, X
    LDA $moveYAlt, X      ; Re-read current moveYAlt
    JSR $&actor_pool.AnimFrameLookup ; Recompute Y frame duration
    STA $002E, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B2 with no operands. Sets bit $0002 on actor+$10 via TSB to assign maximum draw priority.

SetPriorityMax {
    TYX 
    LDA #$0002
    TSB $10               ; SetPriorityMax: TSB $0002 on $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B3 with no operands. Sets bit $0001 on actor+$10 via TSB to assign minimum draw priority.

SetPriorityMin {
    TYX 
    LDA #$0001
    TSB $10               ; SetPriorityMin: TSB $0001 on $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B4 with no operands. Clears bit $0002 on actor+$10 via TRB to remove maximum-priority override.

ClearPriorityMax {
    TYX 
    LDA #$0002
    TRB $10               ; ClearPriorityMax: TRB $0002
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B5 with no operands. Clears bit $0001 on actor+$10 via TRB to remove minimum-priority override.

ClearPriorityMin {
    TYX 
    LDA #$0001
    TRB $10               ; ClearPriorityMin: TRB $0001
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B6 with one byte operand (0–3). Clears OAM priority bits $3000 in attribute word $0E, then XBA/TSB to pack the value into the high byte.

SetOamPriority {
    TYX 
    LDA #$3000            ; TRB #$3000: clear OAM priority bits 12–13 before set
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA                   ; XBA: shift 0–3 value from low byte to high byte for OAM field
    TSB $0E               ; TSB: merge new priority into attribute word $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B7 with one byte operand (0–7). Clears palette bits $0E00 in $0E, then XBA/TSB to set the 4-bit OAM palette subfield.

SetOamPalette {
    TYX 
    LDA #$0E00
    TRB $0E               ; Clear existing palette bits $0E00 before setting
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA                   ; XBA: shift palette value to high byte for OAM attribute field
    TSB $0E               ; TSB: merge palette into $0E attribute word
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B8 with no operands. EORs bit $4000 on OAM attribute word $0E to flip horizontal mirroring.

ToggleHMirror {
    TYX 
    LDA $0E               ; ToggleHMirror: EOR $4000 on $0E
    EOR #$4000            ; EOR $4000: toggle horizontal mirror bit
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B9 with no operands. EORs bit $8000 on OAM attribute word $0E to flip vertical mirroring.

ToggleVMirror {
    TYX 
    LDA $0E
    EOR #$8000            ; EOR $8000: toggle vertical mirror bit
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BA with no operands. Clears horizontal mirror bit $4000 on OAM attribute word $0E via TRB.

ClearHMirror {
    TYX 
    LDA #$4000            ; ClearHMirror: TRB $4000
    TRB $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BB with no operands. Sets horizontal mirror bit $4000 on OAM attribute word $0E via TSB.

SetHMirror {
    TYX 
    LDA #$4000
    TSB $0E               ; SetHMirror: TSB $4000
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BC with two signed byte operands (delta X, delta Y). Sign-extends each byte and adds the offsets to the actor's pixel position at $14/$16.

NudgePosition {
    TYX 
    LDA [$0A]             ; Read signed X offset byte
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit for 8→16 extension
    BEQ loc_00A849
    ORA #$FF00

  loc_00A849:
    CLC 
    ADC $14               ; Add signed offset to actor X position ($14)
    STA $14
    LDA [$0A]             ; Read signed Y offset byte
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test Y sign bit
    BEQ loc_00A85D
    ORA #$FF00

  loc_00A85D:
    CLC 
    ADC $16               ; Add signed offset to actor Y position ($16)
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}