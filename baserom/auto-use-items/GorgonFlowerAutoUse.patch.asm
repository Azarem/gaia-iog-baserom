
!key_item_flags      0B58

-----------------------------------------------
;nvAE_stone_girl1

;Restore lost dialog message after healing the girl
code_0892A5! {
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #BF, #01, &code_0892CE )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_0892DA )
    COP [WaitOnFlagByte] ( #BF, #01 )
    COP [SetInteractHandler] ( &nvAE_stone_girl1_post_interact )
    COP [LoopStart] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0200
    TRB $12
    BRA code_0892CE+4
}

code_0892DA! {
    LDA $key_item_flags+2
    BIT #$0080
    BNE nvAE_stone_girl1_use
    COP [BranchIfHasItem] ( #1D, &nvAE_stone_girl1_use )

  nvAE_stone_girl1_neutral_stub:
    COP [PrintDialogString] ( &dialogstring_0892E4 )
    RTL 
}

nvAE_stone_girl1_use {
    LDA #&code_0399F2
    JML $@ItemUseStub
}

nvAE_stone_girl1_post_interact {
    COP [PrintDialogString] ( &dialogstring_08931A )
    RTL
}

-----------------------------------------------
;nvAE_stone_girl2

;Restore lost dialog message after healing the girl

code_089369! {
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #C0, #01, &code_089392 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_08939E )
    COP [WaitOnFlagByte] ( #C0, #01 )
    COP [SetInteractHandler] ( &nvAE_stone_girl2_post_interact )
    COP [LoopStart] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0200
    TRB $12
}

code_08939E! {
    LDA $key_item_flags+2
    BIT #$0080
    BNE nvAE_stone_girl2_use
    COP [BranchIfHasItem] ( #1D, &nvAE_stone_girl2_use )
    JML $@nvAE_stone_girl1_neutral_stub
}

nvAE_stone_girl2_use {
    LDA #&code_039A01
    JML $@ItemUseStub
}

nvAE_stone_girl2_post_interact {
    JML $@nvAE_stone_girl1_post_interact
}

code_0893BA! {
    JML $@code_0892DF
}

dialogstring_0893BF!:
dialogstring_0893DE!:
dialogstring_089415!:

-----------------------------------------------
;nvAE_stone_girl3

;Restore lost dialog message after healing the girl

code_089474! {
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #C1, #01, &code_08949D )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_0894A9 )
    COP [WaitOnFlagByte] ( #C1, #01 )
    COP [SetInteractHandler] ( &nvAE_stone_girl3_post_interact )
    COP [LoopStart] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0200
    TRB $12
    BRA code_08949D+4
}

code_0894A9! {
    LDA $key_item_flags+2
    BIT #$0080
    BNE nvAE_stone_girl3_use
    COP [BranchIfHasItem] ( #1D, &nvAE_stone_girl3_use )
    JML $@nvAE_stone_girl1_neutral_stub
}

nvAE_stone_girl3_use {
    LDA #&code_039A10
    JML $@ItemUseStub
}

nvAE_stone_girl3_post_interact {
    JML $@nvAE_stone_girl1_post_interact
}

code_0894AE! {
    JML $@code_0892DF
}

dialogstring_0894B3!:
dialogstring_0894D2!:
dialogstring_089509!:
