; Sky Garden missed-Red-Jewel makeup.
;
; Sky Garden holds two Red Jewel chests: scene $4D (chest flag $0C) and scene $52 (chest flag $0F).
; Once the Viper is beaten the Sky Garden can never be revisited, so any jewel still sitting in
; its chest is lost. This actor puts the missed jewels on the Nazca Plain instead.
;
; One actor, spawned once per missed chest. The spawn type byte carries the chest flag index
; (mode-1 spawn record: $0E = type byte >> 1, so chest flag $0C = #19, $0F = #1F).
;
; A jewel is present only when BOTH are true:
;   1. Mystic Statue flag $F9 is set  (Viper defeated -> Sky Garden scenario complete)
;   2. Event flag $0200+chest is clear (the chest was never opened)
;
; Picking the jewel up sets that same chest flag, so a collected jewel never respawns and no
; extra event flag is needed.

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
    COP [SetMetasprite] ( @spriteset_enemies )
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

scene_event_0C9CF1+= [
  actor-spawn < #1D, #2E, #19, @chest_flagged_hidden_red_jewel >   ; Sky Garden 4D chest ($0C)
  actor-spawn < #1F, #2E, #1F, @chest_flagged_hidden_red_jewel >   ; Sky Garden 52 chest ($0F)
]
