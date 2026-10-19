
!key_item_flags      0B58

------------------------------------------------
;av74_kara

code_06D151! {
    COP [BranchOnFlagByte] ( #8C, #01, &code_06D258 )
    COP [NudgePosition] ( #08, #FD )
    COP [SetSpritePriority] ( #10 )
    COP [SpawnAfterOffsetFlags] ( @code_06D251, #$0000, #$0010, #$3000 )
    COP [SetEntryHere]
    COP [BranchIfHasItem] ( #14, &code_06D171 )
    LDA $key_item_flags+2
    BIT #$0004
    BNE code_06D171
    RTL 
}

code_06D25A! {
    COP [BranchOnFlagByte] ( #01, #01, &code_06D26B )
    LDA $key_item_flags+2
    BIT #$0004
    BNE av74_kara_use_powder
    COP [BranchIfHasItem] ( #14, &av74_kara_use_powder )
    COP [BranchOnFlagByte] ( #89, #00, &code_06D273 )
    COP [PrintDialogString] ( &dialogstring_06D278 )
    RTL 
}

av74_kara_use_powder {
    JML $@av74_kara_use_stub
}

code_0393BA+ {
  av74_kara_use_stub:
    COP [PrintDialogString] ( &dialogstring_0393C5 )
    JSR $&code_0393BA
    RTL
}
