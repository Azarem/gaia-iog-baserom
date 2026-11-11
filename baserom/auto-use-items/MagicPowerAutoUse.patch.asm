; ==============================================================================
; MagicPowerAutoUse - auto-use Magic Powder on Kara (Angel Village tunnels)
; ==============================================================================
; What it does: During the Kara rescue (scene $74), if the player already used
;   Magic Powder via auto-use, skips re-checking inventory at the painting spawn
;   and at Kara's interact handler; routes use through ItemUseStub like manual use.
; Vanilla behavior: av74_kara code_06D151 waits on BranchIfHasItem (#14) before
;   solidifying the painting; code_06D25A prints Will's dust dialog unless flag
;   $01 is set via item_use_system code_0393BA (UseItem_MagicPowder on tiles).
; Hooks (overrides): av74_kara.code_06D151! / code_06D25A!; item_use_system.code_0393BA+
;   (av74_kara_use_stub dialog then JSR powder placement).
; Adds: av74_kara_use_powder, av74_kara_use_stub.
; Depends on: !key_item_flags $0B58+2 bit $0004; $@ItemUseStub; item #14.
; State: Flags $8C, $01, $89, $8A; scene $74 tile check in UseItem_MagicPowder.
; Hazards/notes: X = actor slot for COP in av74_kara handlers; painting actor $12 bits.
; ==============================================================================

!key_item_flags      0B58

------------------------------------------------

av74_kara.code_06D151! {
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

av74_kara.code_06D25A! {
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

item_use_system.code_0393BA+ {
  av74_kara_use_stub:
    COP [PrintDialogString] ( &dialogstring_0393C5 )
    JSR $&code_0393BA
    RTL
}
