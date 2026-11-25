?BANK 08
; Keep Gem's original near pointers; the text itself is allocated by the linker.
?INCLUDE 'jeweler_gem'
?INCLUDE 'gem_dialogue'

jeweler_gem.dialogstring_08D094! `[PRT:@GemText08D094]`
jeweler_gem.dialogstring_08D0C8! `[PRT:@GemText08D0C8]`
jeweler_gem.dialogstring_08D0F1! `[PRT:@GemMenuOpen][::][PRT:@GemBusinessMenu]`
jeweler_gem.dialogstring_08D139! `[PRT:@GemText08D139]`
jeweler_gem.dialogstring_08D1E0! `[PRT:@GemText08D1E0]`
jeweler_gem.dialogstring_08D20F! `[PRT:@GemText08D20F]`
jeweler_gem.dialogstring_08D267! `[PRT:@GemText08D267]`
jeweler_gem.dialogstring_08D292! `[PRT:@GemText08D292]`
jeweler_gem.dialogstring_08D2AA! `[PRT:@GemText08D2AA]`
jeweler_gem.dialogstring_08D2D0! `[PRT:@GemText08D2D0]`
jeweler_gem.dialogstring_08D31A! `[PRT:@GemText08D31A]`
jeweler_gem.dialogstring_08D332! `[PRT:@GemText08D332]`
jeweler_gem.dialogstring_08D395! `[PRT:@GemText08D395]`
jeweler_gem.dialogstring_08D3F9! `[PRT:@GemText08D3F9]`
jeweler_gem.dialogstring_08D459! `[PRT:@GemText08D459]`
jeweler_gem.dialogstring_08D4E3! `[PRT:@GemText08D4E3]`
jeweler_gem.dialogstring_08D5AE! `[PRT:@GemText08D5AE]`
jeweler_gem.dialogstring_08D611! `[PRT:@GemText08D611]`
jeweler_gem.dialogstring_08D614! `[PRT:@GemText08D614]`
jeweler_gem.dialogstring_08D617! `[PRT:@GemText08D617]`
jeweler_gem.dialogstring_08D621! `[PRT:@GemText08D621]`
jeweler_gem.dialogstring_08D636! `[PRT:@GemText08D636]`
jeweler_gem.dialogstring_08D64A! `[PRT:@GemText08D64A]`
jeweler_gem.dialogstring_08D65E! `[PRT:@GemText08D65E]`
jeweler_gem.dialogstring_08D672! `[PRT:@GemText08D672]`
jeweler_gem.dialogstring_08D67D! `[PRT:@GemText08D67D]`
jeweler_gem.dialogstring_08D68A! `[PRT:@GemText08D68A]`
GemRefillOfferNear `[PRT:@GemRefillOffer]`
GemNoneSpentNear `[PRT:@GemNoneSpent]`
GemTooPoorNear `[PRT:@GemTooPoor]`
GemRefilledNear `[PRT:@GemRefilled]`
GemNoRoomNear `[PRT:@GemNoRoom]`
GemDeclinedNear `[PRT:@GemDeclined]`

; B cancels. The refill replaces the old small-talk choice, leaving the
; reward cascade, turn-in and inventory-list routes intact.
jeweler_gem.JewelerMenuTable! [
    &JewelerCancelReply
    &GemOfferRefill
    &JewelerGiveJewelsOption
    &JewelerShowInventory
]

GemOfferRefill {
    SEP #$20
    LDA $0B55
    CMP $0B5C
    REP #$20
    BCC gem_refill_available
    COP [PrintDialogString] ( &GemNoneSpentNear )
    RTL
  gem_refill_available:
    COP [PrintDialogString] ( &GemRefillOfferNear )
    COP [DialogueOptions] ( #02, #02, &GemRefillChoices )
}

GemRefillChoices [
    &GemRefillCancel
    &GemPurchaseRefill
    &GemRefillCancel
]

GemRefillCancel {
    COP [PrintDialogString] ( &GemDeclinedNear )
    RTL
}

GemPurchaseRefill {
    LDA $0AD6
    CMP #$0032
    BCC gem_refill_no_power
    SEP #$20
    JSL $@StoreOneHerb
    REP #$20
    BCS gem_refill_no_room
    LDA $0AD6
    SEC
    SBC #$0032
    STA $0AD6
    COP [PrintDialogString] ( &GemRefilledNear )
    RTL
  gem_refill_no_room:
    COP [PrintDialogString] ( &GemNoRoomNear )
    RTL
  gem_refill_no_power:
    COP [PrintDialogString] ( &GemTooPoorNear )
    RTL
}

; $0AB0 is BCD. Preserve the original Defense claim flag ($EA).
; $EF and $F6 record the Ledger and Negative Arc respectively.
jeweler_gem.JewelerInteract! {
    COP [PrintDialogString] ( &dialogstring_08D094 )
    LDA $jewelsCollected
    BEQ JewelerRewardTierCascade
    COP [PrintDialogString] ( &dialogstring_08D0C8 )

  jeweler_gem.JewelerRewardTierCascade!:
    COP [BranchOnFlagByte] ( #EF, #01, &GemCheckHerb )
    LDA $jewelsCollected
    CMP #$0001
    BCC GemCheckHerb
    COP [GiveItem] ( #29, &JewelerInventoryFull )
    COP [SetFlagByte] ( #EF )
    COP [PrintDialogString] ( &GemLedgerRewardNear )
    JMP $&GemCheckHerb
}

GemCheckHerb {
    COP [BranchOnFlagByte] ( #E9, #01, &JewelerCheck5 )
    LDA $jewelsCollected
    CMP #$0003
    BCC gem_skip_herb
    JMP $&JewelerRewardHerb
  gem_skip_herb:
    JMP $&JewelerCheck5
}

jeweler_gem.JewelerCheck5! {
    COP [BranchOnFlagByte] ( #F6, #01, &JewelerCheck8 )
    LDA $jewelsCollected
    CMP #$0005
    BCC JewelerCheck8
    COP [GiveItem] ( #2A, &JewelerInventoryFull )
    COP [SetFlagByte] ( #F6 )
    COP [PrintDialogString] ( &GemArcRewardNear )
    JMP $&JewelerCheck8
}

jeweler_gem.JewelerCheck12! {
    COP [BranchOnFlagByte] ( #EC, #01, &GemCheckDefense )
    LDA $jewelsCollected
    CMP #$0012
    BCC gem_skip_attack
    JMP $&JewelerRewardStr
  gem_skip_attack:
    JMP $&GemCheckDefense
}

jeweler_gem.JewelerRewardStr! {
    INC $playerStr
    COP [SetFlagByte] ( #EC )
    COP [PrintDialogString] ( &dialogstring_08D3F9 )
    JMP $&GemCheckDefense
}

GemCheckDefense {
    COP [BranchOnFlagByte] ( #EA, #01, &JewelerCheck20 )
    LDA $jewelsCollected
    CMP #$0015
    BCC gem_skip_defense
    JMP $&JewelerRewardDef
  gem_skip_defense:
    JMP $&JewelerCheck20
}

jeweler_gem.JewelerRewardDef! {
    INC $playerDef
    COP [SetFlagByte] ( #EA )
    COP [PrintDialogString] ( &dialogstring_08D332 )
    JMP $&JewelerCheck20
}

; List rewards in threshold order across two pages. Each row resets the palette.
jeweler_gem.JewelerShowInventory! {
    COP [PrintDialogString] ( &dialogstring_08D267 )
    COP [PrintDialogString] ( &dialogstring_08D617 )
    COP [BranchOnFlagByte] ( #EF, #00, &gem_ledger_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_ledger_row:
    COP [PrintDialogString] ( &GemLedgerRowNear )
    COP [BranchOnFlagByte] ( #E9, #00, &gem_herb_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_herb_row:
    COP [PrintDialogString] ( &dialogstring_08D621 )
    COP [BranchOnFlagByte] ( #F6, #00, &gem_arc_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_arc_row:
    COP [PrintDialogString] ( &dialogstring_08D636 )
    COP [BranchOnFlagByte] ( #EB, #00, &gem_hp_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_hp_row:
    COP [PrintDialogString] ( &dialogstring_08D64A )
    COP [BranchOnFlagByte] ( #EC, #00, &gem_attack_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_attack_row:
    COP [PrintDialogString] ( &dialogstring_08D65E )
    COP [PrintDialogString] ( &GemListNextPageNear )
    COP [BranchOnFlagByte] ( #EA, #00, &gem_defense_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_defense_row:
    COP [PrintDialogString] ( &GemDefenseRowNear )
    COP [BranchOnFlagByte] ( #ED, #00, &gem_dash_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_dash_row:
    COP [PrintDialogString] ( &dialogstring_08D672 )
    COP [BranchOnFlagByte] ( #EE, #00, &gem_flare_row )
    COP [PrintDialogString] ( &dialogstring_08D611 )
  gem_flare_row:
    COP [PrintDialogString] ( &dialogstring_08D67D )
    COP [PrintDialogString] ( &dialogstring_08D68A )
    COP [PrintDialogString] ( &dialogstring_08D0F1 )
    JMP $&code_08CF4B
}

GemLedgerRewardNear `[PRT:@GemLedgerReward]`
GemArcRewardNear `[PRT:@GemArcReward]`
GemLedgerRowNear `[PRT:@GemLedgerRow]`
GemListNextPageNear `[PRT:@GemListNextPage]`
GemDefenseRowNear `[PRT:@GemDefenseRow]`
