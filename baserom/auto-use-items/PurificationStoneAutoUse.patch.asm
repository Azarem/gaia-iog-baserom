
!key_item_flags      0B58

----------------------------------------------

sp5D_fountain_activator {
    COP [SetInteractHandler] ( &sp5D_fountain_activator_interact )
    COP [WaitOnFlagByte] ( #70, #01 )
    COP [Die]

  sp5D_fountain_activator_interact:
    LDA #&code_039230
    JML $@ItemUseStub
}

;sp5D_fountain

code_0693FB! {
    STZ $066D
    COP [BranchOnFlagByte] ( #70, #01, &code_0694A8 )
    COP [BranchOnFlagByte] ( #6F, #00, &code_0694A8 )
    COP [BranchIfHasItem] ( #11, &sp5D_fountain_stub )
    LDA $key_item_flags+1
    BIT #$0010
    BNE sp5D_fountain_stub
    JMP $&code_0694A8

  sp5D_fountain_stub:
    COP [SpawnAfterAbsFlags] ( @sp5D_fountain_activator, #$00F8, #$0148, #$7000 )
    BRA code_069412
}