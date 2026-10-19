
!key_item_flags      0B58
!joypadMaskStd       065A
!joypadRaw           0660
!displayModeFlags    09EC
!tileQueryResult     0902
!inventorySlots      0AB4
!sfxQueueCh2         06F9

; Cycle display order: when pressing Up/Down, hieroglyphs appear
; in this sequence rather than numeric order.
; Position 0→hiero 2, 1→5, 2→1, 3→3, 4→0, 5→4
hieroglyphOrderCombination [
    #020501030004
]

; Reverse lookup: hieroglyph index → position in cycle order.
; hiero 0→pos 4, 1→2, 2→0, 3→3, 4→5, 5→1
hieroCycleReverse [
    #04
    #02
    #00
    #03
    #05
    #01
]

; Bit masks for availability (hieroglyph index → bit)
hieroBitTable [
    #01
    #02
    #04
    #08
    #10
    #20
]

-------------------------------------------
; Interactable actor placed at the wall.
; On interact: checks if any hieroglyph is available,
; then spawns the puzzle controller.

pyCD_puzzle_activator {
    COP [SetInteractHandler] ( &pyCD_puzzle_activator_interact )
    COP [WaitOnFlagByte] ( #D1, #01 )
    COP [Die]
}

pyCD_puzzle_activator_interact {
    COP [BranchOnFlagByte] ( #0F, #00, &pyCD_puzzle_activator_clear )
    RTL
}

pyCD_puzzle_activator_clear {
    LDA $key_item_flags+3
    BIT #$003F
    BNE pyCD_puzzle_activator_spawn
    COP [BranchIfHasItem] ( #1E, &pyCD_puzzle_activator_spawn )
    COP [BranchIfHasItem] ( #1F, &pyCD_puzzle_activator_spawn )
    COP [BranchIfHasItem] ( #20, &pyCD_puzzle_activator_spawn )
    COP [BranchIfHasItem] ( #21, &pyCD_puzzle_activator_spawn )
    COP [BranchIfHasItem] ( #22, &pyCD_puzzle_activator_spawn )
    COP [BranchIfHasItem] ( #23, &pyCD_puzzle_activator_spawn )
    COP [PrintDialogString] ( &pyCD_puzzle_no_items_str )
    RTL
}

pyCD_puzzle_activator_spawn {
    COP [SpawnListAppend] ( @pyCD_puzzle_controller, #00, #00, #$2000 )
    RTL
}

-------------------------------------------

pyCD_puzzle_no_items_str `[DEF]There are six alcoves[N]in this wall. I wonder[N]what they could be for...[END]`

-------------------------------------------
; Interactive puzzle controller.
; Spawned when player interacts with the wall.
;
; Actor scratch layout ($20-$2F only — $30+ overflows into next actor):
;   $20 = cursor slot (0-5)
;   $22 = previous frame joypadRaw (edge detection)
;   $24 = edge-detected buttons / old cursor during deferred (dual-use)
;   $26 = scratch (cycle candidate / slot counter / metatile temp)
;   $28 = scratch (guard counter / owned count / VRAM addr temp)
;   $2A = placed-count scratch / deferred state (dual-use, see below)
;   $2C = swap mode flag (0 = normal, non-zero = swap active)
;   $2E = floating hieroglyph index (valid when $2C != 0)
;
; $24 and $2A are dual-purpose: during deferred visual updates input
; is skipped entirely (RTL before edge detection), so these fields
; are never overwritten by transient scratch. $2A holds the deferred
; state (0 = idle), $24 holds the old cursor slot for swap moves.
;
; Input is read from joypadRaw ($0660) which bypasses
; joypadMaskStd filtering, then edge-detected manually.

pyCD_puzzle_controller {
    ; === INIT ===
    LDA #$CFFC
    TSB $joypadMaskStd

    LDA #$0000
    STA $20
    STA $22
    STA $2A
    STA $2C

    JSR $&PuzzleDrawIndicators

    ; === MAIN LOOP ===
    COP [SetEntryHere]

    ; Process deferred visual updates before handling input
    LDA $2A
    BEQ puzzle_no_deferred
    JSR $&PuzzleProcessDeferred
    RTL

  puzzle_no_deferred:
    ; Edge-detect: (raw XOR prev) AND raw = newly pressed
    LDA $joypadRaw
    TAY
    EOR $22
    AND $joypadRaw
    STY $22
    STA $24
    BEQ puzzle_ctrl_done

    ; Check swap mode
    LDA $2C
    BNE puzzle_swap_dispatch

    ; === NORMAL MODE ===
    LDA $24

    ; Confirm ($8000)
    BIT #$8000
    BEQ puzzle_skip_confirm
    JMP $&puzzle_ctrl_confirm

  puzzle_skip_confirm:
    ; Cancel ($4000 = B after IOG remap)
    BIT #$4000
    BEQ puzzle_skip_cancel
    JMP $&puzzle_ctrl_exit

  puzzle_skip_cancel:
    BIT #$0200
    BEQ puzzle_skip_left
    JMP $&puzzle_ctrl_left

  puzzle_skip_left:
    BIT #$0100
    BEQ puzzle_skip_right
    JMP $&puzzle_ctrl_right

  puzzle_skip_right:
    BIT #$0800
    BEQ puzzle_skip_up
    JMP $&puzzle_ctrl_up

  puzzle_skip_up:
    BIT #$0400
    BEQ puzzle_ctrl_done
    JMP $&puzzle_ctrl_down

  puzzle_swap_dispatch:
    ; === SWAP MODE ===
    LDA $24

    ; Confirm or Cancel → exit swap
    BIT #$C000
    BEQ puzzle_swap_skip_exit
    JMP $&puzzle_swap_exit

  puzzle_swap_skip_exit:
    ; Left → swap left
    BIT #$0200
    BEQ puzzle_swap_skip_left
    JMP $&puzzle_swap_left

  puzzle_swap_skip_left:
    ; Right → swap right
    BIT #$0100
    BEQ puzzle_ctrl_done
    JMP $&puzzle_swap_right

  puzzle_ctrl_done:
    RTL
}

-------------------------------------------
; Left handler: move cursor left (wraps 0 → 5).

puzzle_ctrl_left {
    JSR $&PuzzleClearIndicators

    LDA $20
    DEC
    BPL puzzle_left_ok
    LDA #$0005

  puzzle_left_ok:
    STA $20

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

    JSR $&PuzzleDrawIndicators
    RTL
}

-------------------------------------------
; Right handler: move cursor right (wraps 5 → 0).

puzzle_ctrl_right {
    JSR $&PuzzleClearIndicators

    LDA $20
    INC
    CMP #$0006
    BCC puzzle_right_ok
    LDA #$0000

  puzzle_right_ok:
    STA $20

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

    JSR $&PuzzleDrawIndicators
    RTL
}

-------------------------------------------
; Confirm handler: enter swap mode if the current slot has a tile.
; Lifts the tile out of the slot (clears slot, draws tile above).

puzzle_ctrl_confirm {
    LDA $20
    ASL
    TAY
    LDA $0B28, Y
    BMI puzzle_confirm_done

    ; Save the hieroglyph and empty the slot
    AND #$00FF
    STA $2E
    LDA #$FFFF
    STA $0B28, Y
    LDA #$FFFF
    STA $2C

    ; Clear the slot metatile (immediate)
    JSR $&PuzzleClearSlotMetatile
    ; Defer: draw floating tile above on next frame
    LDA #$0001
    STA $2A

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

  puzzle_confirm_done:
    RTL
}

-------------------------------------------
; Up handler: cycle to the next available hieroglyph in display order.
; Uses hieroglyphOrderCombination for the cycling sequence.

puzzle_ctrl_up {
    JSR $&PuzzleBuildAvailability
    LDA $24
    AND #$003F
    BEQ puzzle_up_done

    ; Determine starting cycle position
    LDA $20
    ASL
    TAY
    LDA $0B28, Y
    BMI puzzle_up_from_empty

    ; Filled slot: look up its cycle position, start from next
    AND #$00FF
    PHX
    TAX
    SEP #$20
    LDA $@hieroCycleReverse, X
    REP #$20
    PLX
    AND #$00FF
    INC
    BRA puzzle_up_scan

  puzzle_up_from_empty:
    LDA #$0000

  puzzle_up_scan:
    STA $26
    LDA #$0006
    STA $28

  puzzle_up_loop:
    LDA $26
    CMP #$0006
    BCC puzzle_up_test
    LDA #$0000
    STA $26

  puzzle_up_test:
    ; Look up hieroglyph at this cycle position
    LDA $26
    AND #$00FF
    PHX
    TAX
    SEP #$20
    LDA $@hieroglyphOrderCombination, X
    TAX
    LDA $@hieroBitTable, X
    BIT $24
    REP #$20
    BNE puzzle_up_match
    PLX

    LDA $26
    INC
    STA $26
    LDA $28
    DEC
    STA $28
    BNE puzzle_up_loop
    BRA puzzle_up_done

  puzzle_up_match:
    STX $26
    PLX

  puzzle_up_found:
    LDA $20
    ASL
    TAY
    LDA $26
    AND #$00FF
    STA $0B28, Y
    JSR $&PuzzleUpdateSlotMetatile

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

  puzzle_up_done:
    RTL
}

-------------------------------------------
; Down handler: cycle to the previous available hieroglyph in display order.
; Uses hieroglyphOrderCombination for the cycling sequence.

puzzle_ctrl_down {
    JSR $&PuzzleBuildAvailability
    LDA $24
    AND #$003F
    BEQ puzzle_down_done

    ; Determine starting cycle position
    LDA $20
    ASL
    TAY
    LDA $0B28, Y
    BMI puzzle_down_from_empty

    ; Filled slot: look up its cycle position, start from previous
    AND #$00FF
    PHX
    TAX
    SEP #$20
    LDA $@hieroCycleReverse, X
    REP #$20
    PLX
    AND #$00FF
    DEC
    BRA puzzle_down_scan

  puzzle_down_from_empty:
    LDA #$0005

  puzzle_down_scan:
    STA $26
    LDA #$0006
    STA $28

  puzzle_down_loop:
    LDA $26
    BPL puzzle_down_test
    LDA #$0005
    STA $26

  puzzle_down_test:
    ; Look up hieroglyph at this cycle position
    LDA $26
    AND #$00FF
    PHX
    TAX
    SEP #$20
    LDA $@hieroglyphOrderCombination, X
    TAX
    LDA $@hieroBitTable, X
    BIT $24
    REP #$20
    BNE puzzle_down_match
    PLX

    LDA $26
    DEC
    STA $26
    LDA $28
    DEC
    STA $28
    BNE puzzle_down_loop
    BRA puzzle_down_done

  puzzle_down_match:
    STX $26
    PLX

  puzzle_down_found:
    LDA $20
    ASL
    TAY
    LDA $26
    AND #$00FF
    STA $0B28, Y
    JSR $&PuzzleUpdateSlotMetatile

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

  puzzle_down_done:
    RTL
}

-------------------------------------------
; Swap exit: drop floating tile back into the current slot.
; Pressing Confirm or Cancel in swap mode lands here.

puzzle_swap_exit {
    LDA $20
    ASL
    TAY
    LDA $2E
    AND #$00FF
    STA $0B28, Y

    STZ $2C

    ; Clear floating tile above (immediate)
    JSR $&PuzzleClearAboveTile
    ; Defer: redraw slot metatile on next frame
    LDA #$0005
    STA $2A

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    RTL
}

-------------------------------------------
; Swap left: move floating tile left, swap adjacent tile right.

puzzle_swap_left {
    LDA $20
    BEQ puzzle_swap_left_done

    JSR $&PuzzleClearIndicators

    LDA $20
    STA $24

    ; Data swap: left tile fills current empty slot
    LDA $20
    ASL
    TAY
    LDA $0B26, Y
    STA $0B28, Y
    LDA #$FFFF
    STA $0B26, Y

    ; Move cursor left
    LDA $20
    DEC
    STA $20

    JSR $&PuzzleDrawIndicators

    ; Clear new slot metatile (immediate)
    JSR $&PuzzleClearSlotMetatile
    ; Defer: clear old floating → draw new floating → redraw old slot
    LDA #$0006
    STA $2A

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

  puzzle_swap_left_done:
    RTL
}

-------------------------------------------
; Swap right: move floating tile right, swap adjacent tile left.

puzzle_swap_right {
    LDA $20
    CMP #$0005
    BCS puzzle_swap_right_done

    JSR $&PuzzleClearIndicators

    LDA $20
    STA $24

    ; Data swap: right tile fills current empty slot
    LDA $20
    ASL
    TAY
    LDA $0B2A, Y
    STA $0B28, Y
    LDA #$FFFF
    STA $0B2A, Y

    ; Move cursor right
    LDA $20
    INC
    STA $20

    JSR $&PuzzleDrawIndicators

    ; Clear new slot metatile (immediate)
    JSR $&PuzzleClearSlotMetatile
    ; Defer: clear old floating → draw new floating → redraw old slot
    LDA #$0006
    STA $2A

    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20

  puzzle_swap_right_done:
    RTL
}

-------------------------------------------
; Exit handler: clear indicators, unlock input,
; check solution, die.

puzzle_ctrl_exit {
    JSR $&PuzzleClearIndicators

    LDA #$CFFC
    TRB $joypadMaskStd

    ; Check if all 6 slots are filled
    LDY #$0000

  puzzle_exit_scan:
    LDA $0B28, Y
    BMI puzzle_exit_die
    INY
    INY
    CPY #$000C
    BNE puzzle_exit_scan

    ; All filled — check solution
    JSR $&PuzzleCheckSolution
    BCC puzzle_exit_die

    ; Correct solution!
    PHD
    PLX
    COP [SetFlagByte] ( #D1 )
    COP [PlaySoundBoth] ( #$0F0F )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    JSL $@puzzle_exit_string_stub
    LDA #$CFFC
    TRB $joypadMaskStd

  puzzle_exit_die:
    LDA #$0008
    TSB $joypadHeld
    PHD
    PLX
    COP [Die]
}

-------------------------------------------
; Build a 6-bit availability mask for the current cursor slot.
; Result in actor DP $24. Bit N = hieroglyph N available.
;
; Phase 1: OR relic flags + inventory → raw owned mask in $24
; Phase 2: popcount of raw mask → owned count in $28
; Phase 3: remove hieroglyphs placed in OTHER slots from $24,
;           count placed-in-others → $2A
; Phase 4: if current slot is empty AND placed_others >= owned
;           → clear $24 (player has used all their hieroglyphs)

PuzzleBuildAvailability {
    ; Phase 1: start with relic flags (explicit address)
    LDA $0B5B
    AND #$003F
    STA $24

    ; Scan inventory for items $1E-$23, OR into $24
    PHX
    SEP #$20
    LDY #$0000

  build_avail_inv:
    LDA $inventorySlots, Y
    SEC
    SBC #$1E
    CMP #$06
    BCS build_avail_inv_next
    TAX
    LDA $@hieroBitTable, X
    TSB $24

  build_avail_inv_next:
    INY
    CPY #$0010
    BNE build_avail_inv

    ; Phase 2: popcount of $24 → owned count
    LDA $24
    AND #$3F
    LDX #$0000

  build_avail_popcnt:
    CMP #$00
    BEQ build_avail_popcnt_done
    LSR
    BCC build_avail_popcnt
    INX
    BRA build_avail_popcnt

  build_avail_popcnt_done:
    REP #$20
    TXA
    AND #$00FF
    STA $28
    PLX

    ; Phase 3: remove hieroglyphs placed in OTHER slots, count them
    PHX
    LDY #$0000
    LDA #$0000
    STA $26
    STA $2A

  build_avail_remove:
    LDA $26
    CMP $20
    BEQ build_avail_skip
    LDA $0B28, Y
    BMI build_avail_skip
    LDA $2A
    INC
    STA $2A
    LDA $0B28, Y
    AND #$00FF
    TAX
    SEP #$20
    LDA $@hieroBitTable, X
    TRB $24
    REP #$20

  build_avail_skip:
    INY
    INY
    LDA $26
    INC
    STA $26
    CMP #$0006
    BNE build_avail_remove

    ; Phase 4: count cap
    ; If current slot is empty AND placed_others >= owned → clear mask
    LDA $20
    ASL
    TAY
    LDA $0B28, Y
    BPL build_avail_cap_done
    LDA $2A
    CMP $28
    BCC build_avail_cap_done
    STZ $24

  build_avail_cap_done:
    PLX
    STZ $2A
    RTS
}

-------------------------------------------
; Draw BG3 indicator tiles above and below the current cursor slot.
;
; BG3 buffer at $7F0200, 32 cols × 2 bytes = $40 per row.
; Above row 11: base offset $02C0. Below row 14: base offset $0380.
; Slot N uses columns (10+2N, 11+2N), so column offset = $14 + N×4.
;
; Indicator tiles (SNES tilemap word: vhopppcc cccccccc):
;   Above: $20EB / $20DF (tile $EB/$DF, priority bit 13)
;   Below: $A0EB / $A0DF (V-flip bit 15 + priority bit 13)

PuzzleDrawIndicators {
    PHX

    LDA $20
    ASL
    ASL
    CLC
    ADC #$02D4
    TAX
    LDA #$20EB
    STA $7F0200, X
    LDA #$20DF
    STA $7F0202, X

    LDA $20
    ASL
    ASL
    CLC
    ADC #$0394
    TAX
    LDA #$A0EB
    STA $7F0200, X
    LDA #$A0DF
    STA $7F0202, X

    PLX
    LDA #$0001
    TSB $displayModeFlags
    RTS
}

-------------------------------------------
; Clear BG3 indicator tiles at the current cursor slot.

PuzzleClearIndicators {
    PHX

    LDA $20
    ASL
    ASL
    CLC
    ADC #$02D4
    TAX
    LDA #$0000
    STA $7F0200, X
    STA $7F0202, X

    LDA $20
    ASL
    ASL
    CLC
    ADC #$0394
    TAX
    LDA #$0000
    STA $7F0200, X
    STA $7F0202, X

    PLX
    LDA #$0001
    TSB $displayModeFlags
    RTS
}

-------------------------------------------
; Update the metatile display for the current cursor slot.
; Reads slot value from $0B28, looks up the metatile ID,
; writes to mapLayerTilemap, and queues the VRAM update.

PuzzleUpdateSlotMetatile {
    PHX

    ; Look up metatile ID
    LDA $20
    ASL
    TAY
    LDA $0B28, Y
    AND #$00FF
    TAX
    SEP #$20
    LDA $@hieroglyphMetatiles, X
    STA $26
    REP #$20

    ; Write to mapLayerTilemap (offset = $65 + slot index)
    LDA $20
    CLC
    ADC #$0065
    TAX
    LDA $26
    AND #$00FF
    SEP #$20
    STA $7EA000, X
    REP #$20

    ; Queue VRAM update if tile query is free
    LDA $tileQueryResult
    BNE puzzle_mt_done

    ; Expand metatile: ID × 8 into metatileMapLayer ($7E2000)
    LDA $26
    AND #$00FF
    ASL
    ASL
    ASL
    TAX
    LDA $7E2000, X
    STA $0904
    LDA $7E2002, X
    STA $0906
    LDA $7E2004, X
    STA $090A
    LDA $7E2006, X
    STA $090C

    ; VRAM address: $118A + slot × 2
    LDA $20
    ASL
    CLC
    ADC #$118A
    STA $tileQueryResult
    CLC
    ADC #$0020
    STA $0908

  puzzle_mt_done:
    PLX
    RTS
}

-------------------------------------------
; Check if $0B28 matches the solution.
; Returns carry set = correct, carry clear = wrong.

PuzzleCheckSolution {
    ; Solution is sequential: slot[i] == i for all 6 slots.
    LDY #$0000

  puzzle_sol_loop:
    TYA
    LSR
    CMP $0B28, Y
    BNE puzzle_sol_fail
    INY
    INY
    CPY #$000C
    BNE puzzle_sol_loop

    SEC
    RTS

  puzzle_sol_fail:
    CLC
    RTS
}

-------------------------------------------
; Expand metatile $26 (low byte = ID) and queue VRAM write at $28.
; Used by all metatile visual helpers. Returns if queue is busy.

PuzzleQueueMetatile {
    PHX

    LDA $tileQueryResult
    BNE queue_mt_done

    LDA $26
    AND #$00FF
    ASL
    ASL
    ASL
    TAX
    LDA $7E2000, X
    STA $0904
    LDA $7E2002, X
    STA $0906
    LDA $7E2004, X
    STA $090A
    LDA $7E2006, X
    STA $090C

    LDA $28
    STA $tileQueryResult
    CLC
    ADC #$0020
    STA $0908

  queue_mt_done:
    PLX
    RTS
}

-------------------------------------------
; Clear current slot ($20) to empty alcove metatile ($87).

PuzzleClearSlotMetatile {
    PHX

    LDA $20
    CLC
    ADC #$0065
    TAX
    SEP #$20
    LDA #$87
    STA $7EA000, X
    REP #$20

    PLX

    LDA #$0087
    STA $26
    LDA $20
    ASL
    CLC
    ADC #$118A
    STA $28
    JSR $&PuzzleQueueMetatile
    RTS
}

-------------------------------------------
; Redraw slot at $24 (old cursor) based on its $0B28 value.
; If filled → hieroglyph metatile. If empty → alcove ($87).

PuzzleRedrawSlotAt {
    PHX

    LDA $24
    ASL
    TAY
    LDA $0B28, Y
    BMI redraw_slot_empty

    AND #$00FF
    TAX
    SEP #$20
    LDA $@hieroglyphMetatiles, X
    STA $26
    REP #$20
    BRA redraw_slot_map

  redraw_slot_empty:
    LDA #$0087
    STA $26

  redraw_slot_map:
    LDA $24
    CLC
    ADC #$0065
    TAX
    LDA $26
    AND #$00FF
    SEP #$20
    STA $7EA000, X
    REP #$20

    PLX

    LDA $24
    ASL
    CLC
    ADC #$118A
    STA $28
    JSR $&PuzzleQueueMetatile
    RTS
}

-------------------------------------------
; Draw the floating hieroglyph ($2E) one metatile row above
; the current cursor slot ($20). VRAM base = $114A + slot × 2.

PuzzleDrawAboveTile {
    ; Draws the floating tile above the slot via VRAM queue only.
    ; Does NOT modify $7EA000 so the original wall metatile can
    ; be read back by PuzzleClearAboveTile on demand.
    PHX

    LDA $2E
    AND #$00FF
    TAX
    SEP #$20
    LDA $@hieroglyphMetatiles, X
    STA $26
    REP #$20

    PLX

    LDA $20
    ASL
    CLC
    ADC #$114A
    STA $28
    JSR $&PuzzleQueueMetatile
    RTS
}

-------------------------------------------
; Clear the above-slot position at current cursor ($20).
; Reads the original wall metatile from the metatile map
; (never modified for the above row).

PuzzleClearAboveTile {
    PHX

    LDA $20
    CLC
    ADC #$0055
    TAX
    SEP #$20
    LDA $7EA000, X
    STA $26
    REP #$20

    PLX

    LDA $20
    ASL
    CLC
    ADC #$114A
    STA $28
    JSR $&PuzzleQueueMetatile
    RTS
}

-------------------------------------------
; Clear the above-slot position at old cursor ($24).
; Reads the original wall metatile from the metatile map.

PuzzleClearAboveTileAt {
    PHX

    LDA $24
    CLC
    ADC #$0055
    TAX
    SEP #$20
    LDA $7EA000, X
    STA $26
    REP #$20

    PLX

    LDA $24
    ASL
    CLC
    ADC #$114A
    STA $28
    JSR $&PuzzleQueueMetatile
    RTS
}

-------------------------------------------
; Deferred visual update state machine.
; Called once per frame when $2A != 0. Each state performs
; one VRAM queue operation, then chains to the next state.
;
; States:
;   1 = draw floating above $20 → done (swap enter)
;   5 = redraw slot at $20 → done (swap exit)
;   6 = clear old floating at $24 → 7 (swap move step 2)
;   7 = draw new floating above $20 → 8 (swap move step 3)
;   8 = redraw old slot at $24 → done (swap move step 4)

PuzzleProcessDeferred {
    LDA $2A

    CMP #$0001
    BEQ deferred_draw_floating

    CMP #$0005
    BEQ deferred_draw_slot

    CMP #$0006
    BEQ deferred_clear_old_above

    CMP #$0007
    BEQ deferred_draw_new_above

    CMP #$0008
    BEQ deferred_redraw_old_slot

    ; Unknown state — reset
    STZ $2A
    RTS

  deferred_draw_floating:
    JSR $&PuzzleDrawAboveTile
    STZ $2A
    RTS

  deferred_draw_slot:
    JSR $&PuzzleUpdateSlotMetatile
    STZ $2A
    RTS

  deferred_clear_old_above:
    JSR $&PuzzleClearAboveTileAt
    LDA #$0007
    STA $2A
    RTS

  deferred_draw_new_above:
    JSR $&PuzzleDrawAboveTile
    LDA #$0008
    STA $2A
    RTS

  deferred_redraw_old_slot:
    JSR $&PuzzleRedrawSlotAt
    STZ $2A
    RTS
}

-------------------------------------------
; Override the main puzzle actor loop.
; Spawns 5 activators (one per wall slot cluster), then polls for flag D1.
; RTL yields each frame; SetEntryHere re-enters at the flag check.
; Without the explicit RTL, execution falls through to orphaned sub-label
; loc_08CBCD which runs the ORIGINAL sequential solution check.

code_08CBC2! {
    COP [BranchOnFlagByte] ( #D1, #01, &code_08CC09 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0048, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0060, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0078, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$0090, #$0098, #$7000 )
    COP [SpawnAfterAbsFlags] ( @pyCD_puzzle_activator, #$00A8, #$0098, #$7000 )
    COP [SetEntryHere]
    COP [BranchOnFlagByte] ( #D1, #01, &code_08CC09 )
    RTL
}

puzzle_exit_string_stub {
    COP [PrintDialogString] ( &dialogstring_08CD0B )
    RTL
}