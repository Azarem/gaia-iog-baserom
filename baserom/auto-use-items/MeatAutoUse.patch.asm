
!key_item_flags      0B58

----------------------------------------------

code_05976D! {
    COP [PrintDialogString] ( &dialogstring_059E6F )
    COP [SetFlagByte] ( #02 )
    LDA $key_item_flags
    BIT #$0002
    BNE meat_auto_use
    COP [BranchIfHasItem] ( #0A, &meat_auto_use )
    RTL 
}

meat_auto_use {
    LDA #$UseItem_SmokedMeat+E
    JML $@ItemUseStub
}
