; ==============================================================================
; Watermia Lance - Lilly party Red Jewel sparkle
; ==============================================================================
; What it does: After birthday-party flags ($A5, $E2) allow the jewel gift path, Lance's
;   init spawns generic_sparkle when the jewel is still collectible; pickup sets $E2.
; Vanilla behavior: wa79_lance code_07ACEC placed sprite without sparkle; code_07AD15 gave
;   jewel when $A5 set, gated on $E2, without sparkle teardown on $26 child.
; Hooks (overrides): wa79_lance.code_07ACEC!, code_07AD15!.
; Depends on: generic_sparkle; flag bytes $A5, $E2, $97; code_07AD28 -> HiddenRedJewelInventoryFull.
; ==============================================================================

wa79_lance.code_07ACEC! {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [NudgePosition] ( #00, #F8 )
    COP [BranchOnFlagByte] ( #A5, #00, &wa79_lance_init_normal )
    COP [BranchOnFlagByte] ( #E2, #01, &wa79_lance_init_normal )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26

  wa79_lance_init_normal:
    COP [SetInteractHandler] ( &code_07AD07 )
    COP [SetEntryHere]
    RTL 
}

wa79_lance.code_07AD15! {
    COP [BranchOnFlagByte] ( #E2, #01, &code_07AD2C )
    COP [GiveItem] ( #01, &code_07AD28 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_07AEDE )
    COP [SetFlagByte] ( #E2 )
    RTL 
}
