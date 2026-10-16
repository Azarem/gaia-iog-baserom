

code_09C3A2! {
    COP [BranchOnFlagByte] ( #2F, #01, &code_09C3B3 )
    LDA #$1000
    TSB $10
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &ir25_block_slot_interact )
    COP [WaitOnFlagByte] ( #2F, #01 )

  ir25_complete:
    COP [PlaySoundCh2] ( #2C )

  code_09C3B3!:
    COP [Die]
}

ir25_block_slot_interact {
    LDA $0B58
    BIT #$0010
    BNE ir25_block_slot_use
    COP [BranchIfHasItem] ( #07, &ir25_block_slot_use )
    COP [PrintDialogString] ( &ir25_block_text )
    RTL
}

ir25_block_slot_use {
    LDA #&UseItem_DiamondBlock_Place
    JML $@ItemUseStub
    LDA #$1000
    TRB $10
    RTL
}

ir25_block_text `[DEF]There is a strange slot in[N]the floor..[END]`