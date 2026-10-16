


mu66_altar1_activator {
    COP [SetInteractHandler] ( &mu66_altar1_interact )
    COP [WaitOnFlagByte] ( #80, #01 )
    COP [Die]
}

mu66_altar1_interact {
    COP [BranchIfHasItem] ( #13, &mu66_altar1_use )
    COP [PrintDialogString] ( &mu66_altar_interact_str )
    RTL
}

mu66_altar1_use {
    COP [PrintDialogString] ( &mu66_altar_use_str )
    LDA #&code_039349
    JSL $@ItemUseStub
    RTL
}

mu66_altar_interact_str `[DEF]Looks like an empty[N]shrine...[END]`

mu66_altar_use_str `[DEF]He raises the[N]Rama Statue.[FIN]`

-----------------------------------------

mu66_altar2_activator {
    COP [SetInteractHandler] ( &mu66_altar2_interact )
    COP [WaitOnFlagByte] ( #81, #01 )
    COP [Die]
}

mu66_altar2_interact {
    COP [BranchIfHasItem] ( #13, &mu66_altar2_use )
    COP [PrintDialogString] ( &mu66_altar_interact_str )
    RTL
}

mu66_altar2_use {
    COP [PrintDialogString] ( &mu66_altar_use_str )
    LDA #&code_03935A
    JSL $@ItemUseStub
    RTL
}

-----------------------------------------

code_069C2D- {
    COP [SpawnAfterOffsetFlags] ( @mu66_altar1_activator, #$0000, #$0008, #$7000 )
}

-----------------------------------------

code_069C70- {
    COP [SpawnAfterOffsetFlags] ( @mu66_altar2_activator, #$0000, #$0008, #$7000 )
}

-----------------------------------------

code_039349! {
    COP [BranchOnFlagByte] ( #80, #01, &code_03936B )
    LDA $inventoryEquippedType
    CMP #$0013
    BEQ use_rama1_equipped
    COP [RemoveItem] ( #13 )
    BRA use_rama1_continue

  use_rama1_equipped:
    JSR $&RemoveEquippedItem

  use_rama1_continue:
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #80 )
    RTS 
}

-----------------------------------------

code_03935A! {
    COP [BranchOnFlagByte] ( #81, #01, &code_03936B )
    LDA $inventoryEquippedType
    CMP #$0013
    BEQ use_rama2_equipped
    COP [RemoveItem] ( #13 )
    BRA use_rama2_continue

  use_rama2_equipped:
    JSR $&RemoveEquippedItem
    
  use_rama2_continue:
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #81 )
    RTS 
}
