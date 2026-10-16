

code_09C550! {
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [SetInteractHandler] ( &isau_interact_a )
    COP [WaitOnFlagByte] ( #30, #01 )
    COP [SetInteractHandler] ( #$0000 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

isau_interact_a {
    LDA $0B58
    BIT #$0004
    BNE isau_use_a
    COP [BranchIfHasItem] ( #03, &isau_use_a )
    COP [PrintDialogString] ( &isau_interact_str_a )
    RTL
}

isau_use_a {
    LDA #&loc_0386B3
    JSL $@ItemUseStub
    RTL
}

isau_interact_str_a `[DEF]There is a strange[N]mantel here. It's as if[N]something were missing...[END]`

------------------------------------------------

code_09C566! {
    COP [NudgePosition] ( #08, #FE )
    COP [SetSpritePriority] ( #30 )
    COP [SetInteractHandler] ( &isau_interact_b )
    COP [WaitOnFlagByte] ( #31, #01 )
    COP [SetInteractHandler] ( #$0000 )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

isau_interact_b {
    LDA $0B58
    BIT #$0008
    BNE isau_use_b
    COP [BranchIfHasItem] ( #04, &isau_use_b )
    COP [PrintDialogString] ( &isau_interact_str_b )
    RTL
}

isau_use_b {
    LDA #&loc_0387C9
    JSL $@ItemUseStub
    RTL
}

isau_interact_str_b `[DEF]There is a strange[N]mantel here. It's as if[N]something were missing...[END]`