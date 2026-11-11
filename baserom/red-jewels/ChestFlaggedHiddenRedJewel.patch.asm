; ==============================================================================
; Sky Garden missed Red Jewel makeup (Nazca Plain)
; ==============================================================================
; What it does: Spawns flag-gated hidden Red Jewels on scene $4B (Nazca Plain) for Sky
;   Garden chests $4D ($0C) and $52 ($0F) when Viper is beaten but chest event flags stay clear.
; Vanilla behavior: No such actors; Sky Garden jewels could become permanently inaccessible.
; Hooks (overrides): scene_actors.scene_4B_actors+= two spawns (type bytes #19 / #1F -> $0E $0C / $0F).
; Adds: chest_flagged_hidden_red_jewel actor; interact jumps to RedJewelSparkle hrji_complete on success.
; Depends on: generic_sparkle; flag_helpers TestFlagRaw $F9, Test/SetEventFlag_0200; HiddenRedJewelInventoryFull.
; State: Mystic statue flag $F9; chest flags via event $0200+$0E; sets same flag on pickup.
; Hazards/notes: Spawn record type >> 1 must match intended chest flag index in $0E.
; ==============================================================================

chest_flagged_hidden_red_jewel [
  actor-def < #00, #00, #30, {

    LDA #$00F9
    JSL $@flag_helpers.TestFlagRaw
    BCC cfhrj_die
    LDA $0E
    JSL $@flag_helpers.TestEventFlag_0200
    BCS cfhrj_die

    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFFC )
    STY $26

    COP [SetInteractHandler] ( &cfhrj_interact )
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSprAndHitbox] ( #00 )
    COP [SetEntryHere]
    RTL

  cfhrj_die:
    COP [Die]

  cfhrj_interact:
    COP [GiveItem] ( #01, &cfhrj_full )
    LDA $0E
    JSL $@flag_helpers.SetEventFlag_0200
    JML $@hrji_complete

  cfhrj_full:
    JML $@HiddenRedJewelInventoryFull
  } >
]

scene_actors.scene_4B_actors+= [
  actor-spawn < #1D, #2E, #19, @chest_flagged_hidden_red_jewel >   ; Sky Garden 4D chest ($0C)
  actor-spawn < #1F, #2E, #1F, @chest_flagged_hidden_red_jewel >   ; Sky Garden 52 chest ($0F)
]
