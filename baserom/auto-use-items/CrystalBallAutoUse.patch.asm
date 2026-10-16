
;sg4C_platforms
;Each platform spawns a child to act as the crystal placed sprite

code_05F522! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot1_interact )
    COP [WaitOnFlagByte] ( #60, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

-----------------------------------------------

code_05F560! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot2_interact )
    COP [WaitOnFlagByte] ( #61, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

-----------------------------------------------

code_05F58F! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot3_interact )
    COP [WaitOnFlagByte] ( #62, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

-----------------------------------------------

code_05F5CD! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot4_interact )
    COP [WaitOnFlagByte] ( #63, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

-----------------------------------------------

sg4C_interact_str `[DEF]There is an indentation[N]in this tile.[END]`

-----------------------------------------------

sg4C_slot1_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot1_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot1_use {
    LDA #&code_039020
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_slot2_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot2_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot2_use {
    LDA #&code_03902B
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_slot3_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot3_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot3_use {
    LDA #&code_039036
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_slot4_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot4_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot4_use {
    LDA #&code_039041
    JML $@ItemUseStub
}

-----------------------------------------------

  loc_03904A!:
    COP [PrintDialogString] ( &dialogstring_039083 )
    LDA $inventoryEquippedType
    CMP #$000E
    BEQ use_crystal_remove_equipped
    COP [RemoveItem] ( #0E )
    RTS

  use_crystal_remove_equipped:
    JSR $&RemoveEquippedItem
    RTS 
