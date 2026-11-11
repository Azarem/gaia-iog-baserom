; ==============================================================================
; GorgonFlowerAutoUse - auto-offer Gorgon Flower at the three stone girls
; ==============================================================================
; What it does: Each petrified girl gets interact + post-heal dialog; with item
;   #1D or key_item_flags+2 bit $0080, ItemUseStub runs the per-statue placement
;   handlers (code_0399F2 / A01 / A10). Empty dialog overrides suppress duplicate
;   silent-statue lines; girl2/3 post-cutscene paths jump to shared neutral stub.
; Vanilla behavior: nvAE_stone_girl1-3 actors wait on flags $BF/$C0/$C1 with
;   PrintDialogString-only interact; no inventory branch on the statues themselves.
; Hooks (overrides): nvAE_stone_girl1 code_0892A5!/0892DA!; girl2 code_089369!/08939E!/0893BA!
;   and dialogstring_0893BF!/0893DE!/089415!; girl3 code_089474!/0894A9!/0894AE! and
;   dialogstring_0894B3!/0894D2!/089509! (blank overrides).
; Adds: nvAE_stone_girl*_use/post_interact, nvAE_stone_girl1_neutral_stub.
; Depends on: !key_item_flags $0B58+2; $@ItemUseStub; item #1D; scene $AE flags.
; State: Flag bytes $BF, $C0, $C1; actor $12 bit $0200 for solid interact.
; Hazards/notes: Restores post-heal dialog on girl1; blank dialog overrides on girls 2/3;
;   X = actor slot for COP.
; ==============================================================================

!key_item_flags      0B58

-----------------------------------------------

nvAE_stone_girl1.code_0892A5! {
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

nvAE_stone_girl1.code_0892DA! {
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

nvAE_stone_girl2.code_089369! {
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

nvAE_stone_girl2.code_08939E! {
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

nvAE_stone_girl2.code_0893BA! {
    JML $@code_0892DF
}

nvAE_stone_girl2.dialogstring_0893BF!:
nvAE_stone_girl2.dialogstring_0893DE!:
nvAE_stone_girl2.dialogstring_089415!:

-----------------------------------------------

nvAE_stone_girl3.code_089474! {
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

nvAE_stone_girl3.code_0894A9! {
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

nvAE_stone_girl3.code_0894AE! {
    JML $@code_0892DF
}

nvAE_stone_girl3.dialogstring_0894B3!:
nvAE_stone_girl3.dialogstring_0894D2!:
nvAE_stone_girl3.dialogstring_089509!:
