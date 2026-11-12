; ==============================================================================
; Hidden Red Jewel - sparkle hint while collectible
; ==============================================================================
; What it does: Before the per-scene event flag ($0200 + $0E + $80) is set, spawns
;   generic_sparkle child on init; on pickup sets flag, kills sparkle via $0026,Y,
;   then gives item $01 with dialog. If flag already set at init, actor dies immediately.
; Vanilla behavior: hidden_red_jewel init only sets handler/metasprite/hitbox; interact
;   tested flag inside HiddenRedJewelInteract without VFX or early despawn when taken.
; Hooks (overrides): hidden_red_jewel.HiddenRedJewelEntry insert-before/after; HiddenRedJewelInteract!.
; Depends on: generic_sparkle actor; flag_helpers Test/SetEventFlag_0200; HiddenRedJewelInventoryFull.
; State: Event flags $0280-$028F ($0E + $80 on base $0200); $26 holds sparkle child slot index.
; Hazards/notes: X = actor slot for all COP calls; sparkle offset #$FFFC from parent.
; ==============================================================================

!activator_type      001C

-----------------------------------
;hidden_red_jewel

hidden_red_jewel.HiddenRedJewelEntry- {
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS hidden_red_jewel_destroy
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFFC )
    STY $26
}

hidden_red_jewel.HiddenRedJewelEntry+ {
  hidden_red_jewel_destroy:
    COP [Die]
    
}

hidden_red_jewel.HiddenRedJewelInteract! {
    COP [GiveItem] ( #01, &HiddenRedJewelInventoryFull )
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@flag_helpers.SetEventFlag_0200

  hrji_complete:
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &HiddenRedJewelFoundString )
    COP [Die]
}
