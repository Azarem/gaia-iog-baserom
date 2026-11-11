; ==============================================================================
; Minimal HUD option - hide player HUD outside combat areas
; ==============================================================================
; What it does: Options setting (On/Off) skips HUD tilemap upload and per-frame
;   HUD stat redraw in non-combat scenes when On; cutscene full suppress unchanged.
; Vanilla behavior: LoadHudTilemap and UpdateHUD always ran unless $09ED bit 6
;   cleared them (cutscenes); combat lock bit on playerFlags was not consulted.
; Hooks (overrides): scene_lifecycle.LoadHudTilemap (early-out before loc_03DED5);
;   system_core.UpdateHUD (early-out before UpdateHUD_Active).
; Adds: OptionSettingPreset- record (packed bit in $0B3A); choice strings/tables.
; Depends on: options_menu_core registry; system_core include for UpdateHUD tail.
; State: $0B3A bit 5 (1 = Minimal HUD off); temp $0BF6; reads playerFlags $09AE
;   bit 3 ($0008 combat lock), hud_disable_flag $09ED bit 6 ($40).
; Hazards: LoadHudTilemap entry expects M=8 like vanilla; full suppress still
;   clears equipped-icon cache $00DA; minimal path preserves $00DA.
; ==============================================================================

!minimal_hud_setting            0B3A
!minimal_hud_off_bit            20
!hud_disable_flag               09ED
!hud_icon_cache                 00DA
!combat_lock_bit                08
!hud_full_suppress_bit          40

---------------------------------------------
; Options menu strings. The value row shows the choice picked through the temp
; word at $0BF6 (TBL index), and the description appears while the cursor is on
; the setting.

MinimalHudChoices [
  &minimal_hud_on
  &minimal_hud_off
]

minimal_hud_on  |On|
minimal_hud_off |Off|

optstr_minimal_hud |[PAL:0]Minimal HUD[N] [PAL:14][TBL:@MinimalHudChoices,BF6][PAL:0]|
optstr_minimal_hud_desc |[PAL:0][POS:96,5]Minimal Player HUD[DBL]Only displays when[DBL]in a combat area.|

---------------------------------------------
; Scene setup / inventory close: stage the HUD tilemap.
;
; Entry: M = 8-bit (same as the original routine)
; Exit:  RTL without staging anything when the HUD is suppressed
;
; Full suppress (cutscene) also clears the equipped-icon cache ($00DA), matching
; the EquippedIcon patch. Minimal HUD skips only the tilemap and keeps $00DA so
; the item icon survives the non-combat area.
;
; loc_03DED5 is the original loader, which immediately follows this block.

scene_lifecycle.LoadHudTilemap! {
    LDA $hud_disable_flag
    BIT #$hud_full_suppress_bit
    BEQ hud_check_option
    STZ $hud_icon_cache         ; Full suppress (cutscene): clear icon too
    RTL

  hud_check_option:
    LDA $minimal_hud_setting
    BIT #$minimal_hud_off_bit
    BNE loc_03DED5              ; Minimal HUD off → load HUD normally
    LDA $playerFlags
    BIT #$combat_lock_bit       ; Bit 3 = combat lock (non-combat area)
    BEQ loc_03DED5              ; Combat area → load HUD normally
    RTL                         ; Non-combat → skip HUD, keep icon ($00DA preserved)
}

--------------------------------------------------------
?INCLUDE 'system_core'
--------------------------------------------------------
; Per-frame HUD update (HP recovery, stat redraw, enemy health bar).
;
; Entry: M = 8-bit (same as the original routine)
; Exit:  RTL without touching the HUD when suppressed; otherwise falls into the
;        original body at UpdateHUD_Active, which immediately follows this block.

system_core.UpdateHUD! {
    LDA $hud_disable_flag
    BIT #$hud_full_suppress_bit ; Bit 6 = full HUD suppression (cutscene)
    BNE hud_update_suppress
    LDA $minimal_hud_setting
    BIT #$minimal_hud_off_bit
    BNE UpdateHUD_Active              ; Minimal HUD off → proceed with HUD update
    LDA $playerFlags
    BIT #$combat_lock_bit       ; Bit 3 = combat lock (non-combat area)
    BEQ UpdateHUD_Active              ; Combat area → proceed with HUD update

  hud_update_suppress:
    RTL
}

---------------------------------------------
; Registration of the Minimal HUD setting (must stay after the overrides above)

OptionSettingPreset- [
  @optstr_minimal_hud       ;+00 render
  @optstr_minimal_hud_desc  ;+03 desc
  #$0BF6                    ;+06 temp
  #$0B3A                    ;+08 store
  #$0005                    ;+0A shift
  #$0001                    ;+0C mask
  #$0000                    ;+0E xor   (stored 0 = On = choice 0)
  #$0002                    ;+10 count
  #$0000                    ;+12 load   (packed bits)
  #$0000                    ;+14 change
  #$0000                    ;+16 commit (packed bits)
]
