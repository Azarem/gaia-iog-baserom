; =============================================================================
; Minimal HUD — options-menu setting that hides the player HUD outside combat
; =============================================================================
;
; Registered with the options menu (registry format: options_menu_core.asm).
;
; Setting storage: $0B3A bit 5 (Text Speed uses bits 0-1, Run Button bits 2-3,
; Auto-Jewels bit 4). Stored bit set = Minimal HUD off, so zeroed storage (new
; game / old save) reads as On, the same convention as Auto-Jewels.
; Temp (TBL switch) word: $0BF6 (the $0BE0-$0BE9 temp words are all taken and
; $0BEA-$0BEF is the button preview buffer)
;
; When the setting is On:
;   - LoadHudTilemap skips staging the HUD tilemap in non-combat areas
;   - UpdateHUD skips the stat/health redraw in non-combat areas
; "Non-combat area" = playerFlags bit 3 ($0008), the combat lock set at spawn in
; towns and cutscene rooms. When the setting is Off both routines behave like the
; original game (HUD shown everywhere except where $09ED bit 6 suppresses it).
;
; The $09ED bit 6 full-suppress path is independent of the setting and always
; runs first (cutscenes, title screen).

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

LoadHudTilemap! {
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
;        original body at loc_00820E, which immediately follows this block.

UpdateHUD! {
    LDA $hud_disable_flag
    BIT #$hud_full_suppress_bit ; Bit 6 = full HUD suppression (cutscene)
    BNE hud_update_suppress
    LDA $minimal_hud_setting
    BIT #$minimal_hud_off_bit
    BNE loc_00820E              ; Minimal HUD off → proceed with HUD update
    LDA $playerFlags
    BIT #$combat_lock_bit       ; Bit 3 = combat lock (non-combat area)
    BEQ loc_00820E              ; Combat area → proceed with HUD update

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
