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
