; ==============================================================================
; South Cape fisherman pot - hidden Red Jewel sparkle
; ==============================================================================
; What it does: When the pot actor runs, it spawns generic_sparkle and keeps the jewel
;   interact on code_048462; pickup sets flag $D7 and kills the sparkle child.
; Vanilla behavior: e_sc01_pot staged pot animation and handler without sparkle VFX.
; Hooks (overrides): sc01_fisherman.e_sc01_pot!, code_048462!, code_048474! (RTL stub unchanged).
; Depends on: generic_sparkle; parent sc01_fisherman flag $D7 gating; item $01 gift flow.
; State: Flag byte $D7 on successful Red Jewel pickup.
; ==============================================================================

!playerYPos                     09A4

---------------------------------------------
;sc01_fisherman

;code_048372- {
;  sc01_fisherman_preamble:
;    COP [BranchOnFlagByte] ( #1C, #01, &code_048372 )
;    COP [BranchOnFlagByte] ( #16, #01, &sc01_fisherman_alt )
;}

;loc_0483AA- {
;  sc01_fisherman_alt:
;    LDA #$0200
;    TSB $12
;}

sc01_fisherman.e_sc01_pot! {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3E )
    COP [AnimOnce]
    COP [MarkSolidHere]
    ;COP [BranchOnFlagByte] ( #D7, #01, &sc01_pot_exit ) ;not needed, parent does this
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0001, #$FFF7 )
    STY $26
    COP [SetInteractHandler] ( &code_048462 )
    COP [SetEntryHere]
    RTL 
}

sc01_fisherman.code_048462! {
    COP [BranchOnFlagByte] ( #D7, #01, &code_048474 )
    COP [GiveItem] ( #01, &code_048475 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_048479 )
    COP [SetFlagByte] ( #D7 )
}

sc01_fisherman.code_048474! {
    RTL
}
