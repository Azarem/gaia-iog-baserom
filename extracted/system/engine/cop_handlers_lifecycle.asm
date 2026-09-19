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
    LDX $playerActor
    LDY #$0000
    LDA [$0A]             ; Four signed byte tile offsets define a pixel rectangle relative to actor
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_009580
    ORA #$FF00

  loc_009580:
    ASL                   ; Tile→pixel (×16); test player.X ≥ actor.X + minX offset (BCS = outside)
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_00959A
    ORA #$FF00

  loc_00959A:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCS loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095B4
    ORA #$FF00

  loc_0095B4:
    ASL                   ; Upper bounds: test player.X ≤ maxX and player.Y ≤ maxY (BCC = outside)
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCC loc_0095E0
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0095CE
    ORA #$FF00

  loc_0095CE:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCC loc_0095E0
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_0095E0:
    PLX 
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
    LDX $playerActor
    LDY #$0000
    LDA $0016, X
    SEC 
    SBC #$0008
    STA $0000
    LDA [$0A]
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCS loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCC loc_00963D
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
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
    LDY $04
    BRA loc_00964F
}

---------------------------------------------
; COP #47 with no operands. Copies the current actor's pixel position ($14/$16) to the next linked actor at offset $06.

CopyPosToNext {
    TYX 
    LDY $06

  loc_00964F:
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #48 with no operands. Saves the script return address and calls GetPlayerFacingDirection; the facing value (0–3) is returned in accumulator A on RTI.

GetPlayerFacing {
    TYX 
    LDA $0A
    STA $02, S
    JSL $@GetPlayerFacingDirection
    RTI 
}

---------------------------------------------
; COP #49 with one byte (expected form ID) plus one &Code branch. Branches to the target offset when characterForm ($0AD4) does not match the operand; if the form matches, skips the branch.

BranchIfBodyNe {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $characterForm
    BNE loc_00967C
    LDA $0A
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
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDeathCallback, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F1006, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #58 with one &Code operand. Stores the script pointer in onHitCallback ($7F1000) for hit-event dispatch.

SetHitCallback {
    TYX 
    LDA [$0A]
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
    LDA [$0A]
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
    LDA [$0A]
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
    LDA [$0A]
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
    LDA [$0A]
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
    LDA [$0A]
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
    LDA [$0A]
    INC $0A
    INC $0A
    LDY $06
    STA $0000, Y
    LDA #$0000
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
    PHD 
    LDA $12
    BIT #$0040            ; Child flag $0040: route through DieNow_UnlinkChildren to cascade-remove children
    BEQ loc_00A5EC
    PEA $&MarkDeathResumeHandler-1
    BRA loc_00A60E

  loc_00A5EC:
    JSR $&actor_pool.UnlinkActor
}

---------------------------------------------
; PEA/RTS return target reached from MarkDeath when the dying actor has child flag $0040 set.
; 
; Restores the actor's direct page (TCD) and index register (TAX) from the stack after the child-unlinking code in loc_00A60E completes, then RTIs to resume the calling script. Separated from MarkDeath because the child-unlinking path is shared with Die via BRA loc_00A60E.

MarkDeathResumeHandler {
    PLA                   ; Restore actor direct page and index after child-unlinking completes
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
    LDA $12
    BIT #$0040
    BEQ loc_00A605
    PEA $&DieNow_UnlinkChildren-1
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
    STX $0000             ; Save dying actor pointer; walk backward ($04) to find first non-child
    LDA $0004, X
    TAX 
    BEQ loc_00A626

  loc_00A617:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A626
    LDA $0004, X
    TAX 
    BNE loc_00A617

  loc_00A626:
    STX $0002             ; $0002 = backward boundary; walk forward ($06) to find first non-child after
    LDX $0000
    LDA $0006, X
    TAX 
    BEQ loc_00A641

  loc_00A632:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A641
    LDA $0006, X
    TAX 
    BNE loc_00A632

  loc_00A641:
    STX $0004             ; $0004 = forward boundary; return all child slots between boundaries
    LDX $0002
    BNE loc_00A64F
    LDX $0056
    JSR $&actor_pool.ReturnActorSlot

  loc_00A64F:
    LDA $0006, X          ; Return slots by walking next pointers until reaching forward boundary $0004
    CMP $0004
    BEQ loc_00A65D
    TAX 
    JSR $&actor_pool.ReturnActorSlot
    BRA loc_00A64F

  loc_00A65D:
    LDA $0002             ; Patch list pointers: head-removed, tail-removed, or mid-list splice
    BNE loc_00A675
    LDX $0004
    STX $0056
    STZ $0004, X
    LDA $03, S
    TAX 
    TCD 
    LDA $0004
    STA $06
    RTS 

  loc_00A675:
    LDA $0004
    BNE loc_00A68A
    LDX $0002
    STX $0058
    STZ $0006, X
    LDA $03, S
    TAX 
    TCD 
    STZ $06
    RTS 

  loc_00A68A:
    LDY $0004
    LDA $0002
    STA $0004, Y
    TAX 
    TYA 
    STA $0006, X
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
    LDA $04
    TCD 
    TAX 
    JSR $&actor_pool.UnlinkActor
    PLA 
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
    LDA $06
    TCD 
    TAX 
    JSR $&actor_pool.UnlinkActor
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AB with one byte operand (movement index). Stores it in moveYAlt and sets animation frame duration at actor+$2E via AnimFrameLookup.

StageMoveY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AC with two byte operands (X index, Y index). Stages both moveXAlt/moveYAlt and refreshes frame durations at $2C and $2E via AnimFrameLookup.

StageMoveXY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
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
    INC $0A               ; Nonzero operand sets $4000; zero operand clears — controls SW facing
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
    INC $0A
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
    INC $0A
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
    LDX $0058
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002C, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
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
    LDA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002C, X
    LDA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
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
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B3 with no operands. Sets bit $0001 on actor+$10 via TSB to assign minimum draw priority.

SetPriorityMin {
    TYX 
    LDA #$0001
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B4 with no operands. Clears bit $0002 on actor+$10 via TRB to remove maximum-priority override.

ClearPriorityMax {
    TYX 
    LDA #$0002
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B5 with no operands. Clears bit $0001 on actor+$10 via TRB to remove minimum-priority override.

ClearPriorityMin {
    TYX 
    LDA #$0001
    TRB $10
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
    XBA 
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B7 with one byte operand (0–7). Clears palette bits $0E00 in $0E, then XBA/TSB to set the 4-bit OAM palette subfield.

SetOamPalette {
    TYX 
    LDA #$0E00
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    TSB $0E               ; XBA + TSB: pack 4-bit OAM palette into attribute word
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B8 with no operands. EORs bit $4000 on OAM attribute word $0E to flip horizontal mirroring.

ToggleHMirror {
    TYX 
    LDA $0E
    EOR #$4000
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
    EOR #$8000
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BA with no operands. Clears horizontal mirror bit $4000 on OAM attribute word $0E via TRB.

ClearHMirror {
    TYX 
    LDA #$4000
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
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BC with two signed byte operands (delta X, delta Y). Sign-extends each byte and adds the offsets to the actor's pixel position at $14/$16.

NudgePosition {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A849
    ORA #$FF00

  loc_00A849:
    CLC 
    ADC $14
    STA $14
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A85D
    ORA #$FF00

  loc_00A85D:
    CLC 
    ADC $16
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}