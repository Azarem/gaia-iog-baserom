

!key_item_flags      0B58

-------------------------------------------

code_09C3A2! {
    COP [NudgePosition] ( #08, #00 )
    COP [BranchOnFlagByte] ( #2F, #01, &code_09C3B3 )
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &ir25_block_slot_interact )
    COP [WaitOnFlagByte] ( #2F, #01 )
    COP [PlaySoundCh2] ( #2C )

  code_09C3B3!:
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