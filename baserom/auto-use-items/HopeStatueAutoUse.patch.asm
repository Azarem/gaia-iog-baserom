
!key_item_flags      0B58

----------------------------------------------

mu63_pedestal1 {
    COP [SetInteractHandler] ( &mu63_pedestal1_interact )
    COP [WaitOnFlagByte] ( #7B, #01 )
    COP [Die]

  mu63_pedestal1_interact:
    LDA $key_item_flags+1
    BIT #$0040
    BNE mu63_pedestal1_use
    COP [BranchIfHasItem] ( #12, &mu63_pedestal1_use )

  mu63_pedestal1_interact_stub:
    COP [PrintDialogString] ( &mu63_interact_str )
    RTL

  mu63_pedestal1_use:
    JML $@hope_statue_dialog_stub1
}

mu63_interact_str `[DEF]There is an altar here.[N]What could it be for...[END]`

----------------------------------------------

mu63_pedestal2 {
    COP [SetInteractHandler] ( &mu63_pedestal2_interact )
    COP [WaitOnFlagByte] ( #7E, #01 )
    COP [Die]

  mu63_pedestal2_interact:
    LDA $key_item_flags+1
    BIT #$0080
    BNE mu63_pedestal2_use
    COP [BranchIfHasItem] ( #12, &mu63_pedestal2_use )
    JMP $&mu63_pedestal1_interact_stub

  mu63_pedestal2_use:
    JML #@hope_statue_dialog_stub2
}

--------------------------------------------------

code_0699CA- {
    COP [SpawnAfterAbsFlags] ( @mu63_pedestal1, #$0078, #$0070, #$7000 )
    COP [SpawnAfterAbsFlags] ( @mu63_pedestal2, #$0178, #$0070, #$7000 )
}

--------------------------------------------------

code_0392B7! {
    COP [BranchOnFlagByte] ( #7E, #01, &code_0392D9 )
    COP [RemoveItem] ( #12 )
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7E )
    RTS 
}

--------------------------------------------------

code_0392C8! {
    COP [BranchOnFlagByte] ( #7B, #01, &code_0392D9 )
    COP [RemoveItem] ( #12 )
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7B )
    RTS 
}

--------------------------------------------------

code_0392D9+ {
  hope_statue_dialog_stub1:
    COP [PrintDialogString] ( &dialogstring_0392DE )
    JSR code_0392C8
    RTL
    
  hope_statue_dialog_stub2:
    COP [PrintDialogString] ( &dialogstring_0392DE )
    JSR code_0392B7
    RTL
}