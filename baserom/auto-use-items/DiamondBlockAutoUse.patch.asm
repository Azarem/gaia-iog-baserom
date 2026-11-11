; ==============================================================================
; DiamondBlockAutoUse - auto-place Diamond Block in Inca entryway slot
; ==============================================================================
; What it does: The floor slot actor becomes interactable; with item #07 or auto-use
;   flag bit $0010, JML ItemUseStub to run UseItem_DiamondBlock_Place without menu.
; Vanilla behavior: ir25_block_slot code_09C3A2 only waits on flag $2F and plays SFX;
;   no interact handler; placement is inventory-only on tiles ($0E-$0F, $19-$1A).
; Hooks (overrides): ir25_block_slot.code_09C3A2! and sub-label code_09C3B3!.
; Adds: ir25_block_slot_interact, ir25_block_slot_use, ir25_block_text.
; Depends on: !key_item_flags $0B58; $@ItemUseStub; UseItem_DiamondBlock_Place.
; State: Flag $2F; actor $10 bits $1000/$3000 for interact lockout.
; Hazards/notes: X = actor slot for COP; SetInteractHandler on slot actor.
; ==============================================================================


!key_item_flags      0B58

-------------------------------------------

ir25_block_slot.code_09C3A2! {
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_09C3B3 )
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &ir25_block_slot_interact )
    COP [WaitOnFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )

  ir25_block_slot.code_09C3B3!:
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

ir25_block_slot_interact {
    LDA $key_item_flags
    BIT #$0010
    BNE ir25_block_slot_use
    COP [BranchIfHasItem] ( #07, &ir25_block_slot_use )
    COP [PrintDialogString] ( &ir25_block_text )
    RTL
}

ir25_block_slot_use {
    LDA #&UseItem_DiamondBlock_Place
    JML $@ItemUseStub
}

ir25_block_text `[DEF]There is a strange slot in[N]the floor..[END]`
