; ==============================================================================
; CrystalBallAutoUse - auto-place Crystal Balls in Sky Garden platform holes
; ==============================================================================
; What it does: Each spawned platform crystal (flags $60-$63) gets an interact
;   handler; with item #0E, JML ItemUseStub to code_039020/02B/036/041 for that
;   slot. Override at loc_03904A uses COP RemoveItem instead of RemoveEquippedItem.
; Vanilla behavior: sg4C_platforms code_05F522/560/58F/5CD play frame #36 and wait
;   on flag only; UseItem_CrystalBall (scene $4C) sets flags via inventory tiles.
; Hooks (overrides): sg4C_platforms.code_05F522!/05F560!/05F58F!/05F5CD!; item_use_system.loc_03904A!.
; Adds: sg4C_slot1-4_interact/use, sg4C_interact_str.
; Depends on: $@ItemUseStub; item #0E; flag bytes $60-$63.
; State: Scene $4C; actor $10 bits $1000/$3000 during interact wait.
; Hazards/notes: Platform child actors spawned by parent sg4C_platformN; X for COP.
; ==============================================================================

-------------------------------------------

sg4C_platforms.code_05F522! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot1_interact )
    COP [WaitOnFlagByte] ( #60, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_slot1_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot1_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot1_use {
    LDA #&code_039020
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_platforms.code_05F560! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot2_interact )
    COP [WaitOnFlagByte] ( #61, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_slot2_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot2_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot2_use {
    LDA #&code_03902B
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_platforms.code_05F58F! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot3_interact )
    COP [WaitOnFlagByte] ( #62, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_slot3_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot3_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot3_use {
    LDA #&code_039036
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_platforms.code_05F5CD! {
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    LDA #$1000
    TSB $10
    COP [SetInteractHandler] ( &sg4C_slot4_interact )
    COP [WaitOnFlagByte] ( #63, #01 )
    LDA #$3000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

sg4C_slot4_interact {
    COP [BranchIfHasItem] ( #0E, &sg4C_slot4_use )
    COP [PrintDialogString] ( &sg4C_interact_str )
    RTL
}

sg4C_slot4_use {
    LDA #&code_039041
    JML $@ItemUseStub
}

-----------------------------------------------

sg4C_interact_str `[DEF]There is an indentation[N]in this tile.[END]`


-----------------------------------------------

item_use_system.loc_03904A! {
    COP [PrintDialogString] ( &dialogstring_039083 )
    COP [RemoveItem] ( #0E )
    RTS
}
